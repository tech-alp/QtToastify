#include "PlaygroundRuntimeProbe.h"

#include <QCoreApplication>
#include <QDebug>
#include <QEventLoop>
#include <QFont>
#include <QGuiApplication>
#include <QImage>
#include <QKeyEvent>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>

namespace {
bool activeFocusOnTabWarningSeen = false;
QtMessageHandler previousMessageHandler = nullptr;

void playgroundProbeMessageHandler(QtMsgType type,
                                   const QMessageLogContext &context,
                                   const QString &message)
{
    if (type == QtWarningMsg
        && message.contains(QStringLiteral(
            "Cannot set activeFocusOnTab to false once item is the active focus item"))) {
        activeFocusOnTabWarningSeen = true;
    }
    if (previousMessageHandler)
        previousMessageHandler(type, context, message);
}

QObject *findVisualObject(QQuickItem *item, const QString &objectName)
{
    if (!item)
        return nullptr;
    if (item->objectName() == objectName)
        return item;
    for (QQuickItem *child : item->childItems()) {
        if (QObject *found = findVisualObject(child, objectName))
            return found;
    }
    return nullptr;
}

QObject *findObject(QObject *root, const QString &objectName)
{
    if (!root)
        return nullptr;
    if (root->objectName() == objectName)
        return root;
    if (QObject *found =
            root->findChild<QObject *>(objectName, Qt::FindChildrenRecursively)) {
        return found;
    }
    if (auto *window = qobject_cast<QQuickWindow *>(root))
        return findVisualObject(window->contentItem(), objectName);
    return findVisualObject(qobject_cast<QQuickItem *>(root), objectName);
}

bool clickObject(QObject *root, const QString &objectName)
{
    QObject *object = findObject(root, objectName);
    return object && QMetaObject::invokeMethod(object, "click");
}

bool spinBoxValueFits(QObject *root, const QString &objectName)
{
    QObject *spinBox = findObject(root, objectName);
    QObject *contentItem = spinBox
        ? spinBox->property("contentItem").value<QObject *>() : nullptr;
    if (!spinBox || !contentItem)
        return false;

    const qreal contentWidth = contentItem->property("width").toReal();
    const qreal requiredWidth = contentItem->property("implicitWidth").toReal();
    if (contentWidth >= requiredWidth && requiredWidth > 0)
        return true;

    qCritical().nospace()
        << "Playground probe: SpinBox value is clipped for " << objectName
        << "; control=" << spinBox->property("width").toReal()
        << ", leftPadding=" << spinBox->property("leftPadding").toReal()
        << ", rightPadding=" << spinBox->property("rightPadding").toReal()
        << ", content=" << contentWidth
        << ", required=" << requiredWidth
        << ", displayText=" << spinBox->property("displayText").toString();
    return false;
}

bool selectIndex(QObject *root, const QString &objectName, int index)
{
    QObject *object = findObject(root, objectName);
    return object
        && QMetaObject::invokeMethod(object,
                                     "selectIndex",
                                     Q_ARG(QVariant, QVariant(index)));
}

bool focusObject(QObject *root, const QString &objectName)
{
    auto *item = qobject_cast<QQuickItem *>(findObject(root, objectName));
    if (!item)
        return false;

    item->forceActiveFocus(Qt::TabFocusReason);
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    return item->hasActiveFocus();
}

bool sendKey(QQuickWindow *window,
             int key,
             Qt::KeyboardModifiers modifiers = Qt::NoModifier)
{
    if (!window)
        return false;

    QKeyEvent press(QEvent::KeyPress, key, modifiers);
    QKeyEvent release(QEvent::KeyRelease, key, modifiers);
    QCoreApplication::sendEvent(window, &press);
    QCoreApplication::sendEvent(window, &release);
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    return true;
}

bool isFullyVisibleIn(QObject *root,
                      const QString &itemObjectName,
                      const QString &viewportObjectName)
{
    auto *item = qobject_cast<QQuickItem *>(
        findObject(root, itemObjectName));
    auto *viewport = qobject_cast<QQuickItem *>(
        findObject(root, viewportObjectName));
    if (!item || !viewport)
        return false;

    const QRectF bounds = item->mapRectToItem(
        viewport,
        item->boundingRect());
    return bounds.top() >= 0
        && bounds.bottom() <= viewport->height();
}

bool followsTabOrder(QObject *root,
                     QQuickWindow *window,
                     const QStringList &objectNames)
{
    if (objectNames.isEmpty() || !focusObject(root, objectNames.constFirst()))
        return false;

    for (qsizetype index = 1; index < objectNames.size(); ++index) {
        if (!sendKey(window, Qt::Key_Tab))
            return false;

        auto *expected = qobject_cast<QQuickItem *>(
            findObject(root, objectNames.at(index)));
        if (!expected || !expected->hasActiveFocus()) {
            qCritical() << "Playground probe: unexpected Tab focus; expected"
                        << objectNames.at(index) << "actual"
                        << (window && window->activeFocusItem()
                                ? window->activeFocusItem()->objectName()
                                : QStringLiteral("<none>"));
            return false;
        }
    }
    return true;
}

bool hasExclusiveTabStop(QObject *root,
                         const QString &groupObjectName,
                         int optionCount,
                         int selectedIndex)
{
    for (int index = 0; index < optionCount; ++index) {
        QObject *option = findObject(
            root,
            groupObjectName + QStringLiteral(".option.")
                + QString::number(index));
        const bool expectedTabStop = index == selectedIndex;
        const int focusPolicy = option
            ? option->property("focusPolicy").toInt()
            : Qt::NoFocus;
        if (!option
            || option->property("keyboardTabStop").toBool()
                   != expectedTabStop
            || static_cast<bool>(focusPolicy & Qt::TabFocus)
                   != expectedTabStop) {
            return false;
        }
    }
    return true;
}

bool hasExclusiveButtonSelection(QObject *root,
                                 const QString &groupObjectName,
                                 int optionCount,
                                 int selectedIndex)
{
    QObject *buttonGroup = findObject(
        root, groupObjectName + QStringLiteral(".group"));
    if (!buttonGroup || !buttonGroup->property("exclusive").toBool())
        return false;

    for (int index = 0; index < optionCount; ++index) {
        QObject *option = findObject(
            root,
            groupObjectName + QStringLiteral(".option.")
                + QString::number(index));
        const bool selected = index == selectedIndex;
        const QStringList expectedVariations = {
            QStringLiteral("outline")
        };
        if (!option || !option->property("checkable").toBool()
            || option->property("checked").toBool()
                   != selected
            || option->property("variant").toInt()
                   != 2
            || option->property("styleVariations").toStringList()
                   != expectedVariations) {
            return false;
        }
    }
    return true;
}

bool saveProbeScreenshot(QObject *root)
{
    const QString outputPath = qEnvironmentVariable(
        "QTTOASTIFY_PLAYGROUND_SCREENSHOT");
    if (outputPath.isEmpty())
        return true;

    const QString focusObjectName = qEnvironmentVariable(
        "QTTOASTIFY_PLAYGROUND_SCREENSHOT_FOCUS");
    if (!focusObjectName.isEmpty() && !focusObject(root, focusObjectName)) {
        qCritical() << "Playground probe: screenshot focus target was not found"
                    << focusObjectName;
        return false;
    }

    QEventLoop renderLoop;
    QTimer::singleShot(250, &renderLoop, &QEventLoop::quit);
    renderLoop.exec();

    auto *window = qobject_cast<QQuickWindow *>(root);
    const QImage image = window ? window->grabWindow() : QImage();
    if (image.isNull() || !image.save(outputPath)) {
        qCritical() << "Playground probe: screenshot could not be saved"
                    << outputPath;
        return false;
    }
    return true;
}

int runProbe(QQmlApplicationEngine &engine,
             bool exerciseActions,
             bool compactLayout,
             bool minimumLayout,
             bool exerciseResponsiveResize)
{
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Playground probe: root object was not created";
        return 1;
    }

