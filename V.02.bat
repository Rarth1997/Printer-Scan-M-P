@echo off
setlocal enabledelayedexpansion

:: Verificação de administrador
>nul 2>&1 net session || (
    echo ##############################################
    echo #  ERRO: Execute como Administrador!         #
    echo ##############################################
    timeout /t 10
    exit /b
)



:MAIN_MENU
cls
echo ====================================
echo    INSTALADOR DE DRIVERS - MENU     =
echo ====================================
echo [1] Drivers Samsung/HP
echo [2] Drivers Epson
echo [3] Drivers Canon
echo [4] Drivers Xerox
echo [5] Drivers Ricoh
echo [6] MPS/Printway
echo [7] Rastrear Impressoras
echo [8] Adicionar Impressora Por TCP/IP
echo [9] Drivers Termicas 
echo [0] Sair
echo ====================================
set /p choice=Selecione a opcao: 

if "%choice%"=="1" goto Samsung/HP_MENU
if "%choice%"=="2" goto EPSON_MENU
if "%choice%"=="3" goto CANON_MENU
if "%choice%"=="4" goto XEROX_MENU
if "%choice%"=="5" goto RICOH_MENU
if "%choice%"=="6" goto MPS_PRINTWAY_MENU
if "%choice%"=="7" goto PRINTER_TRACKER_MENU
if "%choice%"=="8" goto ADICIONA_IMPRESSORA_POR_TCP_IP_MENU
if "%choice%"=="9" goto TERMICAS_MENU
if "%choice%"=="0" exit /b
goto MAIN_MENU

:Samsung/HP_MENU
cls
echo ====================================
echo      MENU DRIVERS Samsung/HP       =
echo ====================================
echo [0] Voltar ao menu principal
echo [1] Instalar pacote Samsung/HP432_Full
echo [2] Instalar pacote HP_428
echo [3] Instalar pacote HP_4103
echo [4] Instalar apenas Creator
echo [5] Instalar apenas Manager
echo [6] Instalar Printway/MPS
echo ====================================
set /p choice=Digite o numero da opcao desejada: 

if "%choice%"=="0" goto MAIN_MENU
if "%choice%"=="1" goto INSTALL_SAMSUNG_FULL
if "%choice%"=="2" goto Install_HP_428
if "%choice%"=="3" goto INSTALL_HP_4103
if "%choice%"=="4" goto INSTALL_CREATOR
if "%choice%"=="5" goto INSTALL_MANAGER
if "%choice%"=="6" goto INSTALL_PRINTWAY

goto Samsung/HP_MENU

:INSTALL_SAMSUNG_FULL
cls
echo Instalando pacote COMPLETO Samsung/HP432...
echo -------------------------------------

call :INSTALL_ITEM "Driver Universal" "https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M3370FD/SamsungUniversalPrintDriver3_V3.00.16.0101.01.exe" "Samsung_Driver.exe"
call :INSTALL_ITEM "EPM Manager" "https://ftp.hp.com/pub/softlib/software13/printers/SS/Common_SW/WIN_EPM_V2.00.01.36.exe" "EPM_Manager.exe"
call :INSTALL_ITEM "EDC Creator" "https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M5270LX/WIN_EDC_V2.02.61.exe" "EDC_Creator.exe"


echo -------------------------------------
echo Instalacao completa!
pause
goto Samsung/HP_MENU

:Install_HP_428
cls
echo Instalando Driver e Scan
echo -------------------------
call :INSTALL_ITEM "Driver" "https://ftp.hp.com/pub/softlib/software13/printers/LJ/M428-M429/V4_DriveronlyWebpack-48.6.4638-LJM428-M429_V4_DriveronlyWebpack.exe" "428_driver.exe"
call :INSTALL_ITEM "Scan" "https://ftp.hp.com/pub/softlib/software13/printers/SJ0001/MFPs/Full_Webpack-63.5.6303-SJ0001_Full_Webpack.exe" "428_scan.exe"
rundll32 printui.dll,PrintUIEntry /il
echo nao tem desculpa agora !

echo -------------
echo instalacao completa!
pause
goto Samsung/HP_MENU

:INSTALL_HP_4103
cls
echo Instalando Driver e Scan
echo ------------------------
call :INSTALL_ITEM "Driver" "https://ftp.hp.com/pub/softlib/software13/printers/LJ4101-4104/V4_DriveronlyWebpack-54.5.5369-LJ4101-4104_V4_DriveronlyWebpack.exe" "4103_driver.exe"
call :INSTALL_ITEM "Scan" "https://ftp.hp.com/pub/softlib/software13/printers/SJ0001/MFPs/Full_Webpack-63.5.6303-SJ0001_Full_Webpack.exe" "4103_scan.exe"
rundll32 printui.dll,PrintUIEntry /il
echo nao tem desculpa agora !

echo --------------
echo Instalacao completa !
pause
goto Samsung/HP_MENU


:INSTALL_CREATOR
cls
echo Instalando Creator...
echo --------------------
call :INSTALL_ITEM "EDC Creator" "https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M5270LX/WIN_EDC_V2.02.61.exe" "EDC_Creator.exe"
pause
goto Samsung/HP_MENU

