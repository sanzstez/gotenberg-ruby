# Changelog

## 1.1.0 - 2026-07-12

### Added

- ViteRuby helpers.
- A development/test Vite manifest.
- Network idle controls.
- Native Gotenberg PDF metadata support.

### Changed

- PDF metadata is sent through Gotenberg's `metadata` field.
- The minimum supported Gotenberg version is now 8.3.0.

See [Gotenberg 8.3.0](https://github.com/gotenberg/gotenberg/releases/tag/v8.3.0) and the
[metadata documentation](https://gotenberg.dev/docs/convert-with-chromium/convert-html-to-pdf#metadata-pdf-engines).

### Removed

- The `mini_exiftool` dependency.
- `Gotenberg::Exiftools`.
- The client-side HTML title extractor.
- `Gotenberg::ModifyMetadataError`.
