import QtQuick 2.15
import Toastify.Style 1.0

ToastifyStyle {
    readonly property string name: "Light Theme"
    readonly property string description: "Açık tema, pastel renkler ve minimal spacing"
    
    // Override only the properties we want to change
    colors: ({
        info: "#E3F2FD",      // Light Blue
        success: "#E8F5E8",   // Light Green
        warning: "#FFF3E0",   // Light Orange  
        error: "#FFEBEE"      // Light Red
    })

    fonts: ({
        family: "Segoe UI",
        size: 12,             // Smaller font
        weight: Font.Normal
    })

    spacing: ({
        main: 8,                     // Less space between elements
        content: 8,                  // Less content spacing
        text: 2,                     // Minimal text spacing
        container: 8,                // Minimal container padding
        
        closeButton: {
            "padding": 4,            // Minimal close button padding
            "size": 20              // Smaller close button
        },
        
        totalHorizontal: function() {
            return spacing.main + spacing.container * 2;
        },
        
        closeButtonTotal: function() {
            return spacing.closeButton.size;
        }
    })

    containerSizes: ({
        minimum: 240,
        preferred: 300,
        maximum: 400
    })

    shadow: ({
        blur: 0.3,
        color: "#000000",
        opacity: 0.1,
        horizontalOffset: 0,
        verticalOffset: 2
    })

    animation: ({
        enterDuration: 300,
        exitDuration: 200,
        easingType: "OutQuad",
        pauseDuration: 100
    })

    textColors: ({
        color: "#333333"         // Dark text for light backgrounds
    })
}
