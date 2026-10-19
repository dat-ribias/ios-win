@echo off
setlocal enabledelayedexpansion
title UxPlay AirPlay Receiver Launcher
cd /d "%~dp0"

:: MSYS2 UCRT64 PATH
if exist "C:\msys64\ucrt64\bin" (
    set "PATH=C:\msys64\ucrt64\bin;%PATH%"
)
if exist "D:\msys64\ucrt64\bin" (
    set "PATH=D:\msys64\ucrt64\bin;%PATH%"
)

:: Find target executable
set "TARGET_EXE="
if exist "%~dp0build\uxplay-windows.exe" (
    set "TARGET_EXE=%~dp0build\uxplay-windows.exe"
) else if exist "%~dp0uxplay-windows.exe" (
    set "TARGET_EXE=%~dp0uxplay-windows.exe"
) else if exist "%~dp0release\uxplay-windows.exe" (
    set "TARGET_EXE=%~dp0release\uxplay-windows.exe"
)

if "%TARGET_EXE%"=="" (
    echo [ERROR] uxplay-windows.exe not found!
    pause
    exit /b 1
)

start "" "%TARGET_EXE%"
exit /b 0
