@echo off
setlocal EnableDelayedExpansion

fltmc >nul 2>&1
if errorlevel 1 (
    echo.
    echo This script requires administrator privileges.
    echo.
    echo A UAC prompt will appear. Please click "Yes".
    echo.
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:main_menu
cls
title Hypervisor Games Launcher
echo.
echo ================================================
echo       Hypervisor Games Launcher
echo ================================================
echo.
echo [1] Jugar
echo [2] Revertir cambios
echo [3] Salir
echo.
choice /C:123 /N /M "Seleccione una opcion: "
if errorlevel 3 exit /b
if errorlevel 2 goto :revert_changes
if errorlevel 1 goto :play_game

:play_game
cls
echo.
echo ================================================
echo               Modo Jugar
echo ================================================
echo.
echo Ingrese el directorio general de los juegos:
echo.
set /p "games_dir="

if not exist "%games_dir%\" (
    echo.
    echo El directorio no existe. Presione cualquier tecla para volver...
    pause >nul
    goto :main_menu
)

cls
echo.
echo ================================================
echo           Seleccione un juego
echo ================================================
echo.
echo Juegos disponibles:
echo.

set index=0
for /f "delims=" %%d in ('dir /b /ad "%games_dir%"') do (
    echo %%d | find "_" >nul
    if errorlevel 1 (
        set /a index+=1
        set "folder[!index!]=%%d"
        echo [!index!] %%d
    )
)

if !index!==0 (
    echo.
    echo No se encontraron carpetas validas (sin "_").
    echo Presione cualquier tecla para volver...
    pause >nul
    goto :main_menu
)

echo.
set /p "selection=Seleccione el numero del juego: "

if not defined folder[%selection%] (
    echo.
    echo Seleccion invalida. Presione cualquier tecla para volver...
    pause >nul
    goto :main_menu
)

set "selected_folder=!folder[%selection%]!"
set "vbs_script=%games_dir%\%selected_folder%\VBS.cmd"

if not exist "%vbs_script%" (
    echo.
    echo No se encontro VBS.cmd en la carpeta seleccionada.
    echo Presione cualquier tecla para volver...
    pause >nul
    goto :main_menu
)

cls
echo.
echo ================================================
echo           Ejecutando: %selected_folder%
echo ================================================
echo.
echo Iniciando VBS.cmd...
echo.
echo El script seleccionara automaticamente la opcion [1] Continue
echo.

cd /d "%games_dir%\%selected_folder%"

echo Set WshShell = CreateObject("WScript.Shell") > "%temp%\auto_select.vbs"
echo Do >> "%temp%\auto_select.vbs"
echo   success = WshShell.AppActivate("VBS 1.1") >> "%temp%\auto_select.vbs"
echo   If success Then Exit Do >> "%temp%\auto_select.vbs"
echo   WScript.Sleep 500 >> "%temp%\auto_select.vbs"
echo Loop >> "%temp%\auto_select.vbs"
echo WScript.Sleep 1000 >> "%temp%\auto_select.vbs"
echo WshShell.SendKeys "1" >> "%temp%\auto_select.vbs"

start "" wscript.exe "%temp%\auto_select.vbs"
"%vbs_script%"
timeout /t 2 /nobreak >nul
del "%temp%\auto_select.vbs" >nul 2>&1

:revert_changes
cls
echo.
echo ================================================
echo           Revertir Cambios
echo ================================================
echo.
echo Ejecutando VBS.cmd principal con opcion 3 (Revertir Changes)...
echo.
echo El script seleccionara automaticamente la opcion [3] Revert Changes
echo.

cd /d "%~dp0"
if exist "VBS.cmd" (
    echo Set WshShell = CreateObject("WScript.Shell") > "%temp%\auto_select.vbs"
    echo Do >> "%temp%\auto_select.vbs"
    echo   success = WshShell.AppActivate("VBS 1.1") >> "%temp%\auto_select.vbs"
    echo   If success Then Exit Do >> "%temp%\auto_select.vbs"
    echo   WScript.Sleep 500 >> "%temp%\auto_select.vbs"
    echo Loop >> "%temp%\auto_select.vbs"
    echo WScript.Sleep 1000 >> "%temp%\auto_select.vbs"
    echo WshShell.SendKeys "3" >> "%temp%\auto_select.vbs"

    start "" wscript.exe "%temp%\auto_select.vbs"
    "VBS.cmd"
    timeout /t 2 /nobreak >nul
    del "%temp%\auto_select.vbs" >nul 2>&1
) else (
    echo.
    echo No se encontro VBS.cmd en el directorio actual.
    echo Presione cualquier tecla para volver...
    pause >nul
    goto :main_menu
)
goto :main_menu
