pragma Singleton
import QtQuick 2.15

QtObject {
    // Color palette for each toast type
    property var colors: ({
        info: "#3498db",
        success: "#07bc0c",
        warning: "#f1c40f",
        error: "#e74c3c"
    })

    // Font settings
    property var fonts: ({
        family: "Roboto",
        size: 14,
        weight: Font.Normal
    })

    // Layout settings
    property real cornerRadius: 12
    property real borderMargin: 12
    property real iconSize: 18
    property real iconSpacing: 12

    // Comprehensive spacing configuration
    property var spacing: ({
        // Main layout spacing
        main: 12,                    // Space between content area and close button
        content: 12,                 // Space between icon and text in content area
        text: 4,                     // Space between text elements (multi-line)
        
        // Container padding
        container: 12,               // All-around container padding
        
        // Close button configuration
        closeButton: {
            "padding": 6,            // Extra padding around close button for better clickability
            "size": 18 + 6          // Icon size + padding
        },
        
        // Calculated values for convenience
        totalHorizontal: function() {
            return spacing.main + spacing.container * 2;
        },
        
        closeButtonTotal: function() {
            return spacing.closeButton.size;
        }
    })

    // Shadow settings for MultiEffect
    property var shadow: ({
        blur: 0.5,
        color: "#000000",
        opacity: 0.1,
        horizontalOffset: 0,
        verticalOffset: 0
    })

    // Animation settings
    property var animation: ({
        enterDuration: 500,
        exitDuration: 500,
        easingType: "OutBack",
        pauseDuration: 200
    })

    // Progress bar settings
    property var progressBar: ({
        height: 4,
        radius: 2
    })

    // Theme-specific text colors
    property var textColors: ({
        light: "#000000",
        dark: "#ffffff",
        color: "#ffffff"
    })

    // Theme-specific background colors
    property var backgroundColors: ({
        light: "#ffffff",
        dark: "#121212",
        color: "accent"  // Uses accent color
    })

    // Container size constraints
    property var containerSizes: ({
        minimum: 280,
        preferred: 350,
        maximum: 500
    })
}
