#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Destination = "$HOME\Downloads\Invoke-EXISTENZA-Mega-Recovery-v1_0_0.ps1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ExpectedHash = "300c968d100be3088eee820a9a8ba7a0e2fcd6aece10bae6f0ef37d8fcfa41dc"
$BaseUrl = "https://raw.githubusercontent.com/Gestionale2050/gestionale-ecommerce/artifact/existenza-recovery/tools/existenza-recovery-payload-gzip"

Write-Host "Recupero del mega script EXISTENZA..." -ForegroundColor Cyan

$Builder = New-Object System.Text.StringBuilder
foreach ($Index in 1..3) {
    $Name = "part-{0:D2}.b64" -f $Index
    $Url = "$BaseUrl/$Name"
    Write-Host "  Download $Name" -ForegroundColor DarkCyan
    $Part = (Invoke-WebRequest -UseBasicParsing -Uri $Url -TimeoutSec 60).Content.Trim()
    if ([string]::IsNullOrWhiteSpace($Part)) {
        throw "Payload vuoto: $Url"
    }
    [void]$Builder.Append($Part)
}

$CompressedBytes = [Convert]::FromBase64String($Builder.ToString())
$CompressedStream = New-Object System.IO.MemoryStream(,$CompressedBytes)
$GzipStream = New-Object System.IO.Compression.GZipStream(
    $CompressedStream,
    [System.IO.Compression.CompressionMode]::Decompress
)
$OutputStream = New-Object System.IO.MemoryStream

try {
    $Buffer = New-Object byte[] 81920
    while (($Read = $GzipStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {
        $OutputStream.Write($Buffer, 0, $Read)
    }
    $ScriptBytes = $OutputStream.ToArray()
}
finally {
    $GzipStream.Dispose()
    $CompressedStream.Dispose()
    $OutputStream.Dispose()
}

$Parent = Split-Path -Parent $Destination
if (-not (Test-Path -LiteralPath $Parent -PathType Container)) {
    New-Item -ItemType Directory -Path $Parent -Force | Out-Null
}

[System.IO.File]::WriteAllBytes($Destination, $ScriptBytes)
$ActualHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash.ToLowerInvariant()

if ($ActualHash -ne $ExpectedHash) {
    Remove-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    throw "Integrita non valida. Atteso: $ExpectedHash - Effettivo: $ActualHash"
}

$Tokens = $null
$ParseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile(
    $Destination,
    [ref]$Tokens,
    [ref]$ParseErrors
)
if ($ParseErrors.Count -gt 0) {
    Remove-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    $Details = ($ParseErrors | ForEach-Object { $_.Message }) -join " | "
    throw "Parsing PowerShell fallito: $Details"
}

Write-Host "" 
Write-Host "Script creato e verificato:" -ForegroundColor Green
Write-Host $Destination
Write-Host "SHA-256: $ActualHash" -ForegroundColor Green
Write-Host "" 
Write-Host "Non e stato ancora eseguito. Avvialo inizialmente in modalita baseline:" -ForegroundColor Yellow
Write-Host ('& "{0}" -ExpectedSelfHash "{1}" -DeepContentScan' -f $Destination, $ExpectedHash)
