#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class PlaygroundFutureFactory final : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    using QObject::QObject;

    Q_INVOKABLE QObject *start(bool shouldFail);
};
