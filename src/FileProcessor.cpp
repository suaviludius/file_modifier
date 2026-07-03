#include "FileProcessor.h"

#include <chrono>
#include <filesystem>
#include <fstream>
#include <thread>

FileProcessor::FileProcessor(
        const std::string& inputPath,
        const std::string& outputPath,
        uint64_t xorValue,
        bool deleteOriginal,
        std::atomic<bool>& paused,
        std::atomic<bool>& stopped,
        QObject *parent
    ) : m_inputPath {inputPath},
        m_outputPath {outputPath},
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
        ERROR
    };

    std::vector<uint8_t> buffer;
    uint64_t processedBytes = 0;
    uint64_t totalSize = 0;
    std::chrono::steady_clock::time_point startTime;
    int currentPercent = 0; //static_cast<int>((processedBytes * 100) / totalSize);

    std::ifstream inputFile;
    std::ofstream outputFile;

    State currentState = IDLE;

    while (currentState != State::COMPLETED && currentState != State::ERROR) {

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

                // Тут мы читаем чанк, ксорим, записываем и заново ...

                currentState = State::COMPLETED;
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

                if (processedBytes < totalSize) {
                    // Оборачиваем в try-catch, так как файловая система может выдать исключение
                    // (например, если файл заблокирован другой программой)
                    try {
                        std::filesystem::remove(m_outputPath);
                    } catch (const std::filesystem::filesystem_error& e) {
                        // Можно отправить ошибку в GUI
                    }
                }

                currentState = State::ERROR;
                break;

            case State::COMPLETED:
                inputFile.close();
                outputFile.close();

                //emit progressUpdated(100, m_inputPath, 0);

                if (m_deleteOriginal) {
                    std::error_code ec;
                    // Пытаемся удалить файл. Если будет ошибка, она запишется в ec
                    if (std::filesystem::remove(m_inputPath, ec)) {
                        // statusUpdated("Исходный файл удалён");
                    } else {
                        m_error = "Не удалось удалить исходный файл";
                    }
                }

                break;

            case State::ERROR:
                //emit ... (m_error);
                break;
        }
    }
}
