# QtToastify Style Customization Guide

Bu rehber QtToastify'ın stil sistemini nasıl özelleştireceğinizi gösterir.

## ToastifyStyle Yapısı

ToastifyStyle singleton bir QML objesidir ve tüm görsel özellikleri kontrol eder:

```qml
// ToastifyStyle.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    // Renk paleti
    property var colors: ({
        info: "#3498db",
        success: "#07bc0c", 
        warning: "#f1c40f",
        error: "#e74c3c"
    })
    
    // Font ayarları
    property var fonts: ({
        family: "Roboto",
        size: 14,
        weight: Font.Normal
    })
    
    // Spacing konfigürasyonu
    property var spacing: ({
        main: 12,
        content: 12,
        text: 4,
        container: 12,
        closeButton: {
            "padding": 6,
            "size": 24
        }
    })
    
    // Container boyutları
    property var containerSizes: ({
        minimum: 280,
        preferred: 350,
        maximum: 500
    })
}
```

## Özelleştirme Yöntemleri

### 1. Kendi Style Dosyanızı Oluşturun

```qml
// MyCustomStyle.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    // Özel renkler
    property var colors: ({
        info: "#2196F3",      // Material Blue
        success: "#4CAF50",   // Material Green
        warning: "#FF9800",   // Material Orange
        error: "#F44336"      // Material Red
    })
    
    // Büyük fontlar
    property var fonts: ({
        family: "Arial",
        size: 18,
        weight: Font.Bold
    })
    
    // Geniş spacing
    property var spacing: ({
        main: 20,
        content: 20,
        text: 8,
        container: 20,
        closeButton: {
            "padding": 10,
            "size": 32
        }
    })
}
```

### 2. Runtime'da Style Değiştirme

```qml
ApplicationWindow {
    id: window
    
    // Özel style objesi
    property QtObject myStyle: QtObject {
        property var colors: ({
            info: "#FF5722",
            success: "#8BC34A",
            warning: "#FFC107", 
            error: "#E91E63"
        })
    }
    
    Button {
        text: "Custom Toast"
        onClicked: {
            // Toast oluştururken özel değerler kullan
            var toast = toastComponent.createObject(window, {
                message: "Özel stil ile toast!",
                type: Toastify.Info
            })
            
            // Style özelliklerini override et
            toast.accentColor = myStyle.colors.info
            toast.show()
        }
    }
}
```

### 3. Theme-Based Styling

```qml
QtObject {
    id: themeManager
    
    property bool isDarkTheme: false
    
    property var lightTheme: ({
        colors: {
            info: "#E3F2FD",
            success: "#E8F5E8", 
            warning: "#FFF3E0",
            error: "#FFEBEE"
        },
        textColor: "#333333",
        backgroundColor: "#FFFFFF"
    })
    
    property var darkTheme: ({
        colors: {
            info: "#1976D2",
            success: "#388E3C",
            warning: "#F57C00", 
            error: "#D32F2F"
        },
        textColor: "#FFFFFF",
        backgroundColor: "#121212"
    })
    
    readonly property var currentTheme: isDarkTheme ? darkTheme : lightTheme
}
```

## Özelleştirilebilir Özellikler

### Renkler (colors)
- `info`: Bilgi toast'ları için renk
- `success`: Başarı toast'ları için renk
- `warning`: Uyarı toast'ları için renk
- `error`: Hata toast'ları için renk

### Fontlar (fonts)
- `family`: Font ailesi
- `size`: Font boyutu (px)
- `weight`: Font kalınlığı

### Spacing (spacing)
- `main`: Ana layout spacing'i
- `content`: İçerik alanı spacing'i
- `text`: Metin satırları arası spacing
- `container`: Container padding'i
- `closeButton.padding`: Close button padding'i
- `closeButton.size`: Close button toplam boyutu

### Container Boyutları (containerSizes)
- `minimum`: Minimum genişlik
- `preferred`: Tercih edilen genişlik
- `maximum`: Maximum genişlik

### Gölge (shadow)
- `blur`: Bulanıklık miktarı
- `color`: Gölge rengi
- `opacity`: Opaklık
- `horizontalOffset`: Yatay offset
- `verticalOffset`: Dikey offset

### Animasyonlar (animation)
- `enterDuration`: Giriş animasyon süresi
- `exitDuration`: Çıkış animasyon süresi
- `easingType`: Easing tipi
- `pauseDuration`: Duraklama süresi

## Örnek Kullanım Senaryoları

### Mobil Uygulama için Kompakt Stil
```qml
property var mobileStyle: ({
    fonts: { family: "Roboto", size: 12, weight: Font.Medium },
    spacing: { main: 8, content: 8, text: 2, container: 8 },
    containerSizes: { minimum: 200, preferred: 250, maximum: 300 }
})
```

### Desktop Uygulama için Geniş Stil
```qml
property var desktopStyle: ({
    fonts: { family: "Segoe UI", size: 16, weight: Font.Normal },
    spacing: { main: 16, content: 16, text: 6, container: 16 },
    containerSizes: { minimum: 320, preferred: 400, maximum: 600 }
})
```

### Yüksek Kontrast Erişilebilirlik Stili
```qml
property var accessibilityStyle: ({
    colors: {
        info: "#000080",      // Koyu mavi
        success: "#006400",   // Koyu yeşil
        warning: "#FF8C00",   // Koyu turuncu
        error: "#8B0000"      // Koyu kırmızı
    },
    fonts: { family: "Arial", size: 18, weight: Font.Bold },
    shadow: { blur: 0, opacity: 0 }  // Gölge yok
})
```

## Best Practices

1. **Tutarlılık**: Uygulamanız boyunca tutarlı bir stil kullanın
2. **Erişilebilirlik**: Yeterli kontrast oranlarını sağlayın
3. **Platform Uyumu**: Hedef platformun tasarım dilini takip edin
4. **Performance**: Çok karmaşık animasyonlardan kaçının
5. **Test**: Farklı içerik uzunlukları ile test edin

## Debugging

Style sorunlarını debug etmek için:

```qml
Component.onCompleted: {
    console.log("Current style values:")
    console.log("Font size:", ToastifyStyle.fonts.size)
    console.log("Main spacing:", ToastifyStyle.spacing.main)
    console.log("Container sizes:", JSON.stringify(ToastifyStyle.containerSizes))
}
```

Bu rehber ile QtToastify'ı uygulamanızın ihtiyaçlarına göre tamamen özelleştirebilirsiniz!