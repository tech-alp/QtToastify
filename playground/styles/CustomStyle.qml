import QtQuick 2.15
import Toastify.Style 1.0

ToastifyStyle {
    readonly property string name: "Custom Dark"
    readonly property string description: "Koyu tema, büyük fontlar ve artırılmış spacing"
    
    // Override only the properties we want to change
    colors: ({
        info: "#2196F3",      // Material Blue
        success: "#4CAF50",   // Material Green  
        warning: "#FF9800",   // Material Orange
        error: "#F44336"      // Material Red
    })

    fonts: ({
        family: "Arial",
        size: 16,             // Larger font
        weight: Font.Medium
    })

    spacing: ({
        main: 16,                    // More space between content and close button
        content: 16,                 // More space between icon and text
        text: 6,                     // More space between text lines
        container: 16,               // More container padding
        
        closeButton: {
            "padding": 8,            // More padding around close button
            "size": 32              // Larger close button
        },
        
        totalHorizontal: function() {
            return spacing.main + spacing.container * 2;
        },
        
        closeButtonTotal: function() {
            return spacing.closeButton.size;
        }
    })

    containerSizes: ({
        minimum: 320,
        preferred: 400,
        maximum: 600
    })

    shadow: ({
        blur: 1.0,
        color: "#000000",
        opacity: 0.3,
        horizontalOffset: 2,
        verticalOffset: 4
    })

    animation: ({
        enterDuration: 800,
        exitDuration: 600,
        easingType: "OutBack",
        pauseDuration: 300
    })

    textColors: ({
        color: "#FFFFFF"         // White text for dark backgrounds
    })
}
