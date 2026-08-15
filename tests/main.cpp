#include <QtQuickTest>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlEngineExtensionPlugin>
#include <QFontDatabase>
#include <QGuiApplication>

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

class Setup : public QObject
{
    Q_OBJECT

public slots:
    void applicationAvailable()
    {
        if (auto *app = qobject_cast<QGuiApplication *>(
                QCoreApplication::instance())) {
            useConcreteApplicationFont(*app);
        }
    }

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
