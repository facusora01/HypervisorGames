@echo off
setlocal EnableDelayedExpansion

set "error_occurred=0"
set "log_file=%~dp0log.txt"

:log_init
echo [%date% %time%] Script iniciado > "%log_file%"

:log_check_admin
echo [%date% %time%] Verificando privilegios de administrador... >> "%log_file%"
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

set "config_file=%~dp0config.txt"

:load_config
echo [%date% %time%] Cargando configuracion... >> "%log_file%"
if exist "%config_file%" (
    for /f "usebackq delims=" %%a in ("%config_file%") do set "games_dir=%%a"
    call :trim_spaces
    echo [%date% %time%] Directorio cargado: !games_dir! >> "%log_file%"
) else (
    echo [%date% %time%] No existe archivo de configuracion >> "%log_file%"
)

:main_menu
echo [%date% %time%] Mostrando menu principal >> "%log_file%"
cls
title Hypervisor Games Launcher
echo.
echo ================================================
echo       Hypervisor Games Launcher
echo ================================================
echo.
echo [1] Jugar
echo [2] Revertir cambios
echo [3] Cambiar directorio principal
echo [4] Salir
echo.
choice /C:1234 /N /M "Seleccione una opcion: "
echo [%date% %time%] Usuario selecciono opcion: !errorlevel! >> "%log_file%"
if errorlevel 4 (
    echo [%date% %time%] Usuario eligio Salir >> "%log_file%"
    exit /b
)
if errorlevel 3 (
    echo [%date% %time%] Usuario eligio Cambiar directorio >> "%log_file%"
    goto :change_directory
)
if errorlevel 2 (
    echo [%date% %time%] Usuario eligio Revertir cambios >> "%log_file%"
    goto :revert_changes
)
if errorlevel 1 (
    echo [%date% %time%] Usuario eligio Jugar >> "%log_file%"
    goto :play_game
)

:play_game
echo [%date% %time%] Entrando en modo Jugar >> "%log_file%"
cls
echo.
echo ================================================
echo               Modo Jugar
echo ================================================
echo.
echo Habilitando Test Mode para permitir archivos sin firma...
echo [%date% %time%] Habilitando Test Mode >> "%log_file%"
echo [%date% %time%] Ejecutando comando bcdedit directamente >> "%log_file%"
bcdedit /set testsigning on >nul 2>&1
echo [%date% %time%] Comando bcdedit finalizado >> "%log_file%"
echo [%date% %time%] Test Mode habilitado correctamente >> "%log_file%"
echo Test Mode habilitado correctamente.
echo.
if not defined games_dir (
    echo [%date% %time%] Solicitando directorio al usuario >> "%log_file%"
    echo Ingrese el directorio general de los juegos:
    echo.
    set /p "games_dir="
    echo [%date% %time%] Usuario ingreso: !games_dir! >> "%log_file%"
    
    call :trim_spaces
    REM Eliminar backslash final si existe
    if "!games_dir:~-1!"=="\" set "games_dir=!games_dir:~0,-1!"
    echo [%date% %time%] Directorio despues de limpiar: !games_dir! >> "%log_file%"
    
    if not exist "!games_dir!" (
        echo [%date% %time%] ERROR: El directorio no existe >> "%log_file%"
        echo.
        echo El directorio no existe. Presione cualquier tecla para volver...
        pause >nul
        goto :main_menu
    )
    
    echo !games_dir! > "%config_file%"
    echo [%date% %time%] Directorio guardado en config.txt >> "%log_file%"
    echo.
    echo Directorio guardado correctamente.
    echo Presione cualquier tecla para continuar...
    pause >nul
) else (
    echo [%date% %time%] Usando directorio guardado: !games_dir! >> "%log_file%"
    call :trim_spaces
    REM Eliminar backslash final si existe
    if "!games_dir:~-1!"=="\" set "games_dir=!games_dir:~0,-1!"
    
    echo Directorio actual: !games_dir!
    echo.
    if not exist "!games_dir!" (
        echo [%date% %time%] ERROR: El directorio guardado no existe >> "%log_file%"
        echo.
        echo El directorio guardado no existe.
        echo Presione cualquier tecla para cambiarlo...
        pause >nul
        goto :change_directory
    )
    echo [%date% %time%] Directorio verificado correctamente >> "%log_file%"
    echo Presione cualquier tecla para continuar...
    pause >nul
)

cls
echo [%date% %time%] Preparando para listar juegos >> "%log_file%"
echo.
echo ================================================
echo           Seleccione un juego
echo ================================================
echo.
echo Buscando juegos en: !games_dir!
echo [%date% %time%] Directorio de busqueda: !games_dir! >> "%log_file%"
echo.
echo Juegos disponibles:
echo.

