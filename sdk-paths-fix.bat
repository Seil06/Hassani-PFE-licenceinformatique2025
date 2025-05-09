@echo off
REM Run this script as administrator

REM Create a more standard Android SDK directory structure
mkdir D:\Android\Sdk
mkdir D:\Android\Sdk\platforms
mkdir D:\Android\Sdk\build-tools

REM Copy the necessary files (this is better than symlinks on Windows)
xcopy D:\cmdline-tools\platforms\android-35\* D:\Android\Sdk\platforms\android-35\ /E /I /H
xcopy D:\cmdline-tools\build-tools\34.0.0\* D:\Android\Sdk\build-tools\34.0.0\ /E /I /H

REM Set environment variables for the current session
setx ANDROID_HOME "D:\Android\Sdk"
setx ANDROID_SDK_ROOT "D:\Android\Sdk"
setx PATH "%PATH%;D:\Android\Sdk\platform-tools;D:\Android\Sdk\tools;D:\Android\Sdk\tools\bin"

echo Android SDK paths have been set up successfully.
echo Please restart your Command Prompt or PowerShell after running this script.
pause