:INSTALL_MANAGER
cls
echo Instalando Manager...
echo --------------------
call :INSTALL_ITEM "EPM Manager" "https://ftp.hp.com/pub/softlib/software13/printers/SS/Common_SW/WIN_EPM_V2.00.01.36.exe" "EPM_Manager.exe"
pause
goto Samsung/HP_MENU

:INSTALL_PRINTWAY
cls
echo Instalando Printway/MPS...
echo -------------------------
call :INSTALL_ITEM "DocMPS Agent" "https://update.docmps.com.br/NewDocMpsAgentSetup.exe" "DocMPS_Agent.exe"

:: Abrir navegador após instalação
    echo Abrindo portal MPS no navegador...
    start "" "https://mps.doc360.com.br/login/"
    echo ERRO: Falha ao baixar !mps_desc!
    echo URL: !mps_url!

:: SOLUÇÃO DEFINITIVA PARA O PRINTWAY
set "printway_url=https://help.printwayy.com/wp-content/uploads/utilitarios/Setup%%20PrintWayy.exe"
set "printway_file=PrintWayy_Setup.exe"
set "printway_temp=%TEMP%\%printway_file%"

echo.
echo [Instalando PrintWayy]
echo URL: %printway_url%

:: Método alternativo usando certutil
echo Baixando PrintWayy...
certutil -urlcache -split -f "%printway_url%" "%printway_temp%"

if exist "%printway_temp%" (
    echo Instalando...
    start /wait "" "%printway_temp%" /quiet /norestart
    del /f /q "%printway_temp%" >nul 2>&1
    echo PrintWayy instalado com sucesso!
) else (
    echo ERRO: Falha ao baixar PrintWayy
    echo Tentando método alternativo...

    :: Método de fallback usando PowerShell
    powershell -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('%printway_url%','%printway_temp%');exit 0}catch{exit 1}"
    
    if errorlevel 1 (
        echo ERRO CRITICO: Nao foi possivel baixar o PrintWayy
        echo Por favor, baixe manualmente de:
        echo %printway_url%
    ) else (
        echo Instalando...
        start /wait "" "%printway_temp%" /quiet /norestart
        del /f /q "%printway_temp%" >nul 2>&1
        echo PrintWayy instalado com sucesso!
    )
)
     echo Abrindo portal Printway no navegador...
    start "" "https://app.printwayy.com/Account/Login?ReturnUrl=/"
    echo ERRO: Falha ao baixar !printway_desc!
    echo URL: !printway_url!
echo -------------------------
echo Instalacao concluida!
pause
goto Samsung/HP_MENU


goto :EOF

:: ========== MENUS E FUNÇÕES PARA OUTRAS MARCAS ==========

:EPSON_MENU
cls
echo ====================================
echo      MENU DRIVERS EPSON             =
echo ====================================
echo [0] Voltar ao menu principal
echo [1] WF-C5810
echo [2] WF-C5790                 
echo [3] WF-C5710
echo [4] WF-3720
echo [5] L6270
echo [6] L6191
echo [7] L5590
echo [8] L3250/L3251
echo [9] L3150
echo [10] L805
echo [11] Document Capture Pro

echo ====================================
set /p choice=Digite o numero da opcao desejada: 

if "%choice%"=="0" goto MAIN_MENU
if "%choice%"=="1" call :INSTALL_EPSON "WF-L5810" "https://ftp.epson.com/latin/drivers/inkjet/WFC5810_STD_X64_30002_LA.exe" "5810_driver.exe" "https://ftp.epson.com/drivers/WFC5810_C5890_EScan2_67810_AM.exe" "5810_scan.exe"
if "%choice%"=="2"  call :INSTALL_EPSON "WF-C5790" "https://ftp.epson.com/drivers/WFC5790_STD_X64_26301_2_AM.exe" "Epson_WFC5790_driver.exe" "https://ftp.epson.com/drivers/WFC5710_C5790_EScan2_65310_AM.exe" "Epson_5790_scan.exe"
if "%choice%"=="3"  call :INSTALL_EPSON "WF-C5710" "https://ftp.epson.com/drivers/WFC5710_X64_26301_AM.exe" "Epson_L5710_driver.exe" "https://ftp.epson.com/drivers/WFC5710_C5790_EScan2_65310_AM.exe" "Epson_5710_scan.exe"
if "%choice%"=="4"  call :INSTALL_EPSON "WF-3720" "https://ftp.epson.com/drivers/WF3720_X64_266_NA.exe" "Epson_L3720_driver.exe" "https://ftp.epson.com/drivers/epson18528.exe" "Epson_L3720_scan.exe" 
if "%choice%"=="5"  call :INSTALL_EPSON "L6270" "https://ftp.epson.com/latin/drivers/inkjet/L6270_X64_38000_LA.exe" "Epson_L6270_driver.exe" "https://ftp.epson.com/latin/drivers/inkjet/L6270_EScan2_67810_LA.exe" "Epson_L6270_scan.exe"
if "%choice%"=="6"  call :INSTALL_EPSON "L6191" "https://ftp.epson.com/latin/drivers/inkjet/L6191_X64_26802_LA.exe" "Epson_6191_driver.exe" "https://ftp.epson.com/latin/drivers/inkjet/L6191_EScan2_65230_LA.exe" "Epson_L6191_scan.exe"
if "%choice%"=="7"  call :INSTALL_EPSON "L5590" "https://ftp.epson.com/latin/drivers/inkjet/L5590_X64_303_LA.exe" "Epson_L5590_driver.exe" "https://ftp.epson.com/latin/drivers/inkjet/L5590_EScan2_67810_LA.exe" "Epson_L5590_scan.exe"
if "%choice%"=="8"  call :INSTALL_EPSON "L3250/L3251" "https://ftp.epson.com/latin/drivers/inkjet/L3250_L3251_Lite_LA.exe" "Epson_L3250_Full.exe" 
if "%choice%"=="9"  call :INSTALL_EPSON "L3150" "https://ftp.epson.com/latin/drivers/inkjet/L3150_Lite_LA.exe" "Epson_L3150_full.exe"
if "%choice%"=="10" call NSTALL_EPSON "L805" "https://ftp.epson.com/latin/drivers/Impresoras/L805/L805_Win_Lite_1.0APS_FD.exe" "Epson_L805_Full.exe" 
if "%choice%"=="11" call :INSTALL_EPSON "Document Capture Pro" "https://ftp.epson.com/drivers/DCP_3318.exe" "DCP.exe"
goto EPSON_MENU


