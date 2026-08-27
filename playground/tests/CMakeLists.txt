find_package(Qt6 6.11 REQUIRED COMPONENTS Qml Test)

qt_add_executable(tst_playground_state
    tst_playground_state.cpp
)

target_compile_definitions(tst_playground_state PRIVATE
    PLAYGROUND_STATE_SOURCE="${CMAKE_CURRENT_SOURCE_DIR}/../PlaygroundState.qml"
)

target_link_libraries(tst_playground_state PRIVATE
    Qt6::Qml
    Qt6::Test
    Toastify
    Toastifyplugin
    ToastifyStyleplugin
)

add_test(NAME PlaygroundStateTest COMMAND tst_playground_state)
