# niri: the desktop

niri arranges windows as **columns on an endless horizontal strip**. Each
monitor has its own **vertical stack of workspaces**. Dux Shell adds the bar,
launcher, notifications, clipboard history, lock screen and settings.

Every shortcut is **Mod + one key** (Mod = hold Right Alt). None needs Shift.
Keycap positions are in [brackets] (QWERTY).

**Mod + Insert** shows all of them on screen, and the wallpaper is a cheat sheet.

Config: `~/.config/niri/config.kdl` (shortcuts), `onehand-rules.kdl`
(where apps open), `onehand-monitors.kdl` (screens, written at login).

## Go: home row

| Mod + | Action | Keycap |
|---|---|---|
| `e` | focus column left | [G] |
| `h` | focus window below (or the next workspace) | [H] |
| `t` | focus window above (or the previous workspace) | [J] |
| `d` | focus column right | [K] |
| `k` | window floating on/off | [;] |
| `j` | **switch focus between floating and tiled windows** (floating ones sit on top) | [5] |
| `-` | overview of all workspaces | ['] |
| Enter | new terminal (Ghostty; foot if Ghostty can't start, e.g. in a VM) | |

## Move: the row above

| Mod + | Action | Keycap |
|---|---|---|
| `o` | move column left | [T] |
| `r` | move window down (into the next workspace at the end) | [Y] |
| `s` | move window up (into the previous workspace at the end) | [U] |
| `u` | move column right | [I] |
| `y` | fullscreen | [O] |
| `b` | maximize column | [P] |
| `;` | pull the window on the left into this column | [[] |
| `=` | push this window out to the right | []] |
| `\` | fullscreen | [\\] |

## Workspaces and the launcher: bottom row

| Mod + | Action | Keycap |
|---|---|---|
| `n` | workspace up | [N] |
| `w` | workspace down | [M] |
| `v` | send column to the workspace up | [,] |
| `g` | send column to the workspace down | [.] |
| `'` | **launcher**: type an app's name, Enter | [/] |
| `.` | **find a window**: every open window, the last used first; type, Enter (see below) | [R] |
| PgUp | back to the previous workspace | |

## Size and panels: number row

| Mod + | Action | Keycap |
|---|---|---|
| `l` | cycle column width (⅓, ½, ⅔, full) | [6] |
| `m` | narrower by 10% | [7] |
| `f` | wider by 10% | [8] |
| `p` | centre the column | [9] |
| `/` | tabbed column on/off | [0] |
| `[` | notification centre | [-] |
| `]` | clipboard history | [=] |
| Backspace | close the window | |

## One main screen, a second screen beside it

You work on **one screen**: the main one (the ASUS, in front, or a laptop's
own). niri's scrolling strip makes one screen enough: windows sit side by
side and Mod + `e` / `d` scroll between them. All four workspaces live there,
top to bottom, and apps open on theirs by themselves:

| Workspace | Opens there |
|---|---|
| `code` | Zed, Ghostty / foot, JetBrains IDEs |
| `web` | Brave, Brave Nightly, Chrome |
| `notes` | Obsidian |
| `vm` | virt-manager, VM windows, GNOME Boxes |
| (any) | Speech Note, volume mixer, picture-in-picture, file pickers and JetBrains Toolbox float above everything |

The **second screen** (the BenQ) has no workspaces of its own. It shows the
**wallpaper, your cheat sheet with every shortcut**, until you send something
there to keep beside your work: a meeting, a video, documentation, a dashboard.

| Mod + | Action |
|---|---|
| End | **send this window to the other screen.** From the main screen: moves the window there (waking the screen if it's asleep) and keeps you on the main screen. From the second screen: brings the window back. |
| `q` [E] | put the second screen to sleep / wake it (asleep, its windows come back to the main screen) |
| Home | move the focus to the other screen (to scroll or type there) |
| `z` [D] | send the whole workspace to the other screen |

The mouse pointer follows the keyboard focus to the other screen.

**Prefer both screens in use all the time?** Put `ONEHAND_LAYOUT=split` in
`~/.config/environment.d/onehand.conf` and log in again: the main screen then
holds `code` and `vm`, the second `web` and `notes`, and it stays awake.
`ONEHAND_SECOND_SCREEN=on-demand` keeps the second screen asleep from login
and whenever it's empty, waking it only for Mod + End. After plugging in a screen, run
`onehand-monitors`.

## Voice (Speech Note)

| Mod + | Action | Keycap |
|---|---|---|
| `c` | dictate into the focused window | [L] |
| `i` | stop dictating | [B] |
| `a` | read the clipboard aloud | [F] |
| `x` | stop reading / cancel | [C] |

Details: [Speech Note](speech-note.md).

## System, audio, screenshots

| Keys | Action |
|---|---|
| Mod + Insert | show every shortcut |
| Mod + Delete | lock the screen |
| Mod + PgDn | Dux settings (wallpaper, display, theme…) |
| Mod + ↑ / ↓ | volume up / down (also on the lock screen) |
| Mod + ← | mute on/off |
| Mod + → | play / pause |
| Mod + F9 | audio devices (speakers, headphones, microphone) |
| Print | screenshot of a selected area |
| Ctrl + Print | screenshot of the whole screen |
| Mod + Print | screenshot of the focused window |
| Mod + `,` | pause the break reminders for an hour; again: back on (see below) [V] |
| Mod + Pause | force-close an app that won't close (far away on purpose) |
| Mod + Scroll Lock | pass all keys to the app (for remote desktops, VMs); press again to get them back |
| Mod + mouse wheel | workspace up / down |

Media, volume and brightness keys on the keyboard work as usual, with an
on-screen display from Dux.

Screenshots are saved in `~/Pictures/Screenshots` and copied to the clipboard.

## Finding a window

**Mod + .** opens a small list of every open window, on every workspace and
both screens, **the last used first**. The cursor already sits on the window
you used before this one, so **Mod + . then Enter** flips between your last two
windows. Otherwise type a few letters of the app, title or workspace (`brave`,
`obs`, `web`) and press Enter. Up / Down (or Ctrl + t / Ctrl + h) move through
the list; Backspace on an empty line closes it.

## Break reminders

One hand does all the work, so it gets regular rests:

- every **25 minutes of use**: a **20-second micro break**, a notification with
  one short exercise (shake your hand loose, spread your fingers, look far away);
- every **third** break: a **5-minute break** in a small window with a countdown.
  Enter: done · `p`: remind me in 5 minutes · Backspace: skip this one.

Stepping away counts: **2 minutes** without touching the keyboard or mouse
restart the 25 minutes, and **5 minutes** away (or a locked screen) count as the
long break. **Mod + ,** pauses the reminders for an hour (a meeting, a deadline);
press it again to turn them back on. `onehand-breaks status` shows the time to
the next break.

Settings, in `~/.config/environment.d/onehand.conf` (then log in again):

```
ONEHAND_BREAK_EVERY=25           # minutes of use between breaks
ONEHAND_BREAK_SECONDS=20         # micro break length
ONEHAND_LONG_BREAK_EVERY=3       # every Nth break is long (0 = never)
ONEHAND_LONG_BREAK_MINUTES=5
ONEHAND_BREAK_PAUSE_MINUTES=60   # how long Mod + , pauses them
ONEHAND_BREAKS=off               # no reminders at all
```

## Changing it

Edit `~/.config/niri/config.kdl`. niri reloads it as soon as you save, and
`niri validate` checks it for mistakes. Each shortcut's `hotkey-overlay-title`
is the text Mod + Insert shows.
