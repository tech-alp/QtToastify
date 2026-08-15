#include "ToastFuture.h"

#include <utility>

ToastFuture::ToastFuture(QObject *parent)
    : QObject(parent)
{
}

void ToastFuture::resolve(QVariant result)
{
    if (m_settled)
        return;

    m_settled = true;
    m_succeeded = true;
    m_result = std::move(result);

    emit settledChanged();
    emit resolved(m_result);
}

void ToastFuture::reject(QString error)
{
    if (m_settled)
        return;

    m_settled = true;
    m_succeeded = false;
    m_error = std::move(error);

    emit settledChanged();
    emit rejected(m_error);
}
