@echo off
title Ferramenta Avançada - Impressoras e SMB
color 0E
setlocal enabledelayedexpansion

:: Verifica se é Administrador (opcional, mas recomendado)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ATENÇÃO: Execute como Administrador para melhores resultados.
    echo.
)

:MENU
cls
echo =========================================================================
echo          Era essa Impressora que voce queria ?
echo =========================================================================
echo.
echo   [1] Baixar e Instalar PrintWay
echo   [2] Monocromaticas
echo   [3] Jatos de Tintas
echo   [4] Termicas
echo   [5] Naps2
echo   [6] Advacend IP Scanner
echo   [7] Scanner de Producao
echo   [0] Sair
echo.
set /p opcao="Digite a opcao: "

if "%opcao%"=="1" (
    echo Aguarde, baixando PrintWay...
    where curl >nul 2>nul
    if errorlevel 1 (
        bitsadmin /transfer PrintWayDownload /download /priority high "https://help.printwayy.com/wp-content/uploads/utilitarios/Setup%%20PrintWayy.exe" "%CD%\SetupPrintWayy.exe"
    ) else (
        curl -L -# -o "SetupPrintWayy.exe" "https://help.printwayy.com/wp-content/uploads/utilitarios/Setup%%20PrintWayy.exe"
    )
    if exist "SetupPrintWayy.exe" (
        echo Download OK! Iniciando...
        start "" "SetupPrintWayy.exe"
    )
    start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" "https://app.printwayy.com/Account/Login?ReturnUrl=/"
    pause
    goto MENU
)
if "%opcao%"=="2" goto MONO
if "%opcao%"=="3" goto TINTAS 
if "%opcao%"=="4" goto TERMICAS  
if "%opcao%"=="5" (
    echo Aguarde, baixando NAPS2...
    where curl >nul 2>nul
    if errorlevel 1 (
        bitsadmin /transfer NAPS2Download /download /priority high "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe" "%CD%\naps2-8.2.1-win-x64.exe"
    ) else (
        curl -L -# -o "naps2-8.2.1-win-x64.exe" "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe"
    )
    if exist "naps2-8.2.1-win-x64.exe" (
        echo Download OK! Iniciando...
        start "" "naps2-8.2.1-win-x64.exe"
    )
    pause
    goto MENU
)
if "%opcao%"=="6" (
    echo Aguarde, baixando Advanced IP Scanner...
    where curl >nul 2>nul
    if errorlevel 1 (
        bitsadmin /transfer AIPScannerDownload /download /priority high "https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe" "%CD%\AIPScannerSetup.exe"
    ) else (
        curl -L -# -o "AIPScannerSetup.exe" "https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe"
    )
    if exist "AIPScannerSetup.exe" (
        echo Download OK! Iniciando...
        start "" "AIPScannerSetup.exe"
    )
    pause
    goto MENU
)
if "%opcao%"=="7" goto SCANNER_PRODUCAO
if "%opcao%"=="0" exit
goto MENU

:MONO
cls
echo =========================================================================
echo                          Monocromaticas
echo =========================================================================
echo.
echo   [1] HP 432
echo   [2] HP 408
echo   [3] HP 4103
echo   [4] HP 428
echo   [5] Samsung 4020/4070/4080
echo   [6] Canon 527
echo   [7] Canon 6030
echo   [8] Canon 1643_IF_v1
echo   [9] Canon 1643_IF_v2
echo   [10] Canon 1643_MF_X_v2
echo   [11] Xerox 3020
echo   [12] Xerox 205
echo   [13] Xerox 210
echo   [14] Xerox 3335
echo   [15] Xerox 3345
echo   [0] Voltar
echo.
set /p opcao_mono="Digite a opcao: "

