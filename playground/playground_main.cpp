#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QDebug>
#include <QtAwesome.h>
#include <QtAwesomeQuickImageProvider.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    // Set application properties
    app.setApplicationName("QtToastify Playground");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("QtToastify");

    // Initialize QtAwesome
    fa::QtAwesome* awesome = new fa::QtAwesome(qApp);
    awesome->initFontAwesome();


    QQmlApplicationEngine engine;
    
    // Add import paths
    engine.addImportPath("qrc:/");
    engine.addImportPath(":/");

    engine.addImageProvider("fa", new QtAwesomeQuickImageProvider(awesome));

    engine.loadFromModule("PlaygroundExamples", "PlaygroundApp");
    
    qDebug() << "Loading QtToastify Playground";
    
    return app.exec();
}
