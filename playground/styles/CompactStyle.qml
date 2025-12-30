import QtQuick 2.15
import Toastify.Style 1.0

ToastifyStyle {
    readonly property string name: "Compact"
    readonly property string description: "Ultra-kompakt layout, minimal alan kullanımı"
    
    // Override only the properties we want to change
    colors: ({
        info: "#1976D2",      // Darker Blue
        success: "#388E3C",   // Darker Green
        warning: "#F57C00",   // Darker Orange
        error: "#D32F2F"      // Darker Red
    })

    fonts: ({
        family: "Roboto Condensed",
        size: 10,             // Very small font
        weight: Font.Medium   // Medium weight for better readability at small size
    })

    spacing: ({
        main: 4,                     // Minimal space between elements
        content: 4,                  // Minimal content spacing
        text: 1,                     // Almost no text spacing
        container: 4,                // Minimal container padding
        
        closeButton: {
            "padding": 2,            // Minimal close button padding
            "size": 14              // Very small close button
        },
        
        totalHorizontal: function() {
            return spacing.main + spacing.container * 2;
        },
        
        closeButtonTotal: function() {
            return spacing.closeButton.size;
        }
    })

    containerSizes: ({
        minimum: 180,
        preferred: 220,
        maximum: 280
    })

    shadow: ({
        blur: 0,
        color: "#000000",
        opacity: 0,
        horizontalOffset: 0,
        verticalOffset: 0
    })

    animation: ({
        enterDuration: 150,
        exitDuration: 100,
        easingType: "OutQuad",
        pauseDuration: 50
    })

    textColors: ({
        color: "#FFFFFF"         // White text for better contrast
    })
}
