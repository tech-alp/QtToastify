#include <QDebug>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngineExtensionPlugin>

#include "Theme/MerceTheme.h"

#include <cstdlib>

#if defined(QTTOASTIFY_PLAYGROUND_PROBES)
#include "tests/PlaygroundRuntimeProbe.h"

#include <QTimer>
#endif

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
} // namespace

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    useConcreteApplicationFont(app);

#if defined(QTTOASTIFY_PLAYGROUND_PROBES)
    const bool runProbe = playgroundProbeRequested();
    if (runProbe)
        configurePlaygroundProbeApplication(app);
#endif

    app.setApplicationName("QtToastify Playground");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("QtToastify");

    QQmlApplicationEngine engine;
#if defined(QTTOASTIFY_MERCE_QML_IMPORT_PATH)
    engine.addImportPath(QString::fromUtf8(QTTOASTIFY_MERCE_QML_IMPORT_PATH));
#endif
    engine.addImportPath("qrc:/qt/qml");
    engine.addImportPath("qrc:/");
    engine.addImportPath(":/");

    auto *theme = engine.singletonInstance<MerceTheme *>("Merce.Theme", "Theme");
    if (!theme
        || !theme->setContext(QStringLiteral("algit"),
                              QStringLiteral("light"),
                              QStringLiteral("ops"))) {
        qWarning() << "QtToastify Playground: Merce theme context could not be activated";
    }
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [&app](const QUrl &url) {
            qCritical() << "QtToastify Playground: root QML creation failed"
                        << url;
            app.exit(EXIT_FAILURE);
        },
        Qt::QueuedConnection);
    engine.loadFromModule("PlaygroundExamples", "PlaygroundApp");

#if defined(QTTOASTIFY_PLAYGROUND_PROBES)
    if (runProbe) {
        QTimer::singleShot(100, &app, [&app, &engine]() {
            app.exit(runPlaygroundProbe(engine));
        });
        return app.exec();
    }
#endif

    qDebug() << "Loading QtToastify Playground";
    return app.exec();
}
