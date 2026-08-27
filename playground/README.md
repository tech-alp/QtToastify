# QtToastify Playground

The playground is a responsive Qt 6.11 application for configuring and testing
real QtToastify notifications. Its application shell uses Merce tokens,
StyleKit controls, and Merce components; the preview still renders the local
QtToastify target.

## Built-in toast styles

The playground uses the providers from `Toastify/Style/` directly:

- `ToastifyStyleProvider`: default light style
- `DarkStyleProvider`: dark style
- `CompactStyleProvider`: compact layout
- `MaterialStyleProvider`: Material-inspired style

Style, type, position, stack behavior, auto-close duration, progress, and
interaction options can be changed at runtime. The shell remains light and the
preview remains dark; selecting a style changes only the toasts. `Clear Preview`
in the overflow menu dismisses every active notification. A blank message shows
inline validation and disables `Show Toast` until valid text is entered.

## Build and run

Run from the repository root with Qt 6.11 or newer:

```bash
cmake -S . -B build \
  -DBUILD_PLAYGROUND=ON \
  -DQTTOASTIFY_MERCE_SOURCE_DIR=/path/to/Merce \
  -DCMAKE_PREFIX_PATH=/path/to/Qt/6.11.x/<kit>
cmake --build build
./build/playground/QtToastifyPlayground
```

When `QTTOASTIFY_MERCE_SOURCE_DIR` is omitted, CMake downloads the pinned public
Merce revision. `Merce.Notifications`, Font Awesome, Merce tests, token tooling,
and the Merce playground are disabled for this consumer.

## Custom toast style

Application styles derive from `ToastifyStyleProvider`:

```qml
import QtQuick
import Toastify.Style

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

The complete provider API is documented in the main
[README](../README.md#custom-styling).
