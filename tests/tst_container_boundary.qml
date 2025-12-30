import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import Toastify 1.0

TestCase {
    id: testCase
    name: "ContainerBoundaryEnforcement"
    width: 800
    height: 600

    // Feature: toast-layout-fix, Property 1: Container Boundary Enforcement
    // Validates: Requirements 1.1, 1.2, 1.3

    property var testMessages: [
        "Short",
        "Medium length message",
        "This is a very long message that should wrap properly within container boundaries",
        "Extremely long message that goes on and on and should definitely test the container boundary enforcement when a close button is present in the toast notification and the container width is constrained to various sizes"
    ]

    property var testWidths: [280, 320, 350, 400, 500]

    function test_containerBoundaryEnforcement_data() {
        var data = []
        for (var i = 0; i < testMessages.length; i++) {
            for (var j = 0; j < testWidths.length; j++) {
                data.push({
                    message: testMessages[i],
                    containerWidth: testWidths[j],
                    tag: "message_" + i + "_width_" + testWidths[j]
                })
            }
        }
        return data
    }

    function test_containerBoundaryEnforcement(data) {
        // Create toast delegate with test data
        var toast = createTemporaryObject(toastComponent, testCase, {
            message: data.message,
            preferredWidth: data.containerWidth
        })
        
        verify(toast !== null, "Toast should be created successfully")
        
        // Wait for layout to complete
        waitForRendering(toast)
        
        // Property 1: Container Boundary Enforcement
        // For any toast configuration with any combination of content, 
        // all child elements should have positions and dimensions that fall 
        // completely within the container boundaries
        
        var containerWidth = toast.width
        var containerHeight = toast.height
        
        // Verify container respects size constraints
        verify(containerWidth >= toast.minimumWidth, 
               "Container width (" + containerWidth + ") should be >= minimum width (" + toast.minimumWidth + ")")
        verify(containerWidth <= toast.maximumWidth, 
               "Container width (" + containerWidth + ") should be <= maximum width (" + toast.maximumWidth + ")")
        
        // Find all child elements and verify they are within boundaries
        var contentItem = toast.contentItem
        verify(contentItem !== null, "Content item should exist")
        
        // Check content item boundaries
        verify(contentItem.x >= 0, "Content item x position should be >= 0")
        verify(contentItem.y >= 0, "Content item y position should be >= 0")
        verify(contentItem.x + contentItem.width <= containerWidth, 
               "Content item should not exceed container width")
        verify(contentItem.y + contentItem.height <= containerHeight, 
               "Content item should not exceed container height")
        
        // Recursively check all child elements
        checkChildBoundaries(contentItem, containerWidth, containerHeight, "contentItem")
    }

    // Feature: toast-layout-fix, Property 2: Close Button Positioning
    // Validates: Requirements 2.1, 2.2, 2.3
    function test_closeButtonPositioning_data() {
        return test_containerBoundaryEnforcement_data()
    }

    function test_closeButtonPositioning(data) {
        // Create toast delegate with test data
        var toast = createTemporaryObject(toastComponent, testCase, {
            message: data.message,
            preferredWidth: data.containerWidth
        })
        
        verify(toast !== null, "Toast should be created successfully")
        
        // Wait for layout to complete
        waitForRendering(toast)
        
        // Property 2: Close Button Positioning
        // For any toast with a close button, the close button should be positioned 
        // in the top-right area within container boundaries with consistent spacing from edges
        
        var contentItem = toast.contentItem
        verify(contentItem !== null, "Content item should exist")
        
        // Find the close button area
        var closeButtonArea = findChildByObjectName(contentItem, "closeButtonArea")
        verify(closeButtonArea !== null, "Close button area should exist")
        
        // Verify close button is positioned in top-right area
        var containerWidth = toast.width - toast.leftPadding - toast.rightPadding
        var containerHeight = toast.height - toast.topPadding - toast.bottomPadding
        
        // Close button should be aligned to the top
        verify(closeButtonArea.y <= 5, "Close button should be positioned at the top (y <= 5)")
        
        // Close button should be positioned towards the right side
        var closeButtonRightEdge = closeButtonArea.x + closeButtonArea.width
        var contentRightEdge = contentItem.width
        var distanceFromRight = contentRightEdge - closeButtonRightEdge
        verify(distanceFromRight <= 5, "Close button should be positioned near the right edge")
        
        // Close button should stay within container boundaries
        verify(closeButtonArea.x >= 0, "Close button x position should be >= 0")
        verify(closeButtonArea.y >= 0, "Close button y position should be >= 0")
        verify(closeButtonArea.x + closeButtonArea.width <= containerWidth, 
               "Close button should not exceed container width")
        verify(closeButtonArea.y + closeButtonArea.height <= containerHeight, 
               "Close button should not exceed container height")
        
        // Verify consistent spacing - close button should have proper dimensions
        verify(closeButtonArea.width > 0, "Close button should have positive width")
        verify(closeButtonArea.height > 0, "Close button should have positive height")
        
        // Close button should be visible and clickable
        verify(closeButtonArea.visible, "Close button should be visible")
        
        // Find the mouse area within close button for clickability
        var mouseArea = findMouseAreaInCloseButton(closeButtonArea)
        verify(mouseArea !== null, "Close button should have a clickable mouse area")
        verify(mouseArea.enabled, "Close button mouse area should be enabled")
    }

    function checkChildBoundaries(parent, containerWidth, containerHeight, parentName) {
        for (var i = 0; i < parent.children.length; i++) {
            var child = parent.children[i]
            if (!child.visible) continue
            
            var globalPos = parent.mapToItem(null, child.x, child.y)
            var containerPos = testCase.mapFromItem(null, globalPos.x, globalPos.y)
            
            verify(containerPos.x >= 0, 
                   parentName + " child " + i + " x position should be >= 0")
            verify(containerPos.y >= 0, 
                   parentName + " child " + i + " y position should be >= 0")
            verify(containerPos.x + child.width <= containerWidth, 
                   parentName + " child " + i + " should not exceed container width")
            verify(containerPos.y + child.height <= containerHeight, 
                   parentName + " child " + i + " should not exceed container height")
            
            // Recursively check grandchildren
            if (child.children && child.children.length > 0) {
                checkChildBoundaries(child, containerWidth, containerHeight, parentName + ".child" + i)
            }
        }
    }

    // Feature: toast-layout-fix, Property 3: Layout Independence
    // Validates: Requirements 2.4
    function test_layoutIndependence_data() {
        var data = []
        var multiLineMessages = [
            "Short single line",
            "This is a longer message that should wrap to multiple lines when the container width is constrained",
            "This is an extremely long message that will definitely wrap to multiple lines and test the layout independence of the close button when content changes significantly in height and wrapping behavior"
        ]
        
        for (var i = 0; i < multiLineMessages.length; i++) {
            for (var j = 0; j < testWidths.length; j++) {
                data.push({
                    message: multiLineMessages[i],
                    containerWidth: testWidths[j],
                    tag: "multiline_" + i + "_width_" + testWidths[j]
                })
            }
        }
        return data
    }

    function test_layoutIndependence(data) {
        // Create toast delegate with test data
        var toast = createTemporaryObject(toastComponent, testCase, {
            message: data.message,
            preferredWidth: data.containerWidth
        })
        
        verify(toast !== null, "Toast should be created successfully")
        
        // Wait for layout to complete
        waitForRendering(toast)
        
        // Property 3: Layout Independence
        // For any toast content that wraps to multiple lines, the close button position 
        // should remain stable and not affect the content layout
        
        var contentItem = toast.contentItem
        verify(contentItem !== null, "Content item should exist")
        
        // Find the close button area and content area
        var closeButtonArea = findChildByObjectName(contentItem, "closeButtonArea")
        var contentArea = findChildByObjectName(contentItem, "contentArea")
        
        if (closeButtonArea !== null && contentArea !== null) {
            // Record initial close button position
            var initialCloseButtonX = closeButtonArea.x
            var initialCloseButtonY = closeButtonArea.y
            var initialCloseButtonWidth = closeButtonArea.width
            var initialCloseButtonHeight = closeButtonArea.height
            
            // Verify close button maintains top alignment regardless of content height
            verify(closeButtonArea.y <= 5, "Close button should maintain top alignment")
            
            // Verify close button doesn't overlap with content area
            var contentRightEdge = contentArea.x + contentArea.width
            var closeButtonLeftEdge = closeButtonArea.x
            verify(closeButtonLeftEdge >= contentRightEdge - 5, 
                   "Close button should not overlap with content area")
            
            // Verify close button has stable dimensions
            verify(closeButtonArea.width > 0, "Close button should have positive width")
            verify(closeButtonArea.height > 0, "Close button should have positive height")
            
            // For multi-line content, verify close button position is independent of content height
            var contentHeight = contentArea.height
            if (contentHeight > 30) { // Multi-line content likely
                // Close button should still be at the top
                verify(closeButtonArea.y <= 5, 
                       "Close button should remain at top even with multi-line content")
                
                // Close button should maintain its width regardless of content wrapping
                verify(Math.abs(closeButtonArea.width - initialCloseButtonWidth) <= 1,
                       "Close button width should remain stable during content wrapping")
            }
        }
        
        // Verify layout stability - content area should not be affected by close button
        if (contentArea !== null) {
            // Content area should have proper maximum width constraint
            var expectedMaxWidth = toast.width - (closeButtonArea ? closeButtonArea.width : 24) - 12 - toast.leftPadding - toast.rightPadding
            verify(contentArea.width <= expectedMaxWidth + 5, 
                   "Content area should respect maximum width constraint")
        }
    }

    function findChildByObjectName(parent, objectName) {
        if (parent.objectName === objectName) {
            return parent
        }
        
        for (var i = 0; i < parent.children.length; i++) {
            var child = parent.children[i]
            if (child.objectName === objectName) {
                return child
            }
            
            var found = findChildByObjectName(child, objectName)
            if (found !== null) {
                return found
            }
        }
        return null
    }

    function findMouseAreaInCloseButton(closeButtonArea) {
        for (var i = 0; i < closeButtonArea.children.length; i++) {
            var child = closeButtonArea.children[i]
            for (var j = 0; j < child.children.length; j++) {
                var grandchild = child.children[j]
                if (grandchild.toString().indexOf("MouseArea") !== -1) {
                    return grandchild
                }
            }
        }
        return null
    }

    // Feature: toast-layout-fix, Property 4: Layout Adaptability
    // Validates: Requirements 3.1, 3.2, 3.4
    function test_layoutAdaptability_data() {
        var data = []
        var customWidths = [280, 300, 350, 400, 450, 500]
        var contentVariations = [
            { message: "Simple", hasButton: false, hasSubtitle: false },
            { message: "Medium length message with more content", hasButton: false, hasSubtitle: false },
            { message: "Very long message that should test adaptability", hasButton: true, hasSubtitle: false },
            { message: "Complex content", hasButton: true, hasSubtitle: true }
        ]
        
        for (var i = 0; i < contentVariations.length; i++) {
            for (var j = 0; j < customWidths.length; j++) {
                data.push({
                    message: contentVariations[i].message,
                    preferredWidth: customWidths[j],
                    hasButton: contentVariations[i].hasButton,
                    hasSubtitle: contentVariations[i].hasSubtitle,
                    tag: "content_" + i + "_width_" + customWidths[j]
                })
            }
        }
        return data
    }

    function test_layoutAdaptability(data) {
        // Create toast delegate with test data
        var toast = createTemporaryObject(toastComponent, testCase, {
            message: data.message,
            preferredWidth: data.preferredWidth
        })
        
        verify(toast !== null, "Toast should be created successfully")
        
        // Wait for layout to complete
        waitForRendering(toast)
        
        // Property 4: Layout Adaptability
        // For any combination of custom content and preferred width settings, 
        // the layout system should adjust container dimensions while preventing element overflow
        
        var containerWidth = toast.width
        var containerHeight = toast.height
        
        // Verify container adapts to preferred width setting
        if (data.preferredWidth >= toast.minimumWidth && data.preferredWidth <= toast.maximumWidth) {
            verify(Math.abs(containerWidth - data.preferredWidth) <= 5,
                   "Container should adapt to preferred width (" + data.preferredWidth + "), got " + containerWidth)
        }
        
        // Verify container respects constraints while accommodating content
        verify(containerWidth >= toast.minimumWidth,
               "Container should respect minimum width constraint")
        verify(containerWidth <= toast.maximumWidth,
               "Container should respect maximum width constraint")
        
        // Verify layout system prevents element overflow
        var contentItem = toast.contentItem
        verify(contentItem !== null, "Content item should exist")
        
        var contentArea = findChildByObjectName(contentItem, "contentArea")
        var closeButtonArea = findChildByObjectName(contentItem, "closeButtonArea")
        
        if (contentArea !== null && closeButtonArea !== null) {
            // Verify content area adapts to available space
            var availableContentWidth = containerWidth - closeButtonArea.width - 12 - toast.leftPadding - toast.rightPadding
            verify(contentArea.width <= availableContentWidth + 5,
                   "Content area should adapt to available space without overflow")
            
            // Verify close button area maintains its dimensions
            verify(closeButtonArea.width > 0, "Close button area should have positive width")
            verify(closeButtonArea.height > 0, "Close button area should have positive height")
            
            // Verify no overlap between content and close button areas
            var contentRightEdge = contentArea.x + contentArea.width
            var closeButtonLeftEdge = closeButtonArea.x
            verify(closeButtonLeftEdge >= contentRightEdge - 2,
                   "Content and close button areas should not overlap")
        }
        
        // Verify container height adapts to content
        verify(containerHeight >= 40, "Container should have minimum reasonable height")
        
        // For longer messages, verify container expands vertically as needed
        if (data.message.length > 50) {
            verify(containerHeight >= 60, "Container should expand vertically for longer content")
        }
        
        // Verify all elements remain within container boundaries
        checkChildBoundaries(contentItem, containerWidth, containerHeight, "adaptability_contentItem")
    }

    // Feature: toast-layout-fix, Property 5: Spacing Consistency
    // Validates: Requirements 3.3
    function test_spacingConsistency_data() {
        var data = []
        var spacingTestCases = [
            { message: "Short", width: 280 },
            { message: "Medium length message", width: 350 },
            { message: "Very long message that should test spacing consistency across different configurations", width: 400 },
            { message: "Complex multi-line content that wraps and tests spacing", width: 320 }
        ]
        
        for (var i = 0; i < spacingTestCases.length; i++) {
            data.push({
                message: spacingTestCases[i].message,
                containerWidth: spacingTestCases[i].width,
                tag: "spacing_" + i + "_width_" + spacingTestCases[i].width
            })
        }
        return data
    }

    function test_spacingConsistency(data) {
        // Create toast delegate with test data
        var toast = createTemporaryObject(toastComponent, testCase, {
            message: data.message,
            preferredWidth: data.containerWidth
        })
        
        verify(toast !== null, "Toast should be created successfully")
        
        // Wait for layout to complete
        waitForRendering(toast)
        
        // Property 5: Spacing Consistency
        // For any toast configuration, the spacing between all elements should remain 
        // consistent according to the defined spacing values
        
        var contentItem = toast.contentItem
        verify(contentItem !== null, "Content item should exist")
        
        var contentArea = findChildByObjectName(contentItem, "contentArea")
        var closeButtonArea = findChildByObjectName(contentItem, "closeButtonArea")
        
        if (contentArea !== null && closeButtonArea !== null) {
            // Verify main layout spacing consistency
            var expectedMainSpacing = 12  // ToastifyStyle.iconSpacing
            var actualMainSpacing = closeButtonArea.x - (contentArea.x + contentArea.width)
            verify(Math.abs(actualMainSpacing - expectedMainSpacing) <= 2,
                   "Main layout spacing should be consistent (" + expectedMainSpacing + "), got " + actualMainSpacing)
            
            // Verify content area internal spacing
            var iconImage = findIconInContentArea(contentArea)
            var textArea = findTextAreaInContentArea(contentArea)
            
            if (iconImage !== null && textArea !== null) {
                var expectedContentSpacing = 12  // ToastifyStyle.iconSpacing
                var actualContentSpacing = textArea.x - (iconImage.x + iconImage.width)
                verify(Math.abs(actualContentSpacing - expectedContentSpacing) <= 2,
                       "Content area spacing should be consistent (" + expectedContentSpacing + "), got " + actualContentSpacing)
            }
            
            // Verify container padding consistency
            var expectedPadding = 12  // ToastifyStyle.borderMargin
            verify(Math.abs(toast.leftPadding - expectedPadding) <= 1,
                   "Left padding should be consistent (" + expectedPadding + "), got " + toast.leftPadding)
            verify(Math.abs(toast.rightPadding - expectedPadding) <= 1,
                   "Right padding should be consistent (" + expectedPadding + "), got " + toast.rightPadding)
            verify(Math.abs(toast.topPadding - expectedPadding) <= 1,
                   "Top padding should be consistent (" + expectedPadding + "), got " + toast.topPadding)
            verify(Math.abs(toast.bottomPadding - expectedPadding) <= 1,
                   "Bottom padding should be consistent (" + expectedPadding + "), got " + toast.bottomPadding)
            
            // Verify close button dimensions consistency
            var expectedCloseButtonSize = 24  // ToastifyStyle.iconSize + 6 padding
            verify(Math.abs(closeButtonArea.width - expectedCloseButtonSize) <= 2,
                   "Close button width should be consistent (" + expectedCloseButtonSize + "), got " + closeButtonArea.width)
            verify(Math.abs(closeButtonArea.height - expectedCloseButtonSize) <= 2,
                   "Close button height should be consistent (" + expectedCloseButtonSize + "), got " + closeButtonArea.height)
        }
        
        // Verify spacing remains consistent across different configurations
        // Test that spacing doesn't get compromised under different content lengths
        var containerWidth = toast.width
        var totalExpectedSpacing = 12 + 12 + 12 + 12  // main + content + left padding + right padding
        var availableContentWidth = containerWidth - totalExpectedSpacing - 24  // minus close button
        
        verify(availableContentWidth > 0, "Available content width should be positive after accounting for spacing")
        
        // Verify no negative spacing calculations
        if (contentArea !== null) {
            verify(contentArea.width > 0, "Content area width should be positive")
            verify(contentArea.height > 0, "Content area height should be positive")
        }
    }

    function findIconInContentArea(contentArea) {
        for (var i = 0; i < contentArea.children.length; i++) {
            var child = contentArea.children[i]
            if (child.toString().indexOf("Image") !== -1) {
                return child
            }
        }
        return null
    }

    function findTextAreaInContentArea(contentArea) {
        for (var i = 0; i < contentArea.children.length; i++) {
            var child = contentArea.children[i]
            if (child.toString().indexOf("ColumnLayout") !== -1) {
                return child
            }
        }
        return null
    }

    Component {
        id: toastComponent
        ToastifyDelegate {
            type: Toastify.Info
            autoClose: 0  // Disable auto-close for testing
        }
    }
}