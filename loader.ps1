$ErrorActionPreference = "Stop"

$url = "https://raw.githubusercontent.com/Rarth1997/Printer-Scan-M-P/main/e_essa.bat"
$out = "$env:TEMP\printer_tool.bat"

Write-Host "Baixando script..." -ForegroundColor Cyan

Invoke-WebRequest $url -OutFile $out

if (!(Test-Path $out)) {
    Write-Host "Erro ao baixar o script!" -ForegroundColor Red
    exit
}

Write-Host "Executando..." -ForegroundColor Green

Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$out`"" -Verb RunAs