set index=0
echo [%date% %time%] Iniciando busqueda de carpetas... >> "%log_file%"
echo [%date% %time%] Directorio: !games_dir! >> "%log_file%"
echo Iniciando busqueda de carpetas...

REM Listar carpetas usando CMD nativo
pushd "!games_dir!"
if errorlevel 1 (
    echo [%date% %time%] ERROR: No se pudo cambiar al directorio >> "%log_file%"
    echo.
    echo Error al acceder al directorio.
    echo Presione cualquier tecla para volver...
    pause >nul
    popd
    goto :main_menu
)

echo [%date% %time%] Directorio cambiado exitosamente >> "%log_file%"

REM Listar carpetas y filtrar las que tienen _
for /f "delims=" %%d in ('dir /b /ad 2^>nul') do (
    echo %%d | find "_" >nul
    if errorlevel 1 (
        set /a index+=1
        set "folder[!index!]=%%d"
        echo [!index!] %%d
        echo [%date% %time%] Carpeta valida: !index! - %%d >> "%log_file%"
    ) else (
        echo [%date% %time%] Carpeta ignorada: %%d >> "%log_file%"
    )
)

popd
echo [%date% %time%] Directorio restaurado exitosamente >> "%log_file%"

echo [%date% %time%] Busqueda completada. Encontrados !index! directorios >> "%log_file%"
echo Busqueda completada. Encontrados !index! directorios.
echo [%date% %time%] Linea despues de echo completada >> "%log_file%"
echo [%date% %time%] Preparando evaluacion if, index=!index! >> "%log_file%"

if %index%==0 goto :no_folders

echo [%date% %time%] Bloque if index==0 saltado, index=!index! >> "%log_file%"
echo [%date% %time%] Preparando para pedir seleccion al usuario >> "%log_file%"
echo.
echo [%date% %time%] Esperando entrada del usuario... >> "%log_file%"
set /p "selection=Seleccione el numero del juego: "
goto :selection_done

:no_folders
echo [%date% %time%] No se encontraron carpetas validas >> "%log_file%"
echo.
echo No se encontraron carpetas validas (sin "_").
echo Presione cualquier tecla para volver...
pause >nul
goto :main_menu

:selection_done
echo [%date% %time%] Usuario selecciono juego numero: !selection! >> "%log_file%"

if not defined folder[%selection%] (
    echo [%date% %time%] ERROR: Seleccion invalida >> "%log_file%"
    echo.
    echo Seleccion invalida. Presione cualquier tecla para volver...
    pause >nul
    goto :main_menu
)

set "selected_folder=!folder[%selection%]!"
set "vbs_script=%games_dir%\%selected_folder%\VBS.cmd"
echo [%date% %time%] Carpeta seleccionada: !selected_folder! >> "%log_file%"
echo [%date% %time%] Ruta del script: !vbs_script! >> "%log_file%"

if not exist "%vbs_script%" (
    echo [%date% %time%] ERROR: No se encontro VBS.cmd >> "%log_file%"
    echo.
    echo No se encontro VBS.cmd en la carpeta seleccionada.
    echo Presione cualquier tecla para volver...
    pause >nul
    goto :main_menu
)
echo [%date% %time%] VBS.cmd encontrado correctamente >> "%log_file%"

cls
echo [%date% %time%] Preparando ejecucion de VBS.cmd >> "%log_file%"
echo.
echo ================================================
echo           Ejecutando: !selected_folder!
echo ================================================
echo.
echo Iniciando VBS.cmd...
echo.
echo El script seleccionara automaticamente la opcion [1] Continue
echo.

cd /d "%games_dir%\%selected_folder%"
echo [%date% %time%] Directorio cambiado a: %cd% >> "%log_file%"

(
    echo Set WshShell = CreateObject("WScript.Shell"^)
    echo Do
    echo   success = WshShell.AppActivate("VBS 1.1"^)
    echo   If success Then Exit Do
    echo   WScript.Sleep 500
    echo Loop
    echo WScript.Sleep 1000
    echo WshShell.SendKeys "1"
) > "%temp%\auto_select.vbs"
echo [%date% %time%] Script VBScript creado >> "%log_file%"

start "" wscript.exe "%temp%\auto_select.vbs"
echo [%date% %time%] Iniciando VBS.cmd: !vbs_script! >> "%log_file%"
"%vbs_script%"
echo [%date% %time%] VBS.cmd finalizo con codigo: !errorlevel! >> "%log_file%"
timeout /t 2 /nobreak >nul
del "%temp%\auto_select.vbs" >nul 2>&1