if "%opcao_mono%"=="1" call :BAIXAR "HP_432" "https://ftp.hp.com/pub/softlib/software13/printers/herbs/LaserMFP432/HP_Laser_MFP_432_Full_Software_and_Drivers_1.09.exe" "HP_432.exe"
if "%opcao_mono%"=="2" call :BAIXAR "HP_408" "https://ftp.hp.com/pub/softlib/software13/printers/herbs/Laser408/HP_Laser_408_Print_Driver_1.07.exe" "HP_408.exe"
if "%opcao_mono%"=="3" call :BAIXAR "HP_4103" "https://ftp.hp.com/pub/softlib/software13/printers/LJ4101-4104/V4_DriveronlyWebpack-54.5.5369-LJ4101-4104_V4_DriveronlyWebpack.exe" "HP_4103.exe" "https://ftp.hp.com/pub/softlib/software13/printers/SJ0001/MFPs/Full_Webpack-63.6.6364-SJ0001_Full_Webpack.exe" "HP_SJ0001.exe"
if "%opcao_mono%"=="4" call :BAIXAR "HP_428" "https://ftp.hp.com/pub/softlib/software13/printers/LJ/M428-M429/V4_DriveronlyWebpack-48.6.4638-LJM428-M429_V4_DriveronlyWebpack.exe" "HP_428.exe" "https://ftp.hp.com/pub/softlib/software13/printers/SJ0001/MFPs/Full_Webpack-63.6.6364-SJ0001_Full_Webpack.exe"  "HP_SJ0001.exe"
if "%opcao_mono%"=="5" call :BAIXAR "Samsung" "https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M3370FD/SamsungUniversalPrintDriver3_V3.00.16.0101.01.exe"  "SamsungDriver.exe" "https://ftp.hp.com/pub/softlib/software13/printers/SS/Common_SW/WIN_EPM_V2.00.01.36.exe" "WIN_EPM_V2.00.01.36.exe" "https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M5270LX/WIN_EDC_V2.02.61.exe" "SamsungEPM.exe" 
if "%opcao_mono%"=="6" call :BAIXAR_E_ABRIR "Canon_527" "https://gdlp01.c-wss.com/gds/0/0100012920/01/GPlus_PCL6_Driver_V340_32_64_00.exe"  "Canon.exe" "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe" "naps2.exe" 
if "%opcao_mono%"=="7" call :BAIXAR_E_ABRIR "Canon_6030" "https://gdlp01.c-wss.com/gds/2/0100010942/01/LBP6030_V2111_WP_PT.exe"  "Canon.exe" 
if "%opcao_mono%"=="8" call :BAIXAR "Canon_1643_v1" "https://gdlp01.c-wss.com/gds/0/0100010410/03/iR1643MFDriverv6502W64.exe" "Canon_1643_v1.exe" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe" "Canon_Utility.exe" 
if "%opcao_mono%"=="9" call :BAIXAR "Canon_1643_v2" "https://gdlp01.c-wss.com/gds/8/0100011188/01/iR1643iIIMFDriverV720W64.exe" "Canon_1643_v2.exe" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe" "Canon_Utility.exe" 
if "%opcao_mono%"=="10" call :BAIXAR "Canon_1643_X_v2" "https://gdlp01.c-wss.com/gds/7/0100011197/01/MF1643iIIMFDriverV720W64.exe" "Canon_1643_X_v2.exe" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv121₀2.exe" "Canon_Utility.exe" 
if "%opcao_mono%"=="11" call :BAIXAR "Xerox_3020" "https://download.support.xerox.com/pub/drivers/3₀₂₀/drivers/win₁₀/ar/Xerox_Phaser_3₀₂₀_Windows_Print_Drivers_Utilities_V₁.₀₇.exe" "Xerox_3₀₂₀.exe"
if "%opcao_mono%"=="12" call :BAIXAR "Xerox_205" "https://download.support.xerox.com/pub/drivers/B₂₀₅/drivers/win₁₀/ar/Xerox_B₂₀₅_Windows_Print_Drivers_Utilities_V₁.₁₂.exe" "Xerox_2₀₅.exe"
if "%opcao_mono%"=="13" call :BAIXAR "Xerox_210" "https://download.support.xerox.com/pub/drivers/B₂₁₀/drivers/win₁₀/ar/Xerox_B₂₁₀_Windows_Print_Drivers_Utilities_V₁.₁₂.exe" "Xerox_2₁₀.exe"
if "%opcao_mono%"=="14" call :BAIXAR_E_ABRIR "Xerox_3335" "https://download.support.xerox.com/pub/drivers/GLOBALPRINTDRIVER/drivers/win10x64/ar/UNIV_5.1076.3.0_PCL6_x64.zip" "Xerox_3335.zip" "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe" "naps2.exe"
if "%opcao_mono%"=="15" call :BAIXAR_E_ABRIR "Xerox_3345" "https://download.support.xerox.com/pub/drivers/GLOBALPRINTDRIVER/drivers/win10x64/ar/UNIV_5.1076.3.0_PCL6_x64.zip" "Xerox_3345.zip" "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe" "naps2.exe"
if "%opcao_mono%"=="0" goto MENU0

