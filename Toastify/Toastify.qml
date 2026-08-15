import QtQuick
import QtQuick.Controls
import Toastify.Style 1.0

Item {
    id: root

    property Component toastItem: ToastifyDelegate{}
    
    // Style provider - uses default ToastifyStyleProvider if not specified
    property ToastifyStyleProvider style: ToastifyStyleProvider {}

    // In permanently expanded stacks, place the newest toast at the visual top.
    // Compact/hover stacks always keep the newest toast at the screen-edge anchor.
    property bool newestOnTop: false

    // Default mode is compact; hover expands the stack temporarily.
    property bool expand: false
    property int visibleToasts: 3

    property int _toastSequence: 0

    anchors.fill: parent

    // Overlay üzerine çizilmesi için
    parent: Overlay.overlay

    // Enums
    enum Type { Info, Success, Warning, Error }
    enum Position { TopLeftCorner, TopRightCorner, BottomLeftCorner, BottomRightCorner, TopCenter, BottomCenter }

    // Z-Index
    z: 9999

    function getColumn(pos) {
        switch(pos) {
            case Toastify.TopLeftCorner: return topLeftColumn
            case Toastify.TopRightCorner: return topRightColumn
            case Toastify.BottomLeftCorner: return bottomLeftColumn
            case Toastify.BottomRightCorner: return bottomRightColumn
            case Toastify.TopCenter: return topCenterColumn
            case Toastify.BottomCenter: return bottomCenterColumn
            default: return topLeftColumn
        }
    }

    function isOptionalToastProperty(name) {
        return name === "closeButton"
                || name === "action"
                || name === "isLoading"
    }

    function applyOptionalToastProperties(toast, options) {
        const optionalProperties = ["closeButton", "action", "isLoading"]
        for (let i = 0; i < optionalProperties.length; ++i) {
            const propertyName = optionalProperties[i]
            if (options[propertyName] !== undefined
                    && typeof toast[propertyName] !== "undefined") {
                toast[propertyName] = options[propertyName]
            }
        }
    }

    // Position stacks - compact by default, expanded on hover.
    ToastStack {
        id: topLeftColumn
        objectName: "topLeftStack"
        x: root.style.toastOffset
        y: root.style.toastOffset
        expandByDefault: root.expand
        expandedSpacing: root.style.toastSpacing
        collapsedOffset: root.style.collapsedToastOffset
        collapsedScaleStep: root.style.collapsedToastScaleStep
        transitionDuration: root.style.stackTransitionDuration
        visibleToasts: root.visibleToasts
        newestOnTop: root.newestOnTop
    }

    ToastStack {
        id: topRightColumn
        objectName: "topRightStack"
        anchors.right: parent.right
        anchors.rightMargin: root.style.toastOffset
        y: root.style.toastOffset
        expandByDefault: root.expand
        expandedSpacing: root.style.toastSpacing
        collapsedOffset: root.style.collapsedToastOffset
        collapsedScaleStep: root.style.collapsedToastScaleStep
        transitionDuration: root.style.stackTransitionDuration
        visibleToasts: root.visibleToasts
        newestOnTop: root.newestOnTop
    }

    ToastStack {
        id: bottomLeftColumn
        objectName: "bottomLeftStack"
        x: root.style.toastOffset
        y: parent.height - root.style.toastOffset
        bottomAligned: true
        expandByDefault: root.expand
        expandedSpacing: root.style.toastSpacing
        collapsedOffset: root.style.collapsedToastOffset
        collapsedScaleStep: root.style.collapsedToastScaleStep
        transitionDuration: root.style.stackTransitionDuration
        visibleToasts: root.visibleToasts
        newestOnTop: root.newestOnTop
    }

    ToastStack {
        id: bottomRightColumn
        objectName: "bottomRightStack"
        anchors.right: parent.right
        anchors.rightMargin: root.style.toastOffset
        y: parent.height - root.style.toastOffset
        bottomAligned: true
        expandByDefault: root.expand
        expandedSpacing: root.style.toastSpacing
        collapsedOffset: root.style.collapsedToastOffset
        collapsedScaleStep: root.style.collapsedToastScaleStep
        transitionDuration: root.style.stackTransitionDuration
        visibleToasts: root.visibleToasts
        newestOnTop: root.newestOnTop
    }

    ToastStack {
        id: topCenterColumn
        objectName: "topCenterStack"
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.style.toastOffset
        expandByDefault: root.expand
        expandedSpacing: root.style.toastSpacing
        collapsedOffset: root.style.collapsedToastOffset
        collapsedScaleStep: root.style.collapsedToastScaleStep
        transitionDuration: root.style.stackTransitionDuration
        visibleToasts: root.visibleToasts
        newestOnTop: root.newestOnTop
    }

    ToastStack {
        id: bottomCenterColumn
        objectName: "bottomCenterStack"
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - root.style.toastOffset
        bottomAligned: true
        expandByDefault: root.expand
        expandedSpacing: root.style.toastSpacing
        collapsedOffset: root.style.collapsedToastOffset
        collapsedScaleStep: root.style.collapsedToastScaleStep
        transitionDuration: root.style.stackTransitionDuration
        visibleToasts: root.visibleToasts
        newestOnTop: root.newestOnTop
    }


    function createMessage(message, options = {}) {
        if (!message) {
            console.error("Toastify: Message is empty!");
            return null;
        }

        // Position'ı al
        const position = options.position ?? Toastify.TopLeftCorner;
        const targetLayout = getColumn(position);

        if (toastItem.status !== Component.Ready) {
            console.error("Toastify: Component not ready. Error: " + toastItem.errorString());
            return null;
        }

        // Properties objesini oluştur
        let properties = {
            message: message,
            // Base properties
            type: options.type ?? Toastify.Info,
            position: position,
            autoClose: options.autoClose ?? 5000,
            closeOnClick: options.closeOnClick ?? true,
            hideProgressBar: options.hideProgressBar ?? false,
            clickAction: options.clickAction ?? null,
            
            // Style injection - pass the style provider to the toast
            styleProvider: root.style
        };

        // Options'taki tüm ekstra propertyleri ekle
        Object.keys(options).forEach(key => {
            if (!(key in properties) && !isOptionalToastProperty(key)) {
                properties[key] = options[key];
            }
        });

        const entry = targetLayout.createEntry(++root._toastSequence);
        if (entry === null) {
            console.error("Toastify: Error creating stack entry.");
            return null;
        }

        // Toast oluştur
        // Toastify owns the toast lifetime; the entry is only its visual parent.
        // Keeping ownership here also makes an explicit reparent safe.
        const toast = toastItem.createObject(root, properties);

        if (toast === null) {
            entry.destroy();
            console.error("Toastify: Error creating toast object.");
            return null;
        }

        applyOptionalToastProperties(toast, options);

        toast.parent = entry;
        entry.attachToast(toast);

        return toast;
    }

    // Shortcut fonksiyonlar - Object.assign ile
    function success(message, options = {}) {
        const config = Object.assign({}, options, { type: Toastify.Success });
        return createMessage(message, config);
    }

    function error(message, options = {}) {
        const config = Object.assign({}, options, { type: Toastify.Error });
        return createMessage(message, config);
    }

    function warning(message, options = {}) {
        const config = Object.assign({}, options, { type: Toastify.Warning });
        return createMessage(message, config);
    }

    function info(message, options = {}) {
        const config = Object.assign({}, options, { type: Toastify.Info });
        return createMessage(message, config);
    }

    function update(toast, patch = {}) {
        if (!toast || !patch)
            return false;

        const writableProperties = [
            "message", "type", "autoClose", "closeOnClick",
            "hideProgressBar", "clickAction", "closeButton", "action",
            "isLoading"
        ];

        try {
            if (typeof toast["closing"] !== "undefined" && toast.closing)
                return false;

            let restartAutoClose = false;
            for (let i = 0; i < writableProperties.length; ++i) {
                const propertyName = writableProperties[i];
                if (patch[propertyName] === undefined
                        || typeof toast[propertyName] === "undefined") {
                    continue;
                }

                toast[propertyName] = patch[propertyName];
                if (propertyName === "autoClose"
                        || propertyName === "isLoading") {
                    restartAutoClose = true;
                }
            }

            if (restartAutoClose
                    && typeof toast["restartAutoClose"] === "function") {
                toast.restartAutoClose();
            }

            return true;
        } catch (error) {
            console.warn("Toastify: Could not update toast: " + error);
            return false;
        }
    }

    function dismiss(toast) {
        if (!toast)
            return false;

        try {
            if (typeof toast["close"] !== "function")
                return false;

            toast.close();
            return true;
        } catch (error) {
            return false;
        }
    }

    function loading(message, options = {}) {
        const config = Object.assign({}, options, {
            type: options.type ?? Toastify.Info,
            autoClose: 0,
            hideProgressBar: true,
            closeOnClick: false,
            closeButton: options.closeButton ?? false,
            isLoading: true
        });
        return createMessage(message, config);
    }

    function promise(promiseOrFunction, options = {}) {
        const loadingMessage = options.loading !== undefined
                               ? options.loading : options.pending;
        if (loadingMessage === undefined || loadingMessage === null) {
            console.error("Toastify: Promise options require a loading or pending message");
            return null;
        }

        const toastOptions = Object.assign({}, options);
        delete toastOptions.loading;
        delete toastOptions.pending;
        delete toastOptions.success;
        delete toastOptions.error;
        delete toastOptions.finally;

        const pendingToast = loading(String(loadingMessage), toastOptions);
        if (!pendingToast)
            return null;

        const state = { toast: pendingToast };
        if (typeof pendingToast["closingChanged"] !== "undefined") {
            pendingToast.closingChanged.connect(function() {
                if (pendingToast.closing)
                    state.toast = null;
            });
        }

        let targetPromise;
        try {
            targetPromise = typeof promiseOrFunction === "function"
                            ? promiseOrFunction() : promiseOrFunction;
        } catch (error) {
            targetPromise = Promise.reject(error);
        }

        Promise.resolve(targetPromise).then(function(result) {
            try {
                root.settlePromiseToast(state, Toastify.Success,
                                        options.success, result, options);
            } finally {
                root.finishPromiseToast(options);
            }
        }, function(error) {
            try {
                root.settlePromiseToast(state, Toastify.Error,
                                        options.error, error, options);
            } finally {
                root.finishPromiseToast(options);
            }
        });

        return pendingToast;
    }

    function settlePromiseToast(state, type, messageSpec, value, options) {
        if (!state.toast)
            return false;

        const toast = state.toast;
        state.toast = null;

        if (messageSpec === undefined || messageSpec === null)
            return dismiss(toast);

        try {
            const message = typeof messageSpec === "function"
                            ? messageSpec(value) : messageSpec;
            if (message === undefined || message === null)
                return dismiss(toast);

            return update(toast, {
                message: String(message),
                type: type,
                autoClose: options.autoClose ?? 5000,
                closeOnClick: options.closeOnClick ?? true,
                hideProgressBar: options.hideProgressBar ?? false,
                closeButton: options.closeButton ?? true,
                isLoading: false
            });
        } catch (error) {
            console.warn("Toastify: Could not settle promise toast: " + error);
            return dismiss(toast);
        }
    }

    function finishPromiseToast(options) {
        if (typeof options.finally !== "function")
            return;

        try {
            options.finally();
        } catch (error) {
            console.warn("Toastify: Promise finally callback failed: " + error);
        }
    }
}
