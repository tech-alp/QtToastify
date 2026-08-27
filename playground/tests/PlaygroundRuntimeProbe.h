#pragma once

class QGuiApplication;
class QQmlApplicationEngine;

bool playgroundProbeRequested();
void configurePlaygroundProbeApplication(QGuiApplication &app);
int runPlaygroundProbe(QQmlApplicationEngine &engine);