:INSTALL_EPSON
set "epson_desc=%~1"
set "epson_url=%~2"
set "epson_file=%~3"
set "epson_url2=%~4"
set "epson_file2=%~5"
set "epson_temp=%TEMP%\!epson_file!"
set "epson_temp2=%TEMP%\!epson_file2!"

echo.
echo =================================
echo Instalando !epson_desc!
echo =================================
echo URL: !epson_url!

:: Tenta primeiro com CertUtil
echo Baixando driver...
certutil -urlcache -split -f "!epson_url!" "!epson_temp!" >nul 2>&1

if not exist "!epson_temp!" (
    :: Fallback para PowerShell
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!epson_url!','!epson_temp!');exit 0}catch{exit 1}"
)

if exist "!epson_temp!" (
    echo Instalando...
    start /wait "" "!epson_temp!" /silent /norestart
    if errorlevel 1 (
        echo AVISO: !epson_desc! instalado com codigo de erro !errorlevel!
    ) else (
        echo !epson_desc! instalado com sucesso!
    )
    del /f /q "!epson_temp!" >nul 2>&1
) else (
    echo ERRO: Falha ao baixar !epson_desc!
    echo Por favor, baixe manualmente de:
    echo !epson_url!
)
:: Baixar e instalar segundo arquivo
echo Baixando utilitario de scan...
certutil -urlcache -split -f "!epson_url2!" "!epson_temp2!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!epson_url2!','!epson_temp2!');exit 0}catch{exit 1}"
)

if exist "!epson_temp2!" (
    echo Instalando utilitario de scan...
    start /wait "" "!epson_temp2!" /silent
    del /f /q "!epson_temp2!" >nul 2>&1
    echo !epson_desc! instalado com sucesso!
) else (
    echo AVISO: Falha ao baixar utilitario de scan
)
echo.
pause
goto :EOF


:CANON_MENU
cls
echo ====================================
echo      MENU DRIVERS CANON             =
echo ====================================
echo [0] Voltar ao menu principal
echo [1] 527 (Generic Plus PCL6 v3.20)
echo [2] 1643 Versao 1
echo [3] 1643 Versao 2
echo [4] 6030
echo ====================================
set /p choice=Digite o numero da opcao desejada: 

if "%choice%"=="0" goto MAIN_MENU
if "%choice%"=="1" call :INSTALL_CANON_527 "Canon 527" "https://gdlp01.c-wss.com/gds/5/0100012385/05/GPlus_UFRII_Driver_V320_32_64_00.exe" "Canon_527.zip"
if "%choice%"=="2" call :INSTALL_CANON_1643_V1 "Canon 1643 Versao 1" "https://gdlp01.c-wss.com/gds/0/0100010410/03/iR1643MFDriverv6502W64.exe" "Canon_1643v1_driver.exe" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe" "Canon_1643v1_scan.exe"
if "%choice%"=="3" call :INSTALL_CANON_1643_V2 "Canon 1643 Versao 2" "https://gdlp01.c-wss.com/gds/0/0100012270/07/GPlus_UFRII_Driver_V320_W64_00.exe" "Canon_1643v2_driver.exe" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe" "Canon_1643v2_scan.exe"
if "%choice%"=="4" call :INSTALL_CANON_6030 "Canon 6030" "https://gdlp01.c-wss.com/gds/9/0100010579/03/LBP6030_V2113_WP_EN.exe" "Canon_6030.exe"
goto CANON_MENU

:INSTALL_CANON_527
set "canon_desc=%~1"
set "canon_url=%~2"
set "canon_file=%~3"
set "canon_temp=%TEMP%\!canon_file!"
set "extract_path=%USERPROFILE%\Downloads\Canon_527_Driver"
set "download_path=%USERPROFILE%\Downloads\!canon_file!"

echo.
echo =================================
echo Preparando !canon_desc!
echo =================================
echo URL: !canon_url!

