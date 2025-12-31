import QtQuick

ToastifyStyleProvider {
    // Material Design 3 color palette
    colors: ({
        info: "#1976D2",      // Material Blue 700
        success: "#388E3C",   // Material Green 700
        warning: "#F57C00",   // Material Orange 700
        error: "#D32F2F"      // Material Red 700
    })

    // Material Design typography
    fonts: ({
        family: "Roboto",     // Material Design font
        size: 14,
        weight: Font.Medium   // Material uses medium weight
    })

    // Material Design spacing (8dp grid)
    spacing: ({
        main: 16,             // 2 * 8dp
        content: 12,          // 1.5 * 8dp
        text: 4,              // 0.5 * 8dp
        container: 16,        // 2 * 8dp
        closeButton: {
            padding: 8,       // 1 * 8dp
            size: 16          // 2 * 8dp
        },
        
        // Calculated spacing functions
        totalHorizontal: function() {
            return spacing.main + spacing.container * 2;
        },
        
        closeButtonTotal: function() {
            return spacing.closeButton.size;
        }
    })

    // Material Design container sizes
    containerSizes: ({
        minimum: 288,         // Material minimum snackbar width
        preferred: 344,       // Material preferred width
        maximum: 568          // Material maximum width
    })

    // Material Design elevation shadow (4dp)
    shadow: ({
        blur: 0.8,
        color: "#000000",
        opacity: 0.14,
        horizontalOffset: 0,
        verticalOffset: 2
    })

    // Material Design motion
    animation: ({
        enterDuration: 225,   // Material standard easing
        exitDuration: 195     // Material standard easing
    })

    // Material Design corner radius
    cornerRadius: 4           // Material small corner radius
    
    // Material icon size
    iconSize: 18             // Material small icon
    
    // Material progress bar
    progressBar: ({
        height: 4,           // Material progress height
        radius: 2
    })
}
