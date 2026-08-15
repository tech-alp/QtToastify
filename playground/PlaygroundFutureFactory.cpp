#include "PlaygroundFutureFactory.h"

#include "ToastFuture.h"

#include <QPromise>
#include <QTimer>

#include <memory>
#include <stdexcept>

QObject *PlaygroundFutureFactory::start(bool shouldFail)
{
    auto promise = std::make_shared<QPromise<QString>>();
    promise->start();

    auto *bridge = ToastFuture::watch(promise->future(), this);
    QTimer::singleShot(1500, bridge, [promise, shouldFail]() {
        if (shouldFail) {
            promise->setException(std::make_exception_ptr(
                std::runtime_error("device request failed")));
        } else {
            promise->addResult(QStringLiteral("C++ QFuture tamamlandı"));
        }
        promise->finish();
    });
    return bridge;
}
