# Fedora GNC

**A Fedora desktop built to be used with one hand: the right one.**
It's stock Fedora underneath, with the niri tiling desktop, a right-handed
Dvorak keyboard with Polish letters, and every tool set up around the same few
keys. This repository holds the whole system: it builds the installer ISO,
sets up an existing Fedora or Ultramarine machine, and updates machines that
are already set up.

## Basic principles

### 1. Everything within reach of the right hand
The keyboard layout is right-handed Dvorak: the most-used letters sit under
the right hand, and the right half of the keyboard does all the work.
Nothing needs the left hand, and nothing needs two hands at once.

### 2. The same four directions everywhere
**`e h t d` = left, down, up, right** (keycaps G H J K, where the right hand
rests). The row above, **`o r s u`**, *moves* things in the same directions.
This holds in the window manager, both editors, the browser and the menus.
Learn it once, use it everywhere.

### 3. One modifier, one key
Every desktop shortcut is **Mod + one key**, never two modifiers.
**Mod = hold Right Alt**, under the right thumb.

### 4. Tap or hold: one key, two jobs
- **Right Alt:** hold = Mod. Tap, then a letter = Polish letter (ą ć ę ł ń ó ś ż ź).
- **Right Ctrl, Right Shift:** *sticky*. Tap, then the key = Ctrl or Shift + key,
  so combinations never need two keys held at once. A tap is forgotten after
  1 second, and holding still works as usual.

### 5. Keys keep their meaning across tools
The same key does the same kind of thing everywhere:

| Key | niri | LazyVim / Zed | Browser (Vimium C) |
|---|---|---|---|
| `e h t d` | focus ← ↓ ↑ → | move ← ↓ ↑ → | scroll ← ↓ ↑ → |
| `o r s u` | move column / window | Vim's own (open, replace, …) | back · page ↓ · page ↑ · forward |
| `k` | floating | delete | close tab |
| `'` | launcher | | help |

Where a tool's own key had to move to make room, it moved to a fixed,
documented place (`docs/`).

### 6. Keyboard first, voice second, mouse last
Everything can be done from the keyboard. **Dictation** (Speech Note,
offline, Polish) types into any window: Mod + `c` to speak, and Mod + `a`
reads the clipboard aloud. The mouse is optional; the pointer follows the
keyboard focus.

### 7. Places, not searching
Apps open in **fixed places**: workspace `code` (editors, terminal, IDEs), `web`
(browsers) and `notes` (Obsidian). With two screens, each screen has a role:
the main one holds `code`, the second holds `web` and `notes`. With one
screen (a laptop), the same three sit on it in the same order. You always know
where something is.

### 8. One layout, everywhere
Right-handed Dvorak is set **everywhere** a keyboard is read: the desktop and
all its apps, the installer, the text console, the login screen and the
disk-unlock prompt at boot. `onehand-keyboard-check` checks all of them.
(Polish letters exist only on the desktop, so passwords use plain characters.)

### 9. Help is always one key away
- **Mod + Insert** lists every shortcut.
- The **wallpaper** is a cheat sheet.
- **`docs/`** has one guide per tool.
- The **Welcome window** walks through installing and the first steps.

### 10. It stays Fedora
Fedora's packages, updates, SELinux and installer are used as they are. The
system only *adds* (and removes Firefox): no Fedora package is rebuilt or
patched, and `dnf upgrade` keeps working. Third-party apps come from their vendors' own
repositories or Flathub.

### 11. One source, three outputs
This repository is the single source of truth:

| Command | What it does |
|---|---|
| `./build-spin.sh` | builds the installer ISO |
| `./fedora-setup.sh` | sets up an existing machine |
| `tools/make-update-package.sh` | builds the update for machines that are already set up |

All three read the same `files/`, so they can't drift apart. Git history
records what changed and why.

### 12. Changes are safe to make
- Replaced files are kept as `.bak.<date>`.
- A niri config that fails `niri validate` is rolled back.
- The ISO build checks every repository and package before its long part starts.
- Every step has a dry run.
- keyd has an emergency stop: Backspace + Escape + Enter.

**Personal use only.** The ISO includes proprietary apps (Chrome, Claude Code,
Obsidian) and uses the Fedora name, so it isn't for redistribution.
See [FEDORA-GNC.md](FEDORA-GNC.md) for everything that differs from stock Fedora.