    QObject *root = engine.rootObjects().constFirst();
    if (compactLayout) {
        root->setProperty("width", minimumLayout ? 900 : 1000);
        root->setProperty("height", minimumLayout ? 700 : 800);
        QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    }

    const QStringList requiredObjects = {
        QStringLiteral("playground.workspace"),
        QStringLiteral("playground.workspace.loader"),
        QStringLiteral("playground.header"),
        QStringLiteral("playground.header.github"),
        QStringLiteral("playground.configuration"),
        QStringLiteral("playground.input.message"),
        QStringLiteral("playground.input.messageError"),
        QStringLiteral("playground.input.autoClose"),
        QStringLiteral("playground.input.visibleToasts"),
        QStringLiteral("playground.input.showCloseButton"),
        QStringLiteral("playground.input.closeOnClick"),
        QStringLiteral("playground.input.showProgressBar"),
        QStringLiteral("playground.input.newestOnTop"),
        QStringLiteral("playground.input.toastSpacing"),
        QStringLiteral("playground.input.collapsedOffset"),
        QStringLiteral("playground.input.collapsedScaleStep"),
        QStringLiteral("playground.positionPicker"),
        QStringLiteral("playground.selector.style"),
        QStringLiteral("playground.selector.type"),
        QStringLiteral("playground.selector.stack"),
        QStringLiteral("playground.advanced.toggle"),
        QStringLiteral("playground.advanced.fields"),
        QStringLiteral("playground.preview"),
        QStringLiteral("playground.preview.viewport"),
        QStringLiteral("playground.preview.emptyState"),
        QStringLiteral("playground.toastHost"),
        QStringLiteral("playground.actions"),
        QStringLiteral("playground.actions.showToast"),
        QStringLiteral("playground.actions.more"),
        QStringLiteral("playground.actions.morePopup"),
        QStringLiteral("playground.actions.clear")
    };

