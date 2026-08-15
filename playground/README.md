# QtToastify Playground Examples

Bu dizin QtToastify'ın farklı stil konfigürasyonları ile nasıl kullanılabileceğini gösteren playground uygulaması içerir.

## Playground Uygulaması

### Tek Target ile Tüm Örnekler
- **Executable**: `QtToastifyPlayground`
- **Ana Dosya**: `PlaygroundApp.qml`
- **Açıklama**: Tüm stil örneklerini tek bir uygulamada radio button'lar ile seçebileceğiniz interaktif playground

### Özellikler
- **4 Farklı Stil**: Default, Custom Dark, Light Theme, Compact
- **Canlı Stil Değiştirme**: Radio button'lar ile anında stil değişimi
- **Toast Konfigürasyonu**: Message, type, position, options ayarları
- **Test Butonları**: 
  - Normal toast gösterimi
  - Uzun mesaj testi
  - Tüm tipleri aynı anda test etme
- **Stil Bilgileri**: Aktif stilin detaylarını görüntüleme

## Mevcut Stiller

### 1. Default Style
- QtToastify'ın varsayılan stil ayarları
- Font: Sistem fontu, 16px
- Container: 280-500px
- Spacing: 12px

### 2. Custom Dark Style  
- Koyu tema, büyük fontlar ve artırılmış spacing
- Font: Montserrat 16px Medium
- Container: 320-600px
- Spacing: 16px
- Gelişmiş gölge efektleri

### 3. Compact Style
- Kompakt layout
- Font: Roboto 12px
- Container: 200-350px

### 4. Material Style
- Material Design 3 stil rehberi
- Font: Roboto 14px Medium
- Container: 288-568px

## Fontlar

Playground, demo stillerinde kullandığı `Montserrat`, `Roboto` ve
`Roboto Condensed` fontlarını `fonts/` dizininden `FontLoader` ile yükler.
Fontlar SIL Open Font License 1.1 ile dağıtılır; lisans metinleri aynı dizindedir.

QtToastify kütüphanesi font dosyası yüklemez veya paketlemez. Uygulamanız özel
bir `fonts.family` adı kullanıyorsa ilgili fontu uygulama katmanında yüklemelidir.
Style provider içinde fontun gerçek family adını yazmak yeterlidir.

## Build ve Çalıştırma

### CMake ile Build
```bash
# Playground'u aktif et
cmake -B build -S . -DBUILD_PLAYGROUND=ON -DCMAKE_INSTALL_PREFIX=/Users/techalp/Qt/6.10.1/macos/lib/cmake

# Build
cmake --build build

# Çalıştır
./build/playground/QtToastifyPlayground
```

### Alternatif Build (Sadece Playground)
```bash
cd playground
cmake -B build -S . 
cmake --build build
./build/QtToastifyPlayground
```

## Kullanım

1. **Stil Seçimi**: Sol üstteki radio button'lar ile istediğiniz stili seçin
2. **Mesaj Ayarlama**: Toast mesajını, tipini ve pozisyonunu ayarlayın  
3. **Seçenekler**: Close on click, progress bar ve auto close ayarlarını yapın
4. **Test**: Farklı butonlar ile toast'ları test edin

## Özelleştirme Rehberi

Yeni stil eklemek için:

1. `styles/` dizininde yeni stil dosyası oluşturun
2. `PlaygroundApp.qml`'de `availableStyles` array'ine ekleyin
3. CMakeLists.txt'de QML_FILES listesine ekleyin

Detaylı özelleştirme rehberi için `StyleCustomizationGuide.md` dosyasına bakın.
