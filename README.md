# avd

`avd` downloads video or audio at the highest available quality from
YouTube, TikTok, Instagram Reels, and anywhere else
[yt-dlp](https://github.com/yt-dlp/yt-dlp) supports. It's a thin CLI wrapper
around yt-dlp + ffmpeg: it has no per-platform logic, so any site yt-dlp
knows about works here for free.

## Install

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/Sanjay18bala/avd/main/install.sh | bash
```

This installs `yt-dlp` and `ffmpeg` (via Homebrew if available, otherwise
pip/apt fallbacks) and puts `avd` in `~/.local/bin`.

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/Sanjay18bala/avd/main/install.ps1 | iex
```

This installs `yt-dlp` and `ffmpeg` (via winget if available, otherwise
choco/pip fallbacks) and puts `avd` in `%USERPROFILE%\bin`, usable from both
PowerShell and cmd.exe.

## Usage

```sh
avd -v "https://www.youtube.com/watch?v=..."      # video
avd -a "https://www.youtube.com/watch?v=..."      # audio only, extracted to mp3
avd -v "https://www.tiktok.com/@user/video/..."
avd -v "https://www.instagram.com/reel/..."
```

Files save to `~/Downloads`.

## Uninstall

macOS / Linux:

```sh
rm -f ~/.local/bin/avd
```

Windows:

```powershell
Remove-Item "$HOME\bin\avd.ps1", "$HOME\bin\avd.cmd"
```
