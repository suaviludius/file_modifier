#include "FMBackend.h"
#include "FileProcessor.h"

#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>


FMBackend::FMBackend(QObject* parent)
    : QObject(parent),  m_config(std::make_unique<Config>()), m_timer(new QTimer(this)){
    // initial
    // Соединяем сигнал таймера со слотом периодической обработки файлов
    connect(m_timer, &QTimer::timeout, this, &FMBackend::onTimerScan);
}

FMBackend::~FMBackend() {
    stopProcessing();
}

bool FMBackend::checkPathExists(const QString& path) {
    if (path.isEmpty()) {
        return false;
    }

    QDir dir(path);
    return dir.exists();
}

void FMBackend::startProcessing(
    const QString& path,
    const QString& mask,
    const QString& outputPath,
    const QString& xorValue,
    bool deleteOriginal,
    bool useTimer,
    //bool overwrite,
    int intervalSec) {

    // Сохраняем конфигурацию
    m_config->path = path;
    m_config->mask = mask;
    m_config->outputPath = outputPath;
    m_config->xorValue = xorValue;
    m_config->deleteOriginal = deleteOriginal;
    m_config->useTimer = useTimer;
    //m_config->overwrite = overwrite;
    m_config->intervalSec = intervalSec;

    // ВЫводим сообщения в скрол консоль приложения
    addLog("Запуск обработки...");
    addLog("Поиск в: " + path);
    addLog("Маска: " + mask);
    addLog("Сохранение в: " + outputPath);

    // Если таймер включен
    if (m_config->useTimer) {
        m_timer->start(m_config->intervalSec * 1000);
        addLog("Режим таймера (интервал: " + QString::number(m_config->intervalSec) + "с )");
    }

    // Статус
    m_running = true;
    m_paused = false;
    m_stopRequested = false;
    emit statusChanged();

    // Прогресс
    m_currentProgress = 0;
    m_currentSpeed = 0;
    m_currentFile = "";
    emit progressChanged();

    // Начало обработки
    onTimerScan();
}

void FMBackend::stopProcessing() {
    // Статус
    m_running = false;
    m_paused = false;
    m_stopRequested = true;
    emit statusChanged();

    // Прогресс
    m_currentSpeed = 0;
    m_currentFile = "";
    emit progressChanged();

    m_timer->stop();

    // Очищаем очередь
    while (!m_fileQueue.empty()) {
        m_fileQueue.pop();
    }

    addLog("Обработка остановлена");
}


void FMBackend::resume(){
    if(m_running && m_paused){
        addLog("Обработка возобновлена");
        m_paused = false;
        emit statusChanged();
    }
}

void FMBackend::pause(){
    if(m_running && !m_paused){
        addLog("Обработка приостановлена");
        m_paused = true;
        emit statusChanged();
    }
}

void FMBackend::onTimerScan() {
    // Не в режиме остановки
    if (!m_running || m_paused) return;

    QDir dir(m_config->path);
    QStringList filters { m_config->mask };
    // файлы с метаданными
    QFileInfoList  files = dir.entryInfoList(filters, QDir::Files);

    if (files.isEmpty()) {
        addLog("Файлы не найдены по маске: " + m_config->mask);
        return;
    }

    m_totalFiles = files.size();
    m_processedCount = 0;
    m_totalBytes = 0;
    m_processedBytes = 0;

    for (const QFileInfo& fileInfo : files) {
        m_totalBytes += fileInfo.size();
        m_fileQueue.push(fileInfo.absoluteFilePath());
    }

    addLog("Найдено файлов: " + QString::number(m_totalFiles));
    addLog("Общий размер файлов: " + QString::number(m_totalBytes) + " байт");

    processFile(m_fileQueue.front());
}

void FMBackend::processFile(const QString& inputPath) {
    if (m_paused || m_stopRequested || !m_running) return;

    QString filePath = inputPath;
    QFileInfo fileInfo(filePath);
    QString fileName = fileInfo.fileName();
    QString outputPath = resolveNamingConflict(m_config->outputPath, fileName);

    quint64 xorValue = m_config->xorValue.toULongLong(nullptr, 16);

    FileProcessor* processor = new FileProcessor(
        inputPath,
        outputPath,
        xorValue,
        m_config->deleteOriginal,
        m_paused,
        m_stopRequested
    );

    connect(processor, &FileProcessor::progressUpdated, this, &FMBackend::onFileProcessorProgress);
    connect(processor, &FileProcessor::finished, this, &FMBackend::onFileProcessorFinished);
    connect(processor, &FileProcessor::sendError, this, &FMBackend::onFileProcessorError);

    // Обработка файла
    processor->run();
}

void FMBackend::onFileProcessorFinished(const QString& inputPath, bool success) {
    // Получаем указатель на процессор, который отправил сигнал
    FileProcessor* processor = qobject_cast<FileProcessor*>(sender());

    m_processedCount++;

    if (success) {
        addLog(inputPath + ": Обработка успешно завершена");
    } else {
        addLog(inputPath + ": Обработка прервана");
    }

    // Удаляем объект процессора, чтобы не было утечки памяти
    if (processor) {
        processor->deleteLater();
    }

    m_fileQueue.pop();

    // Проверяем, все ли файлы обработаны
    if (m_processedCount >= m_totalFiles || m_fileQueue.empty()) {
        addLog("Все файлы обработаны");
        stopProcessing();
    } else {
        processFile(m_fileQueue.front());
    }
}

void FMBackend::onFileProcessorError(const QString& inputPath, const QString& error) {
    addLog(inputPath + ": " + error);
}

void FMBackend::onFileProcessorProgress(const QString& file, int bytesCount) {
    // Обновляем UI
    m_processedBytes += bytesCount;
    int percent = static_cast<int>((m_processedBytes * 100) / m_totalBytes);

    addLog(m_currentFile + " процент: " + QString::number(percent));

    if(percent > m_currentProgress){
        m_currentProgress = percent;
        m_currentSpeed = 0;
        m_currentFile = file;
        emit progressChanged();
    }
}

QString FMBackend::resolveNamingConflict(const QString& outputPath, const QString& fileName) {
    // Проверяем существование файла внутри папки
    QString resultPath = QDir(outputPath).filePath(fileName);

    if (QFile::exists(resultPath)) {
        if (m_config->overwrite) {
            QFile::remove(resultPath);
        }
        else {
            QFileInfo info(resultPath);
            QString baseName = info.baseName();
            QString suffix = info.suffix();
            QString dirPath = info.path();
            int counter = 1;

            while (QFile::exists(resultPath)) {
                resultPath = dirPath + "/" + baseName + "_" + QString::number(counter) + "." + suffix;
                counter++;
            }
        }
    }

    return resultPath;
}

void FMBackend::addLog(const QString& msg) {
    m_logMessages.append(QDateTime::currentDateTime().toString("hh:mm:ss") + " " + msg);

    if (m_logMessages.size() > MAX_LOG_SIZE) {
        m_logMessages.removeFirst();
    }

    emit logUpdated();
}


