# QtToastify

A modern, customizable toast notification library for Qt/QML applications, inspired by [react-toastify](https://fkhadra.github.io/react-toastify/introduction/).

![QtToastify](https://img.shields.io/badge/Qt-6.10+-41CD52?style=for-the-badge&logo=qt)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

## Features

- 🎨 **Multiple Toast Types**: Info, Success, Warning, and Error notifications
- 📍 **Flexible Positioning**: 6 different positions (corners and centers)
- 🎭 **Customizable Styles**: Built-in style providers with full customization support
- ⏱️ **Auto-Close with Progress Bar**: Configurable auto-close duration with visual progress indicator
- ✨ **Smooth Animations**: Enter and exit animations for polished user experience
- 🖱️ **Interactive**: Click-to-close and custom action buttons
- 🎯 **Style Provider System**: Easy theming with pluggable style providers
- 📱 **Responsive**: Automatic text wrapping and container sizing
- 🔤 **FontAwesome Icons**: Beautiful icons using QtAwesome

## Built-in Styles

QtToastify comes with 4 pre-configured style providers:

| Style | Description | Font Size | Container Width |
|-------|-------------|-----------|-----------------|
| **Default** | Standard style with balanced spacing | 14px | 280-500px |
| **Dark Theme** | Dark theme with larger fonts and enhanced shadows | 16px | 320-600px |
| **Material** | Material Design 3 compliant style | 14px | 288-568px |
| **Compact** | Minimal layout for space-constrained UIs | 12px | 200-350px |

## Requirements

- **Qt 6.10+** with modules:
  - Core
  - Quick
  - Qml
  - QuickControls2
- **CMake 3.20+**
- **C++17** compatible compiler

## Installation

### Clone the Repository

```bash
git clone https://github.com/yourusername/QtToastify.git
cd QtToastify
```

### Build with CMake

```bash
# Configure
cmake -B build -S . -DCMAKE_INSTALL_PREFIX=/path/to/qt/lib/cmake

# Build
cmake --build build

# Install (optional)
cmake --install build
```

### Build Options

```bash
# Build with tests
cmake -B build -S . -DBUILD_TESTS=ON

# Build with playground examples
cmake -B build -S . -DBUILD_PLAYGROUND=ON

# Build both
cmake -B build -S . -DBUILD_TESTS=ON -DBUILD_PLAYGROUND=ON
```

## Quick Start

### Basic Usage

```qml
import QtQuick 2.15
import Toastify 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600
    
    // Add Toastify component
    Toastify {
        id: toastify
    }
    
    Button {
        text: "Show Toast"
        onClicked: {
            toastify.info("Hello, World!")
        }
    }
}
```

### Toast Types

```qml
// Info toast
toastify.info("This is an info message")

// Success toast
toastify.success("Operation completed successfully!")

// Warning toast
toastify.warning("Please check your input")

// Error toast
toastify.error("An error occurred")
```

### Advanced Configuration

```qml
toastify.createMessage("Custom message", {
    type: Toastify.Success,
    position: Toastify.TopRightCorner,
    autoClose: 8000,           // 8 seconds
    closeOnClick: true,
    hideProgressBar: false,
    clickAction: function() {
        console.log("Toast clicked!")
    }
})
```

## API Reference

### Toastify Component

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `toastItem` | Component | `ToastifyDelegate{}` | Custom toast component |
| `style` | ToastifyStyleProvider | `ToastifyStyleProvider{}` | Style provider for theming |

#### Methods

##### `createMessage(message, options)`

Creates a new toast notification.

**Parameters:**
- `message` (string): The message to display
- `options` (object): Configuration options

**Options:**
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `type` | int | `Toastify.Info` | Toast type (Info, Success, Warning, Error) |
| `position` | int | `Toastify.TopLeftCorner` | Toast position |
| `autoClose` | int | `5000` | Auto-close duration in milliseconds (0 = no auto-close) |
| `closeOnClick` | bool | `true` | Close toast on click |
| `hideProgressBar` | bool | `false` | Hide the progress bar |
| `clickAction` | function | `null` | Custom click handler |

**Returns:** Toast object or `null` on error

##### `success(message, options)`

Shortcut for creating a success toast.

##### `error(message, options)`

Shortcut for creating an error toast.

##### `warning(message, options)`

Shortcut for creating a warning toast.

##### `info(message, options)`

Shortcut for creating an info toast.

### Position Enum

```qml
Toastify.TopLeftCorner      // Top-left corner
Toastify.TopRightCorner     // Top-right corner
Toastify.BottomLeftCorner   // Bottom-left corner
Toastify.BottomRightCorner  // Bottom-right corner
Toastify.TopCenter          // Top center
Toastify.BottomCenter       // Bottom center
```

### Type Enum

```qml
Toastify.Info     // Information toast
Toastify.Success  // Success toast
Toastify.Warning  // Warning toast
Toastify.Error    // Error toast
```

## Custom Styling

### Using Built-in Style Providers

```qml
import Toastify 1.0
import Toastify.Style 1.0

Toastify {
    id: toastify
    
    // Use Dark theme
    style: DarkStyleProvider {}
}
```

### Creating Custom Style Provider

Create a new QML file extending `ToastifyStyleProvider`:

```qml
// MyCustomStyle.qml
import QtQuick
import Toastify.Style 1.0

ToastifyStyleProvider {
    // Custom colors
    colors: ({
        info: "#6366f1",      // Indigo
        success: "#10b981",   // Emerald
        warning: "#f59e0b",   // Amber
        error: "#ef4444"      // Red
    })
    
    // Custom fonts
    fonts: ({
        family: "Segoe UI",
        size: 15,
        weight: Font.Medium
    })
    
    // Custom spacing
    spacing: ({
        main: 14,
        content: 14,
        text: 5,
        container: 14,
        closeButton: {
            padding: 7,
            size: 20
        }
    })
    
    // Custom container sizes
    containerSizes: ({
        minimum: 300,
        preferred: 380,
        maximum: 550
    })
    
    // Custom corner radius
    cornerRadius: 14
    
    // Custom shadow
    shadow: ({
        blur: 0.7,
        color: "#000000",
        opacity: 0.15,
        horizontalOffset: 0,
        verticalOffset: 3
    })
    
    // Custom animations
    animation: ({
        enterDuration: 400,
        exitDuration: 400
    })
    
    // Custom text colors
    textColors: ({
        color: "#ffffff"
    })
    
    // Custom progress bar
    progressBar: ({
        height: 5,
        radius: 3
    })
}
```

Then use it in your application:

```qml
Toastify {
    id: toastify
    style: MyCustomStyle {}
}
```

### Style Provider Properties

All style providers support the following properties:

#### Colors
- `colors.info` (color): Info toast background color
- `colors.success` (color): Success toast background color
- `colors.warning` (color): Warning toast background color
- `colors.error` (color): Error toast background color

#### Fonts
- `fonts.family` (string): Font family name
- `fonts.size` (int): Font size in pixels
- `fonts.weight` (enum): Font weight (Normal, Bold, etc.)

#### Spacing
- `spacing.main` (int): Space between content and close button
- `spacing.content` (int): Space between icon and text
- `spacing.text` (int): Space between text lines
- `spacing.container` (int): Container padding
- `spacing.closeButton.padding` (int): Close button padding
- `spacing.closeButton.size` (int): Close button size

#### Container Sizes
- `containerSizes.minimum` (int): Minimum container width
- `containerSizes.preferred` (int): Preferred container width
- `containerSizes.maximum` (int): Maximum container width

#### Visual Styling
- `cornerRadius` (real): Corner radius in pixels
- `iconSize` (real): Icon size in pixels

#### Shadow
- `shadow.blur` (real): Shadow blur amount
- `shadow.color` (color): Shadow color
- `shadow.opacity` (real): Shadow opacity (0-1)
- `shadow.horizontalOffset` (real): Horizontal shadow offset
- `shadow.verticalOffset` (real): Vertical shadow offset

#### Animation
- `animation.enterDuration` (int): Enter animation duration in ms
- `animation.exitDuration` (int): Exit animation duration in ms

#### Text Colors
- `textColors.color` (color): Text color

#### Progress Bar
- `progressBar.height` (int): Progress bar height in pixels
- `progressBar.radius` (int): Progress bar corner radius

## Playground Examples

The project includes a comprehensive playground application to explore different styles and configurations:

```bash
# Build and run playground
cmake -B build -S . -DBUILD_PLAYGROUND=ON
cmake --build build
./build/playground/QtToastifyPlayground
```

The playground features:
- Interactive style switching between all built-in styles
- Real-time toast configuration
- Test buttons for different scenarios
- Long message testing
- All toast types demonstration

## Project Structure

```
QtToastify/
├── CMakeLists.txt              # Main CMake configuration
├── main.cpp                    # Application entry point
├── resources.qrc               # Qt resource file
├── Toastify/                   # Main library
│   ├── CMakeLists.txt
│   ├── Toastify.qml           # Main Toastify component
│   ├── ToastifyDelegate.qml   # Toast delegate component
│   ├── ToastifyStyle.qml      # Style definitions
│   └── Style/                 # Style providers
│       ├── CMakeLists.txt
│       ├── ToastifyStyleProvider.qml
│       ├── DarkStyleProvider.qml
│       ├── MaterialStyleProvider.qml
│       └── CompactStyleProvider.qml
├── playground/                 # Example application
│   ├── CMakeLists.txt
│   ├── PlaygroundApp.qml      # Main playground UI
│   ├── playground_main.cpp
│   └── styles/                # Additional style examples
├── qml/                       # Showcase examples
│   ├── Main.qml
│   ├── ShowcaseSimple.qml
│   └── ShowcaseAdvanced.qml
├── tests/                     # Unit tests
│   ├── CMakeLists.txt
│   ├── main.cpp
│   └── tst_container_boundary.qml
└── resources/                 # Resources
    ├── fonts/                # Montserrat fonts
    └── icons/                # Icon resources
```

## Integration in Your Project

### CMake Integration

Add QtToastify as a subdirectory in your CMake project:

```cmake
# Your CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(MyApp)

find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml QuickControls2)

# Add QtToastify subdirectory
add_subdirectory(path/to/QtToastify)

# Link against Toastify library
add_executable(MyApp main.cpp)
target_link_libraries(MyApp PRIVATE Qt6::Core Qt6::Quick Toastify)
```

### QML Integration

Add the import path to your QML engine:

```cpp
// main.cpp
QQmlApplicationEngine engine;
engine.addImportPath("qrc:/");  // If using resources
// or
engine.addImportPath("path/to/QtToastify");  // If using file system
```

Then import in QML:

```qml
import Toastify 1.0
import Toastify.Style 1.0
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Original design and idea inspired by [react-toastify](https://fkhadra.github.io/react-toastify/introduction/)
- Icons provided by [FontAwesome](https://fontawesome.com/) via [QtAwesome](https://github.com/gamecreature/QtAwesome)
- Font: [Montserrat](https://fonts.google.com/specimen/Montserrat) by Julieta Ulanovsky

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/yourusername/QtToastify).

## Changelog

### Version 1.0.0
- Initial release
- 4 built-in style providers
- 6 toast positions
- 4 toast types
- Custom style provider support
- Playground application
- Unit tests
