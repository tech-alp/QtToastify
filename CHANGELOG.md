# Changelog

All notable changes to QtToastify are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-08-27

### Added

- WebAssembly playground builds and GitHub Pages live-demo deployment.
- Responsive Merce-based playground with real toast previews, compact layout,
  Promise/QFuture scenarios, and runtime interaction probes.
- Tag-driven GitHub Releases with a FetchContent consumer verification step.

### Changed

- `BUILD_PLAYGROUND` now defaults to `OFF`, keeping the QtToastify library on
  its Qt 6.10 baseline while the optional playground uses Qt 6.11.
- Playground behavior switches now use a wider Merce track for clearer state
  recognition.
- Segmented playground selectors now use checkable Merce buttons with
  exclusive button groups.
- The optional playground now requires CMake 3.30 and fetches Merce with
  `EXCLUDE_FROM_ALL`, so only linked Merce targets participate in QtToastify
  builds and installs.
- Project integration documentation now uses an exact QtToastify release tag
  through CMake FetchContent.

### Fixed

- The playground now activates the Merce `ops` profile before constructing QML
  controls, preventing SpinBox indicator geometry from retaining `cart` sizes.
- Runtime probes now reject clipped SpinBox values in the behavior panel.
- Segmented selectors now render selection through Merce's checked state and
  retain their active tab stop during focus transfer, preventing stale colors
  and the `activeFocusOnTab` runtime warning.
- Custom playground selectors now transfer keyboard focus before changing their
  selected tab stop, and the overflow menu supports Tab navigation and Escape.
- Keyboard navigation now scrolls clipped playground configuration controls
  into view in wide and compact layouts.
- Compact-layout actions now scroll the live preview into view so their result
  is immediately visible.
- The message editor now releases Tab focus, and runtime probes verify the full
  form focus order across responsive layouts.
- The playground can clear every active notification and restores its empty
  preview state after the final toast closes.
- The compact live preview now fits the available scroll viewport at the
  minimum supported window size.
- Empty or whitespace-only messages now show inline validation and disable the
  primary Show Toast action.
- Header, Advanced, and overflow actions now meet the playground's 40 px
  minimum interaction-target contract.
- Playground startup now exits with an explicit error when root QML creation
  fails instead of leaving a blank window.
- CI now runs every test whose name starts with `Playground`, including minimum
  window and large-font action probes.
- Static WebAssembly builds now link the `QtQuick.VectorImage` and helper QML
  plugins used by `svgtoqml`-generated icon components.
- WebAssembly packaging now fails before deployment when a required static QML
  plugin is missing from the binary.
- The WebAssembly page now declares its existing Qt logo as the browser favicon.

### Removed

- The singleton-based `ToastifyStyle` API.
- The legacy `theme` option.
- The qrc-based showcase flow.
- Bundled playground fonts and their unused loader.

## [1.0.0]

### Added

- Initial release.
- Four built-in style providers.
- Six toast positions.
- Four toast types.
- Custom style provider support.
- Playground application.
- Unit tests.
