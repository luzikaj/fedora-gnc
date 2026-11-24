# Changelog

Newest first. Note what changed and why; the ISO name carries the build date.

## 2026-11-24
- niri Dojo in the kit: `onehand-dojo` (two screens; hands over to the
  one-screen course when there's only one) and `onehand-dojo-solo` (laptop),
  from the scripts made on 2026-11-17. Launcher entry *niri Dojo*; Welcome →
  The one-handed keys → `d`. Lesson 1 (two screens) follows today's Mod + End
  (you stay on the main screen); practice windows open in foot first (VMs).
  `docs/dojo.md`.

## 2026-11-22
- Vimium C removed: no browser policy, no import file, no Welcome step, no
  docs page. The update and fedora-setup delete the old policy files
  (`/etc/brave/…` and `/etc/opt/chrome/…/onehand-vimium-c.json`); a copy the
  browsers already installed is removed by hand. The wallpaper's Browser card
  is now a yazi (Files) card; trainer week 3 is "Files and terminal".

## 2026-11-20
- `update/update.sh` runs from a Git copy of the repo too: it builds the update
  package from the repo first, then runs that (before, it stopped with
  "files/ is missing").

## 2026-11-17
- Fresh installs: the installer wrote its own keyboard choice (Polish QWERTY)
  to the new system, so the greetd / tuigreet login was not Dvorak.
  `onehand-keyboard-firstboot.service` (`onehand-keyboard-check --firstboot`)
  now puts right-handed Dvorak back on the console and login screen on the
  first boot, before the login screen starts, and rebuilds the boot image for
  an encrypted disk.

## 2026-11-16
- Screenshots on the F-keys: Mod + F9 window, Mod + F10 selection, Mod + F12
  whole screen (Print keys still work). Audio devices moved to Mod + F11.
- Rune (rune.build) in /opt/rune from its latest GitHub release, checked
  against GitHub's SHA-256 for the file (setup, ISO build, update package).
  `~/.rune/config.yaml`: exo mode with your Helix (`hx`) as the editor, so the
  editing keys are yours; Rune's commands behind a leader (Menu or Scroll Lock,
  via `gui.key_mapping`) + niri's letters (e h t d windows, Enter terminal,
  Backspace close, ' prompt, f / / search, g / r / s code). niri rule: `code`.
  `docs/rune.md`.
- Helix back (Fedora's `helix` package, command `hx`) with the one-handed
  config from before the kit was in Git: e h t d move, k delete, D delete
  without copying, j till, l / L word end, Ctrl+t leaves insert, z h / t / H / T
  / u view, Space w + e h t d splits. Same keys as Zed's Helix mode. `docs/helix.md`.
- yazi (file manager) from the `lihaohong/yazi` COPR, with preview helpers
  (poppler-utils, ffmpegthumbnailer, 7zip, ImageMagick). Keys prepended in
  `~/.config/yazi/keymap.toml`: e h t d move, H / T preview, E / D history,
  k trash / K delete, j new tab / J rename tab; h / t in every list and
  LazyVim-style moves in text boxes. fish: `y` opens it and keeps its folder.
  Docs: `docs/yazi.md`.

## 2026-11-13 (evening)
- Login screen in Dvorak on existing systems: the update package now runs
  `onehand-keyboard-check --fix` when the check fails (before, it only
  reported it). The check and the fix know SDDM, which on Wayland ignores the
  X11 setting and reads `~sddm/.config/kxkbrc` instead; fedora-setup writes it too.
- lfk (Kubernetes TUI) from its latest GitHub release RPM, checksum-verified
  against `checksums.txt`. Keys set to the one-handed scheme: e h t d move,
  H / T scroll the preview; diff k, new tab j, Secret editor l, theme / tree J,
  rare types K. Docs: `docs/lfk.md`.
- `github_rpm` takes any checksum file name (k9s: checksums.sha256, lfk: checksums.txt).

## 2026-11-13
- Break reminders (`onehand-breaks`): a 20-second micro break every 25 minutes
  of use, every third one a 5-minute break with a countdown window; time away
  from the keyboard counts. Mod + , pauses them for an hour.
- Window finder (`onehand-windows`, Mod + .): every open window, last used first;
  type to filter, Enter to jump. Mod + . then Enter flips between the last two.
- Snapshots (`onehand-snapshots`): snapper takes a Btrfs snapshot before and
  after every dnf transaction (dnf5 actions plugin) and of /home every hour;
  VM images get their own subvolume. Set up on first boot. New packages:
  swayidle, snapper, libdnf5-plugin-actions.
- One main screen: all workspaces on the main screen. The second screen shows the
  cheat-sheet wallpaper; Mod + End sends the focused window there (focus stays on
  the main screen) or brings it back; Mod + q puts it to sleep / wakes it.
  `ONEHAND_SECOND_SCREEN=on-demand` keeps it asleep unless a window is sent;
  `ONEHAND_LAYOUT=split` keeps the old two-screen layout.

## 2026-11-12
- Mod + j: switch focus between floating and tiled windows (a floating window
  could hide a tiled one with no key to reach it).
- Welcome window tiles itself while the installer runs, so the installer's
  window is alone in front (it opened behind the Welcome window).

## 2026-11-11
- Learning aids: weekly cheat sheets with daily drills (`docs/learn/cheat-sheets.pdf`)
  and an interactive key trainer (`docs/learn/trainer.html`), both built from
  `tools/learn/drills.json`.
- Renamed to **One-Handed Fedora Remix** for the public repository; new logo
  wordmark and wallpaper heading. Licenses: MIT (code, configs), CC BY-SA 4.0
  (docs, artwork), Apache-2.0 (LazyVim starter files).
- `mount-internal-drives.sh` removed (it held one PC's drive IDs).
- Virtual machines: virt-manager on KVM with 3D guests, no password prompts for
  administrators, workspace `vm` on the main screen; `docs/virtualization.md`;
  BUILDING.md tests the ISO in virt-manager.
- README: why niri.
- Kit kept in Git: update package and wallpaper are built from the repository
  (`tools/make-update-package.sh`, `tools/wallpaper/build.sh`).

## 2026-11-10
- One-Handed Fedora Remix name and logo; Welcome window (live installer + first-login checklist).
- Two monitors (ASUS main, BenQ right) with named workspaces and window rules.
- Dictation with Speech Note; Vimium C with one-handed keys (`f` = bookmarks).
- Ghostty with fish, copy/paste without Shift; foot as fallback (`onehand-terminal`).
- Sticky Right Ctrl/Shift (keyd), forgotten after 1 s.
- `onehand-keyboard-check`: right-handed Dvorak everywhere (console, login, disk unlock).
- Development: Python 3 (pipx, uv), .NET 10 SDK, JetBrains Toolbox. Helium removed.
- ISO build: small kickstart (files copied in, not embedded), dependency check
  in `--generate-only`, i3 release identity so the installer avoids Firefox.
- Per-tool shortcut guides in `docs/`.
