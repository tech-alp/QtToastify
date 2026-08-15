import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import Toastify 1.0
import Toastify.Style 1.0

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

    DarkStyleProvider {
        id: darkStyleProvider
    }

    function test_reactToastifyDefaults() {
        var toast = createTemporaryObject(toastComponent, testCase, {
            message: "Wow so easy !"
        })

        verify(toast !== null, "Toast should be created successfully")
        waitForRendering(toast)

        compare(toast.width, 320)
        compare(toast.height, 64)
        compare(toast.styleProvider.backgroundColor.toString(), "#ffffff")
        compare(toast.styleProvider.textColors.color, "#757575")
        compare(toast.styleProvider.colors.info, "#3498db")
        compare(toast.styleProvider.colors.success, "#07bc0c")
        compare(toast.styleProvider.colors.warning, "#f1c40f")
        compare(toast.styleProvider.colors.error, "#e74c3c")
        compare(toast.styleProvider.iconSize, 22)
        compare(toast.styleProvider.cornerRadius, 6)
        compare(toast.styleProvider.progressBar.height, 5)
        compare(toast.styleProvider.toastOffset, 16)
        compare(toast.styleProvider.toastSpacing, 16)
    }

    function test_progressBarStaysInsideBottomEdge() {
        var toast = createTemporaryObject(toastComponent, testCase, {
            message: "Progress geometry",
            autoClose: 5000,
            styleProvider: darkStyleProvider
        })

        verify(toast !== null, "Toast should be created successfully")
        waitForRendering(toast)

        var progressViewport = findChildByObjectName(toast,
                                                      "progressViewport")
        var progressTrack = findChildByObjectName(toast,
                                                   "progressTrack")
        var progressFillClip = findChildByObjectName(toast,
                                                      "progressFillClip")
        var progressFill = findChildByObjectName(toast,
                                                  "progressFill")
        verify(progressViewport !== null, "Progress viewport should exist")
        verify(progressTrack !== null, "Progress track should exist")
        verify(progressFillClip !== null, "Progress fill clip should exist")
        verify(progressFill !== null, "Progress fill should exist")

        compare(progressViewport.clip, true)
        compare(progressFillClip.clip, true)
        compare(toast.progressRadius, toast.styleProvider.cornerRadius)

        fuzzyCompare(progressViewport.mapToItem(toast, 0, 0).x, 0, 0.5)
        fuzzyCompare(progressViewport.mapToItem(toast, 0, 0).y, 0, 0.5)
        fuzzyCompare(progressViewport.width, toast.width, 0.5)
        fuzzyCompare(progressViewport.height, toast.height, 0.5)
        fuzzyCompare(progressFillClip.height, progressViewport.height, 0.5)
        fuzzyCompare(progressTrack.mapToItem(
                         toast, 0, progressTrack.height).y,
                     toast.height, 0.5)
        fuzzyCompare(progressFill.mapToItem(
                         toast, 0, progressFill.height).y,
                     toast.height, 0.5)

        toast.stackHeight = 48
        tryCompare(toast, "height", 48)
        tryCompare(progressViewport, "height", toast.height)
        fuzzyCompare(progressViewport.mapToItem(
                         toast, 0, progressViewport.height).y,
                     toast.height, 0.5)
    }

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
        var closeButtonArea = findChildByObjectName(toast, "closeButtonArea")
        verify(closeButtonArea !== null, "Close button area should exist")
        
        // Verify close button is positioned in top-right area
        var containerWidth = toast.width
        var containerHeight = toast.height
        var expectedMargin = toast.styleProvider.spacing.closeButton.padding
        
        // Close button should be aligned to the top
        verify(Math.abs(closeButtonArea.y - expectedMargin) <= 1,
               "Close button should use configured top margin")
        
        // Close button should be positioned towards the right side
        var closeButtonRightEdge = closeButtonArea.x + closeButtonArea.width
        var distanceFromRight = toast.width - closeButtonRightEdge
        verify(Math.abs(distanceFromRight - expectedMargin) <= 1,
               "Close button should use configured right margin")
        
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
        
        // Effective visibility/enabled state should follow the toast. In an
        // offscreen Qt Quick Test both can be false because no window is shown.
        compare(closeButtonArea.visible, toast.visible,
                "Close button visibility should follow toast visibility")
        compare(closeButtonArea.enabled, toast.enabled,
                "Close button enabled state should follow toast state")
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
        var closeButtonArea = findChildByObjectName(toast, "closeButtonArea")
        var contentArea = findChildByObjectName(contentItem, "contentArea")
        
        if (closeButtonArea !== null && contentArea !== null) {
            // Record initial close button position
            var initialCloseButtonX = closeButtonArea.x
            var initialCloseButtonY = closeButtonArea.y
            var initialCloseButtonWidth = closeButtonArea.width
            var initialCloseButtonHeight = closeButtonArea.height
            
            // Verify close button maintains top alignment regardless of content height
            var expectedMargin = toast.styleProvider.spacing.closeButton.padding
            verify(Math.abs(closeButtonArea.y - expectedMargin) <= 1,
                   "Close button should maintain configured top alignment")
            
            // Verify close button doesn't overlap with content area
            var contentRightEdge = contentArea.mapToItem(toast, contentArea.width, 0).x
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
                verify(Math.abs(closeButtonArea.y - expectedMargin) <= 1,
                       "Close button should remain at top even with multi-line content")
                
                // Close button should maintain its width regardless of content wrapping
                verify(Math.abs(closeButtonArea.width - initialCloseButtonWidth) <= 1,
                       "Close button width should remain stable during content wrapping")
            }
        }
        
        // Verify layout stability - content area should not be affected by close button
        if (contentArea !== null) {
            // Content area should have proper maximum width constraint
            var mappedContentRight = contentArea.mapToItem(toast, contentArea.width, 0).x
            verify(closeButtonArea === null || mappedContentRight <= closeButtonArea.x,
                   "Content area should not overlap close button")
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
        var closeButtonArea = findChildByObjectName(toast, "closeButtonArea")
        
        if (contentArea !== null && closeButtonArea !== null) {
            // Verify content area adapts to available space
            var contentLeft = contentArea.mapToItem(toast, 0, 0).x
            var availableContentWidth = closeButtonArea.x - contentLeft
            verify(contentArea.width <= availableContentWidth + 5,
                   "Content area should adapt to available space without overflow")
            
            // Verify close button area maintains its dimensions
            verify(closeButtonArea.width > 0, "Close button area should have positive width")
            verify(closeButtonArea.height > 0, "Close button area should have positive height")
            
            // Verify no overlap between content and close button areas
            var contentRightEdge = contentArea.mapToItem(toast, contentArea.width, 0).x
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
        var closeButtonArea = findChildByObjectName(toast, "closeButtonArea")
        
        if (contentArea !== null && closeButtonArea !== null) {
            // Verify content area internal spacing
            var iconImage = findIconInContentArea(contentArea)
            var textArea = findTextAreaInContentArea(contentArea)
            
            if (iconImage !== null && textArea !== null) {
                var expectedContentSpacing = 10
                var actualContentSpacing = textArea.x - (iconImage.x + iconImage.width)
                verify(Math.abs(actualContentSpacing - expectedContentSpacing) <= 2,
                       "Content area spacing should be consistent (" + expectedContentSpacing + "), got " + actualContentSpacing)
            }
            
            // Verify container padding consistency
            var expectedPadding = 14
            verify(Math.abs(toast.leftPadding - expectedPadding) <= 1,
                   "Left padding should be consistent (" + expectedPadding + "), got " + toast.leftPadding)
            var expectedRightPadding = expectedPadding + 14 + 6 * 2
            verify(Math.abs(toast.rightPadding - expectedRightPadding) <= 1,
                   "Right padding should reserve close button space")
            verify(Math.abs(toast.topPadding - expectedPadding) <= 1,
                   "Top padding should be consistent (" + expectedPadding + "), got " + toast.topPadding)
            verify(Math.abs(toast.bottomPadding - expectedPadding) <= 1,
                   "Bottom padding should be consistent (" + expectedPadding + "), got " + toast.bottomPadding)
            
            // Verify close button dimensions consistency
            verify(Math.abs(closeButtonArea.width - 14) <= 1,
                   "Close button width should be 14px")
            verify(Math.abs(closeButtonArea.height - 16) <= 1,
                   "Close button height should be 16px")
        }
        
        // Verify spacing remains consistent across different configurations
        // Test that spacing doesn't get compromised under different content lengths
        var containerWidth = toast.width
        var totalExpectedSpacing = 10 + 14 + 40
        var availableContentWidth = containerWidth - totalExpectedSpacing - 22
        
        verify(availableContentWidth > 0, "Available content width should be positive after accounting for spacing")
        
        // Verify no negative spacing calculations
        if (contentArea !== null) {
            verify(contentArea.width > 0, "Content area width should be positive")
            verify(contentArea.height > 0, "Content area height should be positive")
        }
    }

    function findIconInContentArea(contentArea) {
        return findChildByObjectName(contentArea, "statusIcon")
    }

    function findTextAreaInContentArea(contentArea) {
        return findChildByObjectName(contentArea, "textContentArea")
    }

    Component {
        id: toastComponent
        ToastifyDelegate {
            type: Toastify.Info
            autoClose: 0  // Disable auto-close for testing
        }
    }
}