goto MONO

:Tintas
cls
echo =========================================================================
echo                        Jatos de Tinta
echo =========================================================================
echo.
echo   [1] Epson L3110
echo   [2] Epson L3150
echo   [3] Epson L3250
echo   [4] Epson L5590 
echo   [5] Epson L6190
echo   [6] Epson L6270
echo   [7] Epson L6490
echo   [8] Epson L805
echo   [9] Epson L655
echo   [10] Epson WF 3720
echo   [11] Epson WF 5899
echo   [12] Epson WF 5710
echo   [13] Epson WF 5790
echo   [14] Epson WF 5810
echo   [15] Epson M1180
echo   [16] Epson M3180
echo   [0] Voltar
echo.
set /p opcao_mono="Digite a opcao: "

if "%opcao_mono%"=="1" call :BAIXAR "Epson L3110" "https://ftp.epson.com/latin/drivers/inkjet/L3110_Lite_LA.exe" "L3110.exe"
if "%opcao_mono%"=="2" call :BAIXAR "Epson L3150" "https://ftp.epson.com/latin/drivers/inkjet/L3150_Lite_LA.exe" "L3150.exe"
if "%opcao_mono%"=="3" call :BAIXAR "Epson L3250" "https://ftp.epson.com/latin/drivers/inkjet/L3250_L3251_Lite_LA.exe" "L3250.exe"
if "%opcao_mono%"=="4" call :BAIXAR "Epson L5590" "https://ftp.epson.com/latin/drivers/inkjet/L5590_X64_380_LA.exe" "L5590.exe" "https://ftp.epson.com/latin/drivers/inkjet/L5590_EScan2_67810_LA.exe"  "L5590_Full.exe"
if "%opcao_mono%"=="5" call :BAIXAR "Epson L6190" "https://ftp.epson.com/latin/drivers/inkjet/L6191_X64_2120_LA.exe"  "L6190.exe" "https://ftp.epson.com/latin/drivers/inkjet/L6191_EScan2_65230_LA.exe" "L6190_Full.exe" 
if "%opcao_mono%"=="6" call :BAIXAR "Epson L6270" "https://ftp.epson.com/latin/drivers/inkjet/L6270_X64_38000_2_LA.exe"  "L6270.exe" "https://ftp.epson.com/latin/drivers/inkjet/L6270_EScan2_67810_LA.exe" "L6270_Full.exe" 
if "%opcao_mono%"=="7" call :BAIXAR "Epson L6490" "https://download.epson-europe.com/pub/download/6743/epson674340eu.exe?ot_preferences=C0004%3A0%2CC0003%3A0%2CC0002%3A0%2CC0001%3A1&adobe_mc=ad8cb437-bcd3-458a-b124-678dc7b661ea"  "driver.exe" "https://download.epson-europe.com/pub/download/6751/epson675134eu.exe?ot_preferences=C0004%3A0%2CC0003%3A0%2CC0002%3A0%2CC0001%3A1&adobe_mc=ad8cb437-bcd3-458a-b124-678dc7b661ea" "Scan.exe" 
if "%opcao_mono%"=="8" call :BAIXAR "Epson L805" "https://ftp.epson.com/latin/drivers/Impresoras/L805/L805_Win_Lite_1.0APS_FD.exe" "L805.exe" 
if "%opcao_mono%"=="9" call :BAIXAR "Epson L655" "https://ftp.epson.com/latin/drivers/inkjet/L655_L656_X64_260_LA.exe" "L656.exe" "https://ftp.epson.com/latin/drivers/Multi/l655/L655_L656_scan_4020_FD.exe" "Scan.exe"
if "%opcao_mono%"=="10" call :BAIXAR "Epson WF 3720" "https://ftp.epson.com/drivers/WF3720_X64_2100_NA.exe" "3720.exe" "https://ftp.epson.com/drivers/epson18528.exe" "Scan.exe"
if "%opcao_mono%"=="11" call :BAIXAR "Epson WF 5899" "https://ftp.epson.com/drivers/WFM5899_PCL6_X64_210000_AM.exe" "5899.exe" "https://ftp.epson.com/drivers/WFM5899_EScan2_67810_AM.exe" "Scan.exe"
if "%opcao_mono%"=="12" call :BAIXAR "Epson WF 5710" "https://ftp.epson.com/drivers/WFC5710_X64_2120_AM.exe" "5710.exe" "https://ftp.epson.com/drivers/WFC5710_C5790_EScan2_65310_AM.exe" "Scan.exe"
if "%opcao_mono%"=="13" call :BAIXAR "Epson WF 5790" "https://ftp.epson.com/drivers/WFC5790_STD_X64_2120_AM.exe" "5790.exe" "https://ftp.epson.com/drivers/WFC5710_C5790_EScan2_65310_AM.exe" "Scan.exe"
if "%opcao_mono%"=="14" call :BAIXAR "Epson WF 5810" "https://ftp.epson.com/latin/drivers/inkjet/WFC5810_STD_X64_380_LA.exe" "5810.exe" "https://ftp.epson.com/drivers/WFC5810_C5890_EScan2_67810_AM.exe" "Scan.exe"
if "%opcao_mono%"=="15" call :BAIXAR "Epson M1180" "https://ftp.epson.com/latin/drivers/inkjet/M1180_Lite_LA.exe" "M1180.exe" 
if "%opcao_mono%"=="16" call :BAIXAR "Epson M3180" "https://download.epson-europe.com/pub/download/6771/epson677145eu.exe?ot_preferences=C0004%3A0%2CC0003%3A0%2CC0002%3A0%2CC0001%3A1&adobe_mc=ad8cb437-bcd3-458a-b124-678dc7b661ea" "M3180.exe" "https://download.epson-europe.com/pub/download/6769/epson676922eu.exe?ot_preferences=C0004%3A0%2CC0003%3A0%2CC0002%3A0%2CC0001%3A1&adobe_mc=ad8cb437-bcd3-458a-b124-678dc7b661ea" "Scan.exe"
if "%opcao_mono%"=="0" goto MENU
goto MONO

