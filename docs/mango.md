# Mango: the second session

[MangoWM](https://github.com/mangowm/mango) is a second window manager next to
niri. Its **scroller** layout works like niri (windows on a strip that slides
left and right), and on any workspace it can switch to classic **tiling**,
**monocle** (one window at a time) or **dwindle** (spiral splits) with one key.
Dux Shell runs on it too, so the bar, launcher, notifications, lock screen,
power menu, clipboard and screenshots are the same as under niri.

## Starting it

At the login screen press **F3** (session list), pick **Mango**, log in. The
login screen remembers the session you picked last; F3 again goes back to niri.

## Keys

The same one-handed keys as niri: Mod = hold Right Alt, letters are your Dvorak
keycaps.

| Mod + | Action | Like niri? |
|---|---|---|
| `e` `h` `t` `d` | focus left / down / up / right | same |
| `o` `r` `s` `u` | move the window left / down / up / right | same |
| `;` / `=` | pull the window into the column on its left / push it out right | same |
| `n` / `w` | previous / next workspace (tag) | same keys; Mango's workspaces sit side by side |
| `v` / `g` | carry the window to the previous / next workspace | same |
| PgUp | back to the workspace you were on | same |
| `l` | cycle widths: ⅓, ½, ⅔, full | same |
| `m` / `f` | half width / full width | niri: narrower / wider |
| `/` | **layout of this workspace**: scroller → tile → monocle → dwindle | niri: tabbed column |
| `y` or `\` | fullscreen | same |
| `b` | maximize | same |
| `k` | floating on/off | same |
| `j` | back to the last window | niri: floating ↔ tiled focus |
| `-` | overview | same |
| `.` | **window switcher**: keep holding Mod, press `.` again to move on, let go to pick | niri: the window finder list |
| Home / End | other screen / send the window there | same |
| Enter | terminal | same |
| `'` | launcher | same |
| `[` / `]` | notifications / clipboard | same |
| Backspace / Pause | close / force-close | same |
| Insert | all shortcuts (Dux) | same |
| Delete | lock | same |
| PgDn | Dux settings | same |
| F8 | power menu | same |
| F9 / F10 / F12 | screenshot: window / area / screen | same |
| F11 | audio devices | same |
| `,` | pause the break reminders | same |
| `c` `i` `a` `x` | dictate / stop / read aloud / cancel (Speech Note) | same |
| ↑ ↓ ← → | volume up / down, mute, play-pause | same |
| F5 | reload the Mango config | Mango only |

## Workspaces

Tags 1–4 are your workspaces and are always shown: **1 code, 2 web, 3 notes,
4 vm**. Apps open on theirs, as under niri (terminals, Zed, Rune and JetBrains
IDEs on 1; the browsers on 2; Obsidian on 3; virt-manager on 4). Tags 5–9 are
free.

## What's niri-only

These kit helpers talk to niri and don't work under Mango; Mango's own
features stand in:

- the window finder list (Mod + .): Mango's switcher on the same key;
- the second screen's sleep / wake (Mod + q) and screen layout (onehand-monitors):
  Mango arranges the screens by itself; Mod + Home / End still work;
- the niri Dojo, and the Mod + z / Mod + p / Mod + Scroll Lock keys.

## Changing it

The config is `~/.config/mango/config.conf` (the kit's copy is
`files/mango/config.conf`). Check it with `mango -c ~/.config/mango/config.conf -p`,
apply it with Mod + F5. Mango's own documentation:
<https://mangowm.github.io/docs>.

## Where it comes from

`mangowm` is packaged by Terra (Fyra Labs, the repository behind Ultramarine).
The kit adds Terra limited to that one package (`includepkgs=mangowm`), so
nothing else on the system changes source; on Ultramarine, which already uses
Terra, it's left as it is. Screen sharing under Mango uses
`xdg-desktop-portal-wlr` with `slurp` as its picker.
