#ifndef FILEPROCESSOR_H
#define FILEPROCESSOR_H

#include <QObject>
#include <QString>

#include <string>


class FileProcessor : public QObject {
    Q_OBJECT
public:
    constexpr static size_t MAX_CHUNK_SIZE = 1024 * 1024; // 1MB

    FileProcessor(
        const QString& inputPath,
        const QString& outputPath,
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
    // Текущий прогресс в бекенда
    void progressUpdated(const QString& file, int bytes);
    // Сообщения в бекенд
    void sendError(const QString& file, const QString& error);
    // Результат модификации файла
    void finished(const QString& file, bool success);

private:
    QString m_qinputPath;
    std::string m_inputPath;
    std::string m_outputPath;
    uint64_t m_xorValue;
    bool m_deleteOriginal = false;

    // Сообщение об ошибке
    QString m_error;

    // Вместо слотов будем использовать атомик переменные для сигналов из бекенда
    std::atomic<bool>& m_paused;
    std::atomic<bool>& m_stopped;

    // Основной алгоритм
    uint64_t readBlock(std::ifstream& inputFile, std::vector<char>& buffer, uint64_t totalSize, uint64_t processedBytes);
    // модификация данных (XOR)
    void modifyBlock(std::vector<char>& buffer, uint64_t bytesCount, uint64_t xorValue);
    // Запись в файл. возвращает true, если запись прошла успешно
    bool writeBlock(std::ofstream& outputFile, const std::vector<char>& buffer, uint64_t bytesCount);
};

#endif //FILEPROCESSOR_H