:: Baixar arquivo
echo Baixando driver...
certutil -urlcache -split -f "!canon_url!" "!canon_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!canon_url!','!canon_temp!');exit 0}catch{exit 1}"
)


if exist "!canon_temp!" (
    :: Mover para Downloads antes de extrair
    if exist "!download_path!" del /f /q "!download_path!"
    move /y "!canon_temp!" "!download_path!" >nul 2>&1
    
    echo Extraindo arquivos...
    if exist "!extract_path!" rd /s /q "!extract_path!"
    powershell -nologo -command "Expand-Archive -Path '!download_path!' -DestinationPath '!extract_path!' -Force"
    
    echo.
    echo ATENCAO: Para o modelo 527, abra a pasta abaixo
    echo e execute o SETUP.EXE manualmente:
    echo.
    echo !extract_path!
    echo.
    explorer "!extract_path!"
   rundll32 printui.dll,PrintUIEntry /il 
   echo nao tem desculpa agora !
    pause
) else (
    echo ERRO: Falha ao baixar !canon_desc!
    echo URL: !canon_url!
)

goto :EOF

:INSTALL_CANON_1643_V1

echo Instalando Driver e Scan
echo ----------------

call :INSTALL_ITEM "1643_V1_driver" "https://gdlp01.c-wss.com/gds/0/0100010410/03/iR1643MFDriverv6502W64.exe" "Driver.exe"
call :INSTALL_ITEM "1643_V1_scan" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe" "Scan.exe"


goto:EOF

:INSTALL_CANON_1643_V2

echo Instalando Driver e Scan
echo ----------------------

call :INSTALL_ITEM "1643_V2_driver" "https://gdlp01.c-wss.com/gds/8/0100011188/01/iR1643iIIMFDriverV720W64.exe" "Driver.exe"
call :INSTALL_ITEM "1643_v2_scan" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe" "Scan.exe"


goto:EOF

:INSTALL_CANON_6030
set "canon_desc=%~1"
set "canon_url=%~2"
set "canon_file=%~3"
set "canon_temp=%TEMP%\!canon_file!"
set "download_path=%USERPROFILE%\Downloads\!canon_file!"

echo.
echo =================================
echo Preparando !canon_desc!
echo =================================
echo URL: !canon_url!

:: Baixar arquivo
echo Baixando driver...
certutil -urlcache -split -f "!canon_url!" "!canon_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!canon_url!','!canon_temp!');exit 0}catch{exit 1}"
)

if exist "!canon_temp!" (
    echo Movendo para Downloads...
    if exist "!download_path!" del /f /q "!download_path!"
    move /y "!canon_temp!" "!download_path!" >nul 2>&1
    
    echo.
    echo ATENCAO: Para o modelo 6030, execute o instalador
    echo manualmente a partir do arquivo baixado:
    echo.
    echo !download_path!
    echo.
    explorer /select,"!download_path!"
    pause
) else (
    echo ERRO: Falha ao baixar !canon_desc!
    echo URL: !canon_url!
)


goto :EOF


:XEROX_MENU
cls
echo ====================================
echo      MENU DRIVERS XEROX             =
echo ====================================
echo [0] Voltar ao menu principal
echo [1] B205
echo [2] B210
echo [3] 3020
echo [4] 3345/3335 (Driver + Scan)
echo ====================================
set /p choice=Digite o numero da opcao desejada: 

if "%choice%"=="0" goto MAIN_MENU
if "%choice%"=="1" call :INSTALL_XEROX "Xerox B205" "https://download.support.xerox.com/pub/drivers/B205/drivers/win10/ar/Xerox_B205_Windows_Print_Drivers_Utilities_V1.12.exe" "Xerox_B205.exe"
if "%choice%"=="2" call :INSTALL_XEROX "Xerox B210" "https://download.support.xerox.com/pub/drivers/B210/drivers/win10/ar/Xerox_B210_Windows_Print_Drivers_Utilities_V1.12.exe" "Xerox_B210.exe"
if "%choice%"=="3" call :INSTALL_XEROX "Xerox 3020" "https://download.support.xerox.com/pub/drivers/3020/drivers/win10/ar/Xerox_Phaser_3020_Windows_Print_Drivers_Utilities_V1.07.exe" "Xerox_3020.exe"
if "%choice%"=="4" call :INSTALL_XEROX_3345
goto XEROX_MENU

:INSTALL_XEROX
set "xerox_desc=%~1"
set "xerox_url=%~2"
set "xerox_file=%~3"
set "xerox_temp=%TEMP%\!xerox_file!"

echo.
echo =================================
echo Instalando !xerox_desc!
echo =================================
echo URL: !xerox_url!

:: Baixar driver
echo Baixando driver...
certutil -urlcache -split -f "!xerox_url!" "!xerox_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!xerox_url!','!xerox_temp!');exit 0}catch{exit 1}"
)

if exist "!xerox_temp!" (
    echo Instalando...
    start /wait "" "!xerox_temp!" /quiet /norestart
    if errorlevel 1 (
        echo AVISO: !xerox_desc! instalado com codigo de erro !errorlevel!
    ) else (
        echo !xerox_desc! instalado com sucesso!
    )
    del /f /q "!xerox_temp!" >nul 2>&1
) else (
    echo ERRO: Falha ao baixar !xerox_desc!
    echo URL: !xerox_url!
)
echo.
pause
goto :EOF

