#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQuickStyle>
#include <QtAwesome.h>
#include <QtAwesomeQuickImageProvider.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set QML style to Material
    QQuickStyle::setStyle("Material");

    // Initialize QtAwesome
    fa::QtAwesome* awesome = new fa::QtAwesome(qApp);
    awesome->initFontAwesome();

    QQmlApplicationEngine engine;

    engine.addImportPath("qrc:/");

    engine.addImageProvider("fa", new QtAwesomeQuickImageProvider(awesome));

    engine.loadFromModule("Toastify", "Main");

    return app.exec();
}
