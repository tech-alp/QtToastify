# Changelog

All notable changes to QtToastify are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- WebAssembly playground builds and GitHub Pages live-demo deployment.

### Fixed

- Static WebAssembly builds now link the `QtQuick.VectorImage` and helper QML
  plugins used by `svgtoqml`-generated icon components.
- WebAssembly packaging now fails before deployment when a required static QML
  plugin is missing from the binary.

### Removed

- The singleton-based `ToastifyStyle` API.
- The legacy `theme` option.
- The qrc-based showcase flow.

## [1.0.0]

### Added

- Initial release.
- Four built-in style providers.
- Six toast positions.
- Four toast types.
- Custom style provider support.
- Playground application.
- Unit tests.
