#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QDebug>
#include <QFontDatabase>
#include <QQmlEngineExtensionPlugin>

Q_IMPORT_QML_PLUGIN(ToastifyPlugin)
Q_IMPORT_QML_PLUGIN(Toastify_StylePlugin)

namespace {
void useConcreteApplicationFont(QGuiApplication &app)
{
    const QStringList availableFamilies = QFontDatabase::families();
    if (availableFamilies.contains(app.font().family(),
                                   Qt::CaseInsensitive)) {
        return;
    }

    const QStringList candidates = {
        QStringLiteral(".AppleSystemUIFont"),
        QStringLiteral("Segoe UI"),
        QStringLiteral("Noto Sans"),
        QStringLiteral("DejaVu Sans"),
        QStringLiteral("Liberation Sans"),
        QStringLiteral("Arial")
    };

    for (const QString &candidate : candidates) {
        if (!availableFamilies.contains(candidate, Qt::CaseInsensitive))
            continue;

        QFont font = app.font();
        font.setFamily(candidate);
        app.setFont(font);
        return;
    }
}
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    useConcreteApplicationFont(app);
    
    // Set application properties
    app.setApplicationName("QtToastify Playground");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("QtToastify");

    QQmlApplicationEngine engine;
    
    // Add import paths
    engine.addImportPath("qrc:/qt/qml");
    engine.addImportPath("qrc:/");
    engine.addImportPath(":/");

    engine.loadFromModule("PlaygroundExamples", "PlaygroundApp");
    
    qDebug() << "Loading QtToastify Playground";
    
    return app.exec();
}
