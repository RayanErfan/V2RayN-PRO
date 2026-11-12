#Requires -Version 5.1
<#
.SYNOPSIS
    Validates every PRO configuration template against the bundled cores.

.DESCRIPTION
    Runs `sing-box check` against sing-box configs and `xray -test` against Xray
    configs shipped in this repository (guiConfigs\*.json and custom-*.txt/json).
    Exits with code 1 when any configuration is rejected by its core.

.PARAMETER SingBoxPath
    Path to the sing-box (or sing-box-plus) executable.

.PARAMETER XrayPath
    Path to the xray executable.

.PARAMETER RepoRoot
    Repository root. Defaults to the parent directory of this script.
#>
param(
    [Parameter(Mandatory = $true)][string]$SingBoxPath,
    [Parameter(Mandatory = $true)][string]$XrayPath,
    [string]$RepoRoot
)

$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
}

$SingBoxPath = (Resolve-Path $SingBoxPath).Path
$xrayFull = (Resolve-Path $XrayPath).Path
$RepoRoot = (Resolve-Path $RepoRoot).Path
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("pro-validate-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null

$script:failures = @()
$script:checks = 0

function Write-JsonFile {
    param([string]$Path, $Object)
    $json = $Object | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($Path, $json, (New-Object System.Text.UTF8Encoding($false)))
}

function Invoke-SingBoxCheck {
    param([string]$File)
    $script:checks++

    # `sing-box check` fully initialises the config (binds inbounds, runs the WARP
    # scanner). Sanitise the copy so validation stays fast and offline: drop the
    # scanner and ask the inbound to bind a random port.
    $sandbox = Join-Path $tmp ("sb-" + [guid]::NewGuid().ToString('N') + ".json")
    try {
        $cfg = Get-Content -Path $File -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($endpoint in @($cfg.endpoints)) {
            foreach ($peer in @($endpoint.peers)) {
                if ($peer) { $peer.PSObject.Properties.Remove('warp_scanner') }
            }
        }
        foreach ($inbound in @($cfg.inbounds)) {
            if ($inbound) { $inbound | Add-Member -NotePropertyName listen_port -NotePropertyValue 0 -Force }
        }
        Write-JsonFile -Path $sandbox -Object $cfg
    }
    catch {
        $script:failures += "cannot parse '$File': $($_.Exception.Message)"
        Write-Host "  FAIL json: $File" -ForegroundColor Red
        return $false
    }

    $out = & $SingBoxPath check -c $sandbox 2>&1
    if ($LASTEXITCODE -ne 0) {
        $script:failures += "sing-box rejected '$File':`n$($out -join "`n")"
        Write-Host "  FAIL sing-box: $File" -ForegroundColor Red
        return $false
    }
    Write-Host "  ok   sing-box: $([System.IO.Path]::GetFileName($File))" -ForegroundColor Green
    return $true
}

function Invoke-XrayCheck {
    param([string]$File)
    $script:checks++
    $out = & $xrayFull run -test -c $File 2>&1
    if ($LASTEXITCODE -ne 0) {
        $script:failures += "xray rejected '$File':`n$($out -join "`n")"
        Write-Host "  FAIL xray: $File" -ForegroundColor Red
        return $false
    }
    Write-Host "  ok   xray: $([System.IO.Path]::GetFileName($File))" -ForegroundColor Green
    return $true
}

function Test-ConfigFile {
    param([string]$File)
    $text = Get-Content -Path $File -Raw -Encoding UTF8

    # Some templates are JSON arrays (one profile per entry). Validate each entry.
    $data = $text | ConvertFrom-Json
    if ($data -is [System.Array]) {
        $i = 0
        foreach ($entry in $data) {
            $i++
            $single = Join-Path $tmp ("{0}.{1}.json" -f [System.IO.Path]::GetFileNameWithoutExtension($File), $i)
            Write-JsonFile -Path $single -Object $entry
            if ($entry.PSObject.Properties.Name -contains 'route' -or $entry.PSObject.Properties.Name -contains 'endpoints') {
                Invoke-SingBoxCheck -File $single | Out-Null
            }
            else {
                Invoke-XrayCheck -File $single | Out-Null
            }
        }
        return
    }

    if ($data.PSObject.Properties.Name -contains 'route' -or $data.PSObject.Properties.Name -contains 'endpoints') {
        Invoke-SingBoxCheck -File $File | Out-Null
    }
    else {
        Invoke-XrayCheck -File $File | Out-Null
    }
}

try {
    Write-Host "Validating guiConfigs..." -ForegroundColor Cyan
    Get-ChildItem -Path (Join-Path $RepoRoot 'guiConfigs') -Filter '*.json' |
        Where-Object { $_.Name -ne 'guiNConfig.json' } |
        ForEach-Object { Test-ConfigFile -File $_.FullName }

    Write-Host "Validating templates..." -ForegroundColor Cyan
    foreach ($name in 'custom-config-sub.txt', 'custom-xray-sub.json', 'custom-sb-config-sub.txt', 'custom-singbox-sub.json') {
        $file = Join-Path $RepoRoot $name
        if (Test-Path $file) {
            Test-ConfigFile -File $file
        }
    }

    if ($script:failures.Count -gt 0) {
        Write-Host "`n$($script:failures.Count) of $($script:checks) checks failed." -ForegroundColor Red
        exit 1
    }
    Write-Host "`nAll $($script:checks) configuration checks passed." -ForegroundColor Green
    exit 0
}
finally {
    Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