    for (const QString &objectName : requiredObjects) {
        if (!findObject(root, objectName)) {
            qCritical() << "Playground probe: missing" << objectName;
            return 2;
        }
    }

    if (!spinBoxValueFits(root, QStringLiteral("playground.input.autoClose"))
        || !spinBoxValueFits(root, QStringLiteral("playground.input.visibleToasts"))) {
        return 33;
    }

    QObject *workspace = findObject(root, QStringLiteral("playground.workspace"));
    if (!workspace
        || workspace->property("wideLayout").toBool() == compactLayout) {
        qCritical() << "Playground probe: responsive layout mode is incorrect";
        return 3;
    }

    QObject *workspaceLoader = findObject(
        root,
        QStringLiteral("playground.workspace.loader"));
    if (!workspaceLoader || !workspaceLoader->property("clip").toBool()) {
        qCritical() << "Playground probe: workspace content is not clipped";
        return 4;
    }

    const QString scrollObjectName = compactLayout
        ? QStringLiteral("playground.compact.scroll")
        : QStringLiteral("playground.configuration.scroll");
    QObject *scrollView = findObject(root, scrollObjectName);
    if (!scrollView
        || scrollView->property("contentHeight").toReal()
               <= scrollView->property("height").toReal()
        || scrollView->property("effectiveScrollBarWidth").toReal() <= 0
        || scrollView->property("effectiveScrollBarHeight").toReal() > 0) {
        qCritical() << "Playground probe: configuration scroll view is invalid";
        return 5;
    }

    auto *viewport = qobject_cast<QQuickItem *>(
        findObject(root, QStringLiteral("playground.preview.viewport")));
    auto *toastHost = qobject_cast<QQuickItem *>(
        findObject(root, QStringLiteral("playground.toastHost")));
    if (!viewport || !toastHost || toastHost->parentItem() != viewport
        || !qFuzzyCompare(toastHost->width(), viewport->width())
        || !qFuzzyCompare(toastHost->height(), viewport->height())) {
        qCritical() << "Playground probe: toast host escaped the preview viewport";
        return 6;
    }

    if (!hasExclusiveTabStop(
            root,
            QStringLiteral("playground.selector.style"),
            4,
            0)
        || !hasExclusiveTabStop(
            root,
            QStringLiteral("playground.selector.type"),
            4,
            0)
        || !hasExclusiveTabStop(
            root,
            QStringLiteral("playground.positionPicker"),
            6,
            2)
        || !hasExclusiveTabStop(
            root,
            QStringLiteral("playground.selector.stack"),
            2,
            0)
        || !hasExclusiveButtonSelection(
            root,
            QStringLiteral("playground.selector.style"),
            4,
            0)
        || !hasExclusiveButtonSelection(
            root,
            QStringLiteral("playground.selector.type"),
            4,
            0)
        || !hasExclusiveButtonSelection(
            root,
            QStringLiteral("playground.selector.stack"),
            2,
            0)) {
        qCritical() << "Playground probe: custom selector tab stops are incorrect";
        return 7;
    }

