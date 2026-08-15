#include "FutureTestFactory.h"

#include "ToastFuture.h"

#include <QPromise>
#include <QTimer>

#include <memory>
#include <stdexcept>

QObject *FutureTestFactory::resolveAfter(const QString &result,
                                         int delayMilliseconds)
{
    auto promise = std::make_shared<QPromise<QString>>();
    promise->start();

    auto *bridge = ToastFuture::watch(promise->future(), this);
    QTimer::singleShot(delayMilliseconds, bridge, [promise, result]() {
        promise->addResult(result);
        promise->finish();
    });
    return bridge;
}

QObject *FutureTestFactory::resolveVoidAfter(int delayMilliseconds)
{
    auto promise = std::make_shared<QPromise<void>>();
    promise->start();

    auto *bridge = ToastFuture::watch(promise->future(), this);
    QTimer::singleShot(delayMilliseconds, bridge, [promise]() {
        promise->finish();
    });
    return bridge;
}

QObject *FutureTestFactory::rejectAfter(const QString &error,
                                        int delayMilliseconds)
{
    auto promise = std::make_shared<QPromise<QString>>();
    promise->start();

    auto *bridge = ToastFuture::watch(promise->future(), this);
    QTimer::singleShot(delayMilliseconds, bridge, [promise, error]() {
        promise->setException(std::make_exception_ptr(
                                  std::runtime_error(error.toStdString())));
        promise->finish();
    });
    return bridge;
}

QObject *FutureTestFactory::cancelAfter(int delayMilliseconds)
{
    auto promise = std::make_shared<QPromise<QString>>();
    promise->start();
    QFuture<QString> future = promise->future();

    auto *bridge = ToastFuture::watch(future, this);
    QTimer::singleShot(delayMilliseconds, bridge,
                       [promise, future]() mutable {
        future.cancel();
        promise->finish();
    });
    return bridge;
}

int FutureTestFactory::activeBridgeCount() const
{
    return findChildren<ToastFuture *>(QString(),
                                       Qt::FindDirectChildrenOnly).size();
}
