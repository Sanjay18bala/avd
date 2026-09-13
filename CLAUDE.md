# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`avd` is a thin bash CLI wrapper around `yt-dlp` + `ffmpeg` that downloads video or audio at the highest available quality from YouTube, TikTok, Instagram Reels, and anywhere else yt-dlp supports. There is no per-platform logic — yt-dlp auto-detects the site from the URL, so `avd` never needs to know which platform a link is from.

## Files

- `avd` — the CLI itself (bash, `getopts`-based), for macOS/Linux. `-v <url>` downloads video (merges best video+audio into mp4 via ffmpeg), `-a <url>` downloads audio only (extracted to mp3 at quality 0). Output always goes to `~/Downloads/%(title)s.%(ext)s`.
- `install.sh` — the one-line installer macOS/Linux users run via `curl -fsSL .../install.sh | bash`. Installs `yt-dlp`/`ffmpeg` (Homebrew if present, else pip/apt fallback) and copies `avd` into `~/.local/bin`.
- `avd.ps1` — native PowerShell port of `avd` for Windows, same flags and behavior, no bash/WSL/Git Bash dependency.
- `install.ps1` — the Windows installer users run via `irm .../install.ps1 | iex`. Installs `yt-dlp`/`ffmpeg` (winget if present, else choco/pip fallback), copies `avd.ps1` and an `avd.cmd` shim into `%USERPROFILE%\bin`, and adds that dir to the user `PATH`.
- `README.md` — install one-liners and usage examples for both platforms.

## Running / testing locally

There is no build step or test suite — it's a shell script. To exercise a change:

```sh
./avd -h                          # arg-parsing / usage check, should exit 0
./avd                             # no args, should print usage and exit 1
./avd -v "<a real video url>"     # confirm a playable file lands in ~/Downloads
./avd -a "<a real video url>"     # confirm a playable mp3 lands in ~/Downloads
```

To test the installer itself (simulating a fresh machine as much as possible), run `bash install.sh` and confirm `avd` ends up executable on `PATH` at `~/.local/bin/avd`.

Windows side, same shape, in PowerShell:

```powershell
pwsh ./avd.ps1 -h                          # arg-parsing / usage check, should exit 0
pwsh ./avd.ps1                             # no args, should print usage and exit 1
pwsh ./avd.ps1 -v "<a real video url>"     # confirm a playable file lands in ~\Downloads
pwsh ./avd.ps1 -a "<a real video url>"     # confirm a playable mp3 lands in ~\Downloads
```

To test `install.ps1`, run it and confirm `avd.ps1`/`avd.cmd` land executable in `%USERPROFILE%\bin` and that dir is on the user `PATH`.

## Design constraints to preserve

- Keep `avd`/`avd.ps1` platform-agnostic re: sites: don't add TikTok/Instagram/YouTube-specific branches — new site support should come for free from yt-dlp, not from code here.
- `install.sh` and `install.ps1` must keep working with zero arguments via the curl/irm-pipe-to-shell pattern (referenced from `README.md` and from `avd`/`avd.ps1`'s own error message when yt-dlp is missing), so avoid introducing required flags or interactive prompts.
- The Homebrew branch in `install.sh` is macOS/Linuxbrew; without brew, `yt-dlp` is fetched as its official self-contained Linux binary release (no python3/pip3 dependency) and `ffmpeg` falls back to `apt`. The winget branch in `install.ps1` is the Windows equivalent; choco/pip are its fallback. Keep all paths working if you touch the dependency-install functions.
- `avd` (bash) and `avd.ps1` (PowerShell) are two independent implementations of the same CLI, not a shared codebase — a behavior change (new flag, output naming, collision handling) needs to land in both, or the two platforms drift apart.
