@echo off
set "FLUTTER_ROOT=C:\FlutterSDK"
if not exist "%FLUTTER_ROOT%\bin\flutter.bat" (
    echo Flutter SDK not found at %FLUTTER_ROOT%.
    exit /b 1
)
"%FLUTTER_ROOT%\bin\flutter.bat" %*
exit /b %ERRORLEVEL%
