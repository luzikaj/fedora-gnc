# One-Handed Fedora Remix

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
This holds in the window manager, the editors, the browser and the menus.
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

| Key | niri | LazyVim / Zed | Files (yazi) |
|---|---|---|---|
| `e h t d` | focus ← ↓ ↑ → | move ← ↓ ↑ → | parent · down · up · open |
| `H T` | | | scroll the preview ↓ ↑ |
| `k` | floating | delete | move to trash |
| `j` | floating ↔ tiled focus | till | new tab |

Where a tool's own key had to move to make room, it moved to a fixed,
documented place (`docs/`).

### 6. Keyboard first, voice second, mouse last
Everything can be done from the keyboard. **Dictation** (Speech Note,
offline, Polish) types into any window: Mod + `c` to speak, and Mod + `a`
reads the clipboard aloud. The mouse is optional; the pointer follows the
keyboard focus.

### 7. Places, not searching
Apps open in **fixed places**: workspace `code` (editors, terminal, IDEs), `web`
(browsers), `notes` (Obsidian) and `vm` (virtual machines), all on **one main
screen**: niri's scrolling makes one screen enough. A second screen shows the
cheat-sheet wallpaper and takes whatever you want beside your work (a meeting,
a video): **Mod + End** sends the window there and back.
You always know where something is.

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
- Every dnf change takes a Btrfs snapshot before and after, and your home
  folder one every hour: `onehand-snapshots undo` / `files` ([snapshots](docs/snapshots.md)).
- keyd has an emergency stop: Backspace + Escape + Enter.

## Why niri

The desktop is built on **niri**, a *scrollable tiling* Wayland compositor:
windows sit side by side as columns on an endless horizontal strip, and each
monitor has its own vertical stack of workspaces. It was chosen because that
model fits one-handed, keyboard-only work better than the alternatives.

**Four directions are enough.** On the strip, every move is left, right, up or
down: `e h t d` to focus, `o r s u` to move. There's no layout tree to
manage, no split direction to choose first, no master/stack area. In i3 or
Sway you decide *how* to split before opening a window; in niri you just open
it.

**Opening a window never squeezes the others.** A new window becomes a new
column next to the current one; existing windows keep their size, and the
strip scrolls. Classic tiling (i3, Sway, Hyprland) shrinks everything already
on screen and then needs extra keystrokes to resize it back.

**Every action is a key you choose.** All of niri's shortcuts live in its
config file, which binds each action to whatever key you like, with a description
that Mod + Insert shows. That made it possible to put *everything* on Mod + one
right-hand key. GNOME and KDE Plasma come with hundreds of multi-modifier
defaults built around two hands, and changing them all is a fight.

**Places, per screen.** Named workspaces (`code`, `web`, `notes`, `vm`), pinned
to a monitor, plus window rules that open each app on its workspace, are
built in. That's what makes "you always know where something is" work, on two
screens or one.

**Easy to automate and safe to change.** The config is one text file with
`include`s, so generated parts (window rules, the monitor layout) live in
their own files. niri reloads it the moment it's saved, `niri validate`
checks it, and `niri msg` lets scripts query and drive it: `onehand-monitors`
and the Welcome window are built on that.

**A small core, the panels from Dux.** niri does windows and input only. Dux
Shell adds the bar, launcher, notifications and lock screen, without a full
desktop environment's background services and settings to work around.

**Modern and maintained.** It's Wayland-native (X11 apps run through
xwayland-satellite), smooth on 4K and mixed-DPI screens, actively developed, and
packaged for Fedora.

**The trade-offs, honestly:**
- Scrolling tiling takes a few days to get used to.
- niri needs real 3D graphics: in a VM without them it won't start (see
  [virtualization](docs/virtualization.md)).
- It moves fast, so some features need a recent version (the kit uses Dux's
  repository for that).

