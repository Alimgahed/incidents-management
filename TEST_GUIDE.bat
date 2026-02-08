# Quick Start - Build and Test Commands for Incidents Management App
# This batch file provides quick commands for testing on mobile and web

@echo off
echo ================================
echo Incidents Management App
echo Mobile ^& Web Testing Guide
echo ================================
echo.

echo 📱 MOBILE TESTING
echo ===============
echo.
echo Android Device/Emulator:
echo   flutter run
echo.
echo iOS Simulator/Device:
echo   flutter run -d ios
echo.
echo List connected devices:
echo   flutter devices
echo.

echo 🌐 WEB TESTING
echo ==============
echo.
echo Chrome (default):
echo   flutter run -d chrome
echo.
echo Firefox:
echo   flutter run -d firefox
echo.
echo Edge:
echo   flutter run -d edge
echo.

echo 🔨 BUILD FOR PRODUCTION
echo =======================
echo.
echo Android APK:
echo   flutter build apk
echo.
echo Android App Bundle (Play Store):
echo   flutter build appbundle
echo.
echo iOS Build:
echo   flutter build ios
echo.
echo Web Build (Release):
echo   flutter build web --release
echo.

echo 📊 TESTING RESPONSIVE DESIGN
echo ============================
echo.
echo 1. Test on Multiple Devices:
echo    - Mobile phone (375x667 or similar)
echo    - Tablet (600x1024)
echo    - Desktop (1920x1080)
echo.
echo 2. Test Orientations:
echo    - Portrait mode
echo    - Landscape mode
echo.
echo 3. For Web - Use Chrome DevTools:
echo    - Open DevTools (F12)
echo    - Click device toolbar (Ctrl+Shift+M)
echo    - Select different devices to test
echo.

echo 🧹 CLEANING ^& MAINTENANCE
echo =========================
echo.
echo Clean project:
echo   flutter clean
echo.
echo Get dependencies:
echo   flutter pub get
echo.
echo Analyze code:
echo   flutter analyze
echo.

echo 💡 TIPS
echo ======
echo • Press 'w' in terminal while running to open Chrome DevTools
echo • Use '--profile' flag for performance testing: flutter run --profile
echo • Clear cache for web: Ctrl+Shift+Delete in browser
echo • Test with 'flutter run -d chrome --web-port=5000' for custom port
echo.
echo Happy Testing! 🚀