:INSTALL_XEROX_3345
set "xerox_desc=Xerox 3345/3335"
set "scan_url=https://download.support.xerox.com/pub/drivers/3330/drivers/win10/ar/3330_6.0.11.1389_ScanInstall.exe"
set "driver_url=https://download.support.xerox.com/pub/drivers/3330/drivers/win10x64/ar/XeroxPhaser3330_WC3335_3345_7.158.0.0_PCL6_x64.zip"
set "download_folder=%USERPROFILE%\Downloads\Xerox_3345_3335"
set "scan_file=Xerox_3345_Scan.exe"
set "driver_zip=Xerox_3345_Driver.zip"

echo.
echo =================================
echo Instalando !xerox_desc! (Driver + Scan)
echo =================================

:: Criar pasta de destino
if not exist "!download_folder!" (
    mkdir "!download_folder!"
)

:: 1. Baixar e instalar utilitário de scan
echo Baixando utilitario de scan...
set "scan_temp=%TEMP%\!scan_file!"
certutil -urlcache -split -f "!scan_url!" "!scan_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!scan_url!','!scan_temp!');exit 0}catch{exit 1}"
)

if exist "!scan_temp!" (
    echo Instalando utilitario de scan...
    start /wait "" "!scan_temp!" /quiet
    move /y "!scan_temp!" "!download_folder!\" >nul 2>&1
    echo Utilitario de scan instalado!
) else (
    echo ERRO: Falha ao baixar utilitario de scan
)

:: 2. Baixar e extrair driver
echo Baixando driver principal...
set "driver_temp=%TEMP%\!driver_zip!"
certutil -urlcache -split -f "!driver_url!" "!driver_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!driver_url!','!driver_temp!');exit 0}catch{exit 1}"
)

if exist "!driver_temp!" (
    echo Extraindo driver para Downloads...
    powershell -nologo -command "Expand-Archive -Path '!driver_temp!' -DestinationPath '!download_folder!' -Force"
    del /f /q "!driver_temp!" >nul 2>&1
    echo Driver extraido em: !download_folder!
) else (
    echo ERRO: Falha ao baixar driver principal
)

:: Abrir pasta com os arquivos
echo.
echo Instalacao concluida! Arquivos disponiveis em:
echo !download_folder!
explorer "!download_folder!"
rundll32 printui.dll,PrintUIEntry /il
echo nao tem desculpa agora !
pause
goto :EOF

:RICOH_MENU
cls
echo ====================================
echo      MENU DRIVERS RICOH             =
echo ====================================
echo [0] Voltar ao menu principal
echo [1] SP 3710
echo [2] SP 377
echo ====================================
set /p choice=Digite o numero da opcao desejada: 

if "%choice%"=="0" goto MAIN_MENU
if "%choice%"=="1" call :INSTALL_RICOH "Ricoh SP 3710" "https://support.ricoh.com/bb/pub_e/dr_ut_e/0001333/0001333436/V108/z97664L15.exe" "Ricoh_SP3710.exe"
if "%choice%"=="2" call :INSTALL_RICOH "Ricoh SP 377" "https://support.ricoh.com/bb/pub_e/dr_ut_e/0001333/0001333430/V127/r97661L15.exe" "Ricoh_SP377.exe"
goto RICOH_MENU

:INSTALL_RICOH
set "ricoh_desc=%~1"
set "ricoh_url=%~2"
set "ricoh_file=%~3"
set "ricoh_temp=%TEMP%\!ricoh_file!"

echo.
echo =================================
echo Instalando !ricoh_desc!
echo =================================
echo URL: !ricoh_url!

:: Baixar driver
echo Baixando driver...
certutil -urlcache -split -f "!ricoh_url!" "!ricoh_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!ricoh_url!','!ricoh_temp!');exit 0}catch{exit 1}"
)

if exist "!ricoh_temp!" (
    echo Instalando...
    start /wait "" "!ricoh_temp!" /S
    if errorlevel 1 (
        echo AVISO: !ricoh_desc! instalado com codigo de erro !errorlevel!
    ) else (
        echo !ricoh_desc! instalado com sucesso!
    )
    del /f /q "!ricoh_temp!" >nul 2>&1
) else (
    echo ERRO: Falha ao baixar !ricoh_desc!
    echo URL: !ricoh_url!
)
echo.
pause
goto :EOF

:MPS_PRINTWAY_MENU
cls
echo ====================================
echo      MENU MPS/PRINTWAY              =
echo ====================================
echo [0] Voltar ao menu principal
echo [1] DocMPS Agent
echo [2] PrintWayy
echo ====================================
set /p choice=Digite o numero da opcao desejada: 

if "%choice%"=="0" goto MAIN_MENU
if "%choice%"=="1" call :INSTALL_MPS "DocMPS Agent" "https://update.docmps.com.br/NewDocMpsAgentSetup.exe" "DocMPS_Agent.exe"
if "%choice%"=="2" call :INSTALL_PRINTWAY "PrintWayy" "https://help.printwayy.com/wp-content/uploads/utilitarios/Setup PrintWayy.exe" "PrintWayy.exe"
goto MPS_PRINTWAY_MENU

