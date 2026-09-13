$ErrorActionPreference = 'Stop'

$RepoRaw = "https://raw.githubusercontent.com/Sanjay18bala/avd/main"
$InstallDir = Join-Path $HOME "bin"

Write-Host "Installing avd..."

function Test-CommandExists($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Ensure-YtDlp {
    if (Test-CommandExists 'yt-dlp') { return }
    if (Test-CommandExists 'winget') {
        winget install --id yt-dlp.yt-dlp -e --silent --accept-package-agreements --accept-source-agreements
    } elseif (Test-CommandExists 'choco') {
        choco install yt-dlp -y
    } else {
        pip install --user -U yt-dlp
    }
}

function Ensure-Ffmpeg {
    if (Test-CommandExists 'ffmpeg') { return }
    if (Test-CommandExists 'winget') {
        winget install --id Gyan.FFmpeg -e --silent --accept-package-agreements --accept-source-agreements
    } elseif (Test-CommandExists 'choco') {
        choco install ffmpeg -y
    } else {
        Write-Warning "could not auto-install ffmpeg. Install it manually (e.g. via winget/choco), then re-run this script."
    }
}

Ensure-YtDlp
Ensure-Ffmpeg

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$localAvd = Join-Path $scriptDir "avd.ps1"
if (Test-Path $localAvd) {
    Copy-Item $localAvd (Join-Path $InstallDir "avd.ps1") -Force
} else {
    Invoke-WebRequest -Uri "$RepoRaw/avd.ps1" -OutFile (Join-Path $InstallDir "avd.ps1")
}

# Shim so `avd` works from cmd.exe too, not just PowerShell.
@"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0avd.ps1" %*
"@ | Set-Content -Path (Join-Path $InstallDir "avd.cmd") -Encoding ASCII

Write-Host "avd installed to $InstallDir"

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$InstallDir", 'User')
    Write-Host ""
    Write-Host "$InstallDir was added to your PATH. Restart your terminal for it to take effect."
}

Write-Host "Done. Try: avd -v ""<video url>"""
