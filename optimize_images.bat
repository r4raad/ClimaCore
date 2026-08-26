@echo off
echo 🖼️ Image Size Checker for Android Compatibility
echo ================================================

echo.
echo 📊 Checking image sizes in assets/images/...
echo.

for %%f in (assets\images\*.png) do (
    for %%A in ("%%f") do (
        set size=%%~zA
        set /a sizeKB=!size!/1024
        if !sizeKB! gtr 100 (
            echo ⚠️  LARGE: %%~nxf - !sizeKB! KB
        ) else (
            echo ✅ OK: %%~nxf - !sizeKB! KB
        )
    )
)

echo.
echo 📝 Recommendations:
echo 1. Images over 100KB may cause Android crashes
echo 2. Use online tools like TinyPNG.com to compress large images
echo 3. Resize images to max 800x800 pixels
echo 4. Convert PNG to JPEG for better compression
echo.
echo 🎯 Large images to optimize:
echo    - school3.png (631KB)
echo    - school4.png (673KB) 
echo    - logo.png (476KB)
echo    - tree.png (304KB)
echo    - river.png (167KB)
echo    - school2.png (213KB)
echo.
pause
