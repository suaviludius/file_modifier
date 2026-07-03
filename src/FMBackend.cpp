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
    int intervalSec) {

    // Сохраняем конфигурацию
    m_config->path = path;
    m_config->mask = mask;
    m_config->outputPath = outputPath;
    m_config->xorValue = xorValue;
    m_config->deleteOriginal = deleteOriginal;
    m_config->useTimer = useTimer;
    m_config->intervalSec = intervalSec;

    // Валидация (уже проводится в qml)
    // if (!validateConfig(m_config)) {
    //     return;
    // }

    // ВЫводим сообщения в скрол консоль приложения
    addLog("Запуск обработки...");
    addLog("Поиск в: " + path);
    addLog("Маска: " + mask);
    addLog("Сохранение в: " + outputPath);

    // Решить конфликт имен для выходных файлов

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
    // TODO: заблокировать мьютекс!
    while (!m_fileQueue.empty()) {
        m_fileQueue.pop();
    }

    addLog("Обработка остановлена");
    // TODO: придумать как фиксировать статус в qml
}


void FMBackend::resume(){
    if(m_running && m_paused){
        addLog("Обработка приостановлена");
        m_paused = false;
        emit statusChanged();
    }
}

void FMBackend::pause(){
    if(m_running && !m_paused){
        addLog("Обработка возобновлена");
        m_paused = true;
        emit statusChanged();
    }
}

void FMBackend::onTimerScan() {
    // Не в режиме остановки
    if (!m_running || m_paused) return;

    QDir dir(m_config->path);
    QStringList filters;
    filters << m_config->mask;

    QStringList files = dir.entryList(filters, QDir::Files);

    if (files.isEmpty()) {
        addLog("Файлы не найдены по маске: " + m_config->mask);
        return;
    }

    addLog("Найдено файлов: " + QString::number(files.size()));

    for (const QString& file : files) {
        if (m_stopRequested) {
            break;
        }
        // TODO: заблокировать мьютекс!
        m_fileQueue.push(file);
    }

    processQueue();
}

void FMBackend::processQueue() {
    if (m_paused || m_stopRequested || !m_running) return;

    // Запускаем обработку в отдельном потоке
    while (!m_fileQueue.empty()) {
        if (m_paused || m_stopRequested || !m_running) break;

        std::string filePath;
        {
            if (m_fileQueue.empty()) break;
            filePath = m_fileQueue.front().toStdString();
            m_fileQueue.pop();
        }

        quint64 xorValue = m_config->xorValue.toULongLong(nullptr, 16);

        FileProcessor* processor = new FileProcessor(
            filePath,
            "outputPath",
            xorValue,
            m_config->deleteOriginal,
            std::ref(m_paused),
            std::ref(m_stopRequested)
        );

        processor->run();

        // Обработка файла
        // здесь будет код обработки файла с XOR

        // for (int i = 3; i <= 100; i += 1) {
        //     if (m_paused || m_stopRequested) break;
        //     m_currentProgress = i;
        //     m_currentSpeed =  (i / 100.0) * 50;
        //     m_currentFile = QString::fromStdString(filePath);
        //     emit progressChanged();
        // }

        addLog("Обработан: " + QString::fromStdString(filePath));
    }

    stopProcessing();
}

void FMBackend::addLog(const QString& msg) {
    m_logMessages.append(QDateTime::currentDateTime().toString("hh:mm:ss") + " " + msg);

    if (m_logMessages.size() > MAX_LOG_SIZE) {
        m_logMessages.removeFirst();
    }

    emit logUpdated();
}


