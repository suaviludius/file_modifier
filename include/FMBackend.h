#ifndef FMBACKEND_H
#define FMBACKEND_H

#include <QObject>

class FMBackend : public QObject {
    Q_OBJECT
public:
    explicit FMBackend(QObject* parent = nullptr);
    //~FMBackend() override;
};

#endif // FMBACKEND_H