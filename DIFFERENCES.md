# One-Handed Fedora Remix: what's different from Fedora

One-Handed Fedora Remix is a personal Fedora remix built for **one-handed, right-hand-only
use**: a keyboard-driven tiling desktop where every shortcut is one modifier
plus one key, with the same direction keys everywhere (window manager, editors,
browser). It's built from stock Fedora packages plus a few well-known
third-party repositories. The repository that builds it is public; built ISOs
are used only on its owner's machines. It's an unofficial Fedora Remix, not
affiliated with or endorsed by the Fedora Project.

This page lists what was changed compared with a standard Fedora installation.
The shortcuts of each tool are described in detail in [`docs/`](docs/README.md).

---

## At a glance

| Area | Fedora (default) | One-Handed Fedora Remix |
|---|---|---|
| Desktop | GNOME (Workstation) | **niri** (scrollable tiling Wayland compositor) + **Dux Shell** (bar, launcher, notifications, lock screen) |
| Login screen | GDM | **greetd + tuigreet** (text login that starts niri) |
| Keyboard layout | US QWERTY (or locale) | **Right-handed Dvorak** with **Polish letters** on AltGr |
| Modifier keys | Standard | **keyd**: Right Alt = Mod when held, AltGr (Polish letters) when tapped; **sticky** Right Ctrl / Right Shift |
| Browser | Firefox | **Brave, Brave Nightly, Chrome**; Firefox removed; **Vimium C** keyboard navigation |
| Terminal / shell | Ptyxis + bash | **Ghostty + fish** (autosuggestions, zoxide, fzf), copy/paste without Shift |
| Editors / IDEs | GNOME Text Editor | **LazyVim** (Neovim) and **Zed**, both with one-handed keymaps; Fresh; **JetBrains Toolbox** for IntelliJ IDEA, PyCharm, Rider |
| Development | Python 3 | Python 3 with headers, **pipx** and **uv**; **.NET 10 SDK** |
| Voice | None | **Speech Note**: offline dictation into any window, and read-aloud |
| Multi-monitor | Manual | Screens detected at login; named workspaces pinned per screen; apps open on their screen |
| Installer | GNOME live session + installer | Live session logs straight into niri; **Welcome window** with a guided install |
| First login | GNOME Initial Setup | **Welcome checklist** (Wi-Fi, apps, dictation model, browser keys, screens, updates) |
| Name / logo | Fedora Linux | "One-Handed Fedora Remix" name in `/etc/os-release`, the installer and the boot menu; own logo |

---

## 1. Base system

