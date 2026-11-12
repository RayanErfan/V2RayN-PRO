<#
.SYNOPSIS
    Builds the V2RayN-PRO distribution package.

.DESCRIPTION
    Downloads the latest (or pinned) v2rayN desktop build and the PRO core
    stack, drops the PRO configuration on top and produces the release zips.

    Cores used by PRO:
      * v2rayN      - https://github.com/2dust/v2rayN
      * sing-box-plus (kyochikuto fork, required by the PRO sing-box template)
      * Xray-core MahsaNG (GFW-knocker fork)
      * mihomo (MetaCubeX)
      * Iran geo data (Chocolate4U)

.PARAMETER Version
    Version label written to the package (default: date based).

.PARAMETER V2rayNVersion / SingBoxPlusVersion / XrayVersion / MihomoVersion / GeoVersion
    Pinned tag, or "latest".

.PARAMETER OutputDir
    Where the zips are written (default: <repo>\output).

.PARAMETER ValidateOnly
    Download the cores and validate the repository configs, do not build.

.PARAMETER SkipCores
    Only produce the configs-only archive.

.EXAMPLE
    pwsh ./scripts/build-release.ps1 -Version V2RayN-PROv2.1
#>
param(
    [string]$Version = "",
    [string]$V2rayNVersion = "latest",
    [string]$SingBoxPlusVersion = "latest",
    [string]$XrayVersion = "latest",
    [string]$MihomoVersion = "latest",
    [string]$GeoVersion = "latest",
    [string]$OutputDir,
    [switch]$ResolveOnly,
    [switch]$ValidateOnly,
    [switch]$SkipCores,
    [switch]$KeepWork
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.IO.Compression.FileSystem

$RepoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
if (-not $OutputDir) { $OutputDir = Join-Path $RepoRoot 'output' }
if (-not $Version) { $Version = "V2RayN-PROv" + (Get-Date -Format 'yyyy.MM.dd') }

$apiHeaders = @{
    'User-Agent' = 'v2rayN-PRO-build'
    'Accept'     = 'application/vnd.github+json'
}
if (Test-Path Env:\GITHUB_TOKEN) { $apiHeaders['Authorization'] = "Bearer $env:GITHUB_TOKEN" }

$work = Join-Path ([System.IO.Path]::GetTempPath()) ("vnpro-build-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work -Force | Out-Null

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Get-Release([string]$Repo, [string]$Tag) {
    if ($Tag -and $Tag -ne 'latest') {
        return Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/tags/$Tag" -Headers $apiHeaders
    }
    return Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest" -Headers $apiHeaders
}

function Save-File([string]$Uri, [string]$OutFile) {
    $attempt = 0
    while ($true) {
        $attempt++
        try {
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing -Headers @{ 'User-Agent' = 'v2rayN-PRO-build' }
            return
        }
        catch {
            if ($attempt -ge 3) { throw "Download failed: $Uri`n$($_.Exception.Message)" }
            Write-Warning "Download attempt $attempt failed, retrying: $Uri"
            Start-Sleep -Seconds (3 * $attempt)
        }
    }
}

function Expand-Zip([string]$Zip, [string]$Destination) {
    if (Test-Path $Destination) { Remove-Item $Destination -Recurse -Force }
    [System.IO.Compression.ZipFile]::ExtractToDirectory($Zip, $Destination)
}

function Get-Asset($Release, [string]$Pattern) {
    $asset = $Release.assets | Where-Object { $_.name -match $Pattern } | Select-Object -First 1
    if (-not $asset) {
        throw "No asset matching '$Pattern' in release $($Release.tag_name). Assets: $(($Release.assets | ForEach-Object name) -join ', ')"
    }
    return $asset
}

try {
    Write-Step "Resolving versions"
    $relV2rayN = Get-Release '2dust/v2rayN' $V2rayNVersion
    $relSingBox = Get-Release 'kyochikuto/sing-box-plus' $SingBoxPlusVersion
    $relXray = Get-Release 'GFW-knocker/Xray-core' $XrayVersion
    $relMihomo = Get-Release 'MetaCubeX/mihomo' $MihomoVersion
    $relGeo = Get-Release 'chocolate4u/Iran-v2ray-rules' $GeoVersion

    $versions = [ordered]@{
        version    = $Version
        v2rayN     = $relV2rayN.tag_name
        singBoxPlus = $relSingBox.tag_name
        xrayMahsa  = $relXray.tag_name
        mihomo     = $relMihomo.tag_name
        iranGeo    = $relGeo.tag_name
        builtAt    = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    }
    $versions.GetEnumerator() | ForEach-Object { Write-Host ("  {0,-12} {1}" -f $_.Key, $_.Value) }

    if ($ResolveOnly) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
        $versions | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $OutputDir 'versions.json') -Encoding UTF8
        exit 0
    }

    Write-Step "Downloading cores"
    $assetV2rayN = Get-Asset $relV2rayN '^v2rayN-windows-64-desktop\.zip$'
    $assetSingBox = Get-Asset $relSingBox 'windows-amd64\.zip$'
    $assetXray = Get-Asset $relXray '^Xray-windows-64\.zip$'
    $assetMihomo = Get-Asset $relMihomo '^mihomo-windows-amd64-compatible-v.*\.zip$'

    $zipV2rayN = Join-Path $work 'v2rayn.zip'
    $zipSingBox = Join-Path $work 'singbox.zip'
    $zipXray = Join-Path $work 'xray.zip'
    $zipMihomo = Join-Path $work 'mihomo.zip'

    Save-File $assetV2rayN.browser_download_url $zipV2rayN
    Save-File $assetSingBox.browser_download_url $zipSingBox
    Save-File $assetXray.browser_download_url $zipXray
    Save-File $assetMihomo.browser_download_url $zipMihomo

    Expand-Zip $zipV2rayN (Join-Path $work 'v2rayn')
    Expand-Zip $zipSingBox (Join-Path $work 'singbox')
    Expand-Zip $zipXray (Join-Path $work 'xray')
    Expand-Zip $zipMihomo (Join-Path $work 'mihomo')

    $v2rayNDir = (Get-ChildItem (Join-Path $work 'v2rayn') -Directory | Select-Object -First 1).FullName
    if (-not $v2rayNDir) { $v2rayNDir = Join-Path $work 'v2rayn' }

    $xrayExe = (Get-ChildItem (Join-Path $work 'xray') -Recurse -Filter 'xray.exe' | Select-Object -First 1).FullName
    $wintunDll = (Get-ChildItem (Join-Path $work 'xray') -Recurse -Filter 'wintun.dll' | Select-Object -First 1)
    $singBoxDir = (Get-ChildItem (Join-Path $work 'singbox') -Directory | Select-Object -First 1).FullName
    $mihomoExe = (Get-ChildItem (Join-Path $work 'mihomo') -Recurse -Filter 'mihomo-windows-amd64-compatible*.exe' | Select-Object -First 1).FullName

    if ($ValidateOnly) {
        Write-Step "Validating repository configurations"
        & (Join-Path $RepoRoot 'scripts\validate-configs.ps1') `
            -SingBoxPath (Join-Path $singBoxDir 'sing-box.exe') `
            -XrayPath $xrayExe `
            -RepoRoot $RepoRoot
        exit $LASTEXITCODE
    }

    # Iran geo data (Xray .dat + mihomo Country.mmdb)
    Write-Step "Downloading Iran geo data ($($relGeo.tag_name))"
    $geoDir = Join-Path $work 'geo'
    New-Item -ItemType Directory -Path $geoDir -Force | Out-Null
    foreach ($name in 'geosite.dat', 'geoip.dat', 'Country.mmdb') {
        Save-File "https://github.com/chocolate4u/Iran-v2ray-rules/releases/latest/download/$name" (Join-Path $geoDir $name)
    }

    # Iran sing-box rule-sets (cached locally, the PRO ships them)
    Write-Step "Downloading Iran sing-box rule-sets"
    $srsDir = Join-Path $work 'srss'
    New-Item -ItemType Directory -Path $srsDir -Force | Out-Null
    $srsTags = @(
        'geoip-cn', 'geoip-facebook', 'geoip-fastly', 'geoip-google', 'geoip-ir',
        'geoip-netflix', 'geoip-private', 'geoip-telegram', 'geoip-twitter',
        'geosite-category-ads-all', 'geosite-category-ir', 'geosite-cn',
        'geosite-geolocation-!cn', 'geosite-geolocation-cn', 'geosite-greatfire',
        'geosite-ir', 'geosite-private'
    )
    foreach ($tag in $srsTags) {
        Save-File "https://cdn.jsdelivr.net/gh/Chocolate4U/Iran-sing-box-rules@rule-set/$tag.srs" (Join-Path $srsDir "$tag.srs")
    }

    Write-Step "Assembling package"
    $distRoot = Join-Path $work 'dist'
    $dist = Join-Path $distRoot 'V2RayN-PRO'
    New-Item -ItemType Directory -Path $distRoot -Force | Out-Null
    Copy-Item $v2rayNDir $dist -Recurse

    # cores
    Copy-Item $xrayExe (Join-Path $dist 'bin\xray\xray.exe') -Force
    if ($wintunDll) { Copy-Item $wintunDll.FullName (Join-Path $dist 'bin\xray\wintun.dll') -Force }
    Copy-Item (Join-Path $singBoxDir 'sing-box.exe') (Join-Path $dist 'bin\sing_box\sing-box.exe') -Force
    if (Test-Path (Join-Path $singBoxDir 'libcronet.dll')) {
        Copy-Item (Join-Path $singBoxDir 'libcronet.dll') (Join-Path $dist 'bin\sing_box\libcronet.dll') -Force
    }
    Copy-Item $mihomoExe (Join-Path $dist 'bin\mihomo\mihomo.exe') -Force

    # geo data
    Copy-Item (Join-Path $geoDir 'geosite.dat') (Join-Path $dist 'bin\geosite.dat') -Force
    Copy-Item (Join-Path $geoDir 'geoip.dat') (Join-Path $dist 'bin\geoip.dat') -Force
    Copy-Item (Join-Path $geoDir 'Country.mmdb') (Join-Path $dist 'bin\Country.mmdb') -Force
    # Xray >= 25 reads data files next to the executable
    Copy-Item (Join-Path $geoDir 'geosite.dat') (Join-Path $dist 'bin\xray\geosite.dat') -Force
    Copy-Item (Join-Path $geoDir 'geoip.dat') (Join-Path $dist 'bin\xray\geoip.dat') -Force

    # rule-sets
    $distSrs = Join-Path $dist 'bin\srss'
    if (Test-Path $distSrs) { Get-ChildItem $distSrs -File | Remove-Item -Force }
    else { New-Item -ItemType Directory -Path $distSrs -Force | Out-Null }
    Copy-Item (Join-Path $srsDir '*.srs') $distSrs -Force

    # PRO configuration
    $distConfigs = Join-Path $dist 'guiConfigs'
    if (Test-Path $distConfigs) { Remove-Item $distConfigs -Recurse -Force }
    Copy-Item (Join-Path $RepoRoot 'guiConfigs') $distConfigs -Recurse

    # docs and version stamp
    foreach ($doc in 'LICENSE', 'CHANGELOG.md', 'README_EN.md', 'README.md') {
        $src = Join-Path $RepoRoot $doc
        if (Test-Path $src) { Copy-Item $src (Join-Path $dist $doc) -Force }
    }
    $stamp = @(
        "V2RayN-PRO $Version",
        "v2rayN:        $($versions.v2rayN)",
        "sing-box-plus: $($versions.singBoxPlus)",
        "Xray MahsaNG:  $($versions.xrayMahsa)",
        "mihomo:        $($versions.mihomo)",
        "Iran geo:      $($versions.iranGeo)",
        "built:         $($versions.builtAt)"
    ) -join [Environment]::NewLine
    [System.IO.File]::WriteAllText((Join-Path $dist 'PRO-VERSION.txt'), $stamp, (New-Object System.Text.UTF8Encoding($false)))

    Write-Step "Validating assembled configurations"
    & (Join-Path $RepoRoot 'scripts\validate-configs.ps1') `
        -SingBoxPath (Join-Path $dist 'bin\sing_box\sing-box.exe') `
        -XrayPath (Join-Path $dist 'bin\xray\xray.exe') `
        -RepoRoot $RepoRoot
    if ($LASTEXITCODE -ne 0) { throw "Configuration validation failed" }

    Write-Step "Creating archives"
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    $fullZip = Join-Path $OutputDir "V2RayN-PRO-Windows-x64-$Version.zip"
    if (Test-Path $fullZip) { Remove-Item $fullZip -Force }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($distRoot, $fullZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)

    # configs only
    $cfgRoot = Join-Path $work 'cfgroot'
    $cfgDir = Join-Path $cfgRoot 'V2RayN-PRO-configs'
    New-Item -ItemType Directory -Path $cfgDir -Force | Out-Null
    Copy-Item (Join-Path $RepoRoot 'guiConfigs') (Join-Path $cfgDir 'guiConfigs') -Recurse
    foreach ($f in 'custom-config-sub.txt', 'custom-sb-config-sub.txt', 'custom-singbox-sub.json', 'custom-xray-sub.json',
        'SingBox-Rules.json', 'subscribe.txt', 'WireGaurd-WoW.conf', 'README_EN.md', 'README.md', 'CHANGELOG.md') {
        $src = Join-Path $RepoRoot $f
        if (Test-Path $src) { Copy-Item $src (Join-Path $cfgDir $f) -Force }
    }
    $cfgZip = Join-Path $OutputDir "V2RayN-PRO-Configs-Only-$Version.zip"
    if (Test-Path $cfgZip) { Remove-Item $cfgZip -Force }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($cfgRoot, $cfgZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)

    Write-Step "Hashes and metadata"
    $files = Get-ChildItem $OutputDir -Filter "*-$Version.zip"
    $lines = foreach ($f in $files) {
        $hash = (Get-FileHash $f.FullName -Algorithm SHA256).Hash.ToLower()
        "$hash  $($f.Name)"
    }
    [System.IO.File]::WriteAllLines((Join-Path $OutputDir 'SHA256SUMS.txt'), $lines, (New-Object System.Text.UTF8Encoding($false)))

    $versions | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $OutputDir 'versions.json') -Encoding UTF8

    $notes = @"
## V2RayN-PRO $Version

| Component | Version |
|---|---|
| v2rayN | $($versions.v2rayN) |
| sing-box-plus | $($versions.singBoxPlus) |
| Xray-core (MahsaNG) | $($versions.xrayMahsa) |
| mihomo | $($versions.mihomo) |
| Iran geo data | $($versions.iranGeo) |

### Assets

* ``V2RayN-PRO-Windows-x64-$Version.zip`` - complete package (extract and run).
* ``V2RayN-PRO-Configs-Only-$Version.zip`` - PRO configuration only (use with an existing v2rayN).

### Install

1. Download and extract the Windows zip.
2. Run ``v2rayN.exe`` (run as administrator if you use TUN mode).
3. The PRO configuration, routing rules and Iran geo data are already applied.

Existing users: back up ``guiConfigs`` first, then replace the application files but keep your
``guiConfigs`` if you want to retain your own servers and subscriptions.
"@
    [System.IO.File]::WriteAllText((Join-Path $OutputDir 'release-notes.md'), $notes, (New-Object System.Text.UTF8Encoding($false)))

    Write-Step "Done"
    $files | ForEach-Object { Write-Host ("  {0} ({1:N1} MB)" -f $_.Name, ($_.Length / 1MB)) }
}
finally {
    if (-not $KeepWork) { Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue }
}