:TERMICAS
cls
echo =========================================================================
echo                          Termicas
echo =========================================================================
echo.
echo   [1] Tm20X Lan/USB
echo   [2] Bermatech 
echo   [3] HPRT 
echo   [4] HPRT Ares
echo.
set /p opcao_mono="Digite a opcao: "



if "%opcao_mono%"=="1" (
    call :BAIXAR_E_ABRIR "Epson_Tm20X" ^
        "https://ftp.epson.com/latin/drivers/pos/APD_607R1_T20X_WM.zip" "Tm20X.zip" ^
        "https://ftp.epson.com/drivers/pos/TMUSB800d.exe" "TMVirtualPort.exe"
)
if "%opcao_mono%"=="2" (
    call :BAIXAR_E_ABRIR "Bermatech_4200" "https://baixar.programanex.com.br/extras/impressoras/BEMATECH/BEMA_MP_4200_TH_64.zip" "Bermatech4200.zip"
)
if "%opcao_mono%"=="3" call :BAIXAR_E_ABRIR "HPRT" "https://static.hprt.com/hprt/file/20250515/HPRTUtilityForPOSSetup_V1.2.4.23.zip?e=1777512825&token=IAM-9k7ObqNwa2J4Nzcvl1tLlPo7Rq4hOiyFzGqzZfWp:_tcSog58KjEF6Ov0CN9vtTU3KAI="  "HPRT.zip" "https://static.hprt.com/hprt/file/20250701/HPRT+POS+Printer+Driver+v2.7.4.10.zip?e=1777512814&token=IAM-9k7ObqNwa2J4Nzcvl1tLlPo7Rq4hOiyFzGqzZfWp:2fFSNEtOZIkZtIsHTsWchCcKito=" "HPRT_utili.zip"  
if "%opcao_mono%"=="4" (
    call :BAIXAR_E_ABRIR "HPRT_Ares" ^
        "https://static.hprt.com/hprt/file/20250429/HPRTPrinterUtility-V1.0.0.16.Test01.zip" "HPRTAres_driver.zip" ^
        "https://static.hprt.com/hprt/file/20250427/HPRT-Label-Designer-BT2016_R6_3141_UL.zip?e=1777508684&token=IAM-9k7ObqNwa2J4Nzcvl1tLlPo7Rq4hOiyFzGqzZfWp:KKTtUaMsMfKqRjujxWo6AOp8TgE=" "HPRTAres_designer.zip" ^
        "https://static.hprt.com/hprt/file/20250429/HPRT_Label_Derivative_Printer_Windows_Driver_v2.7.2.2.zip?e=1777513177&token=IAM-9k7ObqNwa2J4Nzcvl1tLlPo7Rq4hOiyFzGqzZfWp:QhGJu8hV4NvBQXlPN9el-S-zmng=" "HPRTAres_utility.zip"
)
if "%opcao_mono%"=="0" goto MENU
goto TERMICAS

