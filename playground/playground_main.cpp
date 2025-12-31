#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    // Set application properties
    app.setApplicationName("QtToastify Playground");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("QtToastify");

    QQmlApplicationEngine engine;
    
    // Add import paths
    engine.addImportPath("qrc:/");
    engine.addImportPath(":/");

    engine.loadFromModule("PlaygroundExamples", "PlaygroundApp");
    
    qDebug() << "Loading QtToastify Playground";
    
    return app.exec();
}
