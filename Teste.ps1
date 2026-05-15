# ==================== CONFIGURAÇÕES GLOBAIS ====================
$ErrorActionPreference = "Continue"

# Define uma pasta de trabalho FIXA (evita problemas de execução remota)
$Script:WorkDir = Join-Path $env:TEMP "PrinterTool"
if (-not (Test-Path $Script:WorkDir)) {
    New-Item -ItemType Directory -Path $Script:WorkDir -Force | Out-Null
}
Set-Location $Script:WorkDir
$Script:CurrentDir = $Script:WorkDir

# ==================== FUNÇÕES AUXILIARES ====================
function Write-ColorLog {
    param([string]$Message, [string]$Color = "Yellow")
    Write-Host $Message -ForegroundColor $Color
}

function Download-File {
    param([string]$Url, [string]$Destino)
    # Se Destino for apenas nome de arquivo (sem caminho), usa o WorkDir
    if (-not (Split-Path $Destino -Parent)) {
        $Destino = Join-Path $Script:WorkDir $Destino
    }
    Write-Host "Baixando $([System.IO.Path]::GetFileName($Destino))..." -ForegroundColor Cyan
    $ProgressPreference = 'SilentlyContinue'
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 Windows NT")
        $wc.DownloadFile($Url, $Destino)
        $wc.Dispose()
        return $true
    }
    catch {
        try {
            & curl.exe -L --progress-bar -o "$Destino" "$Url" 2>$null
            return $?
        }
        catch {
            Start-BitsTransfer -Source $Url -Destination $Destino -Priority High -ErrorAction SilentlyContinue
            return $?
        }
    }
}

function Start-AndWait {
    param([string]$FilePath)
    # Se for apenas nome, completa caminho
    if (-not (Split-Path $FilePath -Parent)) {
        $FilePath = Join-Path $Script:WorkDir $FilePath
    }
    if (-not (Test-Path $FilePath)) {
        Write-Host "Arquivo não encontrado: $FilePath" -ForegroundColor Red
        return $false
    }
    try {
        $proc = Start-Process -FilePath $FilePath -PassThru -WindowStyle Normal
        $proc.WaitForExit()
        return $true
    }
    catch {
        Write-Host "Erro ao executar $FilePath : $_" -ForegroundColor Red
        return $false
    }
}

# As funções Invoke-Baixar, Invoke-BaixarEAbrir e Install-HP4103 permanecem IGUAIS à sua versão,
# mas lembre-se de que elas usam $Script:CurrentDir (agora fixo) e Download-File/Start-AndWait atualizados.

# O resto do script (menus) permanece idêntico – nenhuma alteração necessária além do início.