:SCANNER_PRODUCAO
cls
echo =========================================================================
echo                        Scanner de Producao
echo =========================================================================
echo.

echo   [1] Epson DR-C240
echo   [2] Brother ADS-4700
echo   [3] Brother ADS-2800
echo   [4] Epson DS-530
echo   [0] Voltar

set /p opcao_mono="Digite a opcao: "


if "%opcao_mono%"=="1" call :BAIXAR "Epson_Scanner_Producao" "https://gdlp01.c-wss.com/gds/9/0100009799/05/DR-C240_Driver_V.1.4.11712.18001SP4_Windows.zip" "Driver.zip" "https://gdlp01.c-wss.com/gds/0/0200006680/07/CaptureOnTouch_Pro_V5.5.1025.1217.zip" "CaptureOnTouch.zip"
if "%opcao_mono%"=="2" call :BAIXAR "Epson_Scanner_Producao" "https://download.brother.com/welcome/dlf106560/Y21F_C2_ULWT_PP-inst-J1.EXE" "ads4700.exe" 
if "%opcao_mono%"=="3" call :BAIXAR "Epson_Scanner_Producao" "https://download.brother.com/welcome/dlf107270/Y15F_C1_ULWT_PP-inst-H1.EXE" "ads2800.exe"
if "%opcao_mono%"=="4" call :BAIXAR "Epson_Scanner_Producao" "https://ftp.epson.com/drivers/DS530_Combo_AM.exe" "epson.exe"
if "%opcao_mono%"=="0" goto MENU

goto SCANNER_PRODUCAO




:BAIXAR
setlocal enabledelayedexpansion
set "nome=%~1"
shift
set "arquivos="
set "urls="
set "count=0"

:: Coleta pares URL|ARQUIVO dos argumentos restantes
:LOOP_ARGS
if "%~1"=="" goto FIM_ARGS
set /a count+=1
set "url[!count!]=%~1"
set "arq[!count!]=%~2"
shift & shift
goto LOOP_ARGS
if exist "!arq[%%i]!" (
    echo OK! Baixado: !arq[%%i]!
    timeout /t 2 /nobreak >nul
)

rem Depois que baixar todos, abrir a pasta
if %%i==%count% (
    explorer "%CD%"
)

:FIM_ARGS
echo.
echo === Baixando: %nome% ===
for /l %%i in (1,1,%count%) do (
    echo [%%i/%count%] !arq[%%i]!
    where curl >nul 2>nul
    if errorlevel 1 (
        bitsadmin /transfer "DL%%i" /download /priority high "!url[%%i]!" "%CD%\!arq[%%i]!" >nul
    ) else (
        curl -L -# -o "!arq[%%i]!" "!url[%%i]!"
    )
    if exist "!arq[%%i]!" (
        echo OK! Iniciando !arq[%%i]!...
        start "" "!arq[%%i]!"
        timeout /t 2 /nobreak >nul
    ) else (
        echo ERRO ao baixar !arq[%%i]!
    )
)
pause
endlocal
goto MENU

:BAIXAR_E_ABRIR
setlocal enabledelayedexpansion
set "pasta_destino=%USERPROFILE%\Downloads\Epson_%1"
shift

REM Criar pasta
if not exist "%pasta_destino%" mkdir "%pasta_destino%"

echo.
echo === Baixando para: %pasta_destino% ===

set "count=0"
:LOOP
if "%~1"=="" goto BAIXAR_TUDO
set /a count+=1
set "url[!count!]=%~1"
set "nome[!count!]=%~2"
shift & shift
goto LOOP

:BAIXAR_TUDO
for /l %%i in (1,1,%count%) do (
    echo [%%i/%count%] Baixando !nome[%%i]!...
    curl -L -# -o "%pasta_destino%\!nome[%%i]!" "!url[%%i]!"
    
    if exist "%pasta_destino%\!nome[%%i]!" (
        echo OK! !nome[%%i]! baixado
    ) else (
        echo ERRO ao baixar !nome[%%i]!
    )
)

echo.
echo === Todos os arquivos em: %pasta_destino% ===
start "" "%pasta_destino%"
exit /b

:INSTALAR_HP4103
cls
echo =========================================================================
echo                    Instalando Driver HP 4103 (V4)
echo =========================================================================
echo.

