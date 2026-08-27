# QtToastify Playground Design

## Status

Approved implementation baseline for the desktop and WebAssembly playground.
The playground is a demonstration application; it must not change the public
QtToastify API or raise the library's minimum Qt version.

## Goals

- Provide a focused, production-quality workspace for configuring and testing
  real QtToastify notifications.
- Match the approved two-column mockup: compact configuration on the left,
  dark live preview on the right, and primary actions at the bottom.
- Use Merce for semantic tokens, StyleKit control styling, icons, surfaces, and
  reusable controls instead of recreating a second design system.
- Keep QtToastify usable with Qt 6.10 and C++17 when the playground is disabled.
- Use the same playground target for desktop and GitHub Pages WebAssembly.

## Non-goals

- QtToastify does not depend on Merce.
- The playground does not use `Merce.Notifications`; notifications are rendered
  by the local QtToastify target.
- Playground-specific composites such as the position picker are not promoted
  into Merce.
- The first iteration does not add localization selection, mobile navigation,
  persistence, or a general-purpose Qt Quick Controls style package.

## Platform Contract

- Default window: `1440 x 900`.
- Minimum window: `900 x 700`.
- At `1100 px` and wider, configuration and preview use two columns.
- Below `1100 px`, configuration is placed above preview in one scrollable
  column.
- Input is keyboard and pointer based. Interactive targets are at least `40 px`.
- User-facing text is English and wrapped in `qsTr()`.
- The shell stays light and the preview stays dark. Selecting a Toastify style
  changes only the notifications.

## Visual Contract

### Header

- Compact QtToastify identity, title, short description, `Qt 6 · QML` badge,
  and a GitHub link.
- No oversized hero area or decorative illustration.

### Configuration Panel

The panel is approximately `360 px` wide on a large screen and contains:

1. Toastify style selector: Default, Dark, Compact, Material.
2. Message editor.
3. Toast type selector: Info, Success, Warning, Error.
4. Visual `3 x 2` position picker.
5. Stack mode: Default or Expanded.
6. Auto-close duration and visible-toast count.
7. Close button, close on click, progress bar, and newest-on-top switches.
8. Collapsed Advanced section for spacing and collapsed-stack scale values.

Controls use the Merce `algit/light/ops` context. This is the closest bundled
green developer-tool theme and avoids adding a QtToastify-specific brand to the
general Merce repository.

### Preview Panel

- Dark neutral rounded surface with a `Live Preview` label and viewport badge.
- Hosts the real `Toastify` instance and constrains it to the preview bounds.
- Starts empty. Notifications appear only after a user action.
- Selected Toastify style is passed directly to the real toast stack.
- Resizing the application must not move toast content outside the preview.

### Action Bar

- Visible actions: Show Toast, Test All Types, Long Message.
- Action Toast, Promise success/error, C++ QFuture success/error, and Clear
  Preview remain in an overflow menu.
- Show Toast is the single primary action. Other actions are secondary or
  ghost variants.

## QML Architecture

```text
playground/
├── PlaygroundApp.qml
├── PlaygroundState.qml
├── PlaygroundWorkspace.qml
├── components/
│   ├── ActionBar.qml
│   ├── AppHeader.qml
│   ├── ConfigurationPanel.qml
│   ├── FocusScrollView.qml
│   ├── PositionPicker.qml
│   ├── PreviewPanel.qml
│   ├── SectionCard.qml
│   └── SegmentedControl.qml
├── tests/
│   ├── PlaygroundRuntimeProbe.cpp
│   ├── PlaygroundRuntimeProbe.h
│   └── tst_playground_state.cpp
└── cmake/
    └── ResolveMerce.cmake
```

- `PlaygroundApp.qml` owns the StyleKit application window and installs
  `MerceStyle`.
- `PlaygroundState.qml` owns form values and exposes notification option maps.
- `PlaygroundWorkspace.qml` selects the responsive layout and coordinates
  actions without reaching into panel internals.
