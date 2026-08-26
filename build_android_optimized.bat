@echo off
echo 🚀 Building Optimized Android APK for Galaxy M14
echo ================================================

echo.
echo 📱 Target Device: Samsung Galaxy M14
echo 📱 RAM: 4GB/6GB
echo 📱 Storage: 64GB/128GB
echo 📱 Processor: Exynos 1330
echo.

echo 🔧 Cleaning previous builds...
flutter clean

echo.
echo 📦 Getting dependencies...
flutter pub get

echo.
echo 🔧 Building optimized APK...
flutter build apk --release --target-platform android-arm64

echo.
echo ✅ Build completed!
echo 📱 APK location: build/app/outputs/flutter-apk/app-release.apk
echo 📏 APK size: 
dir build\app\outputs\flutter-apk\app-release.apk

echo.
echo 🎯 Optimization Summary:
echo - Memory usage optimized for 4GB RAM
echo - Image cache limited to 50MB
echo - ProGuard enabled for code shrinking
echo - Resource shrinking enabled
echo - Performance monitoring active
echo.

echo 🚀 Ready to install on Galaxy M14!
pause
