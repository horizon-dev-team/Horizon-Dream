@echo off

call "%~dp0..\..\_horizon\tools\sort\sort_dme.bat"
call "%~dp0\..\bootstrap\javascript.bat" "%~dp0\build.ts" %*