    auto *window = qobject_cast<QQuickWindow *>(root);
    QObject *state = findObject(root, QStringLiteral("playground.state"));
    const int initialPosition = state
        ? state->property("position").toInt() : -1;
    if (!window || !state
        || !clickObject(
            root,
            QStringLiteral("playground.selector.style.option.1"))
        || state->property("styleIndex").toInt() != 1
        || !hasExclusiveButtonSelection(
            root, QStringLiteral("playground.selector.style"), 4, 1)
        || !clickObject(
            root,
            QStringLiteral("playground.selector.style.option.0"))
        || state->property("styleIndex").toInt() != 0
        || !hasExclusiveButtonSelection(
            root, QStringLiteral("playground.selector.style"), 4, 0)
        || !focusObject(
            root,
            QStringLiteral("playground.selector.style.option.0"))
        || !sendKey(window, Qt::Key_Right)
        || state->property("styleIndex").toInt() != 1
        || !hasExclusiveTabStop(
            root, QStringLiteral("playground.selector.style"), 4, 1)
        || !hasExclusiveButtonSelection(
            root, QStringLiteral("playground.selector.style"), 4, 1)
        || !sendKey(window, Qt::Key_Left)
        || state->property("styleIndex").toInt() != 0
        || !focusObject(
            root,
            QStringLiteral("playground.selector.type.option.0"))
        || !sendKey(window, Qt::Key_Right)
        || state->property("toastType").toString()
               != QStringLiteral("success")
        || !sendKey(window, Qt::Key_Left)
        || state->property("toastType").toString()
               != QStringLiteral("info")
        || !focusObject(
            root,
            QStringLiteral("playground.positionPicker.option.2"))
        || !sendKey(window, Qt::Key_Left)
        || state->property("position").toInt() == initialPosition
        || !sendKey(window, Qt::Key_Right)
        || state->property("position").toInt() != initialPosition
        || !focusObject(
            root,
            QStringLiteral("playground.selector.stack.option.0"))
        || !sendKey(window, Qt::Key_Right)
        || !state->property("stackExpanded").toBool()
        || !sendKey(window, Qt::Key_Left)
        || state->property("stackExpanded").toBool()) {
        qCritical() << "Playground probe: custom selector keyboard input failed";
        return 8;
    }

    if (!focusObject(root, QStringLiteral("playground.advanced.toggle"))
        || !isFullyVisibleIn(root,
                             QStringLiteral("playground.advanced.toggle"),
                             scrollObjectName)) {
        qCritical() << "Playground probe: focused configuration control is clipped";
        return 9;
    }
    QMetaObject::invokeMethod(scrollView, "scrollToStart");
    focusObject(root, QStringLiteral("playground.actions.showToast"));

    auto *actionBar = qobject_cast<QQuickItem *>(
        findObject(root, QStringLiteral("playground.actions")));
    const QStringList supportingTargets = {
        QStringLiteral("playground.header.github"),
        QStringLiteral("playground.advanced.toggle")
    };
    for (const QString &objectName : supportingTargets) {
        auto *target = qobject_cast<QQuickItem *>(findObject(root, objectName));
        if (!target || target->width() < 40 || target->height() < 40) {
            qCritical() << "Playground probe: undersized interaction target"
                        << objectName;
            return 10;
        }
    }
    const QStringList behaviorSwitches = {
        QStringLiteral("playground.input.showCloseButton"),
        QStringLiteral("playground.input.closeOnClick"),
        QStringLiteral("playground.input.showProgressBar"),
        QStringLiteral("playground.input.newestOnTop")
    };
    for (const QString &objectName : behaviorSwitches) {
        QObject *switchControl = findObject(root, objectName);
        const qreal indicatorWidth = switchControl
            ? switchControl->property("implicitIndicatorWidth").toReal()
            : 0;
        const qreal indicatorHeight = switchControl
            ? switchControl->property("implicitIndicatorHeight").toReal()
            : 0;
        if (!switchControl || indicatorWidth < 48
            || indicatorWidth <= indicatorHeight) {
            qCritical() << "Playground probe: undersized switch track"
                        << objectName << indicatorWidth << indicatorHeight;
            return 10;
        }
    }
    const QStringList visibleActions = {
        QStringLiteral("playground.actions.showToast"),
        QStringLiteral("playground.actions.allTypes"),
        QStringLiteral("playground.actions.longMessage"),
        QStringLiteral("playground.actions.more")
    };
    qreal previousRight = -1;
    for (const QString &objectName : visibleActions) {
        auto *action = qobject_cast<QQuickItem *>(findObject(root, objectName));
        const QRectF bounds = action && actionBar
            ? action->mapRectToItem(actionBar, action->boundingRect())
            : QRectF();
        if (!action || !actionBar || bounds.width() < 40
            || bounds.height() < 40 || bounds.left() < previousRight
            || bounds.left() < 0 || bounds.right() > actionBar->width()) {
            qCritical() << "Playground probe: invalid action layout"
                        << objectName << bounds;
            return 10;
        }
        previousRight = bounds.right();
    }