- A single `PreviewPanel` instance moves between wide and compact layout slots,
  preserving active toasts and asynchronous work across the `1100 px`
  breakpoint.
- Compact-layout actions scroll the live preview into view so their result is
  immediately visible. Its height adapts to the available scroll viewport so
  the full preview remains visible at the minimum supported window size.
- Panels communicate through explicit properties and signals.
- Runtime probe code is compiled only with `BUILD_TESTS=ON`; production
  `main.cpp` remains a bootstrap file.
- Bootstrap exits with an explicit error when root QML creation fails instead
  of leaving an unresponsive blank window.
- Playground composites use Merce tokens and primitives. Existing StyleKit
  controls are used for text, numeric, toggle, and menu behavior.
- Toastify and Toastify.Style never import a playground or Merce module.

## State and Event Flow

```text
Configuration controls
        ↓ bindings
PlaygroundState
        ↓ action signal
PlaygroundWorkspace
        ↓ option snapshot
PreviewPanel / Toastify
```

- Configuration changes update state declaratively.
- A whitespace-only message exposes inline validation and disables the primary
  Show Toast action until valid input returns.
- An action captures the current values and creates one or more real toasts.
- Promise and QFuture jobs remain owned by the workspace until completion.
- The initial state is deterministic and contains no toast.
- The preview tracks active toast lifetimes so Clear Preview can dismiss all
  notifications and restore the empty state without changing QtToastify API.

## Dependency Boundary

```text
QtToastify library (Qt 6.10+, C++17)

QtToastifyPlayground (Qt 6.11+)
├── local QtToastify targets
└── Merce
    ├── Theme
    ├── Foundation
    ├── Style
    └── Controls
```

- Root CMake only exposes `BUILD_PLAYGROUND`, default `OFF`, and conditionally
  enters `playground/`.
- Merce discovery lives in `playground/cmake/ResolveMerce.cmake`.
- Local development may set `QTTOASTIFY_MERCE_SOURCE_DIR`.
- Remote consumption uses a pinned public Merce release.
- `MERCE_BUILD_NOTIFICATIONS`, `MERCE_BUILD_TESTS`,
  `MERCE_ENABLE_FONTAWESOME`, `MERCE_ENABLE_TOKEN_BUILD`, and
  `BUILD_MERCE_PLAYGROUND` are disabled for this consumer.

## Accessibility and Interaction

- Native controls retain their StyleKit keyboard and accessibility behavior.
- Closing the overflow popover restores focus to its More trigger.
- Segmented selectors use checkable Merce `MButton` instances in exclusive
  `ButtonGroup` objects. Segmented and position controls expose accessible
  names, screen-reader press actions, focus rings, Tab navigation, and
  arrow-key selection.
- Configuration regions use the Merce-styled StyleKit scroll view with a
  visible vertical scrollbar and no horizontal overflow. Keyboard focus moves
  clipped configuration controls into view.
- Focus is visible on both light and dark surfaces.
- Text and semantic status colors meet readable contrast on their surfaces.
- Motion uses Merce duration tokens and does not animate layout-heavy geometry.

## Verification

- Configure and build the library with Qt 6.10 and `BUILD_PLAYGROUND=OFF`.
- Configure and build the playground with Qt 6.11 and local Merce.
- Run QML lint for the playground module.
- Verify startup has no QML warnings and no visible toast.
- Exercise all four types, six positions, both stack modes, toggles, advanced
  values, Promise paths, QFuture paths, and clearing the preview.
- Verify custom selector tab stops and real arrow-key navigation, overflow-menu
  Tab/Escape behavior, full form and Advanced Tab order, automatic focus
  scrolling, compact actions, and a 135% application-font run at the minimum
  window size without startup or layout failures.
- Resize across `1099/1100 px` while a Promise toast is active and verify the
  preview instance and toast state are preserved.
- Capture the `1440 x 900`, `1000 x 800`, and minimum `900 x 700` views and
  compare layout, hierarchy, scrolling, and spacing with the approved mockup.
- Build WebAssembly and verify the deployed page loads the real playground.
