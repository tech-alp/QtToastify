import QtQuick

ToastifyStyleProvider {
    // Compact theme - smaller fonts and spacing
    fonts: ({
        family: "Roboto",
        size: 12,             // Smaller font
        weight: Font.Normal
    })

    // Reduced spacing for compact layout
    spacing: ({
        main: 8,              // Less space between content and close button
        content: 8,           // Less space between icon and text
        text: 2,              // Minimal space between text lines
        container: 8,         // Less container padding
        closeButton: {
            padding: 4,       // Less padding around close button
            size: 18          // Smaller close button
        },
        
        // Calculated spacing functions
        totalHorizontal: function() {
            return spacing.main + spacing.container * 2;
        },
        
        closeButtonTotal: function() {
            return spacing.closeButton.size;
        }
    })

    // Smaller containers for compact layout
    containerSizes: ({
        minimum: 200,         // Much smaller minimum
        preferred: 280,       // Smaller preferred
        maximum: 350          // Smaller maximum
    })

    // Minimal shadow for clean look
    shadow: ({
        blur: 0.3,
        color: "#000000",
        opacity: 0.05,
        horizontalOffset: 0,
        verticalOffset: 1
    })

    // Faster animations for snappy feel
    animation: ({
        enterDuration: 300,
        exitDuration: 250
    })

    // Smaller corner radius
    cornerRadius: 6
    
    // Smaller icons
    iconSize: 14
    
    // Thinner progress bar
    progressBar: ({
        height: 2,
        radius: 1
    })
}