    QObject *preview = findObject(root, QStringLiteral("playground.preview"));
    QObject *messageInput = findObject(
        root,
        QStringLiteral("playground.input.message"));
    QObject *showToastAction = findObject(
        root,
        QStringLiteral("playground.actions.showToast"));
    QObject *clearAction = findObject(
        root,
        QStringLiteral("playground.actions.clear"));
    QObject *emptyState = findObject(
        root,
        QStringLiteral("playground.preview.emptyState"));
    QObject *messageError = findObject(
        root,
        QStringLiteral("playground.input.messageError"));
    if (!preview || !messageInput || !showToastAction || !clearAction || !emptyState
        || !messageError
        || preview->property("activeToastCount").toInt() != 0
        || !showToastAction->property("enabled").toBool()
        || clearAction->property("enabled").toBool()
        || !emptyState->property("visible").toBool()
        || messageError->property("visible").toBool()) {
        qCritical() << "Playground probe: startup must not create a toast";
        return 11;
    }

    const QString initialMessage = messageInput->property("text").toString();
    messageInput->setProperty("text", QStringLiteral(" \n\t"));
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    if (state->property("message").toString() != QStringLiteral(" \n\t")
        || state->property("hasMessage").toBool()
        || showToastAction->property("enabled").toBool()
        || !messageError->property("visible").toBool()) {
        qCritical() << "Playground probe: empty message validation failed";
        return 12;
    }
    messageInput->setProperty("text", initialMessage);
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    if (state->property("message").toString() != initialMessage
        || !state->property("hasMessage").toBool()
        || !showToastAction->property("enabled").toBool()
        || messageError->property("visible").toBool()) {
        qCritical() << "Playground probe: message validation did not recover";
        return 13;
    }

    const QStringList tabOrder = {
        QStringLiteral("playground.header.github"),
        QStringLiteral("playground.selector.style.option.0"),
        QStringLiteral("playground.input.message"),
        QStringLiteral("playground.selector.type.option.0"),
        QStringLiteral("playground.positionPicker.option.2"),
        QStringLiteral("playground.selector.stack.option.0"),
        QStringLiteral("playground.input.autoClose"),
        QStringLiteral("playground.input.visibleToasts"),
        QStringLiteral("playground.input.showCloseButton"),
        QStringLiteral("playground.input.closeOnClick"),
        QStringLiteral("playground.input.showProgressBar"),
        QStringLiteral("playground.input.newestOnTop"),
        QStringLiteral("playground.advanced.toggle"),
        QStringLiteral("playground.actions.showToast"),
        QStringLiteral("playground.actions.allTypes"),
        QStringLiteral("playground.actions.longMessage"),
        QStringLiteral("playground.actions.more")
    };
    if (!followsTabOrder(root, window, tabOrder)) {
        qCritical() << "Playground probe: form Tab order is incorrect";
        return 12;
    }
    auto *styleOption = qobject_cast<QQuickItem *>(findObject(
        root,
        QStringLiteral("playground.selector.style.option.0")));
    if (!focusObject(root, QStringLiteral("playground.input.message"))
        || !sendKey(window, Qt::Key_Backtab, Qt::ShiftModifier)
        || !styleOption || !styleOption->hasActiveFocus()) {
        qCritical() << "Playground probe: message editor Backtab navigation failed";
        return 13;
    }
    QMetaObject::invokeMethod(scrollView, "scrollToStart");
    focusObject(root, QStringLiteral("playground.actions.showToast"));

    QObject *morePopup = findObject(
        root,
        QStringLiteral("playground.actions.morePopup"));
    if (!clickObject(root, QStringLiteral("playground.actions.more"))) {
        qCritical() << "Playground probe: overflow menu failed to open";
        return 12;
    }
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    const QStringList enabledOverflowOrder = {
        QStringLiteral("playground.actions.actionToast"),
        QStringLiteral("playground.actions.promiseSuccess"),
        QStringLiteral("playground.actions.promiseError"),
        QStringLiteral("playground.actions.futureSuccess"),
        QStringLiteral("playground.actions.futureError")
    };
    bool overflowOrderValid = morePopup
        && morePopup->property("opened").toBool();
    for (const QString &objectName : enabledOverflowOrder) {
        auto *action = qobject_cast<QQuickItem *>(findObject(root, objectName));
        overflowOrderValid = overflowOrderValid
            && sendKey(window, Qt::Key_Tab)
            && action && action->hasActiveFocus()
            && action->width() >= 40 && action->height() >= 40;
    }
    auto *moreAction = qobject_cast<QQuickItem *>(findObject(
        root,
        QStringLiteral("playground.actions.more")));
    if (!overflowOrderValid
        || !sendKey(window, Qt::Key_Escape)
        || morePopup->property("opened").toBool()
        || !moreAction || !moreAction->hasActiveFocus()) {
        qCritical() << "Playground probe: overflow keyboard navigation failed";
        return 13;
    }

