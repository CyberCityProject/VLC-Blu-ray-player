# Installe VLC et les fichiers necessaires pour lire un Blu-ray physique.
# Usage : clic droit > Executer avec PowerShell, ou :
#   powershell -ExecutionPolicy Bypass -File .\vlc-bluray-setup.ps1
#
# Les disques du commerce sont chiffres (AACS). VLC ne peut pas embarquer
# la base de cles. Ce script la telecharge depuis la base publique FindVUK
# et copie les bibliotheques ouvertes libaacs / libbdplus a cote de VLC.
# Un Blu-ray Ultra HD (4K) reste en general illisible dans VLC.

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$KeyDbUrl = "https://fvonline-db.bplaced.net/fv_download.php?lang=fra"
$DllApi   = "https://api.github.com/repos/KnugiHK/libaacs-libbdplus-windows/releases/latest"

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host "Relance en administrateur (copie dans Program Files)..."
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process -FilePath "powershell.exe" -ArgumentList $arg -Verb RunAs
    exit
}

function Get-VlcDir {
    $candidates = @(
        "$env:ProgramFiles\VideoLAN\VLC",
        "${env:ProgramFiles(x86)}\VideoLAN\VLC"
    )
    foreach ($dir in $candidates) {
        if (Test-Path (Join-Path $dir "vlc.exe")) { return $dir }
    }
    return $null
}

Write-Host "== VLC =="
$vlcDir = Get-VlcDir
if (-not $vlcDir) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget est absent et VLC n'est pas installe. Installe VLC depuis https://www.videolan.org/ puis relance ce script."
    }
    winget install --id VideoLAN.VLC -e --accept-package-agreements --accept-source-agreements
    $vlcDir = Get-VlcDir
}
if (-not $vlcDir) { throw "VLC introuvable apres l'installation." }
Write-Host "VLC : $vlcDir"

$is64 = $vlcDir -notlike "*Program Files (x86)*"
$archDir = $(if ($is64) { "winx64" } else { "winx86" })
Write-Host "Architecture : $archDir"

$work = Join-Path $env:TEMP "vlc-bluray-setup"
New-Item -ItemType Directory -Force -Path $work | Out-Null

function Save-Url([string]$Url, [string]$Dest) {
    Write-Host "Telechargement : $Url"
    Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing -Headers @{ "User-Agent" = "vlc-bluray-setup" }
}

Write-Host "== Bibliotheques =="
# vlc-bluray.whoknowsmy.name ne publie plus les DLL.
# Binaires maintenus : https://github.com/KnugiHK/libaacs-libbdplus-windows
$release = Invoke-RestMethod -Uri $DllApi -Headers @{ "User-Agent" = "vlc-bluray-setup" }
$asset = $release.assets | Where-Object { $_.name -eq "libaacs_libbdplus.zip" } | Select-Object -First 1
if (-not $asset) { throw "Archive libaacs_libbdplus.zip absente de la derniere release GitHub." }
Write-Host "Version : $($release.tag_name)"

$dllZip = Join-Path $work "libaacs_libbdplus.zip"
Save-Url $asset.browser_download_url $dllZip
$dllRoot = Join-Path $work "dlls"
if (Test-Path $dllRoot) { Remove-Item $dllRoot -Recurse -Force }
Expand-Archive -Path $dllZip -DestinationPath $dllRoot -Force

$archPath = Get-ChildItem $dllRoot -Recurse -Directory | Where-Object { $_.Name -eq $archDir } | Select-Object -First 1
if (-not $archPath) { throw "Dossier $archDir introuvable dans l'archive." }

$dlls = Get-ChildItem $archPath.FullName -Filter *.dll
if (-not ($dlls.Name -contains "libaacs.dll")) { throw "libaacs.dll absent du dossier $archDir." }
foreach ($dll in $dlls) {
    $head = [System.IO.File]::ReadAllBytes($dll.FullName)[0..1]
    if ($head[0] -ne 0x4D -or $head[1] -ne 0x5A) {
        throw "$($dll.Name) n'est pas une bibliotheque Windows."
    }
    Copy-Item $dll.FullName (Join-Path $vlcDir $dll.Name) -Force
    Write-Host "Copie : $vlcDir\$($dll.Name)"
}

Write-Host "== Base de cles =="
$zip = Join-Path $work "keydb.zip"
Save-Url $KeyDbUrl $zip
$unzip = Join-Path $work "keydb"
if (Test-Path $unzip) { Remove-Item $unzip -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $unzip -Force
$cfg = Get-ChildItem $unzip -Recurse -File | Where-Object { $_.Name -match '^(KEYDB|keydb)\.cfg$' } | Select-Object -First 1
if (-not $cfg) { throw "KEYDB.cfg absent de l'archive telechargee." }

$targets = @(
    (Join-Path $env:APPDATA "aacs"),
    (Join-Path $env:ProgramData "aacs")
)
foreach ($dir in $targets) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $out = Join-Path $dir "KEYDB.cfg"
    Copy-Item $cfg.FullName $out -Force
    attrib -R $out
    Write-Host "Copie : $out"
}

Write-Host ""
Write-Host "Termine."
Write-Host "Dans VLC : Media > Ouvrir un disque > Blu-ray > le lecteur du disque."
Write-Host "Si le menu bloque la lecture, ouvre le disque en dossier et choisis le plus gros fichier BDMV\STREAM\*.m2ts."
Write-Host "Les Blu-ray Ultra HD (4K) ne sont en general pas lus par VLC."