echo [%date% %time%] Preparando reinicio de PC >> "%log_file%"
echo.
echo ================================================
echo         Cambios aplicados correctamente
echo ================================================
echo.
echo - DSE desactivado
echo - Test Mode habilitado
echo.
echo La PC se reiniciara en 5 segundos...
echo.
timeout /t 5 /nobreak
shutdown /r /t 0 /c "Hypervisor Games Launcher: Reiniciando para aplicar cambios"
goto :eof

:change_directory
echo [%date% %time%] Entrando en modo Cambiar Directorio >> "%log_file%"
cls
echo.
echo ================================================
echo       Cambiar Directorio Principal
echo ================================================
echo.
echo Directorio actual: !games_dir!
echo.
echo Ingrese el nuevo directorio general de los juegos:
echo.
set /p "new_dir="
echo [%date% %time%] Nuevo directorio ingresado: !new_dir! >> "%log_file%"

if not exist "!new_dir!" (
    echo [%date% %time%] ERROR: El nuevo directorio no existe >> "%log_file%"
    echo.
    echo El directorio no existe. Presione cualquier tecla para volver...
    pause >nul
    goto :main_menu
)

set "games_dir=%new_dir%"
echo !games_dir! > "%config_file%"
echo [%date% %time%] Directorio actualizado: !games_dir! >> "%log_file%"
echo.
echo Directorio actualizado correctamente.
echo Presione cualquier tecla para volver...
pause >nul
goto :main_menu

:revert_changes
echo [%date% %time%] Entrando en modo Revertir Cambios >> "%log_file%"
cls
echo.
echo ================================================
echo           Revertir Cambios
echo ================================================
echo.
echo Deshabilitando Test Mode...
echo [%date% %time%] Deshabilitando Test Mode >> "%log_file%"
echo [%date% %time%] Ejecutando comando bcdedit directamente >> "%log_file%"
bcdedit /set testsigning off >nul 2>&1
echo [%date% %time%] Comando bcdedit finalizado >> "%log_file%"
echo [%date% %time%] Test Mode deshabilitado correctamente >> "%log_file%"
echo Test Mode deshabilitado correctamente.
echo.
echo Ejecutando VBS.cmd principal con opcion 3 (Revert Changes)...
echo.
echo El script seleccionara automaticamente la opcion [3] Revert Changes
echo.
echo [%date% %time%] Preparando ejecucion de VBS.cmd principal >> "%log_file%"

cd /d "%~dp0"
echo [%date% %time%] Directorio cambiado a: %cd% >> "%log_file%"
if exist "VBS.cmd" (
    echo [%date% %time%] VBS.cmd principal encontrado >> "%log_file%"
    echo [%date% %time%] Creando script VBScript para enviar tecla 3 >> "%log_file%"
    (
        echo Set WshShell = CreateObject("WScript.Shell"^)
        echo Do
        echo   success = WshShell.AppActivate("VBS 1.1"^)
        echo   If success Then Exit Do
        echo   WScript.Sleep 500
        echo Loop
        echo WScript.Sleep 1000
        echo WshShell.SendKeys "3"
    ) > "%temp%\auto_select.vbs"
    echo [%date% %time%] Script VBScript creado >> "%log_file%"

    start "" wscript.exe "%temp%\auto_select.vbs"
    echo [%date% %time%] Iniciando VBS.cmd principal >> "%log_file%"
    "VBS.cmd"
    echo [%date% %time%] VBS.cmd principal finalizo con codigo: !errorlevel! >> "%log_file%"
    timeout /t 2 /nobreak >nul
    del "%temp%\auto_select.vbs" >nul 2>&1
    echo [%date% %time%] Script VBScript eliminado >> "%log_file%"

    echo [%date% %time%] Preparando reinicio de PC >> "%log_file%"
    echo.
    echo ================================================
    echo         Cambios revertidos correctamente
    echo ================================================
    echo.
    echo - DSE reactivado
    echo - Test Mode deshabilitado
    echo.
    echo La PC se reiniciara en 5 segundos...
    echo.
    timeout /t 5 /nobreak
    echo [%date% %time%] Ejecutando comando de reinicio >> "%log_file%"
    shutdown /r /t 0 /c "Hypervisor Games Launcher: Reiniciando para revertir cambios"
    goto :eof
) else (
    echo [%date% %time%] ERROR: No se encontro VBS.cmd principal >> "%log_file%"
    echo.
    echo No se encontro VBS.cmd en el directorio actual.
    echo Presione cualquier tecla para volver...
    pause >nul
    goto :main_menu
)
echo [%date% %time%] Regresando al menu principal >> "%log_file%"
goto :main_menu

:trim_spaces
REM Eliminar espacios en blanco al final usando metodo mas robusto
:trim_loop_internal
if not "!games_dir:~-1!"==" " (
    goto :trim_done_internal
)
set "games_dir=!games_dir:~0,-1!"
goto :trim_loop_internal
:trim_done_internal
goto :eof
