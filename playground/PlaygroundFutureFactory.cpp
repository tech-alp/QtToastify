#include "PlaygroundFutureFactory.h"

#include "ToastFuture.h"

#include <QPromise>
#include <QTimer>

#include <memory>
#ifndef QT_NO_EXCEPTIONS
#include <stdexcept>
#endif

QObject *PlaygroundFutureFactory::start(bool shouldFail)
{
    auto promise = std::make_shared<QPromise<QString>>();
    promise->start();

    QFuture<QString> future = promise->future();
    auto *bridge = ToastFuture::watch(future, this);
    QTimer::singleShot(1500, bridge, [future, promise, shouldFail]() mutable {
        if (shouldFail) {
#ifdef QT_NO_EXCEPTIONS
            future.cancel();
#else
            promise->setException(std::make_exception_ptr(
                std::runtime_error("device request failed")));
#endif
        } else {
            promise->addResult(QStringLiteral("C++ QFuture tamamlandı"));
        }
        promise->finish();
    });
    return bridge;
}
