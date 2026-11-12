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

## Two monitors

The main screen (ASUS, in front) has the workspaces **`code`** and **`vm`**; the second
screen (BenQ, on its right) has **`web`** and **`notes`**. Apps open on
their own workspace:

| App | Opens on |
|---|---|
| Zed, Ghostty / foot, JetBrains IDEs | `code` (main screen) |
| Brave, Brave Nightly, Chrome | `web` (second screen) |
| Obsidian | `notes` (second screen) |
| virt-manager, VM windows, GNOME Boxes | `vm` (main screen, below `code`) |
| Speech Note, volume mixer, picture-in-picture, file pickers, JetBrains Toolbox | float above everything |

| Mod + | Action |
|---|---|
| Home | focus the other monitor |
| End | send the column to the other monitor |
| `z` [D] | send the whole workspace to the other monitor |

The mouse pointer follows the keyboard focus to the other screen. After
plugging in a screen, run `onehand-monitors` (it runs by itself at login).

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
| Mod + Pause | force-close an app that won't close (far away on purpose) |
| Mod + Scroll Lock | pass all keys to the app (for remote desktops, VMs); press again to get them back |
| Mod + mouse wheel | workspace up / down |

Media, volume and brightness keys on the keyboard work as usual, with an
on-screen display from Dux.

Screenshots are saved in `~/Pictures/Screenshots` and copied to the clipboard.

## Changing it

Edit `~/.config/niri/config.kdl`. niri reloads it as soon as you save, and
`niri validate` checks it for mistakes. Each shortcut's `hotkey-overlay-title`
is the text Mod + Insert shows.