:INSTALL_MPS
set "mps_desc=%~1"
set "mps_url=%~2"
set "mps_file=%~3"
set "mps_temp=%TEMP%\!mps_file!"

echo.
echo =================================
echo Instalando !mps_desc!
echo =================================
echo URL: !mps_url!

:: Baixar e instalar
echo Baixando...
certutil -urlcache -split -f "!mps_url!" "!mps_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!mps_url!','!mps_temp!');exit 0}catch{exit 1}"
)

if exist "!mps_temp!" (
    echo Instalando...
    start /wait "" "!mps_temp!" /S
    if errorlevel 1 (
        echo AVISO: !mps_desc! instalado com codigo de erro !errorlevel!
    ) else (
        echo !mps_desc! instalado com sucesso!
    )
    del /f /q "!mps_temp!" >nul 2>&1
    
    :: Abrir navegador após instalação
    echo Abrindo portal MPS no navegador...
    start "" "https://mps.doc360.com.br/login/"
) else (
    echo ERRO: Falha ao baixar !mps_desc!
    echo URL: !mps_url!
)
echo.
pause
goto :EOF

:INSTALL_PRINTWAY
set "printway_desc=%~1"
set "printway_url=%~2"
set "printway_file=%~3"
set "printway_temp=%TEMP%\!printway_file!"

echo.
echo =================================
echo Instalando !printway_desc!
echo =================================
echo URL: !printway_url!

:: Substituir espaços na URL
set "printway_url=!printway_url: =%%20!"

:: Baixar
echo Baixando...
certutil -urlcache -split -f "!printway_url!" "!printway_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!printway_url!','!printway_temp!');exit 0}catch{exit 1}"
)

if exist "!printway_temp!" (
    echo Instalando...
    start /wait "" "!printway_temp!" /quiet /norestart
    del /f /q "!printway_temp!" >nul 2>&1
    echo !printway_desc! instalado com sucesso!
    
    :: Abrir navegador após instalação
    echo Abrindo portal PrintWayy no navegador...
    start "" "https://app.printwayy.com/Account/Login?ReturnUrl=/"    
) else (
    echo ERRO: Falha ao baixar !printway_desc!
    echo URL: !printway_url!
)
:: ====================================
::     FUNÇÃO DE RASTREAMENTO DE IMPRESSORAS
:: ====================================
:PRINTER_TRACKER_MENU
cls

:: Verificação de dependências SNMP
where snmpwalk >nul 2>&1
if errorlevel 1 (
    echo SNMP Toolkit nao instalado. Deseja instalar? (s/n)
    set /p install_snmp=
    if /i "!install_snmp!"=="s" (
        echo Instalando SNMP Toolkit...
        winget install Microsoft.SNMP.Toolkit
    )
)

echo ====================================
echo      RASTREADOR DE IMPRESSORAS       =
echo ====================================
echo [1] Escanear rede por impressoras
echo [2] Testar impressora especifica
echo [0] Voltar ao menu principal
echo ====================================
set /p choice=Digite o numero da opcao: 

if "%choice%"=="1" goto SCAN_NETWORK
if "%choice%"=="2" goto TEST_PRINTER
if "%choice%"=="0" goto MAIN_MENU
goto PRINTER_TRACKER_MENU

:SCAN_NETWORK
cls
echo ====================================
echo      ESCANEAMENTO DE REDE           =
echo ====================================
echo Este processo pode demorar alguns minutos
echo.
set /p network_ip=Digite o IP da rede (ex: 192.168.1): 
set /p start_ip=IP inicial (ex: 1): 
set /p end_ip=IP final (ex: 254): 

echo.
echo Iniciando escaneamento...
echo Impressoras encontradas:
echo ------------------------

set printer_count=0
for /l %%i in (%start_ip%,1,%end_ip%) do (
    set ip=%network_ip%.%%i
    call :CHECK_PRINTER "!ip!"
)

echo ------------------------
echo Total de impressoras encontradas: %printer_count%
pause
goto PRINTER_TRACKER_MENU

:TEST_PRINTER
cls
echo ====================================
echo      TESTE DE IMPRESSORA            =
echo ====================================
set /p printer_ip=Digite o IP da impressora: 

echo.
echo Testando impressora em !printer_ip!...
call :CHECK_PRINTER "!printer_ip!"
pause
goto PRINTER_TRACKER_MENU

:CHECK_PRINTER
setlocal
set ip=%~1
set found=0

echo.
echo =================================
echo Testando !ip!...
echo =================================

:: 1. Teste de ping básico
ping -n 1 -w 500 !ip! >nul
if errorlevel 1 (
    echo Status: Offline
    goto :END_CHECK
)

:: 2. Teste de portas de impressão
echo - Portas abertas:
call :TEST_PORT !ip! 9100 "Raw"
call :TEST_PORT !ip! 515 "LPR"
call :TEST_PORT !ip! 631 "IPP"

:: 3. Teste SNMP (se snmpwalk estiver disponível)
where snmpwalk >nul 2>&1
if not errorlevel 1 (
    echo - Teste SNMP:
    snmpwalk -v2c -c public !ip! .1.3.6.1.2.1.25.3.2.1.3.1 >nul
    if not errorlevel 1 (
        echo   SNMP: OK (Respondeu)
        set found=1
    ) else (
        echo   SNMP: Falha ou sem suporte
    )
)

