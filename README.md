# Fedora GNC: one-handed setup

Your right-handed, one-handed Fedora desktop as one kit. Use it in either of
two ways:

- **Set up an existing Fedora or Ultramarine machine:** `./fedora-setup.sh`
- **Build a live USB / installer ISO** with everything already in it:
  `./build-spin.sh`

Both read the same lists and the same `files/` folder, so they always match.

## What you get

- **Keyboard:** right-handed Dvorak with Polish letters. **Hold Right Alt** =
  Mod (or the Win key). **Tap Right Alt, then a letter** = ą ć ę ł ń ó ś ż ź.
  **Sticky keys:** tap Right Ctrl or Right Shift, then the key (holding them
  works as usual). All through keyd. The text console and login screen use plain
  right-handed Dvorak: same keys, no Polish letters.
- **niri** with your one-handed shortcuts (Mod + one key, no Shift, e h t d
  directions) and **Dux Shell** (bar, launcher, notifications, clipboard, lock
  screen, settings).
- **Two monitors:** the ASUS (main, in front) gets the `code` workspace (Zed,
  Ghostty); the BenQ (on its right) gets `web` (Brave, Brave Nightly, Chrome)
  and `notes` (Obsidian). Apps open on their screen by themselves.
- **Voice:** Speech Note dictates into any window and reads text aloud, offline.
- **Browsers:** Vimium C in Brave, Brave Nightly and Chrome, with one-handed keys.
- **Terminal:** Ghostty running fish (autosuggestions, `z` folder jumps, fzf).
  Copy and paste with Ctrl+C / Ctrl+V, no Shift.
- **Development:** Python 3 (with headers, pipx and uv), the .NET 10 SDK
  (`dotnet`), and the JetBrains Toolbox App to install IntelliJ IDEA, PyCharm,
  Rider and the other JetBrains IDEs (they open on the `code` workspace).
- **Login:** a text login screen (greetd + tuigreet) that starts niri.
- **Your configs:** Zed keymap, LazyVim (Neovim) with the same one-handed keys,
  k9s plugins, and the niri tutorial PDF in `~/Documents`.
- **Wallpaper:** the Fedora GNC cheat sheet with every shortcut, set on the first
  login. Change it in Dux settings (Mod + PgDn).
- **Apps:** Brave, Brave Nightly, Chrome, Ghostty, Zed, LazyVim (`nvim`),
  lazygit, Fresh, k9s, nnn, AWS CLI, Claude Code, plus Obsidian, Speech Note and
  Typing Tutor from Flathub. Firefox is removed.

Mod + Insert shows every shortcut.

**Full shortcut guides, one per tool:** [`docs/`](docs/README.md): keyboard,
niri, Speech Note, LazyVim, Zed, Vimium C, Ghostty and fish, k9s, Welcome window.

### New keys

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

