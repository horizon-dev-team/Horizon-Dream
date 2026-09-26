@echo off

"%~dp0..\..\_horizon\tools\sort_horizon_dme.bat"

"%~dp0\..\bootstrap\javascript.bat" "%~dp0\build.ts" %*
