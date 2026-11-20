@echo off
setlocal
REM Convert every .png in icons\ to a sibling .dmi. Pillow is auto-installed
REM by the Python script if missing.

set SCRIPT_DIR=%~dp0
set SCRIPT_PATH=%SCRIPT_DIR%wall_dmi_cutter.py
set ARGS=--batch

where py >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    py "%SCRIPT_PATH%" %ARGS%
    exit /b %ERRORLEVEL%
)

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    python "%SCRIPT_PATH%" %ARGS%
    exit /b %ERRORLEVEL%
)

echo Python not found. Install Python 3 or add it to PATH.
echo Download: https://www.python.org/downloads/windows/
exit /b 1
