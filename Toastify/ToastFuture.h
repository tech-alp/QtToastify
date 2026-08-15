#pragma once

#include <QFuture>
#include <QFutureWatcher>
#include <QObject>
#include <QVariant>
#include <QtQml/qqmlregistration.h>

#include <exception>
#include <type_traits>

class ToastFuture final : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Use ToastFuture::watch() from C++")

    Q_PROPERTY(bool settled READ settled NOTIFY settledChanged FINAL)
    Q_PROPERTY(bool succeeded READ succeeded NOTIFY settledChanged FINAL)
    Q_PROPERTY(QVariant result READ result NOTIFY settledChanged FINAL)
    Q_PROPERTY(QString error READ error NOTIFY settledChanged FINAL)

public:
    template<typename T>
    static ToastFuture *watch(const QFuture<T> &future, QObject *owner)
    {
        Q_ASSERT(owner);
        if (!owner)
            return nullptr;

        auto *bridge = new ToastFuture(owner);
        auto *watcher = new QFutureWatcher<T>(bridge);

        QObject::connect(watcher, &QFutureWatcherBase::finished, bridge,
                         [bridge, watcher]() {
            QFuture<T> watchedFuture = watcher->future();

            const auto finishBridge = [&]() {
                // Re-throws a producer exception before checking cancellation;
                // Qt marks exceptional futures as canceled as well.
                watchedFuture.waitForFinished();

                if (watchedFuture.isCanceled()) {
                    bridge->reject(QStringLiteral("Operation canceled"));
                } else if constexpr (std::is_void_v<T>) {
                    bridge->resolve({});
                } else if (watchedFuture.resultCount() == 0) {
                    bridge->resolve({});
                } else if constexpr (std::is_same_v<std::decay_t<T>,
                                                     QVariant>) {
                    bridge->resolve(watchedFuture.result());
                } else {
                    bridge->resolve(QVariant::fromValue(
                                        watchedFuture.result()));
                }
            };

#ifndef QT_NO_EXCEPTIONS
            try {
                finishBridge();
            } catch (const std::exception &exception) {
                const QString message = QString::fromUtf8(exception.what());
                bridge->reject(message.isEmpty()
                               ? QStringLiteral("QFuture failed") : message);
            } catch (...) {
                bridge->reject(QStringLiteral("QFuture failed"));
            }
#else
            finishBridge();
#endif

            watcher->deleteLater();
        });

        watcher->setFuture(future);
        return bridge;
    }

    bool settled() const noexcept { return m_settled; }
    bool succeeded() const noexcept { return m_succeeded; }
    QVariant result() const { return m_result; }
    QString error() const { return m_error; }

    Q_INVOKABLE void release() { deleteLater(); }

signals:
    void settledChanged();
    void resolved(const QVariant &result);
    void rejected(const QString &error);

private:
    explicit ToastFuture(QObject *parent = nullptr);

    void resolve(QVariant result);
    void reject(QString error);

    bool m_settled = false;
    bool m_succeeded = false;
    QVariant m_result;
    QString m_error;
};
