# QtToastify Playground

`PlaygroundApp.qml`, QtToastify'in güncel `ToastifyStyleProvider` tabanlı
stillerini ve toast seçeneklerini tek uygulamada test eder.

## Stiller

Playground doğrudan `Toastify/Style/` altındaki provider'ları kullanır:

- `ToastifyStyleProvider`: varsayılan açık tema
- `DarkStyleProvider`: koyu tema
- `CompactStyleProvider`: dar alanlar için kompakt tema
- `MaterialStyleProvider`: Material tabanlı tema

Stil seçimi, stack davranışı, toast tipi, konum, progress bar ve
auto-close ayarları arayüzden canlı değiştirilebilir.

## Fontlar

Playground, demo provider'larında kullanılan `Montserrat`, `Roboto` ve
`Roboto Condensed` fontlarını `fonts/` dizininden yükler. QtToastify
kütüphanesi uygulama fontlarını yüklemez.

## Build ve Çalıştırma

Komutlar proje kökünden çalıştırılır:

```bash
cmake -S . -B build \
  -DBUILD_PLAYGROUND=ON \
  -DCMAKE_PREFIX_PATH=/path/to/Qt/6.10.x/<kit>
cmake --build build
./build/playground/QtToastifyPlayground
```

## Özel Stil

Uygulama stilleri `ToastifyStyleProvider` tabanından türetilir:

```qml
import QtQuick
import Toastify.Style 1.0

ToastifyStyleProvider {
    backgroundColor: "#ffffff"
    shadow: ({
        blurRadius: 12,
        spread: 1,
        color: "#000000",
        opacity: 0.18,
        horizontalOffset: 0,
        verticalOffset: 4
    })
}
```

Provider'ların tam API'si ve kullanımı ana [README](../README.md#custom-styling)
içinde belgelenir.
