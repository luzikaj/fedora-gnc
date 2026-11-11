#!/bin/bash
# Re-renders the One-Handed Fedora Remix cheat-sheet wallpaper into files/wallpapers/.
# Edit the shortcut lists in make_wallpaper.py, then run this.
# Needs Python 3 and Playwright with Chromium:
#   pip install --user playwright && python3 -m playwright install chromium
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
python3 make_wallpaper.py
python3 shot_wallpaper.py
rm -f wallpaper.html
echo "Wallpapers written to files/wallpapers/ (check them before committing)."