    if (exerciseResponsiveResize) {
        state->setProperty("autoClose", 0);
        if (!clickObject(root, QStringLiteral("playground.actions.more"))) {
            qCritical() << "Playground resize probe: overflow menu failed";
            return 10;
        }
        QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
        if (!clickObject(
                root,
                QStringLiteral("playground.actions.promiseSuccess"))) {
            qCritical() << "Playground resize probe: Promise action failed";
            return 11;
        }
        QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
        if (preview->property("activeToastCount").toInt() != 1) {
            qCritical() << "Playground resize probe: Promise toast was not created";
            return 12;
        }

        const QList<int> widths = {1099, 1100};
        for (int width : widths) {
            root->setProperty("width", width);
            QCoreApplication::processEvents(QEventLoop::AllEvents, 500);

            QObject *resizedPreview = findObject(
                root,
                QStringLiteral("playground.preview"));
            auto *resizedViewport = qobject_cast<QQuickItem *>(findObject(
                root,
                QStringLiteral("playground.preview.viewport")));
            auto *resizedToastHost = qobject_cast<QQuickItem *>(findObject(
                root,
                QStringLiteral("playground.toastHost")));
            const bool expectedWideLayout = width >= 1100;
            if (resizedPreview != preview || resizedToastHost != toastHost
                || !resizedViewport
                || resizedToastHost->parentItem() != resizedViewport
                || resizedPreview->property("activeToastCount").toInt() != 1
                || workspace->property("wideLayout").toBool()
                       != expectedWideLayout) {
                qCritical() << "Playground resize probe: preview state was lost at"
                            << width;
                return 13;
            }
        }

        QEventLoop settlementLoop;
        QTimer::singleShot(1800, &settlementLoop, &QEventLoop::quit);
        settlementLoop.exec();
        if (preview->property("activeToastCount").toInt() != 1) {
            qCritical() << "Playground resize probe: Promise toast was lost";
            return 14;
        }

        qInfo() << "Playground resize probe: PASS";
        return 0;
    }

    if (!exerciseActions) {
        focusObject(root, QStringLiteral("playground.header"));
        if (!saveProbeScreenshot(root))
            return 26;
        qInfo() << "Playground probe: PASS";
        return 0;
    }

    const QStringList overflowActions = {
        QStringLiteral("playground.actions.actionToast"),
        QStringLiteral("playground.actions.promiseSuccess"),
        QStringLiteral("playground.actions.promiseError"),
        QStringLiteral("playground.actions.futureSuccess"),
        QStringLiteral("playground.actions.futureError")
    };
    for (const QString &objectName : overflowActions) {
        if (!findObject(root, objectName)) {
            qCritical() << "Playground action probe: missing" << objectName;
            return 9;
        }
    }

    if (!selectIndex(root, QStringLiteral("playground.selector.style"), 2)
        || !selectIndex(root, QStringLiteral("playground.selector.type"), 3)
        || !selectIndex(root, QStringLiteral("playground.positionPicker"), 0)
        || !selectIndex(root, QStringLiteral("playground.selector.stack"), 1)) {
        qCritical() << "Playground action probe: a custom selector is not invokable";
        return 11;
    }
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    if (state->property("styleIndex").toInt() != 2
        || state->property("toastType").toString() != QStringLiteral("error")
        || state->property("position").toInt() != 0
        || !state->property("stackExpanded").toBool()
        || !hasExclusiveTabStop(
            root,
            QStringLiteral("playground.selector.style"),
            4,
            2)
        || !hasExclusiveTabStop(
            root,
            QStringLiteral("playground.selector.type"),
            4,
            3)
        || !hasExclusiveTabStop(
            root,
            QStringLiteral("playground.positionPicker"),
            6,
            0)
        || !hasExclusiveTabStop(
            root,
            QStringLiteral("playground.selector.stack"),
            2,
            1)
        || !hasExclusiveButtonSelection(
            root,
            QStringLiteral("playground.selector.style"),
            4,
            2)
        || !hasExclusiveButtonSelection(
            root,
            QStringLiteral("playground.selector.type"),
            4,
            3)
        || !hasExclusiveButtonSelection(
            root,
            QStringLiteral("playground.selector.stack"),
            2,
            1)) {
        qCritical() << "Playground action probe: custom selector values did not propagate";
        return 12;
    }

