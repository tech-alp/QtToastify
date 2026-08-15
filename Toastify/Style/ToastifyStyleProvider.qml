import QtQuick

QtObject {
    id: root
    
    // React-Toastify light theme status colors
    property var colors: ({
        info: "#3498db",
        success: "#07bc0c", 
        warning: "#f1c40f",
        error: "#e74c3c"
    })
    
    property color backgroundColor: "#ffffff"

    // Browser default is 16px sans-serif; use the platform sans-serif in Qt.
    property var fonts: ({
        family: Qt.application.font.family,
        size: 16,
        weight: Font.Normal
    })
    
    // Spacing configuration
    property var spacing: ({
        main: 10,
        content: 10,
        text: 4,                     // Space between text lines
        container: 14,
        closeButton: {
            padding: 6,
            size: 14,
            width: 14,
            height: 16
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
        minimum: 320,
        preferred: 320,
        maximum: 320,
        minimumHeight: 64
    })
    
    // Visual styling
    property real cornerRadius: 6
    property real iconSize: 22
    property real toastOffset: 16
    property real toastSpacing: 16
    property real collapsedToastOffset: 14
    property real collapsedToastScaleStep: 0.05
    property int stackTransitionDuration: 400
    
    // Shadow configuration
    property var shadow: ({
        blur: 0.5,
        color: "#000000",
        opacity: 0.1,
        horizontalOffset: 0,
        verticalOffset: 4
    })
    
    // Animation configuration
    property var animation: ({
        enterDuration: 500,
        exitDuration: 300
    })
    
    // Text colors
    property var textColors: ({
        color: "#757575"
    })

    property var closeButtonStyle: ({
        color: "#000000",
        opacity: 0.3,
        hoveredOpacity: 1.0
    })
    
    // Progress bar styling
    property var progressBar: ({
        height: 5,
        radius: 6,
        opacity: 0.7,
        backgroundOpacity: 0.2
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
