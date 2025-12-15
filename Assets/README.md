# App Assets

This directory contains application resources:

## App Icon
Place your app icon here as `AppIcon.icns`.

To create an app icon:
1. Design a 1024x1024 PNG image
2. Use Icon Composer or `iconutil` to convert to .icns format:
   ```bash
   mkdir -p AppIcon.iconset
   sips -z 16 16 icon.png --out AppIcon.iconset/icon_16x16.png
   sips -z 32 32 icon.png --out AppIcon.iconset/icon_16x16@2x.png
   sips -z 32 32 icon.png --out AppIcon.iconset/icon_32x32.png
   sips -z 64 64 icon.png --out AppIcon.iconset/icon_32x32@2x.png
   sips -z 128 128 icon.png --out AppIcon.iconset/icon_128x128.png
   sips -z 256 256 icon.png --out AppIcon.iconset/icon_128x128@2x.png
   sips -z 256 256 icon.png --out AppIcon.iconset/icon_256x256.png
   sips -z 512 512 icon.png --out AppIcon.iconset/icon_256x256@2x.png
   sips -z 512 512 icon.png --out AppIcon.iconset/icon_512x512.png
   sips -z 1024 1024 icon.png --out AppIcon.iconset/icon_512x512@2x.png
   iconutil -c icns AppIcon.iconset
   ```

## Other Resources
- `AppIcon.icns` - Application icon
- Additional images or resources can be added here