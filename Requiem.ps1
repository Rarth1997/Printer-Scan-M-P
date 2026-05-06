<#
.SYNOPSIS
    Ferramenta Avançada para Download e Instalação de Drivers de Impressoras
.DESCRIPTION
    Script automatizado para download e instalação de drivers de impressoras
    Suporta HP, Canon, Epson, Xerox, Samsung, Brother e impressoras térmicas
.PARAMETER Mode
    Modo de execução: Interactive (padrão), Install, Download
.PARAMETER Printer
    Nome da impressora para instalação direta (ex: HP432, EpsonL3110)
.EXAMPLE
    .\PrinterTool.ps1
    .\PrinterTool.ps1 -Printer HP432
    .\PrinterTool.ps1 -Mode Download -Printer CanonMF1643
.NOTES
    Autor: Seu Nome
    Versão: 2.0
    Requer: PowerShell 5.1+ e privilégios de administrador
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Interactive', 'Install', 'Download')]
    [string]$Mode = 'Interactive',
    
    [Parameter(Mandatory=$false)]
    [string]$Printer,
    
    [Parameter(Mandatory=$false)]
    [switch]$NoAdmin
)

#Requires -Version 5.1

# ==================== CONFIGURAÇÃO INICIAL ====================

$ErrorActionPreference = "Continue"
$ProgressPreference = 'SilentlyContinue'
$Script:WorkDir = Join-Path $env:TEMP "PrinterTool"
$Script:Version = "2.0.0"

# Cores para output
$Script:Colors = @{
    Success = 'Green'
    Error = 'Red'
    Warning = 'Yellow'
    Info = 'Cyan'
    Header = 'White'
}