**The ISO is for personal use.** The repository is open (see [License](#license)),
but the ISO it builds includes proprietary apps (Chrome, Claude Code, Obsidian),
so built ISOs aren't for redistribution.
See [DIFFERENCES.md](DIFFERENCES.md) for everything that differs from stock Fedora,
and [docs/packages.md](docs/packages.md) for every package it adds or removes.

---

## What you get

| Area | What it includes |
|---|---|
| Desktop | **niri** + **Dux Shell** (bar, launcher, notifications, clipboard, lock screen, settings); text login (greetd + tuigreet) |
| Keyboard | `dvorak_r_pl` layout; keyd: Mod, Polish letters, sticky Ctrl/Shift |
| Screens | named workspaces `code` · `web` · `notes` · `vm` on the main screen; second screen shows the cheat sheet and takes windows on request (Mod + End) |
| Voice | Speech Note dictation and read-aloud |
| Browsers | Brave, Brave Nightly, Chrome |
| Terminal | Ghostty + fish (autosuggestions, `z`, fzf); copy/paste without Shift; foot as a fallback |
| Editors | LazyVim (Neovim), Zed and Helix with the same keys; Rune (IDE around Helix); Fresh |
| Development | Python 3 (pipx, uv), .NET 10 SDK, JetBrains Toolbox, lazygit, k9s, lfk, AWS CLI, Claude Code |
| Virtual machines | virt-manager on KVM, 3D guests, no password prompts; workspace `vm` |
| Other apps | Obsidian, Typing Tutor, yazi (file manager, `y`), nnn (Firefox removed) |
| Everyday care | break reminders for your hand (micro break every 25 min, Mod + , pauses); window finder (Mod + .); Btrfs snapshots before/after every update and hourly for home |

**Shortcut guides, one per tool:** [`docs/`](docs/README.md).
**Building the ISO, testing, installing and updating, step by step:** [BUILDING.md](BUILDING.md).
**Learning it:** the **niri Dojo** (launcher: *niri Dojo*, or `onehand-dojo`: live lessons that watch niri and tick off each step; one-screen course on a laptop), [weekly cheat sheets (PDF)](docs/learn/cheat-sheets.pdf) and an [interactive key trainer](docs/learn/trainer.html); regenerate both from `tools/learn/drills.json` with `tools/learn/build.py`.

### Key summary

| Keys | Action |
|---|---|
| Mod + c / i | dictate into the focused window / stop dictating |
| Mod + a / x | read the clipboard aloud / stop reading |
| Mod + Home / End / z | other monitor / send column there / send whole workspace there |
| Mod + . | find any window by typing (Enter right away: back to the previous window) |
| Mod + , | pause the break reminders for an hour / back on |
| Mod + F8 | power menu (lock, suspend, log out, reboot, power off) |
| tap Right Ctrl, then key | Ctrl + key (same for Right Shift) |
| Ctrl + C / Ctrl + V (Ghostty) | copy (when text is selected) / paste |

**Files (yazi, `y` in the terminal):** e h t d parent/down/up/open · H T
preview · E D back/forward · Space select · y x p copy/cut/paste · k trash ·
r rename · a new · j new tab · f filter · / find · z Z jump · ~ every key.

### Editor keys (LazyVim, Zed and Helix share them)

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
2. **Monitors:** nothing to do. If you plug in a screen later, run
   `onehand-monitors`. If the names don't match (it looks for "ASUS" and
   "BenQ"), the bigger screen is taken as the main one.

## Folder contents

| Path | What it is |
|---|---|
| `fedora-setup.sh` | Sets up a machine. **All lists live at its top.** |
| `files/` | Your configs: `niri/` (config, window rules, monitors), `xkb/`, `keyd/`, `zed/`, `nvim/` (LazyVim), `ghostty/`, `fish/`, `k9s/`, `lfk/`, `yazi/`, `helix/`, `rune/`, `bin/onehand-monitors`, `branding/` (logo), wallpapers, tutorial. |
| `build-spin.sh` | Builds the live ISO. |
| `niri-spin-base.ks` | Live-system basics for the ISO: language, time zone, installer. |
| `branding.ks` | The spin's name, "One-Handed Fedora Remix", and logo for the system and the installer. Change the name with `PRODUCT="..." ./build-spin.sh`. |
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
arrows, Enter to choose). It's also in the launcher as "Install One-Handed Fedora Remix".

After installing, the Welcome window opens at each login until you choose
"All done". It's a checklist: Wi-Fi, apps from Flathub, the Polish dictation
model, screens, the keys, updates. Open it again any time
from the launcher (Mod + ') as "Welcome". On installed machines,
`fedora-setup` is available as a command too, for setting up another user.

For a VirtualBox VM: 4 GB RAM or more, 2+ CPUs, VMSVGA graphics with 3D
acceleration on. (Ghostty may not start in VirtualBox; the Welcome window uses
the lighter foot terminal, which does.)

The repository is public, but built ISOs aren't for sharing: they include
apps that may not be redistributed (see [License](#license)).

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
tools/wallpaper/build.sh               # only if shortcuts changed (update make_wallpaper.py first)
git add -A && git commit -m "keyd: forget sticky taps after 1 s"
git push

# on your PC (already set up):
onehand-version                        # installed kit version; is there a newer one?
git pull && update/update.sh
# new ISO, on a Fedora machine of the release you want:
./build-spin.sh --generate-only && ./build-spin.sh
```

Habits that keep it easy:

- **One change per commit**, with a message that says why. Add a line to
  `CHANGELOG.md` for anything you'd want to know later.
- **Tag the commit an ISO was built from**: `git tag iso-45-20261110 && git push --tags`.
  `git diff iso-45-20261110` then shows what changed since that ISO.
- **Keep the docs and the wallpaper in step** with shortcut changes: the guide
  in `docs/` and `tools/wallpaper/make_wallpaper.py`.
- **GitHub checks** (`.github/workflows/check.yml`) run on every push: scripts
  parse, JSON and niri files are well-formed, the update package builds.
- **Keep the repository private.** It contains your configs, and the ISO
  includes proprietary apps that can't be shared publicly.

## License

- **Code and configs:** [MIT](LICENSES/MIT.txt)
- **Docs, wallpapers and logo:** [CC BY-SA 4.0](LICENSES/CC-BY-SA-4.0.txt)
- **Two LazyVim starter files:** [Apache-2.0](LICENSES/Apache-2.0.txt)

[LICENSE](LICENSE) lists which file is under which license.

*Fedora* is a trademark of Red Hat, Inc. This is an unofficial Fedora Remix,
not affiliated with or endorsed by the Fedora Project. The ISO it builds
includes apps that may not be redistributed, so built ISOs are for personal
use only.

