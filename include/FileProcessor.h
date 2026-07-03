#ifndef FILEPROCESSOR_H
#define FILEPROCESSOR_H

#include <QObject>

#include <string>

class FileProcessor : public QObject {
    Q_OBJECT
public:
    constexpr static size_t MAX_CHUNK_SIZE = 1024 * 1024; // 1MB

    FileProcessor(
        const std::string& inputPath,
        const std::string& outputPath,
        uint64_t xorValue,
        bool deleteOriginal,
        std::atomic<bool>& paused,
        std::atomic<bool>& stopped,
        QObject *parent = nullptr
    );
    //~FileProcessor() override = default;

    // Основной автомат работы обработчика
    void run();

signals:
    // Какие сигналы в бекенд надо отправлять?
    void progressUpdated(int percent, const QString& file, double speedMBs);

private:
    std::string m_inputPath;
    std::string m_outputPath;
    uint64_t m_xorValue;
    bool m_deleteOriginal = false;

    // Сообщение об ошибке
    std::string m_error;

    // Вместо слотов будем использовать атомик переменные для сигналов из бекенда
    std::atomic<bool>& m_paused;
    std::atomic<bool>& m_stopped;
};

#endif //FILEPROCESSOR_H
