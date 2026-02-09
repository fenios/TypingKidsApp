# Clipart Module

## Purpose
Provides a reusable layer for downloading, decoding, and caching free clipart images used in learning features.

## Responsibilities
- Fetch images from remote URLs using `URLSession`.
- Cache image data in memory and on disk.
- Decode raster images and render SVGs via WebKit.
- Expose a simple async API for views/view models.

## Key Types
- `ClipartImageLoader`, `ClipartImageLoading`
- `DefaultClipartImageCache`, `DiskImageStore`
- `ClipartImageFormat`, `ClipartImageError`
- `SVGRenderer`

## Dependencies
- WebKit
