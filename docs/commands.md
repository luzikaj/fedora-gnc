# Commands

Every command One-Handed Fedora Remix adds. The `onehand-*` commands are in
`/usr/local/bin`, so they work in any terminal; the `install-*` helpers stay in
the kit's folder. Each section below is the command's own help text (the
comment at the top of the script). **Generated** by `tools/list-commands.py`;
CI checks this page is current.

| Command | What it does | Key | Needs sudo | Runs by itself |
|---|---|---|---|---|
| [`onehand-breaks`](#onehand-breaks) | break reminders for the working hand; pause, status, a break now | Mod + , (`pause`) | no | `daemon` at every niri / Mango login |
| [`onehand-dojo`](#onehand-dojo) | hands-on niri lessons, checked live (two screens; one-screen course by itself) |  | no |  |
| [`onehand-dojo-solo`](#onehand-dojo-solo) | the one-screen (laptop) niri lessons |  | no |  |
| [`onehand-keyboard-check`](#onehand-keyboard-check) | is right-handed Dvorak set everywhere? `--fix` repairs it |  | `--fix` asks for sudo; `--firstboot` runs as root (service) | `--firstboot` once after installing (onehand-keyboard-firstboot.service) |
| [`onehand-monitors`](#onehand-monitors) | screen layout for niri (main / second screen, workspaces) |  | no | `--login` at every niri login |
| [`onehand-second-screen`](#onehand-second-screen) | send a window to the second screen and back; sleep / wake it | Mod + End (`send`), Mod + q (`toggle`) | no |  |
| [`onehand-snapshots`](#onehand-snapshots) | Btrfs snapshots: list, undo an update, get back a file |  | `setup`, `undo` (sudo); `list` / `files` work as you (wheel group) | `setup` once (onehand-snapshots-setup.service); `dnf-pre` / `dnf-post` by dnf |
| [`onehand-terminal`](#onehand-terminal) | Ghostty, or foot when Ghostty can't start (VMs) | Mod + Enter | no |  |
| [`onehand-version`](#onehand-version) | installed kit version; is a newer one available? |  | no | `--notify` once a day after login |
| [`onehand-welcome`](#onehand-welcome) | the Welcome window: install, first steps, keys, updates |  | no | on the live USB and at the first login |
| [`onehand-windows`](#onehand-windows) | find any open window by typing, jump to it | Mod + . | no |  |
| [`install-jetbrains-toolbox`](#install-jetbrains-toolbox) | install / update JetBrains Toolbox (checksum-verified) |  | yes (run with sudo) |  |
| [`install-lfk`](#install-lfk) | install / update lfk (checksum-verified) |  | yes (run with sudo) |  |
| [`install-rune`](#install-rune) | install / update Rune (checked against GitHub's SHA-256) |  | yes (run with sudo) |  |

## onehand-breaks

Installed as `/usr/local/bin/onehand-breaks`. More in [niri.md](niri.md#break-reminders).

Key: Mod + , (`pause`).

```
onehand-breaks: break reminders. One hand does all the work, so give it rests.

Every 25 minutes of use: a 20-second micro break (a notification with one
short exercise). Every third break: a 5-minute break in a small window with a
countdown. Stepping away counts: 2 idle minutes reset the timer, and 5 idle
minutes (or a locked screen) count as the long break.

  onehand-breaks daemon    run in the background (started at niri login)
  onehand-breaks pause     (Mod + ,) pause reminders for an hour; again: resume
  onehand-breaks now       take a long break now
  onehand-breaks status    time to the next break

Settings (in ~/.config/environment.d/onehand.conf, then log in again):
  ONEHAND_BREAKS=off              no reminders at all
  ONEHAND_BREAK_EVERY=25          minutes of use between breaks
  ONEHAND_BREAK_SECONDS=20        length of a micro break
  ONEHAND_LONG_BREAK_EVERY=3      every Nth break is a long one (0 = never)
  ONEHAND_LONG_BREAK_MINUTES=5    length of a long break
  ONEHAND_BREAK_PAUSE_MINUTES=60  how long Mod + , pauses them
```

## onehand-dojo

Installed as `/usr/local/bin/onehand-dojo`. More in [dojo.md](dojo.md).

```
onehand-dojo: hands-on niri practice with YOUR one-handed shortcuts
(One-Handed Fedora Remix; launcher: "niri Dojo")

Run it in a terminal inside niri:   onehand-dojo
With one screen it runs the one-screen course (onehand-dojo-solo) instead.

It opens practice windows A, B and C, gives you one task at a time, and
watches niri (through `niri msg`) to see when you've done it, then moves on.
You never type anything into this terminal: just use the shortcuts.

Keys are the letters on your right-handed Dvorak keycaps.
Mod = hold Right Alt (or the left Win key).

  onehand-dojo            full course (about 5 minutes)
  onehand-dojo --from 4   start at lesson 4
  onehand-dojo --solo     the one-screen course, even with two screens
  Ctrl+C in this window   stop at any time (practice windows are closed)

Needs: niri, jq, and a terminal (ghostty, foot, alacritty or konsole).
```

## onehand-dojo-solo

Installed as `/usr/local/bin/onehand-dojo-solo`. More in [dojo.md](dojo.md).

```
onehand-dojo-solo: hands-on niri practice on ONE screen (laptop or desktop)
(One-Handed Fedora Remix; `onehand-dojo` starts it by itself on one screen)

Run it in a terminal inside niri:   onehand-dojo-solo   (or onehand-dojo --solo)

Same idea as onehand-dojo, for a single screen: this guide window floats in
a corner of your practice workspace, and every task also pops up as a
notification, so you can still read it on another workspace.
You never type into this terminal: just use the shortcuts.

Keys are the letters on your right-handed Dvorak keycaps.
Mod = hold Right Alt (or the left Win key). No Shift, no arrows, no
navigation keys needed, so it works the same on a laptop keyboard.

  onehand-dojo-solo            full course (about 5 minutes)
  onehand-dojo-solo --from 4   start at lesson 4
  Ctrl+C in this window             stop (practice windows are closed)

Needs: niri, jq, a terminal (ghostty, foot, alacritty or konsole).
Optional: notify-send (libnotify) for the pop-up copy of each task.
```

## onehand-keyboard-check

Installed as `/usr/local/bin/onehand-keyboard-check`. More in [keyboard.md](keyboard.md).

```
onehand-keyboard-check: is right-handed Dvorak in force everywhere?

  onehand-keyboard-check         check every place the layout is set
  onehand-keyboard-check --fix   set it again where it's wrong (asks for sudo)
  onehand-keyboard-check --firstboot   (root, once after installing; see the service)

Layers checked:
  desktop (niri, and every app in it)  layout dvorak_r_pl from /etc/xkb
  text console + login screen          /etc/vconsole.conf
  disk-unlock prompt at boot           the console keymap inside the initramfs
  X11 setting (GDM, LightDM, …)        localectl X11 layout
  login screen                         the login manager in use (SDDM keeps
                                       its own file; the others follow X11)
  key remapping                        keyd (Right Alt, sticky Ctrl/Shift)
```

## onehand-monitors

Installed as `/usr/local/bin/onehand-monitors`. More in [niri.md](niri.md).

```
onehand-monitors: sets up the screens for niri and pins the named workspaces.

Layout "primary" (the default): you work on the main screen.
  main screen  (in front) -> all workspaces: code, web, notes, vm
  second screen (beside)  -> nothing pinned: it shows the wallpaper (the
                             cheat sheet) until you send a window there
                             (Mod + End). Mod + q puts it to sleep / wakes it.
                             With ONEHAND_SECOND_SCREEN=on-demand it sleeps
                             from login and whenever it's empty.
Layout "split": both screens in use all the time.
  main screen -> code, vm      second screen -> web, notes

Runs at every niri login (spawn-at-startup "onehand-monitors" "--login");
run it by hand after plugging in a screen. It writes
~/.config/niri/onehand-monitors.kdl, which niri reloads by itself, and
remembers which screen is which for onehand-second-screen.

Settings (change here, or put them in ~/.config/environment.d/onehand.conf):
```

## onehand-second-screen

Installed as `/usr/local/bin/onehand-second-screen`. More in [niri.md](niri.md).

Key: Mod + End (`send`), Mod + q (`toggle`).

```
onehand-second-screen: send windows to the second screen; wake / sleep it.

  onehand-second-screen send     (Mod + End) send the focused window to the
                                 other screen. From the main screen: wakes
                                 the second screen, moves the window there
                                 and keeps you working on the main screen.
                                 From the second screen: brings the window
                                 back (with ONEHAND_SECOND_SCREEN=on-demand,
                                 the second screen then sleeps once empty).
  onehand-second-screen toggle   (Mod + q) wake the second screen, or put it
                                 to sleep (its windows move to the main one)
  onehand-second-screen on | off | status

Which screen is which comes from onehand-monitors (run at every login).
```

## onehand-snapshots

Installed as `/usr/local/bin/onehand-snapshots`. More in [snapshots.md](snapshots.md).

```
onehand-snapshots: Btrfs snapshots, so a bad update or a deleted file can be undone.

  - Every dnf install / update / remove takes a "pre" and a "post" snapshot of
    the system (snapper, through dnf5's actions plugin). The last 10 are kept.
  - Your home folder gets an hourly snapshot: the last 6 hours, 7 days and
    2 weeks are kept.
  - VM disk images (/var/lib/libvirt/images) are left out, so big VM disks
    don't fill the drive.

  onehand-snapshots list              what's there (system and home)
  onehand-snapshots changes N         files a dnf transaction changed (N = its pre number)
  onehand-snapshots undo N            put the system's files back as they were before
                                      transaction N (asks first; then reboot)
  onehand-snapshots files PATH [K]    older copies of a file or folder in your home
                                      (K: copy the one from home snapshot K next to it)
  onehand-snapshots setup             (root) set it all up; runs once by itself
  onehand-snapshots dnf-pre PID | dnf-post N    (used by dnf; not for you)

First try `sudo dnf history undo last` for a bad update; `undo` here is the
bigger hammer for when the system is in a mess.
```

## onehand-terminal

Installed as `/usr/local/bin/onehand-terminal`.

Key: Mod + Enter.

```
onehand-terminal: open Ghostty, or foot if Ghostty can't start.

Ghostty needs working 3D graphics; in virtual machines without them it closes
straight away. Then foot (drawn without the GPU) opens instead, and is used
directly for the rest of this login.
  onehand-terminal [ARGS…]   extra arguments go to the terminal
```

## onehand-version

Installed as `/usr/local/bin/onehand-version`. More in [../BUILDING.md](../BUILDING.md).

```
onehand-version: which version of the One-Handed Fedora Remix kit this
system has, and whether a newer one exists.

  onehand-version            installed version, and what's new since (if it can check)
  onehand-version --short    just the installed version
  onehand-version --check    quiet: exit 0 up to date, 10 newer kit available, 2 can't tell
  onehand-version --notify   (at login) a notification when a newer kit exists; once a day
  onehand-version --of DIR   the version of a kit folder (used by the build scripts)

The version is the date and short hash of the kit's Git commit, for example
2026.11.24+719d097 ("-modified" when built from a copy with local changes).
Every way of installing writes it to /etc/onehand/version: the ISO, a run of
fedora-setup.sh and the update package.

Checking for a newer kit, in this order:
  1. your clone of the repo (REPO in /etc/onehand/version, written when you
     update from a clone, or ONEHAND_REPO=~/path/to/fedora-gnc): git fetch
  2. the GitHub CLI, if you're logged in (gh auth login): the repo's main branch
```

## onehand-welcome

Installed as `/usr/local/bin/onehand-welcome`. More in [welcome.md](welcome.md).

```
onehand-welcome: the friendly start of One-Handed Fedora Remix.

  On the live USB: install to disk, connect to Wi-Fi, learn the keys.
  After installing: a one-time checklist (apps, dictation, browser keys,
  screens, updates). Open it again any time from the launcher: "Welcome".

  onehand-welcome            show the menu in this terminal
  onehand-welcome --launch   open it in its own window (used at login)
  onehand-welcome install    go straight to installing (live USB)
```

## onehand-windows

Installed as `/usr/local/bin/onehand-windows`. More in [niri.md](niri.md#finding-a-window).

Key: Mod + ..

```
onehand-windows: find any open window by typing, and jump to it (Mod + .).

Opens a small floating list of every window on every workspace and screen,
the most recently used first, with the cursor already on the window you used
before this one: Mod + . then Enter flips between your last two windows.
Type a few letters of the app, title or workspace ("brave", "obs", "web") to
narrow it down; Up / Down (or Ctrl + t / Ctrl + h) move; Enter jumps;
Backspace on an empty line or Mod + Backspace closes the list.

  onehand-windows          open the list (in its own floating terminal)
  onehand-windows --list   print the list (id, workspace, app, title)
```

## install-jetbrains-toolbox

Installed as the kit's `files/jetbrains/` (not on the PATH).

```
install-jetbrains-toolbox [ROOT]

Installs the latest JetBrains Toolbox App (the launcher for IntelliJ IDEA,
PyCharm, Rider, ...) into ROOT/opt/jetbrains-toolbox, checksum-verified,
with a launcher entry and a `jetbrains-toolbox` command. ROOT defaults to /
(run with sudo); build-spin.sh passes the ISO's staging folder.

On first start, Toolbox sets itself up in ~/.local/share/JetBrains/Toolbox,
updates itself there, and installs the IDEs you pick, per user.
```

## install-lfk

Installed as the kit's `files/lfk/` (not on the PATH). More in [lfk.md](lfk.md).

```
install-lfk: install or upgrade lfk (Kubernetes TUI) from its latest GitHub
release .rpm, verified against the release's checksums.txt. Run with sudo.
```

## install-rune

Installed as the kit's `files/rune/` (not on the PATH). More in [rune.md](rune.md).

```
install-rune [ROOT]

Installs or updates Rune (rune.build, GPL-3.0) from its latest GitHub release
into ROOT/opt/rune, with a `rune` command and a launcher entry. ROOT defaults
to / (run with sudo); build-spin.sh passes the ISO's staging folder.

Rune publishes no checksum file; the download is checked against the
SHA-256 that GitHub records for the release file (and fetched over HTTPS).
Installed here, Rune doesn't update itself: the kit's update package runs
this again.
```
