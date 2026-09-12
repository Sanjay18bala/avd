# avd

Download video or audio at the highest available quality from YouTube,
TikTok, Instagram Reels, and anywhere else [yt-dlp](https://github.com/yt-dlp/yt-dlp)
supports. `avd` is a thin CLI wrapper around yt-dlp + ffmpeg.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Sanjay18bala/avd/main/install.sh | bash
```

This installs `yt-dlp` and `ffmpeg` (via Homebrew if available, otherwise
pip/apt fallbacks) and puts `avd` in `~/.local/bin`.

For tab completion of `avd`'s flags, add the line the installer prints to
your `~/.zshrc` or `~/.bashrc`, then open a new terminal:

```sh
source "$HOME/.local/bin/avd-completion.sh"
```

## Usage

```sh
avd -v "https://www.youtube.com/watch?v=..."      # highest quality video
avd -a "https://www.youtube.com/watch?v=..."      # highest quality audio (mp3)
avd -v "https://www.tiktok.com/@user/video/..."
avd -v "https://www.instagram.com/reel/..."
```

Files are saved to `~/Downloads`.