    QObject *advancedFields = findObject(
        root,
        QStringLiteral("playground.advanced.fields"));
    if (!advancedFields || advancedFields->property("visible").toBool()
        || !clickObject(root, QStringLiteral("playground.advanced.toggle"))) {
        qCritical() << "Playground action probe: advanced settings did not open";
        return 13;
    }
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    if (!advancedFields->property("visible").toBool()) {
        qCritical() << "Playground action probe: advanced settings stayed hidden";
        return 14;
    }
    const QStringList advancedTabOrder = {
        QStringLiteral("playground.advanced.toggle"),
        QStringLiteral("playground.input.toastSpacing"),
        QStringLiteral("playground.input.collapsedOffset"),
        QStringLiteral("playground.input.collapsedScaleStep"),
        QStringLiteral("playground.actions.showToast")
    };
    if (!followsTabOrder(root, window, advancedTabOrder)) {
        qCritical() << "Playground action probe: advanced Tab order is incorrect";
        return 15;
    }
    QMetaObject::invokeMethod(scrollView, "scrollToStart");

    state->setProperty("autoClose", 0);
    state->setProperty("stackExpanded", true);
    state->setProperty("newestOnTop", true);
    state->setProperty("visibleToasts", 5);
    state->setProperty("showCloseButton", false);
    state->setProperty("closeOnClick", false);
    state->setProperty("showProgressBar", false);
    state->setProperty("toastSpacing", 24.0);
    state->setProperty("collapsedOffset", 10.0);
    state->setProperty("collapsedScaleStep", 0.08);
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);

    QVariant toastOptionsResult;
    if (!QMetaObject::invokeMethod(state,
                                   "toastOptions",
                                   Q_RETURN_ARG(QVariant,
                                                toastOptionsResult))) {
        qCritical() << "Playground action probe: toast options are not invokable";
        return 15;
    }
    const QVariantMap toastOptions = toastOptionsResult.toMap();
    if (toastOptions.value(QStringLiteral("autoClose")).toInt() != 0
        || toastOptions.value(QStringLiteral("closeButton")).toBool()
        || toastOptions.value(QStringLiteral("closeOnClick")).toBool()
        || !toastOptions.value(QStringLiteral("hideProgressBar")).toBool()
        || toastHost->property("visibleToasts").toInt() != 5
        || !toastHost->property("expand").toBool()
        || !toastHost->property("newestOnTop").toBool()) {
        qCritical() << "Playground action probe: behavior values did not propagate";
        return 16;
    }

    if (!clickObject(root, QStringLiteral("playground.actions.showToast"))) {
        qCritical() << "Playground action probe: Show Toast is not invokable";
        return 17;
    }
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    if (compactLayout
        && !isFullyVisibleIn(
            root,
            QStringLiteral("playground.preview"),
            scrollObjectName)) {
        qCritical() << "Playground action probe: compact preview is clipped";
        return 18;
    }

    if (!clickObject(root, QStringLiteral("playground.actions.allTypes"))
        || !clickObject(root, QStringLiteral("playground.actions.longMessage"))) {
        qCritical() << "Playground action probe: a visible action is not invokable";
        return 19;
    }
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);

    for (const QString &objectName : overflowActions) {
        if (!clickObject(root, QStringLiteral("playground.actions.more"))) {
            qCritical() << "Playground action probe: overflow menu is not invokable";
            return 19;
        }
        QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
        if (!morePopup || !morePopup->property("opened").toBool()
            || !clickObject(root, objectName)) {
            qCritical() << "Playground action probe: overflow action failed"
                        << objectName;
            return 20;
        }
        QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
        if (morePopup->property("opened").toBool()) {
            qCritical() << "Playground action probe: overflow menu did not close";
            return 21;
        }
    }

    for (int position = 0; position < 6; ++position) {
        state->setProperty("position", position);
        if (!clickObject(root, QStringLiteral("playground.actions.showToast")))
            return 22;
    }

    for (int styleIndex = 0; styleIndex < 4; ++styleIndex) {
        state->setProperty("styleIndex", styleIndex);
        if (!clickObject(root, QStringLiteral("playground.actions.showToast")))
            return 23;
    }
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);

    const int activeToastCount = preview->property("activeToastCount").toInt();
    if (activeToastCount != 21) {
        qCritical() << "Playground action probe: expected 21 active toasts, got"
                    << activeToastCount;
        return 24;
    }

    QObject *currentStyle = state->property("currentStyle").value<QObject *>();
    if (!currentStyle
        || currentStyle->property("toastSpacing").toReal() != 24.0
        || currentStyle->property("collapsedToastOffset").toReal() != 10.0
        || currentStyle->property("collapsedToastScaleStep").toReal() != 0.08) {
        qCritical() << "Playground action probe: advanced style values did not propagate";
        return 25;
    }

    QEventLoop settlementLoop;
    QTimer::singleShot(3200, &settlementLoop, &QEventLoop::quit);
    settlementLoop.exec();

    if (!clearAction->property("enabled").toBool()
        || !clickObject(root, QStringLiteral("playground.actions.more"))) {
        qCritical() << "Playground action probe: clear action is unavailable";
        return 27;
    }
    QCoreApplication::processEvents(QEventLoop::AllEvents, 500);
    if (!morePopup || !morePopup->property("opened").toBool()) {
        qCritical() << "Playground action probe: clear menu did not open";
        return 28;
    }
    const QStringList overflowOrderWithClear = {
        QStringLiteral("playground.actions.actionToast"),
        QStringLiteral("playground.actions.promiseSuccess"),
        QStringLiteral("playground.actions.promiseError"),
        QStringLiteral("playground.actions.futureSuccess"),
        QStringLiteral("playground.actions.futureError"),
        QStringLiteral("playground.actions.clear")
    };
    auto *firstOverflowAction = qobject_cast<QQuickItem *>(findObject(
        root,
        overflowOrderWithClear.constFirst()));
    bool clearOrderValid = firstOverflowAction
        && firstOverflowAction->width() >= 40
        && firstOverflowAction->height() >= 40
        && focusObject(root, overflowOrderWithClear.constFirst());
    for (qsizetype index = 1; index < overflowOrderWithClear.size(); ++index) {
        const QString &objectName = overflowOrderWithClear.at(index);
        auto *action = qobject_cast<QQuickItem *>(findObject(root, objectName));
        const bool keySent = sendKey(window, Qt::Key_Tab);
        const bool stepValid = keySent && action && action->hasActiveFocus()
            && action->width() >= 40 && action->height() >= 40;
        clearOrderValid = clearOrderValid && stepValid;
    }
    if (!clearOrderValid) {
        qCritical() << "Playground action probe: enabled overflow order is invalid";
        return 29;
    }
    if (!saveProbeScreenshot(root))
        return 26;

    if (!clickObject(root, QStringLiteral("playground.actions.clear"))) {
        qCritical() << "Playground action probe: clear action failed";
        return 30;
    }

    QEventLoop clearLoop;
    QTimer::singleShot(800, &clearLoop, &QEventLoop::quit);
    clearLoop.exec();
    if (preview->property("activeToastCount").toInt() != 0
        || clearAction->property("enabled").toBool()
        || !emptyState->property("visible").toBool()) {
        qCritical() << "Playground action probe: preview did not return to empty state";
        return 31;
    }

    qInfo() << "Playground action probe: PASS";
    return 0;
}
} // namespace

