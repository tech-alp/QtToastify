#include <QQmlComponent>
#include <QQmlEngine>
#include <QQmlEngineExtensionPlugin>
#include <QScopedPointer>
#include <QSet>
#include <QtTest>

Q_IMPORT_QML_PLUGIN(ToastifyPlugin)
Q_IMPORT_QML_PLUGIN(Toastify_StylePlugin)

class tst_playground_state : public QObject
{
    Q_OBJECT

private slots:
    void defaultsProduceToastifyOptions();
};

void tst_playground_state::defaultsProduceToastifyOptions()
{
    QQmlEngine engine;
    engine.addImportPath(QStringLiteral("qrc:/qt/qml"));
    engine.addImportPath(QStringLiteral("qrc:/"));

    QQmlComponent component(
        &engine,
        QUrl::fromLocalFile(QStringLiteral(PLAYGROUND_STATE_SOURCE)));
    QScopedPointer<QObject> state(component.create());
    QVERIFY2(state, qPrintable(component.errorString()));

    QCOMPARE(state->property("message").toString(),
             QStringLiteral("This is a sample toast message."));
    QVERIFY(state->property("hasMessage").toBool());
    QCOMPARE(state->property("toastType").toString(), QStringLiteral("info"));
    QCOMPARE(state->property("styleIndex").toInt(), 0);
    QCOMPARE(state->property("autoClose").toInt(), 5000);
    QCOMPARE(state->property("visibleToasts").toInt(), 3);
    QVERIFY(state->property("showCloseButton").toBool());
    QVERIFY(state->property("closeOnClick").toBool());
    QVERIFY(state->property("showProgressBar").toBool());
    QVERIFY(!state->property("newestOnTop").toBool());
    QVERIFY(!state->property("expand").toBool());
    QVERIFY(!state->property("stackExpanded").toBool());
    QCOMPARE(state->property("toastSpacing").toReal(), 16.0);
    QCOMPARE(state->property("collapsedOffset").toReal(), 14.0);
    QCOMPARE(state->property("collapsedScaleStep").toReal(), 0.05);
    QVERIFY(state->property("currentStyle").value<QObject *>());

    QVariant result;
    QVERIFY(QMetaObject::invokeMethod(state.get(),
                                      "toastOptions",
                                      Q_RETURN_ARG(QVariant, result)));
    const QVariantMap options = result.toMap();
    QCOMPARE(options.value(QStringLiteral("position")).toInt(),
             state->property("position").toInt());
    QCOMPARE(options.value(QStringLiteral("autoClose")).toInt(), 5000);
    QVERIFY(options.value(QStringLiteral("closeOnClick")).toBool());
    QVERIFY(options.value(QStringLiteral("closeButton")).toBool());
    QVERIFY(!options.value(QStringLiteral("hideProgressBar")).toBool());

    QSet<QObject *> styles;
    for (int styleIndex = 0; styleIndex < 4; ++styleIndex) {
        state->setProperty("styleIndex", styleIndex);
        styles.insert(state->property("currentStyle").value<QObject *>());
    }
    QCOMPARE(styles.size(), 4);

    state->setProperty("position", 5);
    state->setProperty("autoClose", 0);
    state->setProperty("showCloseButton", false);
    state->setProperty("closeOnClick", false);
    state->setProperty("showProgressBar", false);

    QVariant changedResult;
    QVERIFY(QMetaObject::invokeMethod(state.get(),
                                      "toastOptions",
                                      Q_RETURN_ARG(QVariant, changedResult)));
    const QVariantMap changedOptions = changedResult.toMap();
    QCOMPARE(changedOptions.value(QStringLiteral("position")).toInt(), 5);
    QCOMPARE(changedOptions.value(QStringLiteral("autoClose")).toInt(), 0);
    QVERIFY(!changedOptions.value(QStringLiteral("closeOnClick")).toBool());
    QVERIFY(!changedOptions.value(QStringLiteral("closeButton")).toBool());
    QVERIFY(changedOptions.value(QStringLiteral("hideProgressBar")).toBool());

    state->setProperty("message", QStringLiteral(" \n\t"));
    QVERIFY(!state->property("hasMessage").toBool());
    state->setProperty("message", QStringLiteral("Ready"));
    QVERIFY(state->property("hasMessage").toBool());
}

QTEST_MAIN(tst_playground_state)

#include "tst_playground_state.moc"
