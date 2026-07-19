#include <QtQuickTest>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlEngineExtensionPlugin>

Q_IMPORT_QML_PLUGIN(ToastifyPlugin)
Q_IMPORT_QML_PLUGIN(Toastify_StylePlugin)

class Setup : public QObject
{
    Q_OBJECT

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        // Add import path for Toastify module
        engine->addImportPath("qrc:/qt/qml/");
        engine->addImportPath("../");
        engine->addImportPath("../qml");
        engine->addImportPath("qrc:/");
    }
};

QUICK_TEST_MAIN_WITH_SETUP(toast_layout_tests, Setup)

#include "main.moc"