# ==================== VERIFICAÇÕES ====================

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Initialize-WorkDirectory {
    if (-not (Test-Path $Script:WorkDir)) {
        try {
            New-Item -ItemType Directory -Path $Script:WorkDir -Force | Out-Null
            Write-Log "Diretório de trabalho criado: $Script:WorkDir" -Type Info
        }
        catch {
            Write-Log "Erro ao criar diretório: $_" -Type Error
            exit 1
        }
    }
    Set-Location $Script:WorkDir
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Success', 'Error', 'Warning', 'Info', 'Header')]
        [string]$Type = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = $Script:Colors[$Type]
    
    switch ($Type) {
        'Success' { $prefix = "[✓]" }
        'Error'   { $prefix = "[✗]" }
        'Warning' { $prefix = "[!]" }
        'Info'    { $prefix = "[i]" }
        'Header'  { $prefix = "" }
    }
    
    Write-Host "$prefix $Message" -ForegroundColor $color
    
    # Log para arquivo
    $logFile = Join-Path $Script:WorkDir "PrinterTool.log"
    "$timestamp [$Type] $Message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# ==================== DOWNLOAD ====================

function Get-FileFromUrl {
    param(
        [string]$Url,
        [string]$OutputFile,
        [switch]$ShowProgress
    )
    
    try {
        Write-Log "Baixando: $OutputFile" -Type Info
        
        if ($ShowProgress) {
            $ProgressPreference = 'Continue'
        }
        
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $webClient.DownloadFile($Url, (Join-Path $Script:WorkDir $OutputFile))
        
        $ProgressPreference = 'SilentlyContinue'
        
        $fileInfo = Get-Item (Join-Path $Script:WorkDir $OutputFile)
        
        if ($fileInfo.Length -eq 0) {
            Remove-Item $fileInfo.FullName -Force
            throw "Arquivo baixado está vazio"
        }
        
        $sizeInMB = [math]::Round($fileInfo.Length / 1MB, 2)
        Write-Log "Download concluído: $OutputFile ($sizeInMB MB)" -Type Success
        return $true
    }
    catch {
        Write-Log "Erro no download: $_" -Type Error
        return $false
    }
}

function Invoke-FileExecution {
    param(
        [string]$FilePath,
        [switch]$Wait,
        [string[]]$Arguments
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Log "Arquivo não encontrado: $FilePath" -Type Error
        return $false
    }
    
    $extension = [System.IO.Path]::GetExtension($FilePath).ToLower()
    
    try {
        switch ($extension) {
            ".exe" {
                Write-Log "Executando: $FilePath" -Type Info
                if ($Wait) {
                    Start-Process -FilePath $FilePath -ArgumentList $Arguments -Wait
                } else {
                    Start-Process -FilePath $FilePath -ArgumentList $Arguments
                }
            }
            ".msi" {
                Write-Log "Instalando MSI: $FilePath" -Type Info
                $msiArgs = @("/i", "`"$FilePath`"") + $Arguments
                if ($Wait) {
                    Start-Process msiexec.exe -ArgumentList $msiArgs -Wait
                } else {
                    Start-Process msiexec.exe -ArgumentList $msiArgs
                }
            }
            ".zip" {
                $destFolder = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
                $destPath = Join-Path (Split-Path $FilePath) $destFolder
                
                Write-Log "Extraindo ZIP: $FilePath" -Type Info
                Expand-Archive -Path $FilePath -DestinationPath $destPath -Force
                Write-Log "Extração concluída em: $destPath" -Type Success
                
                Start-Process explorer.exe -ArgumentList $destPath
            }
            default {
                Write-Log "Tipo de arquivo não suportado: $extension" -Type Warning
                Start-Process explorer.exe -ArgumentList (Split-Path $FilePath)
            }
        }
        return $true
    }
    catch {
        Write-Log "Erro ao executar arquivo: $_" -Type Error
        return $false
    }
}

# ==================== DATABASE DE IMPRESSORAS ====================

function Get-PrinterDatabase {
    return @{
        # ===== MONOCROMÁTICAS =====
        'HP432' = @{
            Name = 'HP LaserJet MFP 432'
            Category = 'Mono'
            Files = @(
                @{Url='https://ftp.hp.com/pub/softlib/software13/printers/herbs/LaserMFP432/HP_Laser_MFP_432_Full_Software_and_Drivers_1.09.exe'; FileName='HP_432.exe'}
            )
        }
        'HP408' = @{
            Name = 'HP LaserJet 408'
            Category = 'Mono'
            Files = @(
                @{Url='https://ftp.hp.com/pub/softlib/software13/printers/herbs/Laser408/HP_Laser_408_Print_Driver_1.07.exe'; FileName='HP_408.exe'}
            )
        }
        'HP4103' = @{
            Name = 'HP LaserJet Pro MFP 4103'
            Category = 'Mono'
            Files = @(
                @{Url='https://ftp.hp.com/pub/softlib/software13/printers/LJ4101-4104/V4_DriveronlyWebpack-54.5.5369-LJ4101-4104_V4_DriveronlyWebpack.exe'; FileName='HP_4103.exe'},
                @{Url='https://ftp.hp.com/pub/softlib/software13/printers/SJ0001/MFPs/Full_Webpack-63.6.6364-SJ0001_Full_Webpack.exe'; FileName='HP_SJ0001.exe'}
            )
        }
        'HP428' = @{
            Name = 'HP LaserJet MFP M428/M429'
            Category = 'Mono'
            Files = @(
                @{Url='https://ftp.hp.com/pub/softlib/software13/printers/LJ/M428-M429/V4_DriveronlyWebpack-48.6.4638-LJM428-M429_V4_DriveronlyWebpack.exe'; FileName='HP_428.exe'},
                @{Url='https://ftp.hp.com/pub/softlib/software13/printers/SJ0001/MFPs/Full_Webpack-63.6.6364-SJ0001_Full_Webpack.exe'; FileName='HP_SJ0001.exe'}
            )
        }
        'Samsung4020' = @{
            Name = 'Samsung 4020/4070/4080'
            Category = 'Mono'
            Files = @(
                @{Url='https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M3370FD/SamsungUniversalPrintDriver3_V3.00.16.0101.01.exe'; FileName='SamsungDriver.exe'},
                @{Url='https://ftp.hp.com/pub/softlib/software13/printers/SS/Common_SW/WIN_EPM_V2.00.01.36.exe'; FileName='WIN_EPM.exe'},
                @{Url='https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-M5270LX/WIN_EDC_V2.02.61.exe'; FileName='SamsungEPM.exe'}
            )
        }
        'Canon527' = @{
            Name = 'Canon imageRUNNER 527'
            Category = 'Mono'
            DownloadToFolder = $true
            Files = @(
                @{Url='https://gdlp01.c-wss.com/gds/0/0100012920/01/GPlus_PCL6_Driver_V340_32_64_00.exe'; FileName='Canon.exe'},
                @{Url='https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe'; FileName='naps2.exe'}
            )
        }
        'Canon6030' = @{
            Name = 'Canon LBP6030'
            Category = 'Mono'
            DownloadToFolder = $true
            Files = @(
                @{Url='https://gdlp01.c-wss.com/gds/2/0100010942/01/LBP6030_V2111_WP_PT.exe'; FileName='Canon.exe'}
            )
        }
        'Canon1643v1' = @{
            Name = 'Canon iR1643 IF v1'
            Category = 'Mono'
            Files = @(
                @{Url='https://gdlp01.c-wss.com/gds/0/0100010410/03/iR1643MFDriverv6502W64.exe'; FileName='Canon_1643_v1.exe'},
                @{Url='https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe'; FileName='Canon_Utility.exe'}
            )
        }
        'Canon1643v2' = @{
            Name = 'Canon iR1643 IF v2'
            Category = 'Mono'
            Files = @(
                @{Url='https://gdlp01.c-wss.com/gds/8/0100011188/01/iR1643iIIMFDriverV720W64.exe'; FileName='Canon_1643_v2.exe'},
                @{Url='https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe'; FileName='Canon_Utility.exe'}
            )
        }
        'Canon1643Xv2' = @{
            Name = 'Canon 1643 MF X v2'
            Category = 'Mono'
            Files = @(
                @{Url='https://gdlp01.c-wss.com/gds/7/0100011197/01/MF1643iIIMFDriverV720W64.exe'; FileName='Canon_1643_X_v2.exe'},
                @{Url='https://gdlp01.c-wss.com/gds/8/0200006868/03/winmfscanutilityv12102.exe'; FileName='Canon_Utility.exe'}
            )
        }
        'Xerox3020' = @{
            Name = 'Xerox Phaser 3020'
            Category = 'Mono'
            Files = @(
                @{Url='https://download.support.xerox.com/pub/drivers/3020/drivers/win10/ar/Xerox_Phaser_3020_Windows_Print_Drivers_Utilities_V1.07.exe'; FileName='Xerox_3020.exe'}
            )
        }
        'Xerox205' = @{
            Name = 'Xerox B205'
            Category = 'Mono'
            Files = @(
                @{Url='https://download.support.xerox.com/pub/drivers/B205/drivers/win10/ar/Xerox_B205_Windows_Print_Drivers_Utilities_V1.12.exe'; FileName='Xerox_205.exe'}
            )
        }
        'Xerox210' = @{
            Name = 'Xerox B210'
            Category = 'Mono'
            Files = @(
                @{Url='https://download.support.xerox.com/pub/drivers/B210/drivers/win10/ar/Xerox_B210_Windows_Print_Drivers_Utilities_V1.12.exe'; FileName='Xerox_210.exe'}
            )
        }
        'Xerox3335' = @{
            Name = 'Xerox 3335'
            Category = 'Mono'
            DownloadToFolder = $true
            Files = @(
                @{Url='https://download.support.xerox.com/pub/drivers/GLOBALPRINTDRIVER/drivers/win10x64/ar/UNIV_5.1076.3.0_PCL6_x64.zip'; FileName='Xerox_3335.zip'},
                @{Url='https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe'; FileName='naps2.exe'}
            )
        }
        'Xerox3345' = @{
            Name = 'Xerox 3345'
            Category = 'Mono'
            DownloadToFolder = $true
            Files = @(
                @{Url='https://download.support.xerox.com/pub/drivers/GLOBALPRINTDRIVER/drivers/win10x64/ar/UNIV_5.1076.3.0_PCL6_x64.zip'; FileName='Xerox_3345.zip'},
                @{Url='https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe'; FileName='naps2.exe'}
            )
        }
        
        # ===== JATOS DE TINTA =====
        'EpsonL3110' = @{
            Name = 'Epson L3110'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L3110_Lite_LA.exe'; FileName='L3110.exe'}
            )
        }
        'EpsonL3150' = @{
            Name = 'Epson L3150'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L3150_Lite_LA.exe'; FileName='L3150.exe'}
            )
        }
        'EpsonL3250' = @{
            Name = 'Epson L3250'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L3250_L3251_Lite_LA.exe'; FileName='L3250.exe'}
            )
        }
        'EpsonL5590' = @{
            Name = 'Epson L5590'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L5590_X64_380_LA.exe'; FileName='L5590.exe'},
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L5590_EScan2_67810_LA.exe'; FileName='L5590_Full.exe'}
            )
        }
        'EpsonL6190' = @{
            Name = 'Epson L6190'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L6191_X64_2120_LA.exe'; FileName='L6190.exe'},
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L6191_EScan2_65230_LA.exe'; FileName='L6190_Full.exe'}
            )
        }
        'EpsonL6270' = @{
            Name = 'Epson L6270'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L6270_X64_38000_2_LA.exe'; FileName='L6270.exe'},
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L6270_EScan2_67810_LA.exe'; FileName='L6270_Full.exe'}
            )
        }
        'EpsonL6490' = @{
            Name = 'Epson L6490'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://download.epson-europe.com/pub/download/6743/epson674340eu.exe'; FileName='driver.exe'},
                @{Url='https://download.epson-europe.com/pub/download/6751/epson675134eu.exe'; FileName='Scan.exe'}
            )
        }
        'EpsonL805' = @{
            Name = 'Epson L805'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/Impresoras/L805/L805_Win_Lite_1.0APS_FD.exe'; FileName='L805.exe'}
            )
        }
        'EpsonL655' = @{
            Name = 'Epson L655'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/L655_L656_X64_260_LA.exe'; FileName='L656.exe'},
                @{Url='https://ftp.epson.com/latin/drivers/Multi/l655/L655_L656_scan_4020_FD.exe'; FileName='Scan.exe'}
            )
        }
        'EpsonWF3720' = @{
            Name = 'Epson WorkForce 3720'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/drivers/WF3720_X64_2100_NA.exe'; FileName='3720.exe'},
                @{Url='https://ftp.epson.com/drivers/epson18528.exe'; FileName='Scan.exe'}
            )
        }
        'EpsonWF5899' = @{
            Name = 'Epson WorkForce 5899'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/drivers/WFM5899_PCL6_X64_210000_AM.exe'; FileName='5899.exe'},
                @{Url='https://ftp.epson.com/drivers/WFM5899_EScan2_67810_AM.exe'; FileName='Scan.exe'}
            )
        }
        'EpsonWF5710' = @{
            Name = 'Epson WorkForce 5710'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/drivers/WFC5710_X64_2120_AM.exe'; FileName='5710.exe'},
                @{Url='https://ftp.epson.com/drivers/WFC5710_C5790_EScan2_65310_AM.exe'; FileName='Scan.exe'}
            )
        }
        'EpsonWF5790' = @{
            Name = 'Epson WorkForce 5790'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/drivers/WFC5790_STD_X64_2120_AM.exe'; FileName='5790.exe'},
                @{Url='https://ftp.epson.com/drivers/WFC5710_C5790_EScan2_65310_AM.exe'; FileName='Scan.exe'}
            )
        }
        'EpsonWF5810' = @{
            Name = 'Epson WorkForce 5810'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/WFC5810_STD_X64_380_LA.exe'; FileName='5810.exe'},
                @{Url='https://ftp.epson.com/drivers/WFC5810_C5890_EScan2_67810_AM.exe'; FileName='Scan.exe'}
            )
        }
        'EpsonM1180' = @{
            Name = 'Epson M1180'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/inkjet/M1180_Lite_LA.exe'; FileName='M1180.exe'}
            )
        }
        'EpsonM3180' = @{
            Name = 'Epson M3180'
            Category = 'Inkjet'
            Files = @(
                @{Url='https://download.epson-europe.com/pub/download/6771/epson677145eu.exe'; FileName='M3180.exe'},
                @{Url='https://download.epson-europe.com/pub/download/6769/epson676922eu.exe'; FileName='Scan.exe'}
            )
        }
        
        # ===== TÉRMICAS =====
        'EpsonTM20X' = @{
            Name = 'Epson TM-20X'
            Category = 'Thermal'
            DownloadToFolder = $true
            Files = @(
                @{Url='https://ftp.epson.com/latin/drivers/pos/APD_607R1_T20X_WM.zip'; FileName='Tm20X.zip'},
                @{Url='https://ftp.epson.com/drivers/pos/TMUSB800d.exe'; FileName='TMVirtualPort.exe'}
            )
        }
        'Bematech4200' = @{
            Name = 'Bematech MP-4200 TH'
            Category = 'Thermal'
            DownloadToFolder = $true
            Files = @(
                @{Url='https://baixar.programanex.com.br/extras/impressoras/BEMATECH/BEMA_MP_4200_TH_64.zip'; FileName='Bermatech4200.zip'}
            )
        }
        'HPRT' = @{
            Name = 'HPRT POS Printer'
            Category = 'Thermal'
            DownloadToFolder = $true
            Files = @(
                @{Url='https://static.hprt.com/hprt/file/20250515/HPRTUtilityForPOSSetup_V1.2.4.23.zip'; FileName='HPRT.zip'},
                @{Url='https://static.hprt.com/hprt/file/20250701/HPRT+POS+Printer+Driver+v2.7.4.10.zip'; FileName='HPRT_utili.zip'}
            )
        }
        'HPRTAres' = @{
            Name = 'HPRT Ares Label Printer'
            Category = 'Thermal'
            DownloadToFolder = $true
            Files = @(
                @{Url='https://static.hprt.com/hprt/file/20250429/HPRTPrinterUtility-V1.0.0.16.Test01.zip'; FileName='HPRTAres_driver.zip'},
                @{Url='https://static.hprt.com/hprt/file/20250427/HPRT-Label-Designer-BT2016_R6_3141_UL.zip'; FileName='HPRTAres_designer.zip'},
                @{Url='https://static.hprt.com/hprt/file/20250429/HPRT_Label_Derivative_Printer_Windows_Driver_v2.7.2.2.zip'; FileName='HPRTAres_utility.zip'}
            )
        }
        
        # ===== SCANNERS DE PRODUÇÃO =====
        'CanonDRC240' = @{
            Name = 'Canon DR-C240'
            Category = 'Scanner'
            DownloadToFolder = $true
            Files = @(
                @{Url='https://gdlp01.c-wss.com/gds/9/0100009799/05/DR-C240_Driver_V.1.4.11712.18001SP4_Windows.zip'; FileName='Driver.zip'},
                @{Url='https://gdlp01.c-wss.com/gds/0/0200006680/07/CaptureOnTouch_Pro_V5.5.1025.1217.zip'; FileName='CaptureOnTouch.zip'}
            )
        }
        'BrotherADS4700' = @{
            Name = 'Brother ADS-4700'
            Category = 'Scanner'
            Files = @(
                @{Url='https://download.brother.com/welcome/dlf106560/Y21F_C2_ULWT_PP-inst-J1.EXE'; FileName='ads4700.exe'}
            )
        }
        'BrotherADS2800' = @{
            Name = 'Brother ADS-2800'
            Category = 'Scanner'
            Files = @(
                @{Url='https://download.brother.com/welcome/dlf107270/Y15F_C1_ULWT_PP-inst-H1.EXE'; FileName='ads2800.exe'}
            )
        }
        'EpsonDS530' = @{
            Name = 'Epson DS-530'
            Category = 'Scanner'
            Files = @(
                @{Url='https://ftp.epson.com/drivers/DS530_Combo_AM.exe'; FileName='epson.exe'}
            )
        }
        
        # ===== UTILITÁRIOS =====
        'PrintWay' = @{
            Name = 'PrintWayy Cloud Print'
            Category = 'Utility'
            Files = @(
                @{Url='https://help.printwayy.com/wp-content/uploads/utilitarios/Setup%20PrintWayy.exe'; FileName='SetupPrintWayy.exe'}
            )
            PostInstall = {
                Start-Process "chrome.exe" -ArgumentList "https://app.printwayy.com/Account/Login?ReturnUrl=/"
            }
        }
        'NAPS2' = @{
            Name = 'NAPS2 Scanner Software'
            Category = 'Utility'
            Files = @(
                @{Url='https://github.com/cyanfish/naps2/releases/download/v8.2.1/naps2-8.2.1-win-x64.exe'; FileName='naps2-8.2.1-win-x64.exe'}
            )
        }
        'AdvancedIPScanner' = @{
            Name = 'Advanced IP Scanner'
            Category = 'Utility'
            Files = @(
                @{Url='https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe'; FileName='AIPScannerSetup.exe'}
            )
        }
    }
}

# ==================== PROCESSAMENTO ====================

function Install-Printer {
    param(
        [string]$PrinterKey
    )
    
    $database = Get-PrinterDatabase
    
    if (-not $database.ContainsKey($PrinterKey)) {
        Write-Log "Impressora não encontrada: $PrinterKey" -Type Error
        Write-Log "Use: .\PrinterTool.ps1 -ListPrinters para ver opções disponíveis" -Type Info
        return $false
    }
    
    $printer = $database[$PrinterKey]
    
    Write-Host ""
    Write-Log "═══════════════════════════════════════════════════" -Type Header
    Write-Log "  Instalando: $($printer.Name)" -Type Header
    Write-Log "═══════════════════════════════════════════════════" -Type Header
    Write-Host ""
    
    $downloadFolder = if ($printer.DownloadToFolder) {
        Join-Path $env:USERPROFILE "Downloads\$PrinterKey"
    } else {
        $Script:WorkDir
    }
    
    if ($printer.DownloadToFolder -and -not (Test-Path $downloadFolder)) {
        New-Item -ItemType Directory -Path $downloadFolder -Force | Out-Null
    }
    
    $fileCount = $printer.Files.Count
    $currentFile = 1
    
    foreach ($file in $printer.Files) {
        Write-Log "[$currentFile/$fileCount] Processando: $($file.FileName)" -Type Info
        
        $outputPath = Join-Path $downloadFolder $file.FileName
        
        if (Get-FileFromUrl -Url $file.Url -OutputFile $file.FileName) {
            if (-not $printer.DownloadToFolder) {
                Invoke-FileExecution -FilePath $outputPath
            }
        }
        
        $currentFile++
    }
    
    if ($printer.DownloadToFolder) {
        Write-Log "Arquivos salvos em: $downloadFolder" -Type Success
        Start-Process explorer.exe -ArgumentList $downloadFolder
    }
    
    if ($printer.PostInstall) {
        & $printer.PostInstall
    }
    
    Write-Host ""
    Write-Log "Instalação concluída!" -Type Success
    return $true
}

# ==================== MENUS INTERATIVOS ====================

function Show-Header {
    Clear-Host
    $width = 75
    Write-Host ("═" * $width) -ForegroundColor Yellow
    Write-Host ("  PrinterTool v$Script:Version - Gerenciador de Drivers").PadRight($width) -ForegroundColor White
    Write-Host ("═" * $width) -ForegroundColor Yellow
    Write-Host ""
}

function Show-MainMenu {
    while ($true) {
        Show-Header
        
        Write-Host "   [1] Baixar e Instalar PrintWay" -ForegroundColor Cyan
        Write-Host "   [2] Monocromáticas" -ForegroundColor Cyan
        Write-Host "   [3] Jatos de Tintas" -ForegroundColor Cyan
        Write-Host "   [4] Térmicas" -ForegroundColor Cyan
        Write-Host "   [5] NAPS2 (Scanner Software)" -ForegroundColor Cyan
        Write-Host "   [6] Advanced IP Scanner" -ForegroundColor Cyan
        Write-Host "   [7] Scanners de Produção" -ForegroundColor Cyan
        Write-Host "   [0] Sair" -ForegroundColor Red
        Write-Host ""
        
        $choice = Read-Host "Digite a opção"
        
        switch ($choice) {
            "1" { Install-Printer -PrinterKey 'PrintWay'; Read-Host "`nPressione ENTER para continuar" }
            "2" { Show-MonoMenu }
            "3" { Show-InkjetMenu }
            "4" { Show-ThermalMenu }
            "5" { Install-Printer -PrinterKey 'NAPS2'; Read-Host "`nPressione ENTER para continuar" }
            "6" { Install-Printer -PrinterKey 'AdvancedIPScanner'; Read-Host "`nPressione ENTER para continuar" }
            "7" { Show-ScannerMenu }
            "0" { 
                Write-Log "Encerrando PrinterTool..." -Type Info
                exit 
            }
            default {
                Write-Log "Opção inválida!" -Type Warning
                Start-Sleep -Seconds 1
            }
        }
    }
}

function Show-MonoMenu {
    while ($true) {
        Show-Header
        Write-Host "                    IMPRESSORAS MONOCROMÁTICAS" -ForegroundColor White
        Write-Host ("═" * 75) -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "   [1] HP 432          [2] HP 408          [3] HP 4103" -ForegroundColor Cyan
        Write-Host "   [4] HP 428          [5] Samsung 4020   [6] Canon 527" -ForegroundColor Cyan
        Write-Host "   [7] Canon 6030      [8] Canon 1643 v1  [9] Canon 1643 v2" -ForegroundColor Cyan
        Write-Host "   [10] Canon 1643 X   [11] Xerox 3020    [12] Xerox 205" -ForegroundColor Cyan
        Write-Host "   [13] Xerox 210      [14] Xerox 3335    [15] Xerox 3345" -ForegroundColor Cyan
        Write-Host "   [0] Voltar" -ForegroundColor Red
        Write-Host ""
        
        $choice = Read-Host "Digite a opção"
        
        switch ($choice) {
            "1"  { Install-Printer -PrinterKey 'HP432'; Read-Host "`nPressione ENTER" }
            "2"  { Install-Printer -PrinterKey 'HP408'; Read-Host "`nPressione ENTER" }
            "3"  { Install-Printer -PrinterKey 'HP4103'; Read-Host "`nPressione ENTER" }
            "4"  { Install-Printer -PrinterKey 'HP428'; Read-Host "`nPressione ENTER" }
            "5"  { Install-Printer -PrinterKey 'Samsung4020'; Read-Host "`nPressione ENTER" }
            "6"  { Install-Printer -PrinterKey 'Canon527'; Read-Host "`nPressione ENTER" }
            "7"  { Install-Printer -PrinterKey 'Canon6030'; Read-Host "`nPressione ENTER" }
            "8"  { Install-Printer -PrinterKey 'Canon1643v1'; Read-Host "`nPressione ENTER" }
            "9"  { Install-Printer -PrinterKey 'Canon1643v2'; Read-Host "`nPressione ENTER" }
            "10" { Install-Printer -PrinterKey 'Canon1643Xv2'; Read-Host "`nPressione ENTER" }
            "11" { Install-Printer -PrinterKey 'Xerox3020'; Read-Host "`nPressione ENTER" }
            "12" { Install-Printer -PrinterKey 'Xerox205'; Read-Host "`nPressione ENTER" }
            "13" { Install-Printer -PrinterKey 'Xerox210'; Read-Host "`nPressione ENTER" }
            "14" { Install-Printer -PrinterKey 'Xerox3335'; Read-Host "`nPressione ENTER" }
            "15" { Install-Printer -PrinterKey 'Xerox3345'; Read-Host "`nPressione ENTER" }
            "0"  { return }
            default { Write-Log "Opção inválida!" -Type Warning; Start-Sleep -Seconds 1 }
        }
    }
}

function Show-InkjetMenu {
    while ($true) {
        Show-Header
        Write-Host "                    IMPRESSORAS JATO DE TINTA" -ForegroundColor White
        Write-Host ("═" * 75) -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "   [1] Epson L3110     [2] Epson L3150    [3] Epson L3250" -ForegroundColor Cyan
        Write-Host "   [4] Epson L5590     [5] Epson L6190    [6] Epson L6270" -ForegroundColor Cyan
        Write-Host "   [7] Epson L6490     [8] Epson L805     [9] Epson L655" -ForegroundColor Cyan
        Write-Host "   [10] Epson WF 3720  [11] Epson WF 5899 [12] Epson WF 5710" -ForegroundColor Cyan
        Write-Host "   [13] Epson WF 5790  [14] Epson WF 5810 [15] Epson M1180" -ForegroundColor Cyan
        Write-Host "   [16] Epson M3180" -ForegroundColor Cyan
        Write-Host "   [0] Voltar" -ForegroundColor Red
        Write-Host ""
        
        $choice = Read-Host "Digite a opção"
        
        switch ($choice) {
            "1"  { Install-Printer -PrinterKey 'EpsonL3110'; Read-Host "`nPressione ENTER" }
            "2"  { Install-Printer -PrinterKey 'EpsonL3150'; Read-Host "`nPressione ENTER" }
            "3"  { Install-Printer -PrinterKey 'EpsonL3250'; Read-Host "`nPressione ENTER" }
            "4"  { Install-Printer -PrinterKey 'EpsonL5590'; Read-Host "`nPressione ENTER" }
            "5"  { Install-Printer -PrinterKey 'EpsonL6190'; Read-Host "`nPressione ENTER" }
            "6"  { Install-Printer -PrinterKey 'EpsonL6270'; Read-Host "`nPressione ENTER" }
            "7"  { Install-Printer -PrinterKey 'EpsonL6490'; Read-Host "`nPressione ENTER" }
            "8"  { Install-Printer -PrinterKey 'EpsonL805'; Read-Host "`nPressione ENTER" }
            "9"  { Install-Printer -PrinterKey 'EpsonL655'; Read-Host "`nPressione ENTER" }
            "10" { Install-Printer -PrinterKey 'EpsonWF3720'; Read-Host "`nPressione ENTER" }
            "11" { Install-Printer -PrinterKey 'EpsonWF5899'; Read-Host "`nPressione ENTER" }
            "12" { Install-Printer -PrinterKey 'EpsonWF5710'; Read-Host "`nPressione ENTER" }
            "13" { Install-Printer -PrinterKey 'EpsonWF5790'; Read-Host "`nPressione ENTER" }
            "14" { Install-Printer -PrinterKey 'EpsonWF5810'; Read-Host "`nPressione ENTER" }
            "15" { Install-Printer -PrinterKey 'EpsonM1180'; Read-Host "`nPressione ENTER" }
            "16" { Install-Printer -PrinterKey 'EpsonM3180'; Read-Host "`nPressione ENTER" }
            "0"  { return }
            default { Write-Log "Opção inválida!" -Type Warning; Start-Sleep -Seconds 1 }
        }
    }
}

function Show-ThermalMenu {
    while ($true) {
        Show-Header
        Write-Host "                    IMPRESSORAS TÉRMICAS" -ForegroundColor White
        Write-Host ("═" * 75) -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "   [1] Epson TM-20X (LAN/USB)" -ForegroundColor Cyan
        Write-Host "   [2] Bematech MP-4200 TH" -ForegroundColor Cyan
        Write-Host "   [3] HPRT POS Printer" -ForegroundColor Cyan
        Write-Host "   [4] HPRT Ares Label" -ForegroundColor Cyan
        Write-Host "   [0] Voltar" -ForegroundColor Red
        Write-Host ""
        
        $choice = Read-Host "Digite a opção"
        
        switch ($choice) {
            "1" { Install-Printer -PrinterKey 'EpsonTM20X'; Read-Host "`nPressione ENTER" }
            "2" { Install-Printer -PrinterKey 'Bematech4200'; Read-Host "`nPressione ENTER" }
            "3" { Install-Printer -PrinterKey 'HPRT'; Read-Host "`nPressione ENTER" }
            "4" { Install-Printer -PrinterKey 'HPRTAres'; Read-Host "`nPressione ENTER" }
            "0" { return }
            default { Write-Log "Opção inválida!" -Type Warning; Start-Sleep -Seconds 1 }
        }
    }
}

function Show-ScannerMenu {
    while ($true) {
        Show-Header
        Write-Host "                    SCANNERS DE PRODUÇÃO" -ForegroundColor White
        Write-Host ("═" * 75) -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "   [1] Canon DR-C240" -ForegroundColor Cyan
        Write-Host "   [2] Brother ADS-4700" -ForegroundColor Cyan
        Write-Host "   [3] Brother ADS-2800" -ForegroundColor Cyan
        Write-Host "   [4] Epson DS-530" -ForegroundColor Cyan
        Write-Host "   [0] Voltar" -ForegroundColor Red
        Write-Host ""
        
        $choice = Read-Host "Digite a opção"
        
        switch ($choice) {
            "1" { Install-Printer -PrinterKey 'CanonDRC240'; Read-Host "`nPressione ENTER" }
            "2" { Install-Printer -PrinterKey 'BrotherADS4700'; Read-Host "`nPressione ENTER" }
            "3" { Install-Printer -PrinterKey 'BrotherADS2800'; Read-Host "`nPressione ENTER" }
            "4" { Install-Printer -PrinterKey 'EpsonDS530'; Read-Host "`nPressione ENTER" }
            "0" { return }
            default { Write-Log "Opção inválida!" -Type Warning; Start-Sleep -Seconds 1 }
        }
    }
}

# ==================== CLI COMMANDS ====================

function Show-PrinterList {
    $database = Get-PrinterDatabase
    
    Write-Host ""
    Write-Host "═════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  IMPRESSORAS DISPONÍVEIS" -ForegroundColor White
    Write-Host "═════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    
    $categories = $database.Values | Group-Object -Property Category
    
    foreach ($category in $categories) {
        Write-Host "  $($category.Name):" -ForegroundColor Cyan
        foreach ($printer in $category.Group) {
            $key = ($database.GetEnumerator() | Where-Object { $_.Value -eq $printer }).Key
            Write-Host "    - $key : $($printer.Name)" -ForegroundColor White
        }
        Write-Host ""
    }
    
    Write-Host "Uso: .\PrinterTool.ps1 -Printer <PrinterKey>" -ForegroundColor Yellow
    Write-Host "Exemplo: .\PrinterTool.ps1 -Printer HP432" -ForegroundColor Yellow
    Write-Host ""
}

# ==================== MAIN ====================

function Main {
    # Banner
    Write-Host ""
    Write-Host "═════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  PrinterTool v$Script:Version - Ferramenta de Gerenciamento de Drivers" -ForegroundColor White
    Write-Host "═════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    
    # Verificar admin
    if (-not $NoAdmin -and -not (Test-Administrator)) {
        Write-Log "AVISO: Executando sem privilégios de administrador" -Type Warning
        Write-Log "Algumas funcionalidades podem não funcionar corretamente" -Type Warning
        Write-Host ""
    }
    
    # Inicializar diretório
    Initialize-WorkDirectory
    
    # Processar modo CLI
    if ($Printer) {
        Install-Printer -PrinterKey $Printer
        exit
    }
    
    # Modo interativo
    if ($Mode -eq 'Interactive') {
        Show-MainMenu
    }
}

# ==================== EXECUÇÃO ====================

Main