:: 4. Teste via WS-Discovery (WSD)
echo - Teste WSD:
powershell -nologo -command "$ip='!ip!'; $result = Test-NetConnection -ComputerName $ip -Port 3702; if ($result.TcpTestSucceeded) { Write-Host '   WSD: OK (Porta 3702 aberta)' } else { Write-Host '   WSD: Nao respondeu' }"

:: 5. Tentar resolver nome DNS
echo - Resolucao DNS:
nslookup !ip! 2>nul | find /i "Name:"
if errorlevel 1 echo   Nao foi possivel resolver nome

:: 6. Incrementar contador se encontrada
if !found!==1 (
    set /a printer_count+=1
    echo.
    echo !ip! - IMPRESSORA DETECTADA!
)

:END_CHECK
endlocal
goto :EOF

:TEST_PORT
set ip=%~1
set port=%~2
set name=%~3

powershell -nologo -command "$ip='%ip%'; $port=%port%; $result = Test-NetConnection -ComputerName $ip -Port $port -WarningAction SilentlyContinue; if ($result.TcpTestSucceeded) { Write-Host '   Porta %port% (%name%): ABERTA' }"
goto :EOF

goto ADICIONA_IMPRESSORA_POR_TCP_IP_MENU

:ADICIONA_IMPRESSORA_POR_TCP_IP_MENU
cls
echo ====================================
echo      MENU ADICIONAR IMPRESSORA             =
echo ====================================
echo [0] Voltar ao menu principal
echo [1] Adicionar Impressora Por TCP/IP

echo ====================================
set /p choice=Digite o numero da opcao desejada: 

if "%choice%"=="1" Adicionar Impressora Por TCP/IP
if "%choice%"=="0" goto MAIN_MENU

:Adicionar Impressora Por TCP/IP 
cls 
rundll32 printui.dll,PrintUIEntry /il
echo nao tem desculpa agora !
echo.
echo Instalacao concluida!

goto ADICIONA_IMPRESSORA_POR_TCP_IP_MENU
pause
goto :EOF

:TERMICAS_MENU
cls
echo ====================================
echo      MENU DRIVERS TERMICAS         =
echo ====================================
echo [0] Voltar ao menu principal
echo [1] Instalar TM20X-LAN
echo [2] Instalar TM20_USB
echo [3] Instalar BERMATECH-4200TH (LAN/USB)
echo [4] Instalar TP80K-L (LAN/USB)
echo ====================================
set /p choice=Digite o numero da opcao desejada: 

if "%choice%"=="0" goto MAIN_MENU
if "%choice%"=="1" call :INSTALL_TM20X_LAN "TM20X_LAN" "https://ftp.epson.com/latin/drivers/pos/APD_601_T20X_WM.zip" "termicas_T20x-Lan.zip"
if "%choice%"=="2" call :INSTALL_TM20_USB 
if "%choice%"=="3" call :INSTALL_BERMATECH-4200TH "BERMATECH_4200TH" "https://www.bztech.com.br/arquivos/driver-bematech-mp-4200.zip" "Bermatech.zip"
if "%choice%"=="4" call :INSTALL_TP80K-L 
goto TERMICAS_MENU

:INSTALL_TM20X_LAN
set "termicas_desc=%~1"
set "termicas_url=%~2"
set "termicas_file=%~3"
set "termicas_temp=%TEMP%\!termicas_file!"
set "extract_path=%USERPROFILE%\Downloads\termicas_T20x-lan_Driver"
set "download_path=%USERPROFILE%\Downloads\!termicas_file!"

echo.
echo =================================
echo Preparando !canon_desc!
echo =================================
echo URL: !termicas_url!

:: Baixar arquivo
echo Baixando driver...
certutil -urlcache -split -f "!termicas_url!" "!termicas_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!termicas_url!','!termicas_temp!');exit 0}catch{exit 1}"
)

if exist "!termicas_temp!" (
    :: Mover para Downloads antes de extrair
    if exist "!download_path!" del /f /q "!download_path!"
    move /y "!termicas_temp!" "!download_path!" >nul 2>&1
    
    echo Extraindo arquivos...
    if exist "!extract_path!" rd /s /q "!extract_path!"
    powershell -nologo -command "Expand-Archive -Path '!download_path!' -DestinationPath '!extract_path!' -Force"
    
    echo.
    echo ATENCAO: Para o modelo TM20x-LAN, abra a pasta abaixo
    echo e execute o SETUP.EXE manualmente:
    echo.
    echo !extract_path!
    echo.
    explorer "!extract_path!"
    pause
) else (
    echo ERRO: Falha ao baixar !canon_desc!
    echo URL: !termicas_url!
)

pause
goto :EOF


:INSTALL_TM20_USB
set "TM20_USB_desc=TM20"
set "scan_url=https://ftp.epson.com/drivers/pos/TMUSB800d.exe"
set "driver_url=https://ftp.epson.com/latin/drivers/pos/APD_601_T20X_WM.zip"
set "download_folder=%USERPROFILE%\Downloads\TM20_USB"
set "scan_file=TM20_USB.exe"
set "driver_zip=TM20_USB.zip"

