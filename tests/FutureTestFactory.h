#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class FutureTestFactory final : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    using QObject::QObject;

    Q_INVOKABLE QObject *resolveAfter(const QString &result,
                                     int delayMilliseconds);
    Q_INVOKABLE QObject *resolveVoidAfter(int delayMilliseconds);
    Q_INVOKABLE QObject *rejectAfter(const QString &error,
                                    int delayMilliseconds);
    Q_INVOKABLE QObject *cancelAfter(int delayMilliseconds);
    Q_INVOKABLE int activeBridgeCount() const;
};
