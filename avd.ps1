# avd - download video/audio at the highest available quality (Windows)
# Native PowerShell counterpart to `avd`. Same flags, same yt-dlp/ffmpeg backend.

$Version = "1.0.0"

function Show-Usage {
    @'
avd - download video/audio at the highest available quality

Usage:
  avd -v <url>   Download video (YouTube, TikTok, Instagram Reels, and
                 anything else yt-dlp supports)
  avd -a <url>   Download audio only, as mp3
                 (in an interactive terminal, prompts for quality)
  avd -h, --help       Show this help
  avd --version        Show version

Files are saved to ~\Downloads.
'@
}

if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
    Write-Error "yt-dlp is not installed. Run install.ps1 from https://github.com/Sanjay18bala/avd, or 'winget install yt-dlp.yt-dlp'."
    exit 1
}

if ($args.Count -eq 0 -or $args[0] -in @('-h', '--help')) {
    Show-Usage
    exit 0
}

if ($args[0] -eq '--version') {
    Write-Output "avd $Version"
    exit 0
}

$mode = $null
$url = $null
for ($i = 0; $i -lt $args.Count; $i++) {
    switch ($args[$i]) {
        '-v' { $mode = 'video'; $i++; $url = $args[$i] }
        '-a' { $mode = 'audio'; $i++; $url = $args[$i] }
    }
}

if (-not $mode -or -not $url) {
    Show-Usage
    exit 1
}

function Show-ArrowMenu {
    param([string[]]$Options)
    $sel = 0
    $n = $Options.Count
    $top = [Console]::CursorTop

    function Draw {
        [Console]::SetCursorPosition(0, $top)
        for ($i = 0; $i -lt $n; $i++) {
            $line = if ($i -eq $sel) { "> $($Options[$i])" } else { "  $($Options[$i])" }
            Write-Host $line.PadRight([Console]::WindowWidth - 1)
        }
    }

    Draw
    while ($true) {
        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            'UpArrow'   { $sel = ($sel - 1 + $n) % $n; Draw }
            'DownArrow' { $sel = ($sel + 1) % $n; Draw }
            'Enter'     { return $sel }
        }
    }
}

function Select-Quality {
    param([string]$Mode, [string]$Url)

    Write-Host "Fetching available qualities..."

    $json = yt-dlp -j --skip-download -q --no-warnings $Url 2>$null
    if (-not $json) { return $null }

    $formats = ($json | ConvertFrom-Json).formats

    if ($Mode -eq 'video') {
        $vals = @($formats |
            Where-Object { $_.vcodec -and $_.vcodec -ne 'none' -and $_.height } |
            ForEach-Object { $_.height } | Sort-Object -Unique -Descending | Select-Object -First 4)
        $labels = @($vals | ForEach-Object { "${_}p" + $(if ($_ -ge 2160) { " (4K)" } else { "" }) })
    } else {
        $vals = @($formats |
            Where-Object { (-not $_.vcodec -or $_.vcodec -eq 'none') -and $_.acodec -and $_.acodec -ne 'none' -and $_.abr } |
            ForEach-Object { [math]::Round($_.abr) } | Sort-Object -Unique -Descending | Select-Object -First 4)
        $labels = @($vals | ForEach-Object { "${_}kbps" })
    }

    if (-not $vals -or $vals.Count -eq 0) { return $null }
    $labels[0] += " (highest)"

    Write-Host ""
    Write-Host "Available qualities (Up/Down arrows, Enter to select):"
    Write-Host ""
    $idx = Show-ArrowMenu -Options $labels
    Write-Host ""
    return $vals[$idx]
}

function Resolve-UniquePath {
    param([string]$FormatSel, [string]$Template, [string]$Url, [string]$KnownExt)

    $base = yt-dlp -f $FormatSel --skip-download -q --no-warnings --print filename -o $Template $Url 2>$null
    if (-not $base) { return $null }

    $base = [System.IO.Path]::ChangeExtension($base, $KnownExt)
    if (-not (Test-Path -LiteralPath $base)) { return $base }

    $dir = Split-Path $base -Parent
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($base)
    $n = 1
    while (Test-Path -LiteralPath (Join-Path $dir "$stem ($n).$KnownExt")) { $n++ }
    return (Join-Path $dir "$stem ($n).$KnownExt")
}

$chosen = $null
$interactive = [Environment]::UserInteractive -and -not [Console]::IsOutputRedirected -and -not [Console]::IsInputRedirected
if ($interactive) {
    $chosen = Select-Quality -Mode $mode -Url $url
}

$downloadsDir = Join-Path $HOME "Downloads"
New-Item -ItemType Directory -Force -Path $downloadsDir | Out-Null

$videoTemplate = Join-Path $downloadsDir "%(title)s [%(height)sp] [%(id)s].%(ext)s"
$audioTemplate = Join-Path $downloadsDir "%(title)s [%(abr)dk] [%(id)s].%(ext)s"

if ($mode -eq 'video') {
    $videoFormat = if ($chosen) { "bestvideo[height<=$chosen]+bestaudio/best[height<=$chosen]" } else { "bestvideo+bestaudio/best" }
    $finalPath = Resolve-UniquePath -FormatSel $videoFormat -Template $videoTemplate -Url $url -KnownExt 'mp4'
    if (-not $finalPath) { $finalPath = $videoTemplate }
    yt-dlp -f $videoFormat --recode-video mp4 -o $finalPath --progress --newline $url
} else {
    $audioFormat = if ($chosen) { "bestaudio[abr<=$chosen]/bestaudio" } else { "bestaudio/best" }
    $finalPath = Resolve-UniquePath -FormatSel $audioFormat -Template $audioTemplate -Url $url -KnownExt 'mp3'
    if (-not $finalPath) { $finalPath = $audioTemplate }
    yt-dlp -f $audioFormat -x --audio-format mp3 --audio-quality 0 -o $finalPath --progress --newline $url
}