bool playgroundProbeRequested()
{
    const QStringList arguments = QCoreApplication::arguments();
    return arguments.contains(QStringLiteral("--probe"))
        || arguments.contains(QStringLiteral("--probe-actions"))
        || arguments.contains(QStringLiteral("--probe-compact"))
        || arguments.contains(QStringLiteral("--probe-minimum"))
        || arguments.contains(QStringLiteral("--probe-large-font"))
        || arguments.contains(QStringLiteral("--probe-responsive"));
}

void configurePlaygroundProbeApplication(QGuiApplication &app)
{
    if (QCoreApplication::arguments().contains(
            QStringLiteral("--probe-large-font"))) {
        QFont font = app.font();
        font.setPointSizeF(font.pointSizeF() * 1.35);
        app.setFont(font);
    }
}

int runPlaygroundProbe(QQmlApplicationEngine &engine)
{
    const QStringList arguments = QCoreApplication::arguments();
    const bool probeActions =
        arguments.contains(QStringLiteral("--probe-actions"));
    const bool probeCompact =
        arguments.contains(QStringLiteral("--probe-compact"));
    const bool probeMinimum =
        arguments.contains(QStringLiteral("--probe-minimum"));
    const bool probeResponsive =
        arguments.contains(QStringLiteral("--probe-responsive"));

    activeFocusOnTabWarningSeen = false;
    previousMessageHandler = qInstallMessageHandler(
        playgroundProbeMessageHandler);
    const int result = runProbe(engine,
                                probeActions,
                                probeCompact || probeMinimum,
                                probeMinimum,
                                probeResponsive);
    qInstallMessageHandler(previousMessageHandler);
    previousMessageHandler = nullptr;

    if (result == 0 && activeFocusOnTabWarningSeen) {
        qCritical() << "Playground probe: activeFocusOnTab changed on the focused item";
        return 32;
    }
    return result;
}
