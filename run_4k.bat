@echo off
setlocal enabledelayedexpansion
title UxPlay AirPlay Receiver - 4K HEVC Launcher
cd /d "%~dp0"

echo ========================================================
echo        UxPlay AirPlay Receiver - Che do 4K (HEVC)
echo ========================================================
echo.

:: 1. Thiet lap Profile 4K HEVC va D3D11 trong Registry
echo [*] Thiet lap cau hinh 4K HEVC 60fps va D3D11...
reg add "HKCU\Software\leapbtw\uxplay-windows" /v "stream_profile" /t REG_SZ /d "hevc4k" /f >nul 2>&1
reg add "HKCU\Software\leapbtw\uxplay-windows" /v "renderer_mode" /t REG_SZ /d "d3d11" /f >nul 2>&1
reg add "HKCU\Software\leapbtw\uxplay-windows" /v "ble_enabled" /t REG_SZ /d "true" /f >nul 2>&1

:: 2. Them MSYS2 UCRT64 vao PATH neu co
if exist "C:\msys64\ucrt64\bin" (
    set "PATH=C:\msys64\ucrt64\bin;%PATH%"
)
if exist "D:\msys64\ucrt64\bin" (
    set "PATH=D:\msys64\ucrt64\bin;%PATH%"
)

:: 3. Tim file uxplay-windows.exe
set "TARGET_EXE="
if exist "%~dp0build\uxplay-windows.exe" (
    set "TARGET_EXE=%~dp0build\uxplay-windows.exe"
) else if exist "%~dp0uxplay-windows.exe" (
    set "TARGET_EXE=%~dp0uxplay-windows.exe"
) else if exist "%~dp0release\uxplay-windows.exe" (
    set "TARGET_EXE=%~dp0release\uxplay-windows.exe"
)

if "%TARGET_EXE%"=="" (
    echo [LOI] Khong tim thay file uxplay-windows.exe!
    echo Vui long kiem tra folder build\ hoac release\.
    echo.
    pause
    exit /b 1
)

:: 4. Kiem tra Bonjour Service
sc query "Bonjour Service" 2>nul | find "RUNNING" >nul 2>&1
if errorlevel 1 (
    echo [CANH BAO] "Bonjour Service" chua khoi chay!
    echo Neu thiet bi Apple khong tim thay may tinh, hay cai dat Apple Bonjour.
    echo.
) else (
    echo [OK] Bonjour Service dang hoat dong.
)

:: 5. Khoi chay ung dung
echo [*] Dang khoi chay: %TARGET_EXE%
echo [*] Da ap dung profile 4K: HEVC 3840x2160@60fps - D3D11
echo.
start "" "%TARGET_EXE%"
echo [HOAN TAT] Ung dung da khoi chay duoi System Tray (Khay he thong).
ping 127.0.0.1 -n 3 >nul 2>&1
exit /b 0
