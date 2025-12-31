import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Toastify.Style 1.0

Item {
    id: root

    property Component toastItem: ToastifyDelegate{}
    
    // Style provider - uses default ToastifyStyleProvider if not specified
    property ToastifyStyleProvider style: ToastifyStyleProvider {}

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

    // Pozisyon Kolonları - İçeriğe göre boyutlanır
    ColumnLayout {
        id: topLeftColumn
        x: 12
        y: 12
        spacing: 10
    }

    ColumnLayout {
        id: topRightColumn
        anchors.right: parent.right
        anchors.rightMargin: 12
        y: 12
        spacing: 10
    }

    ColumnLayout {
        id: bottomLeftColumn
        x: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        spacing: 10
    }

    ColumnLayout {
        id: bottomRightColumn
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        spacing: 10
    }

    ColumnLayout {
        id: topCenterColumn
        anchors.horizontalCenter: parent.horizontalCenter
        y: 50
        spacing: 10
    }

    ColumnLayout {
        id: bottomCenterColumn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        spacing: 10
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
            
            // Promise support
            isPromiseToast: options.isPromiseToast ?? false,
            promiseResult: options.promiseResult ?? null,
            
            // Style injection - pass the style provider to the toast
            styleProvider: root.style
        };

        // Options'taki tüm ekstra propertyleri ekle
        Object.keys(options).forEach(key => {
            if (!(key in properties)) {
                properties[key] = options[key];
            }
        });

        // Toast oluştur
        const toast = toastItem.createObject(targetLayout, properties);

        if (toast === null) {
            console.error("Toastify: Error creating toast object.");
            return null;
        }

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

    // Promise support function - React Toastify benzeri
    function promise(promiseOrFunction, options = {}) {
        if (!options.pending && !options.success && !options.error) {
            console.error("Toastify: Promise options must include pending, success, and error messages");
            return null;
        }

        // Pending toast'ı oluştur
        const pendingConfig = Object.assign({}, options, {
            type: Toastify.Info,
            autoClose: false, // Promise tamamlanana kadar açık kalsın
            hideProgressBar: true, // Progress bar'ı gizle
            closeOnClick: false, // Tıklayarak kapatmayı devre dışı bırak
            isPromiseToast: true // Promise toast olduğunu belirt
        });

        const pendingToast = createMessage(options.pending, pendingConfig);
        if (!pendingToast) return null;

        // Promise'i resolve et
        let targetPromise;
        if (typeof promiseOrFunction === 'function') {
            try {
                targetPromise = promiseOrFunction();
            } catch (error) {
                targetPromise = Promise.reject(error);
            }
        } else {
            targetPromise = promiseOrFunction;
        }

        // Promise'in sonucunu bekle
        targetPromise
            .then(result => {
                // Success durumu
                pendingToast.updateToSuccess(options.success, result);
            })
            .catch(error => {
                // Error durumu
                pendingToast.updateToError(options.error, error);
            });

        return pendingToast;
    }
}
