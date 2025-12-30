#include <QtQuickTest>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlEngineExtensionPlugin>
#include <QtAwesome.h>
#include <QtAwesomeQuickImageProvider.h>

Q_IMPORT_QML_PLUGIN(ToastifyPlugin)

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

        // Initialize QtAwesome
        fa::QtAwesome* awesome = new fa::QtAwesome(qApp);
        awesome->initFontAwesome();
        engine->addImageProvider("fa", new QtAwesomeQuickImageProvider(awesome));
    }
};

QUICK_TEST_MAIN_WITH_SETUP(toast_layout_tests, Setup)

#include "main.moc"
