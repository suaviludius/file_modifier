#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "FMBackend.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Создаём бэкенд и экспортируем его в графическую часть
    FMBackend backend;
    engine.rootContext()->setContextProperty("backend", &backend);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("file_modifier", "Main");

    return QGuiApplication::exec();
}