---

## What you get

| Area | What it includes |
|---|---|
| Desktop | **niri** + **Dux Shell** (bar, launcher, notifications, clipboard, lock screen, settings); text login (greetd + tuigreet) |
| Keyboard | `dvorak_r_pl` layout; keyd: Mod, Polish letters, sticky Ctrl/Shift |
| Screens | named workspaces `code` · `web` · `notes`; ASUS main + BenQ right, or one laptop screen |
| Voice | Speech Note dictation and read-aloud |
| Browsers | Brave, Brave Nightly, Chrome; Vimium C with one-handed keys (`f` = bookmarks) |
| Terminal | Ghostty + fish (autosuggestions, `z`, fzf); copy/paste without Shift; foot as a fallback |
| Editors | LazyVim (Neovim) and Zed with the same keys; Fresh |
| Development | Python 3 (pipx, uv), .NET 10 SDK, JetBrains Toolbox, lazygit, k9s, AWS CLI, Claude Code |
| Other apps | Obsidian, Typing Tutor, nnn (Firefox removed) |

**Shortcut guides, one per tool:** [`docs/`](docs/README.md).
**Building the ISO, testing, installing and updating, step by step:** [BUILDING.md](BUILDING.md).

### Key summary

| Keys | Action |
|---|---|
| Mod + c / i | dictate into the focused window / stop dictating |
| Mod + a / x | read the clipboard aloud / stop reading |
| Mod + Home / End / z | other monitor / send column there / send whole workspace there |
| tap Right Ctrl, then key | Ctrl + key (same for Right Shift) |
| Ctrl + C / Ctrl + V (Ghostty) | copy (when text is selected) / paste |

**Browser (Vimium C):** e h t d scroll · r s page · y b top/bottom · o u
back/forward · i open link · n link in new tab · w copy link · a c tab ← → ·
k j close/reopen tab · l address bar · m find tab · / v g find · ; focus input ·
' help · Ctrl + [ = Esc.

### Editor keys (Zed and LazyVim share them)

| Keys | Action |
|---|---|
| e h t d | left, down, up, right |
| k / kk | delete (operator) / delete line |
| j | till character |
| l / L | end of word / WORD |
| E / D | previous / next buffer (LazyVim) |
| Ctrl + t | leave insert mode |
| z h / z t, z H / z T | scroll line, half page |
| z u | cursor line to top |
| Space w + e h t d | go to window; with Shift: move it |
| Space w k | close window (LazyVim) |

LazyVim's own help: press Space and wait; the menu lists everything.

## First time on a new machine

1. **Speech Note:** open it from the launcher and download a Polish speech
   model (and a voice for reading aloud). Setting "Listening mode" to *One
   sentence* makes dictation stop by itself after a pause.
2. **Vimium C:** it installs itself in Brave, Brave Nightly and Chrome. In its
   Options, use *Import settings* with `~/Documents/vimium-c-onehand.json`.
3. **Monitors:** nothing to do. If you plug in a screen later, run
   `onehand-monitors`. If the names don't match (it looks for "ASUS" and
   "BenQ"), the bigger screen is taken as the main one.

## Folder contents

| Path | What it is |
|---|---|
| `fedora-setup.sh` | Sets up a machine. **All lists live at its top.** |
| `files/` | Your configs: `niri/` (config, window rules, monitors), `xkb/`, `keyd/`, `zed/`, `nvim/` (LazyVim), `ghostty/`, `fish/`, `vimium/`, `k9s/`, `bin/onehand-monitors`, `branding/` (logo), wallpapers, tutorial. |
| `build-spin.sh` | Builds the live ISO. |
| `niri-spin-base.ks` | Live-system basics for the ISO: language, time zone, installer. |
| `branding.ks` | The spin's name, "Fedora GNC", and logo for the system and the installer. Change the name with `PRODUCT="..." ./build-spin.sh`. |
| `mount-internal-drives.sh` | Optional: mounts the NTFS drives of your original PC. Run it by hand: `sudo ./mount-internal-drives.sh --dry-run` first. |
| `update/` | The update script for machines that are already set up; `tools/make-update-package.sh` packs it with the current files. |
| `tools/` | `make-update-package.sh` (update package), `wallpaper/build.sh` (re-renders the cheat-sheet wallpaper). |
| `docs/` | Shortcut guides, one per tool. |

