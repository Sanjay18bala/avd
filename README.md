# avd

Download video or audio at the highest available quality from YouTube,
TikTok, Instagram Reels, and anywhere else [yt-dlp](https://github.com/yt-dlp/yt-dlp)
supports. `avd` is a thin CLI wrapper around yt-dlp + ffmpeg.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Sanjay18bala/avd/main/install.sh | bash
```

This installs `yt-dlp` and `ffmpeg` (via Homebrew if available, otherwise
pip/apt fallbacks), puts `avd` in `~/.local/bin`, and wires up tab
completion for `avd`'s flags in your `~/.zshrc` or `~/.bashrc`. Open a new
terminal afterwards to pick it up.

## Usage

```sh
avd -v "https://www.youtube.com/watch?v=..."      # highest quality video
avd -a "https://www.youtube.com/watch?v=..."      # highest quality audio (mp3)
avd -v "https://www.tiktok.com/@user/video/..."
avd -v "https://www.instagram.com/reel/..."
```

Files are saved to `~/Downloads`.

## Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/Sanjay18bala/avd/main/uninstall.sh | bash
```

This removes `avd` and its completion script, and also strips the tab
completion block it added to your `~/.zshrc` or `~/.bashrc`.
