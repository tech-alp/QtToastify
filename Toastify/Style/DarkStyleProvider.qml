import QtQuick

ToastifyStyleProvider {
    // Dark theme colors - Material Design inspired
    colors: ({
        info: "#2196F3",      // Material Blue
        success: "#4CAF50",   // Material Green  
        warning: "#FF9800",   // Material Orange
        error: "#F44336"      // Material Red
    })

    // Larger fonts for better readability in dark theme
    fonts: ({
        family: "Arial",
        size: 16,             // Larger font
        weight: Font.Medium
    })

    // Increased spacing for more breathing room
    spacing: ({
        main: 16,                    // More space between content and close button
        content: 16,                 // More space between icon and text
        text: 6,                     // More space between text lines
        container: 16,               // More container padding
        closeButton: {
            padding: 16,             // More padding around close button
            size: 16                 // Larger close button
        },
        
        // Calculated spacing functions
        totalHorizontal: function() {
            return spacing.main + spacing.container * 2;
        },
        
        closeButtonTotal: function() {
            return spacing.closeButton.size;
        }
    })

    // Larger containers for dark theme
    containerSizes: ({
        minimum: 320,
        preferred: 400,
        maximum: 600
    })

    // Enhanced shadow for dark theme
    shadow: ({
        blur: 1.0,
        color: "#000000",
        opacity: 0.3,
        horizontalOffset: 2,
        verticalOffset: 4
    })

    // Slower, more dramatic animations
    animation: ({
        enterDuration: 800,
        exitDuration: 600
    })

    // Larger corner radius for modern look
    cornerRadius: 16
    
    // Larger icons
    iconSize: 20
}