To change a shortcut or setting, edit the file in `files/` and re-run
`./fedora-setup.sh` (or rebuild the ISO). Replaced files are backed up with a
`.bak.<date>` suffix.

## Set up a machine

```
tar xzf fedora-onehand-setup.tar.gz && cd fedora-onehand-setup
./fedora-setup.sh --dry-run    # see what it would do
./fedora-setup.sh
```

Run it as your normal user, not with sudo. Reboot afterwards. If the machine
already has a login manager (such as GDM), it's kept: pick "niri" there.

## Build the ISO

The short version is below; the full walkthrough with timings, testing and
troubleshooting is in [BUILDING.md](BUILDING.md).

On a Fedora machine of the release you want (about 30 GB free):

```
./build-spin.sh --generate-only   # checks every repository and package first
./build-spin.sh                   # 20–60 minutes; ISO ends up in out/<date-time>/
```

The live USB logs straight into niri and opens a **Welcome** window:
install to disk, connect to Wi-Fi, or learn the keys (move with h / t or the
arrows, Enter to choose). It's also in the launcher as "Install Fedora GNC".

After installing, the Welcome window opens at each login until you choose
"All done". It's a checklist: Wi-Fi, apps from Flathub, the Polish dictation
model, Vimium C settings, screens, the keys, updates. Open it again any time
from the launcher (Mod + ') as "Welcome". On installed machines,
`fedora-setup` is available as a command too, for setting up another user.

For a VirtualBox VM: 4 GB RAM or more, 2+ CPUs, VMSVGA graphics with 3D
acceleration on. (Ghostty may not start in VirtualBox; the Welcome window uses
the lighter foot terminal, which does.)

"Fedora GNC" is fine for your own machines. If you ever share the ISO publicly,
Fedora's trademark rules ask for a name like "GNC, a Fedora Remix".

## When something goes wrong

- `niri validate`: check the niri config (needs niri 25.11+, from Dux's repo)
- `onehand-keyboard-check`: is right-handed Dvorak set everywhere (desktop,
  console, login, disk unlock); `--fix` repairs it
- `systemctl status keyd`: is the Right Alt / sticky-key remapping running
- `systemctl status onehand-ydotoold`: dictation can't type into windows
- `journalctl --user -b -u niri`: niri and Dux errors
- **"No Fedora NN repository at …"** (ISO build): a COPR isn't built for that
  release yet. Build with `RELEASE=` one lower.
- **keyd misbehaving:** press Backspace + Escape + Enter together to stop it.

## Working on the kit (Git)

The kit is a Git repository. Everything that ends up on a machine is made
from it: the ISO (`build-spin.sh`), a fresh setup (`fedora-setup.sh`) and
the update for set-up machines (`tools/make-update-package.sh`). Build output
(`build/`, `out/`, `dist/`, ISOs, archives) is never committed.

A change, from edit to machines:

```
git switch -c sticky-timeout           # optional: a branch per change
$EDITOR files/keyd/default.conf        # edit the files
tools/wallpaper/build.sh               # only if shortcuts changed (update make_gnc.py first)
git add -A && git commit -m "keyd: forget sticky taps after 1 s"
git push

# on your PC (already set up):
tools/make-update-package.sh && tar xzf dist/onehand-update-gnc.tar.gz -C /tmp \
    && /tmp/onehand-update-gnc/update.sh
# new ISO, on a Fedora machine of the release you want:
./build-spin.sh --generate-only && ./build-spin.sh
```

Habits that keep it easy:

- **One change per commit**, with a message that says why. Add a line to
  `CHANGELOG.md` for anything you'd want to know later.
- **Tag the commit an ISO was built from**: `git tag iso-45-20261110 && git push --tags`.
  `git diff iso-45-20261110` then shows what changed since that ISO.
- **Keep the docs and the wallpaper in step** with shortcut changes: the guide
  in `docs/` and `tools/wallpaper/make_gnc.py`.
- **GitHub checks** (`.github/workflows/check.yml`) run on every push: scripts
  parse, JSON and niri files are well-formed, the update package builds.
- **Keep the repository private.** It contains your configs, and the ISO
  includes proprietary apps that can't be shared publicly.

