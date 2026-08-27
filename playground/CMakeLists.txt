# QtToastify Playground Examples
cmake_minimum_required(VERSION 3.30)

find_package(Qt6 6.11 REQUIRED COMPONENTS LabsStyleKit)

include(cmake/ResolveMerce.cmake)
qttoastify_resolve_merce()

# Create single playground executable
qt_add_executable(QtToastifyPlayground
    main.cpp
)

qt_add_qml_module(QtToastifyPlayground
    URI PlaygroundExamples
    VERSION 1.0
    QML_FILES
        PlaygroundApp.qml
        PlaygroundState.qml
        PlaygroundWorkspace.qml
        components/ActionBar.qml
        components/AppHeader.qml
        components/ConfigurationPanel.qml
        components/FocusScrollView.qml
        components/PositionPicker.qml
        components/PreviewPanel.qml
        components/SectionCard.qml
        components/SegmentedControl.qml
    SOURCES
        PlaygroundFutureFactory.cpp
        PlaygroundFutureFactory.h
    DEPENDENCIES
        TARGET Toastify
        TARGET ToastifyStyle
        TARGET MerceTheme
        TARGET MerceFoundation
        TARGET MerceStyle
        TARGET MerceControls
)

target_link_libraries(QtToastifyPlayground PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
    Qt6::LabsStyleKit
    Merce::Theme
    Merce::Foundation
    Merce::Style
    Merce::Controls
    Toastify
    Toastifyplugin
    ToastifyStyleplugin
)

# Set properties
set_target_properties(QtToastifyPlayground PROPERTIES
    QT_QML_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR}
)

# Install playground (optional)
if(CMAKE_INSTALL_PREFIX)
    install(TARGETS QtToastifyPlayground
        DESTINATION bin
    )

    install(FILES
        README.md
        DESTINATION share/QtToastify/playground
    )
endif()

if(BUILD_TESTS)
    target_sources(QtToastifyPlayground PRIVATE
        tests/PlaygroundRuntimeProbe.cpp
        tests/PlaygroundRuntimeProbe.h
    )

    target_compile_definitions(QtToastifyPlayground PRIVATE
        QTTOASTIFY_PLAYGROUND_PROBES
    )

    add_subdirectory(tests)

    add_test(
        NAME PlaygroundRuntimeProbe
        COMMAND QtToastifyPlayground --probe -platform offscreen
    )
    add_test(
        NAME PlaygroundActionProbe
        COMMAND QtToastifyPlayground --probe-actions -platform offscreen
    )
    add_test(
        NAME PlaygroundCompactProbe
        COMMAND QtToastifyPlayground --probe-compact -platform offscreen
    )
    add_test(
        NAME PlaygroundMinimumProbe
        COMMAND QtToastifyPlayground --probe-minimum -platform offscreen
    )
    add_test(
        NAME PlaygroundCompactActionProbe
        COMMAND QtToastifyPlayground --probe-actions --probe-compact -platform offscreen
    )
    add_test(
        NAME PlaygroundMinimumActionProbe
        COMMAND QtToastifyPlayground --probe-actions --probe-minimum -platform offscreen
    )
    add_test(
        NAME PlaygroundLargeFontProbe
        COMMAND QtToastifyPlayground --probe-large-font --probe-compact -platform offscreen
    )
    add_test(
        NAME PlaygroundMinimumLargeFontActionProbe
        COMMAND QtToastifyPlayground --probe-actions --probe-large-font --probe-minimum -platform offscreen
    )
    add_test(
        NAME PlaygroundResponsiveProbe
        COMMAND QtToastifyPlayground --probe-responsive -platform offscreen
    )
    set_tests_properties(
        PlaygroundRuntimeProbe
        PlaygroundActionProbe
        PlaygroundCompactProbe
        PlaygroundMinimumProbe
        PlaygroundCompactActionProbe
        PlaygroundMinimumActionProbe
        PlaygroundLargeFontProbe
        PlaygroundMinimumLargeFontActionProbe
        PlaygroundResponsiveProbe
        PROPERTIES ENVIRONMENT "QSG_RHI_BACKEND=software"
    )
endif()
