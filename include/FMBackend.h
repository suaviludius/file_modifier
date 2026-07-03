#ifndef FMBACKEND_H
#define FMBACKEND_H

#include <QObject>
#include <QTimer>
#include <QThreadPool>

#include <atomic>
#include <queue>

// Структуа конфигурации с фронта
struct Config {
    QString path;
    QString mask;
    QString outputPath;
    QString xorValue;
    bool deleteOriginal = false;
    bool useTimer = false;
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

    // Список с логами
    QStringList m_logMessages;
    // Максимальное количество логов в m_logMessages
    static constexpr int MAX_LOG_SIZE = 100;

    // Добавление лог сообщений
    void addLog(const QString& msg);
    // Обработка очереди
    void processQueue();

};

#endif // FMBACKEND_H

// D:/Projects/CPP/file_modifier/tests