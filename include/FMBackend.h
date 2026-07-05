#ifndef FMBACKEND_H
#define FMBACKEND_H

#include <QObject>
#include <QTimer>
#include <QThreadPool>

#include <atomic>
#include <queue>

// Главный класс, соединяющий qml и бекенд
class FMBackend : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY statusChanged)
    Q_PROPERTY(bool isPaused READ isPaused NOTIFY statusChanged)
    Q_PROPERTY(QStringList logMessages READ logMessages NOTIFY logUpdated)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(double speed READ speed NOTIFY progressChanged)
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY progressChanged)
public:
    // Структуа конфигурации с фронта
    struct Config {
        QString path;
        QString mask;
        QString outputPath;
        QString xorValue;
        bool deleteOriginal = false;
        bool useTimer = false;
        bool overwrite = false;
        int intervalSec = 0;
    };

    // Рабоиче состояния
    enum class Status{
        READY,
        RUNNING,
        PAUSE,
        STOPPED,
        ERROR
    };

    explicit FMBackend(QObject* parent = nullptr);
    ~FMBackend() override;

    // Геттеры для свойств
    bool isRunning() const {return m_running;}
    bool isPaused() const {return m_paused;}
    int progress() const {return m_currentProgress;}
    double speed() const {return m_currentSpeed;}
    QString currentFile() const {return m_currentFile;}
    QStringList logMessages() const {return m_logMessages;}

// Cлоты для подклюучения к сигналам qml элементов
public slots:
    // Валидация
    bool checkPathExists(const QString& path);

    // Управление
    void startProcessing(
        const QString& path,
        const QString& mask,
        const QString& otputPath,
        const QString& xorValue,
        bool deleteOriginal,
        bool useTimer,
        //bool overwrite, // 1 - overwrite, 2 - rename
        int intervalSec
    );
    void stopProcessing();
    void pause();
    void resume();

// Сигналы для уведомлений
signals:
    // Изменение режима работы
    void statusChanged();
    // Обновление лог сообщений в ScrollView
    void logUpdated();
    // Обновление прогресса обработки
    void progressChanged();

private slots:
    // Поиск файлов в дирректории по маске
    void onTimerScan();
    // Приемникики сигналов с процессора
    // Прогресс от обрабатываемого файла
    void onFileProcessorProgress(const QString& file, int bytes);
    // Сообщения об ошибке
    void onFileProcessorError(const QString& file, const QString& error);
    // Сообщения об ошибке
    void onFileProcessorFinished(const QString& file, bool success);

private:
    std::atomic<bool> m_running = false;
    std::atomic<bool> m_paused = false;
    std::atomic<bool> m_stopRequested = false;

    // Очередь in файлов найденых по маске
    std::queue<QString> m_fileQueue;
    // Текущий in файл
    QString m_currentFile;

    // Параметры конфигурации для выполнения программы
    std::unique_ptr<Config> m_config;

    // Таймер
    QTimer* m_timer;

    // Прогресс обработки
    int m_currentProgress = 0;
    double m_currentSpeed = 0.0;
    uint64_t m_processedBytes = 0;
    uint64_t m_totalBytes = 0;

    // Количество обработанных файлов
    size_t m_totalFiles;
    size_t m_processedCount;

    // Список с логами
    QStringList m_logMessages;
    // Максимальное количество логов в m_logMessages
    static constexpr int MAX_LOG_SIZE = 100;

    // Добавление лог сообщений
    void addLog(const QString& msg);
    // Обработка файла
    void processFile(const QString& fileName);
    // Разрешение конфликта имен
    QString resolveNamingConflict(const QString& outputPath, const QString& fileName);

};

#endif // FMBACKEND_H

// D:/Projects/CPP/file_modifier/tests