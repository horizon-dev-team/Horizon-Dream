@echo off
setlocal
REM Build modules_wall\false_walls.dmi from every wall .dmi in modules_wall.
REM Pass --selftest to compare the algorithm with the vanilla icons\turf\walls\false_walls.dmi.

set SCRIPT_PATH=%~dp0false_wall_atlas.py

where py >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    py "%SCRIPT_PATH%" %*
    exit /b %ERRORLEVEL%
)

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    python "%SCRIPT_PATH%" %*
    exit /b %ERRORLEVEL%
)

echo Python not found. Install Python 3 or add it to PATH.
echo Download: https://www.python.org/downloads/windows/
exit /b 1