echo.
echo =================================
echo      TM20-USB
echo =================================

:: Criar pasta de destino
if not exist "!download_folder!" (
    mkdir "!download_folder!"
)

:: 1. Baixar e instalar utilitário de scan
echo Baixando utilitario de scan...
set "scan_temp=%TEMP%\!scan_file!"
certutil -urlcache -split -f "!scan_url!" "!scan_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!scan_url!','!scan_temp!');exit 0}catch{exit 1}"
)

if exist "!scan_temp!" (
    echo Instalando utilitario de scan...
    start /wait "" "!scan_temp!" /quiet
    move /y "!scan_temp!" "!download_folder!\" >nul 2>&1
    echo Utilitario de scan instalado!
) else (
    echo ERRO: Falha ao baixar utilitario de scan
)

:: 2. Baixar e extrair driver
echo Baixando driver principal...
set "driver_temp=%TEMP%\!driver_zip!"
certutil -urlcache -split -f "!driver_url!" "!driver_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!driver_url!','!driver_temp!');exit 0}catch{exit 1}"
)

if exist "!driver_temp!" (
    echo Extraindo driver para Downloads...
    powershell -nologo -command "Expand-Archive -Path '!driver_temp!' -DestinationPath '!download_folder!' -Force"
    del /f /q "!driver_temp!" >nul 2>&1
    echo Driver extraido em: !download_folder!
) else (
    echo ERRO: Falha ao baixar driver principal
)

:: Abrir pasta com os arquivos
echo.
echo Instalacao concluida! Arquivos disponiveis em:
echo !download_folder!
explorer "!download_folder!"

pause
goto :EOF
goto TERMICAS_MENU

:INSTALL_BERMATECH-4200TH
set "termicas_desc=%~1"
set "termicas_url=%~2"
set "termicas_file=%~3"
set "termicas_temp=%TEMP%\!termicas_file!"
set "extract_path=%USERPROFILE%\Downloads\termicas_BERMATECH-4200TH_Driver"
set "download_path=%USERPROFILE%\Downloads\!termicas_file!"

echo.
echo =================================
echo Preparando !canon_desc!
echo =================================
echo URL: !termicas_url!

:: Baixar arquivo
echo Baixando driver...
certutil -urlcache -split -f "!termicas_url!" "!termicas_temp!" >nul 2>&1 || (
    powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!termicas_url!','!termicas_temp!');exit 0}catch{exit 1}"
)

if exist "!termicas_temp!" (
    :: Mover para Downloads antes de extrair
    if exist "!download_path!" del /f /q "!download_path!"
    move /y "!termicas_temp!" "!download_path!" >nul 2>&1
    
    echo Extraindo arquivos...
    if exist "!extract_path!" rd /s /q "!extract_path!"
    powershell -nologo -command "Expand-Archive -Path '!download_path!' -DestinationPath '!extract_path!' -Force"
    
    echo.
    echo ATENCAO: Para o modelo BERMATECH-4200TH, abra a pasta abaixo
    echo e execute o SETUP.EXE manualmente:
    echo.
    echo !extract_path!
    echo.
    explorer "!extract_path!"
    pause
) else (
    echo ERRO: Falha ao baixar !canon_desc!
    echo URL: !termicas_url!
)
pause
goto :EOF

:INSTALL_TP80K-L

cls
echo Instalando TP80K-L...
echo --------------------
call :INSTALL_ITEM "TP80K-L" "https://drive.usercontent.google.com/download?id=139qdGk9F5RSJlHadYFsdZhyBRjKej-qS&export=download&authuser=0&confirm=t&uuid=06e0eef9-4f5c-4fb0-8a8f-e51e5f265e24&at=AN8xHoq9K47GSeTxRa62_4TBUUZX:1754161603000" "TP80K-L.exe"
call :INSTALL_ITEM "Eu_tambem" "https://drive.usercontent.google.com/download?id=1lQ9oWi97nIGNtYme43EhbgNpEz13gJ8S&export=download&authuser=0&confirm=t&uuid=70a0d11c-ea0e-4740-adcc-30fb3e80f3ab&at=AN8xHopsCBMuPxxzNubxVskBrgHH:1754161644581" "Eu_tambem.exe"


echo -------------------------
echo Instalacao concluida!

goto :EOF



:INSTALL_ITEM
set "desc=%~1"
set "url=%~2"
set "file=%~3"
set "temp_file=%TEMP%\!file!"

echo.
echo [Instalando !desc!]
echo URL: !url!


:: Download usando PowerShell
powershell -nologo -command "$ErrorActionPreference='Stop';try{(New-Object Net.WebClient).DownloadFile('!url!','!temp_file!');exit 0}catch{exit 1}"

if errorlevel 1 (
    echo ERRO: Falha ao baixar !desc!
    echo Verifique a URL: !url!
    pause
    
)
echo Instalando...
start /wait "" "!temp_file!" /quiet /norestart

if errorlevel 1 (
    echo AVISO: !desc! instalado com codigo de erro !errorlevel!
) else (
    echo !desc! instalado com sucesso!
)

del /f /q "!temp_file!" >nul 2>&1
timeout /t 1 >nul
echo.
pause
goto :EOF

