cmake_minimum_required(VERSION 3.20)
project(QtToastify VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt Setup
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Quick
    Qml
    QuickControls2
)

qt_standard_project_setup()

qt_policy(SET QTP0001 NEW)

add_subdirectory(Toastify)

# Add tests subdirectory
option(BUILD_TESTS "Build tests" OFF)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Add playground examples subdirectory
option(BUILD_PLAYGROUND "Build playground examples" ON)
if(BUILD_PLAYGROUND)
    add_subdirectory(playground)
endif()
