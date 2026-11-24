# niri Dojo: practise with live checks

The Dojo teaches niri with **your** one-handed shortcuts. It opens practice
windows A, B and C, gives you one task at a time and **watches niri** (through
`niri msg`) to tick each task off the moment you've done it. You never type
into its window: you just use the shortcuts. About 5 minutes.

Start it from the launcher (Mod + ', **niri Dojo**), from the Welcome window
(The one-handed keys → `d`), or in a terminal:

| Command | What it does |
|---|---|
| `onehand-dojo` | the full course; with only one screen, the one-screen course |
| `onehand-dojo --solo` | the one-screen course, even with two screens |
| `onehand-dojo --from 4` | start at lesson 4 (works with `--solo` too) |
| Ctrl + C in the Dojo window | stop; the practice windows are closed |

## Two screens (the desk)

1. **Two monitors:** send the guide to the other screen (Mod + End; you stay on
   the main one), jump over and back (Mod + Home).
2. **Workspaces are floors:** go down to an empty one (Mod + w).
3. **Focus between columns:** Mod + e / d.
4. **Moving windows:** Mod + o / u.
5. **Stacking two windows in one column:** Mod + `;`, Mod + t / h, Mod + `=`.
6. **Sizes:** Mod + l (preset widths), Mod + m / f (narrower / wider).
7. **Floors again:** carry a window down / up (Mod + g / v), just look
   (Mod + w / n).
8. **The overview:** Mod + `-`.
9. **Floating:** Mod + k.
10. **Closing:** Mod + Backspace.

At the end the guide is still on the second screen: Mod + End there brings it back.

## One screen (laptop)

The same lessons, minus the two-monitor one. The guide floats small in the
bottom-right corner of your practice workspace, and every task also pops up as
a notification, so you can read it after moving to another workspace. Only
letters and Backspace: no arrows or navigation keys.

## Notes

- Your best time is kept (`~/.local/state/niri-dojo-best`, `…-solo-best`) when
  you run the whole course.
- Practice windows open in foot (it works in VMs without 3D too).
- Needs jq (installed by the kit).
