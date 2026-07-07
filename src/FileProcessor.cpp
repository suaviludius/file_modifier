#include "FileProcessor.h"

#include <chrono>
#include <filesystem>
#include <algorithm>
#include <fstream>
#include <thread>

FileProcessor::FileProcessor(
        const QString& inputPath,
        const QString& outputPath,
        uint64_t xorValue,
        bool deleteOriginal,
        std::atomic<bool>& paused,
        std::atomic<bool>& stopped,
        QObject *parent
    ) : m_qinputPath {inputPath},
        m_inputPath {inputPath.toStdString()},
        m_outputPath {outputPath.toStdString()},
        m_xorValue {xorValue},
        m_deleteOriginal {deleteOriginal},
        m_paused {paused},
        m_stopped {stopped},
        QObject(parent) {
        // initial
}

void FileProcessor::run(){
    // Состояния для FSM
    enum State {
        IDLE,
        OPENIING_FILE,
        PROCESSING,
        PAUSED,
        STOPPING,
        COMPLETED,
        ERROR,
        FINISHED
    };

    std::vector<char> buffer;
    uint64_t processedBytes = 0;
    uint64_t bytesRead = 0;
    uint64_t totalSize = 0;
    std::chrono::steady_clock::time_point startTime;
    int currentPercent = 0; //static_cast<int>((processedBytes * 100) / totalSize);

    std::ifstream inputFile;
    std::ofstream outputFile;

    State currentState = IDLE;

    while (currentState != State::FINISHED) {

        switch (currentState) {

            case State::IDLE:
                currentState = State::OPENIING_FILE;
                break;


            case State::OPENIING_FILE:
                if (m_stopped.load(std::memory_order_relaxed)) {
                    currentState = State::STOPPING;
                    break;
                }

                if (!std::filesystem::exists(m_inputPath)) {
                    m_error = "Файл не существует";
                    currentState = State::STOPPING;
                    break;
                }

                inputFile.open(m_inputPath, std::ios::binary);
                if (!inputFile.is_open()) {
                    m_error = "Не удалось открыть входной файл";
                    currentState = State::STOPPING;
                    break;
                }

                outputFile.open(m_outputPath, std::ios::binary);
                if (!outputFile.is_open()) {
                    m_error = "Не удалось создать выходной файл";
                    // Закрываем вручную, так как inputFile объявлен выше
                    inputFile.close();
                    currentState = State::STOPPING;
                    break;
                }

                totalSize = std::filesystem::file_size(m_inputPath);
                if (totalSize == 0) {
                    inputFile.close();
                    outputFile.close();
                    currentState = State::COMPLETED;
                    break;
                }

                buffer.resize(MAX_CHUNK_SIZE);  // 1 MB
                processedBytes = 0;
                startTime = std::chrono::steady_clock::now();
                currentState = State::PROCESSING;
                break;


            case State::PROCESSING:
                if (m_stopped.load(std::memory_order_relaxed)) {
                    currentState = State::STOPPING;
                    break;
                }
                if (m_paused.load(std::memory_order_relaxed)) {
                    currentState = State::PAUSED;
                    break;
                }

                // Чтение
                bytesRead = readBlock(inputFile, buffer, totalSize, processedBytes);

                if (bytesRead <= 0) {
                    if (processedBytes == totalSize) {
                        currentState = State::COMPLETED;
                    } else {
                        m_error = "Ошибка чтения файла";
                        currentState = State::STOPPING;
                    }
                    break;
                }

                // Модификация
                modifyBlock(buffer, bytesRead, m_xorValue);

                // Запись
                if (!writeBlock(outputFile, buffer, bytesRead)) {
                    m_error = "Ошибка записи";
                    currentState = State::STOPPING;
                    break;
                }

                // Обновляем прогресс
                emit progressUpdated(m_qinputPath, bytesRead);

                processedBytes += bytesRead;
                if (processedBytes == totalSize) {
                    currentState = State::COMPLETED;
                }
                break;

            case State::PAUSED:
                while (m_paused && m_paused.load(std::memory_order_acquire)) {
                    std::this_thread::sleep_for(std::chrono::milliseconds(100));

                    if (m_stopped && m_stopped.load(std::memory_order_acquire)) {
                        currentState = State::STOPPING;
                        break;
                    }
                }

                if (currentState == State::PAUSED) {
                    currentState = State::PROCESSING;
                }

                break;

            case State::STOPPING:
                inputFile.close();
                outputFile.close();

                if (std::filesystem::exists(m_outputPath) && processedBytes < totalSize) {
                    // Оборачиваем в try-catch, так как файловая система может выдать исключение
                    // (например, если файл заблокирован другой программой)
                    try {
                        std::filesystem::remove(m_outputPath);
                    } catch (const std::filesystem::filesystem_error& e) {
                        // Можно отправить ошибку в GUI
                    }
                }

                if(m_error.isEmpty()) m_error = "Остановка по требованию";
                currentState = State::ERROR;
                break;

            case State::COMPLETED:
                inputFile.close();
                outputFile.close();

                emit progressUpdated(m_qinputPath, 100);

                if (m_deleteOriginal) {
                    std::error_code ec;
                    // Пытаемся удалить файл. Если будет ошибка, она запишется в ec
                    if (std::filesystem::remove(m_inputPath, ec)) {
                        // Исходный файл удалён
                    } else {
                        sendError(m_qinputPath, "Не удалось удалить исходный файл");
                    }
                }

                emit finished(m_qinputPath, true);
                currentState = State::FINISHED;

                break;

            case State::ERROR:
                if(!m_error.isEmpty()) sendError(m_qinputPath, m_error);
                // Если выходим в ошибку, то на прогрессе это не должно отразиться
                emit progressUpdated(m_qinputPath, totalSize - bytesRead);
                emit finished(m_qinputPath, false);
                currentState = State::FINISHED;
                break;

            default: break;
        }
    }
}

uint64_t FileProcessor::readBlock(std::ifstream& inputFile, std::vector<char>& buffer, uint64_t totalSize, uint64_t processedBytes) {
    // Вычисляем, сколько байт нужно прочитать, чтобы не выйти за пределы totalSize
    uint64_t bytesToRead = std::min(static_cast<uint64_t>(buffer.size()), totalSize - processedBytes);

    if (bytesToRead <= 0) return 0;

    inputFile.read(buffer.data(), bytesToRead);
    // Возвращает количество реально прочитанных байт
    return inputFile.gcount();
}


void  FileProcessor::modifyBlock(std::vector<char>& buffer, uint64_t bytesCount, uint64_t xorValue) {
    char* data = buffer.data();
    uint64_t i = 0;

    // Обрабатываем блоки по 8 байт (64 бита)
    for (; i <= bytesCount - 8; i += 8) {
        uint64_t block;
        std::memcpy(&block, data + i, 8);
        block ^= xorValue;
        std::memcpy(data + i, &block, 8);
    }

    // Обрабатываем оставшиеся байты (хвост < 8 байт)3
    for (; i < bytesCount; ++i) {
        uint64_t shift = (i % 8) * 8;
        data[i] ^= static_cast<char>((xorValue >> shift) & 0xFF);
    }
}

bool FileProcessor::writeBlock(std::ofstream& outputFile, const std::vector<char>& buffer, uint64_t bytesCount) {
    if (bytesCount <= 0) return true;

    outputFile.write(buffer.data(), bytesCount);
    return static_cast<bool>(outputFile); // true, если поток в порядке (нет failbit/badbit)
}