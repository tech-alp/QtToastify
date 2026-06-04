import QtQuick

QtObject {
    id: root
    
    // Color scheme for different toast types
    property var colors: ({
        info: "#3498db",
        success: "#07bc0c", 
        warning: "#f1c40f",
        error: "#e74c3c"
    })
    
    // Font configuration
    property var fonts: ({
        family: "Roboto",
        size: 14,
        weight: Font.Normal
    })
    
    // Spacing configuration
    property var spacing: ({
        main: 12,                    // Space between content and close button
        content: 12,                 // Space between icon and text
        text: 4,                     // Space between text lines
        container: 12,               // Container padding
        closeButton: {
            padding: 6,              // Close button padding
            size: 12                 // Close button size
        },
        
        // Calculated spacing functions (for backward compatibility)
        totalHorizontal: function() {
            return spacing.main + spacing.container * 2;
        },
        
        closeButtonTotal: function() {
            return spacing.closeButton.size;
        }
    })
    
    // Container size constraints
    property var containerSizes: ({
        minimum: 280,
        preferred: 350,
        maximum: 500
    })
    
    // Visual styling
    property real cornerRadius: 12
    property real iconSize: 18
    
    // Shadow configuration
    property var shadow: ({
        blur: 0.5,
        color: "#000000",
        opacity: 0.1,
        horizontalOffset: 0,
        verticalOffset: 0
    })
    
    // Animation configuration
    property var animation: ({
        enterDuration: 500,
        exitDuration: 500
    })
    
    // Text colors
    property var textColors: ({
        color: "#ffffff"
    })
    
    // Progress bar styling
    property var progressBar: ({
        height: 4,
        radius: 2
    })
    
    // Helper function to get color for toast type
    function getColorForType(type) {
        switch(type) {
            case 0: return colors.info
            case 1: return colors.success
            case 2: return colors.warning
            case 3: return colors.error
            default: return colors.info
        }
    }
}