- **Fedora 45**, x86_64, built as a live ISO with `livemedia-creator` from a
  kickstart (Fedora's classic tooling for live spins).
- Starts from Fedora's `@core`, `@standard`, `@hardware-support`, `@fonts`,
  `@multimedia` and `@networkmanager-submodules` groups. The release
  identity is the i3 spin's (`fedora-release-identity-i3`), only because
  Fedora's installer needs a spin identity to use its lightweight browser
  instead of Firefox. It installs no i3, and the name shown everywhere is
  "One-Handed Fedora Remix".
- **Unchanged from Fedora:** kernel, SELinux (enforcing), firewalld, NetworkManager,
  systemd, dnf, Flatpak, PipeWire. Updates still come from Fedora's own repositories.
- **Locale defaults:** Polish (`pl_PL.UTF-8`), Europe/Warsaw time zone.
- Root account locked; the user created in the installer is the administrator.
- Firefox is removed.

## 2. Desktop: niri + Dux Shell

- **niri** (newer builds from Dux's repository): windows are arranged in
  columns on an endless horizontal strip, and each monitor has its own
  vertical stack of workspaces.
- **Dux Shell** (formerly DankMaterialShell), built on Quickshell: top bar,
  app launcher, notification centre, clipboard history, lock screen, wallpaper
  and settings. It starts with every niri session.
- **xwayland-satellite** for X11-only apps, GNOME/GTK portals for screen
  sharing and file pickers, `tuned-ppd` for power profiles.

### One-handed shortcuts

Every niri shortcut is **Mod + one key, never Shift**. The keys sit under the
right hand on right-handed Dvorak:

| Keys | Action |
|---|---|
| Mod + `e` `h` `t` `d` | focus left / down / up / right |
| Mod + `o` `r` `s` `u` | move column or window, same directions |
| Mod + `n` / `w` | workspace up / down |
| Mod + `'` | app launcher |
| Mod + Enter | terminal |
| Mod + Backspace | close window |
| Mod + `l` `m` `f` `p` | width presets, narrower, wider, centre |
| Mod + Home / End / `z` | other monitor / send column there / send whole workspace there |
| Mod + `c` `i` `a` `x` | dictate / stop dictating / read clipboard aloud / stop reading |
| Mod + Insert | overlay listing every shortcut |
| Mod + arrows | volume, mute, play/pause |

The default wallpaper is a full cheat sheet of these, plus the editor, browser
and terminal keys.

## 3. Keyboard and input

- **Layout `dvorak_r_pl`** (installed in `/etc/xkb/symbols`): Xorg's
  right-handed Dvorak (`us(dvorak-r)`) with ą ć ę ł ń ó ś ż ź on AltGr, and
  the Menu key acting as Super. The text console and login screen use stock
  right-handed Dvorak.
- **keyd** (system service) remaps a few keys for one hand:
  - **Right Alt**: hold = Mod (Super); tap, then a letter = Polish letter.
  - **Right Ctrl** and **Right Shift** are **sticky**: tap, then the next key gets
    Ctrl / Shift. Holding them still works normally.
  - The virtual keyboard used for dictation is excluded, so dictated text
    isn't remapped.
  - Emergency stop: Backspace + Escape + Enter.

## 4. Two-monitor setup

- `onehand-monitors` (a small script that runs at every login) reads the
  connected screens from niri, finds the main and second screen by name, and writes
  `~/.config/niri/onehand-monitors.kdl` with their positions. The main screen
  sits in front and the second to its right, vertically centred.
- Named workspaces are pinned to screens: **`code`** on the main screen,
  **`web`** and **`notes`** on the second.
- **Window rules** (`onehand-rules.kdl`) open apps where they belong:
  - Brave, Brave Nightly, Chrome → `web` (two-thirds width)
  - Zed, Ghostty, JetBrains IDEs → `code`
  - Obsidian → `notes`
  - Speech Note, the volume mixer, picture-in-picture and file pickers float;
    Speech Note never takes focus away from the window you're dictating into.
- The pointer follows keyboard focus across screens.

## 5. Applications

**Development tooling (Fedora's repositories):** Python 3 with
`python3-devel`, `pipx` and `uv`; the .NET 10 SDK (`dotnet-sdk-10.0`, the
current long-term-support release); gcc, make, git; the X11/GTK libraries the
JetBrains IDEs need.

**From Fedora's repositories:** Neovim (with tree-sitter, ripgrep, fd, fzf,
lazygit's dependencies), fish, zoxide, foot, nnn, htop, tmux, bat, jq, AWS CLI
v2, ydotool, pavucontrol, playerctl, wev, NetworkManager TUI, development basics
(gcc, make, git, python3-pip).

**From third-party repositories:**

| App | Source |
|---|---|
| Brave, Brave Nightly | Brave's official RPM repositories |
| Google Chrome | Google's official repository |
| Claude Code | Anthropic's official RPM repository (stable channel, GPG key fingerprint checked) |
| Ghostty | COPR `scottames/ghostty` (listed in Ghostty's install docs) |
| Dux Shell, Quickshell, matugen, newer niri | COPR `duxlabs/dms`, `duxlabs/dux-repo` |
| keyd | COPR `alternateved/keyd` |
| lazygit | COPR `atim/lazygit` |
| k9s, Fresh editor | Latest GitHub release RPMs, checksum-verified |
| JetBrains Toolbox App | Latest release from JetBrains, checksum-verified, in `/opt/jetbrains-toolbox` |
| Codecs etc. | RPM Fusion (enabled) |

**From Flathub** (installed on the first boot after installation, not baked
into the ISO): Zed, Obsidian, Speech Note, Typing Tutor.

## 6. Editors and IDEs

- **LazyVim** (Neovim distribution) with a one-handed keymap: `e h t d`
  move, `k` delete, `j` till, `l` end of word, `E`/`D` switch buffers,
  `Ctrl+t` leaves insert mode, `z h`/`z t` scroll, `Space w` + `e h t d`
  for windows. Plugins are downloaded at setup, so `nvim` opens ready.
- **Zed** in Helix mode with the same moves and edits.
- **Fresh** (terminal editor), installed as-is.
- **JetBrains Toolbox App** in `/opt/jetbrains-toolbox` (command
  `jetbrains-toolbox`, launcher entry "JetBrains Toolbox"). On first start it
  sets itself up per user in `~/.local/share/JetBrains/Toolbox`, updates
  itself, and installs whichever IDEs you pick.

## 7. Browser

- **Vimium C** is force-installed through Chromium enterprise policy in Brave,
  Brave Nightly and Chrome (`/etc/brave/policies/managed`,
  `/etc/opt/chrome/policies/managed`).
- One-handed key map shipped as an import file
  (`~/Documents/vimium-c-onehand.json`): `e h t d` scroll, `r s` page,
  `i` open link, `n` link in new tab, `a c` previous/next tab, `k j`
  close/reopen tab, `l` address bar, `'` help. Link hints use only right-hand
  keys.

## 8. Terminal

- **Ghostty** starts **fish** (login shell stays bash). Ctrl+C copies when text
  is selected and otherwise interrupts as usual; Ctrl+V pastes; selecting text
  copies it.
- fish setup: no greeting, zoxide (`z folder`, `zi`), fzf key bindings
  (Ctrl+R history, Ctrl+T files, Alt+C directories), short abbreviations
  (`v` nvim, `g` git, `lg` lazygit), Neovim as `$EDITOR`.
- **foot** is included as a lightweight terminal that works without GPU
  acceleration (used by the Welcome window and handy in virtual machines).

## 9. Voice: dictation and read-aloud

- **Speech Note** (Flathub) runs offline speech-to-text and text-to-speech.
  It starts minimised to the tray at login, so dictation starts instantly.
- **ydotoold** runs as a system service (`onehand-ydotoold.service`) and gives
  Speech Note a virtual keyboard to type dictated text into the focused
  window; a Flatpak override lets the app reach its socket. The socket is
  usable by all local users, which suits a personal machine.
- Keys: Mod + `c` dictate, Mod + `i` stop, Mod + `a` read the clipboard aloud,
  Mod + `x` stop/cancel. The Polish speech model is downloaded once inside
  Speech Note.

## 10. Live USB, installer and first login

- The live USB logs `liveuser` straight into niri (greetd auto-login, set up
  only in the live session).
- A **Welcome window** opens on the live desktop: install to disk (with
  plain-language guidance before Fedora's installer opens), connect to Wi-Fi,
  learn the keys, or just try it. Navigation is one-handed (`h`/`t` or arrows,
  Enter).
- The installer is Fedora's Anaconda, with an installer profile that shows the
  spin's name and uses the lightweight installer browser (as Fedora's own spins do).
- On the installed system, the Welcome window opens at each login as a
  **checklist** until dismissed: network, Flathub apps (shows what's missing and
  can install it), dictation model, Vimium C settings, screens, keys and the
  niri tutorial, system updates.

## 11. Branding

- `/etc/os-release` says **One-Handed Fedora Remix** (`VARIANT_ID=onehanded`, `LOGO=onehanded-remix-logo`),
  kept in place by a small boot service, because Fedora updates rewrite
  `/usr/lib/os-release`. Everything else still identifies as Fedora
  (`ID=fedora`), so Fedora repositories and tools work unchanged.
- An original logo (not derived from Fedora's logo) in the icon theme.
- Default wallpaper: the One-Handed Fedora Remix cheat sheet (2560×1440 and 1920×1080).

## 12. What's added to the system (for the curious)

| Path | Purpose |
|---|---|
| `/etc/xkb/symbols/dvorak_r_pl` | Keyboard layout |
| `/etc/keyd/default.conf` | Right Alt / sticky Ctrl and Shift |
| `/etc/greetd/config.toml` | Text login that starts niri |
| `/etc/brave/…`, `/etc/opt/chrome/…/onehand-vimium-c.json` | Vimium C install policy |
| `/usr/local/bin/onehand-monitors` | Screen detection at login |
| `/usr/local/bin/onehand-welcome` | Welcome window / installer launcher / checklist |
| `/opt/jetbrains-toolbox`, `/usr/local/bin/jetbrains-toolbox` | JetBrains Toolbox App |
| `/usr/local/bin/fedora-setup` | The setup script, to set up further users or machines |
| `/usr/share/backgrounds/onehand/default.png` | Default wallpaper |
| `onehand-ydotoold.service` | Virtual keyboard for dictation |
| `onehand-branding.service` | Keeps the One-Handed Fedora Remix name in os-release |
| User units `onehand-wallpaper`, `onehand-welcome` | First-login wallpaper and Welcome window |
| `~/.config/niri/`, `nvim/`, `zed/`, `ghostty/`, `fish/conf.d/`, `k9s/` | Per-user configs (copied from `/etc/skel`) |

## 13. How it's built and maintained

- One kit, two uses:
  - `fedora-setup.sh` turns an existing Fedora (or Ultramarine) install into this setup.
  - `build-spin.sh` builds the live/installer ISO from the same package lists
    and config files, so the two never drift apart.
- Every package and repository is checked before the ISO build. Third-party
  repositories are installed with their signing keys, so the installed
  system keeps updating normally with `dnf upgrade` and `flatpak update`.
- Config files that get replaced are backed up with a `.bak.<date>` suffix.

## 14. Licensing note

The repository's own files are open: code and configs under MIT, docs and
artwork under CC BY-SA 4.0 (see [LICENSE](LICENSE)). The name follows Fedora's
Remix rules ("Fedora Remix" kept together, no Fedora logo).

Built ISOs are for personal use and aren't redistributed: they include
proprietary software (Google Chrome, Claude Code, Obsidian) under their own
terms. Publishing an ISO would also need Fedora's generic branding packages,
proprietary apps downloaded from their vendors at install time instead of
shipped on the ISO, and the source packages published alongside it.