set "exe=HP_4103.exe"
set "url=https://ftp.hp.com/pub/softlib/software13/printers/LJ4101-4104/V4_DriveronlyWebpack-54.5.5369-LJ4101-4104_V4_DriveronlyWebpack.exe"
set "pasta=C:\HP_LJ4101-4104\HP_LJ4101-4104_V4"
set "inf=%pasta%\hplo03744_x64.inf"
set "driver=HP LaserJet Pro MFP 4101 4102 4103 4104 PCL-6 (V4)"
set "nome_impressora=HP LaserJet Pro MFP 4103"

:: 1. Baixa se necessário
if not exist "%exe%" (
    echo Baixando driver...
    where curl >nul 2>nul
    if errorlevel 1 (
        bitsadmin /transfer HP4103 /download /priority high "%url%" "%CD%\%exe%"
    ) else (
        curl -L -# -o "%exe%" "%url%"
    )
)

:: 2. Extrai silencioso
if not exist "%inf%" (
    echo Extraindo driver, aguarde...
    start /wait "" "%exe%" /s /v"/qn"
) else (
    echo Driver ja encontrado, pulando extracao.
)

:: 3. Loop de espera FORA do bloco if
set "tentativas=0"
:AGUARDA_HP4103
if exist "%inf%" goto CONTINUA_HP4103
set /a tentativas+=1
if %tentativas% geq 12 (
    echo ERRO: Pasta nao criada apos extracao.
    pause
    goto MONO
)
timeout /t 5 /nobreak >nul
goto AGUARDA_HP4103

:CONTINUA_HP4103
echo Driver encontrado!

:: 4. Injeta driver
echo Registrando driver...
pnputil /add-driver "%inf%" /install
if errorlevel 1 (
    echo ERRO ao registrar! Rode como Administrador.
    pause
    goto MONO
)

:: 5. Pede IP
echo.
set /p ip="Digite o IP da impressora (ex: 192.168.1.100): "
if "%ip%"=="" (
    echo IP invalido!
    pause
    goto MONO
)

:: 6. Porta TCP/IP
echo Criando porta...
powershell -Command "if (-not (Get-PrinterPort -Name 'IP_%ip%' -ErrorAction SilentlyContinue)) { Add-PrinterPort -Name 'IP_%ip%' -PrinterHostAddress '%ip%' }"

:: 7. Driver no spooler
echo Adicionando driver ao spooler...
powershell -Command "if (-not (Get-PrinterDriver -Name '%driver%' -ErrorAction SilentlyContinue)) { Add-PrinterDriver -Name '%driver%' -InfPath '%inf%' }"

:: 8. Cria impressora
echo Criando impressora...
powershell -Command "if (-not (Get-Printer -Name '%nome_impressora%' -ErrorAction SilentlyContinue)) { Add-Printer -Name '%nome_impressora%' -DriverName '%driver%' -PortName 'IP_%ip%' } else { Set-Printer -Name '%nome_impressora%' -PortName 'IP_%ip%' }"

:: 9. Confirmação
powershell -Command "Get-Printer -Name '%nome_impressora%' -ErrorAction SilentlyContinue" | find "%nome_impressora%" >nul
if errorlevel 1 (
    echo ATENCAO: Verifique em Dispositivos e Impressoras.
) else (
    echo.
    echo  Impressora "%nome_impressora%" instalada! IP: %ip%
)
pause
goto MONO

:EXECUTAR_E_ABRIR_IMPRESSORA
setlocal enabledelayedexpansion
set "exe=%~1"

if "%exe%"=="" (
    echo Erro: Nenhum arquivo especificado!
    pause
    goto MENU
)

if not exist "%exe%" (
    echo ERRO: Arquivo nao encontrado - %exe%
    pause
    endlocal
    exit /b 1
)

cls
echo =========================================================================
echo                    Executando Instalador
echo =========================================================================
echo.
echo Arquivo: %exe%
echo.
echo Aguarde a extracao...
echo.

:: Executa o .exe e aguarda a conclusão
start /wait "" "%exe%"

echo.
echo Abrindo tela de Adicionar Impressora...
timeout /t 2 /nobreak >nul

:: Abre a tela de adicionar impressora
explorer shell:::{2227A280-3AEA-1069-A2DE-08002B30309D}

echo.
echo Clique em 'Adicionar impressora ou scanner' para continuar.
pause
endlocal
exit /b 0




