# ==================== FUNÇÕES AUXILIARES ====================
function Write-ColorLog {
    param(
        [string]$Message,
        [string]$Color = "Yellow"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Download-File {
    param([string]$Url, [string]$Destino)
    Write-Host "Baixando $([System.IO.Path]::GetFileName($Destino))..." -ForegroundColor Cyan
    
    # Força o PowerShell a não mostrar barra de progresso (isso acelera MUITO)
    $ProgressPreference = 'SilentlyContinue'
    
    try {
        # Usa WebClient que é mais rápido que Invoke-WebRequest
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 Windows NT")
        $wc.DownloadFile($Url, $Destino)
        $wc.Dispose()
        return $true
    }
    catch {
        # Fallback para curl.exe (nativo, mais rápido que BITS)
        try {
            & curl.exe -L --progress-bar -o "$Destino" "$Url"
            return $true
        }
        catch {
            # Último recurso: BITS
            Start-BitsTransfer -Source $Url -Destination $Destino -Priority High -ErrorAction SilentlyContinue
            return $?
        }
    }
}

function Start-AndWait {
    param([string]$FilePath)
    try {
        $proc = Start-Process -FilePath $FilePath -PassThru -WindowStyle Normal
        $proc.WaitForExit()
        return $true
    }
    catch {
        Write-Host "Erro ao executar $FilePath : $_" -ForegroundColor Red
        return $false
    }
}

# ==================== SUB-ROTINAS DE BAIXAR ====================
function Invoke-Baixar {
    param(
        [string]$Nome,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Args
    )
    # $Args vem em pares: URL1, ARQUIVO1, URL2, ARQUIVO2, ...
    $count = [math]::Floor($Args.Count / 2)
    Write-Host "`n=== Baixando: $Nome ===" -ForegroundColor Cyan
    for ($i = 0; $i -lt $count; $i++) {
        $url = $Args[$i*2]
        $arquivo = $Args[$i*2+1]
        Write-Host "[$($i+1)/$count] $arquivo"
        if (Download-File -Url $url -Destino "$Script:CurrentDir\$arquivo") {
            Write-Host "OK! Iniciando $arquivo..." -ForegroundColor Green
            Start-AndWait -FilePath "$Script:CurrentDir\$arquivo"
            Start-Sleep -Seconds 2
        } else {
            Write-Host "ERRO ao baixar $arquivo" -ForegroundColor Red
        }
    }
    Read-Host "`nPressione ENTER para continuar"
}

function Invoke-BaixarEAbrir {
    param(
        [string]$NomePasta,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Args
    )
    $pastaDestino = Join-Path $env:USERPROFILE "Downloads\$NomePasta"
    if (-not (Test-Path $pastaDestino)) {
        New-Item -ItemType Directory -Path $pastaDestino -Force | Out-Null
    }
    Write-Host "`n=== Baixando para: $pastaDestino ===" -ForegroundColor Cyan
    $count = [math]::Floor($Args.Count / 2)
    for ($i = 0; $i -lt $count; $i++) {
        $url = $Args[$i*2]
        $arquivo = $Args[$i*2+1]
        Write-Host "[$($i+1)/$count] Baixando $arquivo..."
        if (Download-File -Url $url -Destino "$pastaDestino\$arquivo") {
            Write-Host "OK! $arquivo baixado" -ForegroundColor Green
        } else {
            Write-Host "ERRO ao baixar $arquivo" -ForegroundColor Red
        }
    }
    Write-Host "`n=== Todos os arquivos em: $pastaDestino ===" -ForegroundColor Green
    Invoke-Item $pastaDestino
}

# ==================== INSTALAÇÃO ESPECIAL HP4103 ====================


# ==================== MENUS ====================
function Show-MainMenu {
    Clear-Host
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-ColorLog "          Era essa Impressora que voce queria ?" -Color White
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-Host @"
   [1] Baixar e Instalar PrintWay
   [2] Monocromaticas
   [3] Jatos de Tintas
   [4] Termicas
   [5] Naps2
   [6] Advanced IP Scanner
   [7] Scanner de Producao
   [8] Sem nome ainda
   [0] Sair
"@
    $opcao = Read-Host "`nDigite a opcao"
    switch ($opcao) {
       "1" {
    Write-Host "Aguarde, baixando PrintWay..." -ForegroundColor Cyan
    $url = "https://help.printwayy.com/wp-content/uploads/utilitarios/Setup%20PrintWayy.exe"
    $dest = "$Script:CurrentDir\SetupPrintWayy.exe"
    if (Download-File -Url $url -Destino $dest) {
        Write-Host "Download OK! Iniciando..." -ForegroundColor Green
        Start-Process $dest
    }
    # Abre o navegador em modo anônimo/privado
    $chrome = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
    $edge = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    $firefox = "${env:ProgramFiles}\Mozilla Firefox\firefox.exe"
    
    if (Test-Path $chrome) {
        Start-Process $chrome -ArgumentList "--incognito", "https://app.printwayy.com/Customers/Login?ReturnUrl=/"
    }
    elseif (Test-Path $edge) {
        Start-Process $edge -ArgumentList "--inprivate", "https://app.printwayy.com/Customers/Login?ReturnUrl=/"
    }
    elseif (Test-Path $firefox) {
        Start-Process $firefox -ArgumentList "--private-window", "https://app.printwayy.com/Customers/Login?ReturnUrl=/"
    }
    else {
        Write-Host "Navegador compatível não encontrado. Abra manualmente: https://app.printwayy.com" -ForegroundColor Yellow
        Start-Process "https://app.printwayy.com/Customers/Login?ReturnUrl=/"
    }
    Read-Host "`nPressione ENTER"
    Show-MainMenu
}
        "2" { Show-MonoMenu }
        "3" { Show-InkjetMenu }
        "4" { Show-ThermalMenu }
        "5" {
            Write-Host "Aguarde, baixando NAPS2..." -ForegroundColor Cyan
            $url = "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe"
            $dest = "$Script:CurrentDir\naps2-8.2.1-win-x64.exe"
            if (Download-File -Url $url -Destino $dest) {
                Write-Host "Download OK! Iniciando..." -ForegroundColor Green
                Start-Process $dest
            }
            Read-Host "`nPressione ENTER"
            Show-MainMenu
        }
        "6" {
            Write-Host "Aguarde, baixando Advanced IP Scanner..." -ForegroundColor Cyan
            $url = "https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe"
            $dest = "$Script:CurrentDir\AIPScannerSetup.exe"
            if (Download-File -Url $url -Destino $dest) {
                Write-Host "Download OK! Iniciando..." -ForegroundColor Green
                Start-Process $dest
            }
            Read-Host "`nPressione ENTER"
            Show-MainMenu
        }
        "7" { Show-ScannerMenu }
        "8" { Show-AindaMenu }
        "0" { exit }
        default { Show-MainMenu }
    }
}

function Show-MonoMenu {
    Clear-Host
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-ColorLog "                          Monocromaticas" -Color White
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-Host @"
   [1] HP 432
   [2] HP 408
   [3] HP 4003
   [4] HP 4103
   [5] HP 428
   [6] Samsung 4020/4070/4080
   [7] Brother 2540W
   [8] Brother 8912DW
   [9] Canon 527
   [10] Canon 6030
   [11] Canon 1643_IF_v1
   [12] Canon 1643_IF_v2
   [13] Canon 1643_MF_X_v2
   [14] Xerox 3020
   [15] Xerox 205
   [16] Xerox 210
   [17] Xerox 3335
   [18] Xerox 3345
   [19] Ricoh 377
   [20] Ricoh 3710
   [0] Voltar
"@
    $op = Read-Host "`nDigite a opcao"
    switch ($op) {
        "1"  { Invoke-Baixar "HP_432" "https://ftp.hp.com/pub/softlib/software13/printers/herbs/LaserMFP432/HP_Laser_MFP_432_Full_Software_and_Drivers_1.09.exe" "HP_432.exe" }
        "2"  { Invoke-Baixar "HP_408" "https://ftp.hp.com/pub/softlib/software13/printers/herbs/Laser408/HP_Laser_408_Print_Driver_1.07.exe" "HP_408.exe" }
        "3"  { Invoke-Baixar "HP_4003" "https://ftp.hp.com/pub/softlib/software13/printers/LJ4001-4004/HPEasyStart-16.2.1-LJ4001-4004_UWWL_54_4_5341_Webpack.exe" "HP_4003.exe" }
        "4"  { Invoke-Baixar "HP_4103" "https://ftp.hp.com/pub/softlib/software13/printers/LJ4101-4104/V4_DriveronlyWebpack-54.5.5369-LJ4101-4104_V4_DriveronlyWebpack.exe" "HP_4103.exe" "https://ftp.hp.com/pub/softlib/software13/printers/USS/ARM64_MFP/Full_Webpack-63.5.6118_ARM64-SJ0001_Full_Webpack.exe" "Scan.exe"}
        "5"  { Invoke-Baixar "HP_428" "https://ftp.hp.com/pub/softlib/software13/printers/LJ/M428-M429/V4_DriveronlyWebpack-48.6.4638-LJM428-M429_V4_DriveronlyWebpack.exe" "HP_428.exe" "https://ftp.hp.com/pub/softlib/software13/printers/SJ0001/MFPs/Full_Webpack-63.6.6364-SJ0001_Full_Webpack.exe" "HP_SJ0001.exe" }
        "6"  { Invoke-Baixar "Samsung" "https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M3370FD/SamsungUniversalPrintDriver3_V3.00.16.0101.01.exe" "SamsungDriver.exe" "https://ftp.hp.com/pub/softlib/software13/printers/SS/Common_SW/WIN_EPM_V2.00.01.36.exe" "WIN_EPM_V2.00.01.36.exe" "https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M5270LX/WIN_EDC_V2.02.61.exe" "SamsungEPM.exe" }
        "7"  { Invoke-Baixar "Brother_2540w" "https://download.brother.com/welcome/dlf106196/Y14B_C1_ULWL1_PP-inst-F1.EXE" "Brother.exe" }
        "8"  { Invoke-Baixar "Brother_8112DW" "https://download.brother.com/welcome/dlf004894/MFC-8912DW-inst-D1-usa.EXE" "Brother.exe" }
        "9"  { Invoke-BaixarEAbrir "Canon_527" "https://gdlp01.c-wss.com/gds/0/0100012920/01/GPlus_PCL6_Driver_V340_32_64_00.exe" "Canon.exe" "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe" "naps2.exe" }
        "10"  { Invoke-BaixarEAbrir "Canon_6030" "https://gdlp01.c-wss.com/gds/2/0100010942/01/LBP6030_V2111_WP_PT.exe" "Canon.exe" }
        "11"  { Invoke-Baixar "Canon_1643_v1" "https://gdlp01.c-wss.com/gds/0/0100010410/03/iR1643MFDriverv6502W64.exe" "Canon_1643_v1.exe" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe" "Canon_Utility.exe" }
        "12"  { Invoke-Baixar "Canon_1643_v2" "https://gdlp01.c-wss.com/gds/8/0100011188/01/iR1643iIIMFDriverV720W64.exe" "Canon_1643_v2.exe" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe" "Canon_Utility.exe" }
        "13" { Invoke-Baixar "Canon_1643_X_v2" "https://gdlp01.c-wss.com/gds/7/0100011197/01/MF1643iIIMFDriverV720W64.exe" "Canon_1643_X_v2.exe" "https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe" "Canon_Utility.exe" }
        "14" { Invoke-Baixar "Xerox_3020" "https://download.support.xerox.com/pub/drivers/3020/drivers/win10/ar/Xerox_Phaser_3020_Windows_Print_Drivers_Utilities_V1.07.exe" "Xerox_3020.exe" }
        "15" { Invoke-Baixar "Xerox_205" "https://download.support.xerox.com/pub/drivers/B205/drivers/win10/ar/Xerox_B205_Windows_Print_Drivers_Utilities_V1.12.exe" "Xerox_205.exe" }
        "16" { Invoke-Baixar "Xerox_210" "https://download.support.xerox.com/pub/drivers/B210/drivers/win10/ar/Xerox_B210_Windows_Print_Drivers_Utilities_V1.12.exe" "Xerox_210.exe" } 
        "17" { Invoke-BaixarEAbrir "Xerox_3335" "https://download.support.xerox.com/pub/drivers/GLOBALPRINTDRIVER/drivers/win10x64/ar/UNIV_5.1076.3.0_PCL6_x64.zip" "Xerox_3335.zip" "https://download.support.xerox.com/pub/drivers/WC3335_WC3345/drivers/win10/en_GB/Xerox_WorkCentre_3335_Network_USB_Driver_Signed_v3.32.06.01.zip" "Scan.zip" "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe" "naps2.exe" }
        "18" { Invoke-BaixarEAbrir "Xerox_3345" "https://download.support.xerox.com/pub/drivers/GLOBALPRINTDRIVER/drivers/win10x64/ar/UNIV_5.1076.3.0_PCL6_x64.zip" "Xerox_3345.zip" "https://download.support.xerox.com/pub/drivers/WC3335_WC3345/drivers/win10/en_GB/Xerox_WorkCentre_3345_Network_USB_Driver_Signed_v3.32.06.01.zip" "Scan.zip" "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe" "naps2.exe" }
        "19" { Invoke-Baixar "Ricoh_377" "https://support.ricoh.com/bb/pub_e/dr_ut_e/0001333/0001333430/V127/r97661L15.exe" "Ricoh_377.exe" "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe" "naps2.exe" }
        "20" { Invoke-BaixarEAbrir "Ricoh_3710" "https://support.ricoh.com/bb/pub_e/dr_ut_e/0001333/0001333436/V108/z97664L15.exe" "Ricoh_3710.exe" "https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe" "naps2.exe" }
        "0"  { Show-MainMenu }
        default { Show-MonoMenu }
    }
    Show-MonoMenu
}

function Show-InkjetMenu {
    Clear-Host
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-ColorLog "                        Jatos de Tinta" -Color White
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-Host @"
   [1] Epson L3110
   [2] Epson L3210
   [3] Epson L3150
   [4] Epson L3250
   [5] Epson L5590 
   [6] Epson L6190
   [7] Epson L6170
   [8] Epson L6270
   [9] Epson L6490
   [10] Epson L805
   [11] Epson L655
   [12] Epson WF 3720
   [13] Epson WF 5899
   [14] Epson WF 5710
   [15] Epson WF 5790
   [16] Epson WF 5810
   [17] Epson M1180
   [18] Epson M3180
   [0] Voltar
"@
    $op = Read-Host "`nDigite a opcao"
    switch ($op) {
        "1"  { Invoke-Baixar "Epson L3110" "https://ftp.epson.com/latin/drivers/inkjet/L3110_Lite_LA.exe" "L3110.exe" }
        "2"  { Invoke-Baixar "Epson L3210" "https://ftp.epson.com/latin/drivers/inkjet/L3210_X64_38000_LA.exe" "L3210.exe" }
        "3"  { Invoke-Baixar "Epson L3150" "https://ftp.epson.com/latin/drivers/inkjet/L3150_Lite_LA.exe" "L3150.exe" }
        "4"  { Invoke-Baixar "Epson L3250" "https://ftp.epson.com/latin/drivers/inkjet/L3250_L3251_Lite_LA.exe" "L3250.exe" }
        "5"  { Invoke-Baixar "Epson L5590" "https://ftp.epson.com/latin/drivers/inkjet/L5590_X64_380_LA.exe" "L5590.exe" "https://ftp.epson.com/latin/drivers/inkjet/L5590_EScan2_67810_LA.exe" "L5590_Full.exe" }
        "6"  { Invoke-Baixar "Epson L6190" "https://ftp.epson.com/latin/drivers/inkjet/L6191_X64_2120_LA.exe" "L6190.exe" "https://ftp.epson.com/latin/drivers/inkjet/L6191_EScan2_65230_LA.exe" "L6190_Full.exe" }
        "7"  { Invoke-Baixar "Epson L6170" "https://ftp.epson.com/latin/drivers/inkjet/L6171_X64_2120_LA.exe" "L6170.exe" "https://ftp.epson.com/latin/drivers/inkjet/L6161_L6171_EScan2_65230_LA.exe" "L6170_Full.exe" }
        "8"  { Invoke-Baixar "Epson L6270" "https://ftp.epson.com/latin/drivers/inkjet/L6270_X64_38000_2_LA.exe" "L6270.exe" "https://ftp.epson.com/latin/drivers/inkjet/L6270_EScan2_67810_LA.exe" "L6270_Full.exe" }
        "9"  { Invoke-Baixar "Epson L6490" "https://download.epson-europe.com/pub/download/6743/epson674340eu.exe?ot_preferences=C0004%3A0%2CC0003%3A0%2CC0002%3A0%2CC0001%3A1&adobe_mc=ad8cb437-bcd3-458a-b124-678dc7b661ea" "driver.exe" "https://download.epson-europe.com/pub/download/6751/epson675134eu.exe?ot_preferences=C0004%3A0%2CC0003%3A0%2CC0002%3A0%2CC0001%3A1&adobe_mc=ad8cb437-bcd3-458a-b124-678dc7b661ea" "Scan.exe" }
        "10"  { Invoke-Baixar "Epson L805" "https://ftp.epson.com/latin/drivers/Impresoras/L805/L805_Win_Lite_1.0APS_FD.exe" "L805.exe" }
        "11"  { Invoke-Baixar "Epson L655" "https://ftp.epson.com/latin/drivers/inkjet/L655_L656_X64_260_LA.exe" "L656.exe" "https://ftp.epson.com/latin/drivers/Multi/l655/L655_L656_scan_4020_FD.exe" "Scan.exe" }
        "12" { Invoke-Baixar "Epson WF 3720" "https://ftp.epson.com/drivers/WF3720_X64_2100_NA.exe" "3720.exe" "https://ftp.epson.com/drivers/epson18528.exe" "Scan.exe" }
        "13" { Invoke-Baixar "Epson WF 5899" "https://ftp.epson.com/drivers/WFM5899_PCL6_X64_210000_AM.exe" "5899.exe" "https://ftp.epson.com/drivers/WFM5899_EScan2_67810_AM.exe" "Scan.exe" }
        "14" { Invoke-Baixar "Epson WF 5710" "https://ftp.epson.com/drivers/WFC5710_X64_2120_AM.exe" "5710.exe" "https://ftp.epson.com/drivers/WFC5710_C5790_EScan2_65310_AM.exe" "Scan.exe" }
        "15" { Invoke-Baixar "Epson WF 5790" "https://ftp.epson.com/drivers/WFC5790_STD_X64_2120_AM.exe" "5790.exe" "https://ftp.epson.com/drivers/WFC5710_C5790_EScan2_65310_AM.exe" "Scan.exe" }
        "16" { Invoke-Baixar "Epson WF 5810" "https://ftp.epson.com/latin/drivers/inkjet/WFC5810_STD_X64_380_LA.exe" "5810.exe" "https://ftp.epson.com/drivers/WFC5810_C5890_EScan2_67810_AM.exe" "Scan.exe" }
        "17" { Invoke-Baixar "Epson M1180" "https://ftp.epson.com/latin/drivers/inkjet/M1180_Lite_LA.exe" "M1180.exe" }
        "18" { Invoke-Baixar "Epson M3180" "https://download.epson-europe.com/pub/download/6771/epson677145eu.exe?ot_preferences=C0004%3A0%2CC0003%3A0%2CC0002%3A0%2CC0001%3A1&adobe_mc=ad8cb437-bcd3-458a-b124-678dc7b661ea" "M3180.exe" "https://download.epson-europe.com/pub/download/6769/epson676922eu.exe?ot_preferences=C0004%3A0%2CC0003%3A0%2CC0002%3A0%2CC0001%3A1&adobe_mc=ad8cb437-bcd3-458a-b124-678dc7b661ea" "Scan.exe" }
        "0"  { Show-MainMenu }
        default { Show-InkjetMenu }
    }
    Show-InkjetMenu
}

function Show-ThermalMenu {
    Clear-Host
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-ColorLog "                          Termicas" -Color White
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-Host @"
   [1] Tm20X Lan/USB
   [2] Bematech 
   [3] HPRT 
   [4] HPRT Ares
   [0] Voltar
"@
    $op = Read-Host "`nDigite a opcao"
    switch ($op) {
        "1" {
            Invoke-BaixarEAbrir "Epson_Tm20X" `
                "https://ftp.epson.com/latin/drivers/pos/APD_607R1_T20X_WM.zip" "Tm20X.zip" `
                "https://ftp.epson.com/drivers/pos/TMUSB800d.exe" "TMVirtualPort.exe"
        }
        "2" {
            Invoke-BaixarEAbrir "Bermatech_4200" `
                "https://baixar.programanex.com.br/extras/impressoras/BEMATECH/BEMA_MP_4200_TH_64.zip" "Bermatech4200.zip"
        }
        "3" {
            Invoke-BaixarEAbrir "HPRT" `
                "https://drive.usercontent.google.com/download?id=1qzu0ZRxQBYBbw1d1dke1Z1EE0vYNDvlY&export=download" "HPRT.zip" `
                "https://drive.usercontent.google.com/download?id=17TRObdjips4ek71TjFKFkNx_ghrgOQHp&export=download&confirm=t&uuid=3997f980-4d77-4f09-8484-0d7cdd816513" "HPRTutili.zip"
        }
        "4" {
            Invoke-BaixarEAbrir "HPRT_Ares" `
                "https://drive.usercontent.google.com/download?id=1K5vTsSQ-ZYxYYuRm_4nhLMKhYgXxqHRX&export=download&confirm=t&uuid=0940aa64-c35c-4a75-ab9c-ebac9850a126" "HPRTAres_driver.zip" `
                "https://drive.usercontent.google.com/download?id=106KQt6JCRlyL7p9u9jUZNaNZU0zgj5YQ&export=download" "HPRTAres_designer.zip" `
                "https://drive.usercontent.google.com/download?id=14R2GWMWGyB4TUB_Vp4EJxf5fHoTyaEqr&export=download" "HPRTAres_utility.zip"
        }
        "0"  { Show-MainMenu }
        default { Show-ThermalMenu }
    }
    Show-ThermalMenu
}

function Show-ScannerMenu {
    Clear-Host
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-ColorLog "                        Scanner de Producao" -Color White
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-Host @"
   [1] Canon DR-C240
   [2] Brother ADS-4700
   [3] Brother ADS-2800
   [4] Epson DS-530
   [0] Voltar
"@
    $op = Read-Host "`nDigite a opcao"
    switch ($op) {
        "1" { Invoke-Baixar "Epson_Scanner_Producao" "https://gdlp01.c-wss.com/gds/9/0100009799/05/DR-C240_Driver_V.1.4.11712.18001SP4_Windows.zip" "Driver.zip" "https://gdlp01.c-wss.com/gds/0/0200006680/07/CaptureOnTouch_Pro_V5.5.1025.1217.zip" "CaptureOnTouch.zip" }
        "2" { Invoke-Baixar "Epson_Scanner_Producao" "https://download.brother.com/welcome/dlf106560/Y21F_C2_ULWT_PP-inst-J1.EXE" "ads4700.exe" }
        "3" { Invoke-Baixar "Epson_Scanner_Producao" "https://download.brother.com/welcome/dlf107270/Y15F_C1_ULWT_PP-inst-H1.EXE" "ads2800.exe" }
        "4" { Invoke-Baixar "Epson_Scanner_Producao" "https://ftp.epson.com/drivers/DS530_Combo_AM.exe" "epson.exe" }
        "0" { Show-MainMenu }
        default { Show-ScannerMenu }
    }
    Show-ScannerMen
}

Function Show-AindaMenu {
 Clear-Host
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-ColorLog "                       Ainda Menu" -Color White
    Write-ColorLog "=========================================================================" -Color Yellow
    Write-Host @"
   [1] Samsung Universal Scanner
   [0] Voltar
"@
    $op = Read-Host "`nDigite a opcao"
    switch ($op) {
        "1" { Invoke-Baixar "Samsung Universal Scanner" "https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M3370FD/UniversalScanDriver_V1.02.19.exe" "Driver.exe" 
        "0" { Show-MainMenu }
        default { Show-AindaMenu }
    }
    Show-AindaMen
}
   
   

# ==================== INÍCIO ====================
# Verifica administrador (apenas aviso, não impede execução)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ATENÇÃO: Execute como Administrador para melhores resultados.`n" -ForegroundColor Yellow
}
Show-MainMenu
