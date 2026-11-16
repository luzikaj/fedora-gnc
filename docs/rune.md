# Rune

[Rune](https://rune.build) is a fast, keyboard-driven IDE (GPL-3.0): windows,
tabs, terminals, project-wide search, language intelligence, a debugger and an
AI agent in one GPU-drawn window. Start it from the launcher (Mod + ', "Rune")
or with `rune` in a terminal; it opens on the `code` workspace.

One-Handed Fedora Remix sets it up so that:

- **the editor is your Helix.** Rune runs `hx` inside its tabs ("exo" mode),
  so editing uses exactly your [Helix keys](helix.md): e h t d, k delete,
  Ctrl + t leaves insert, z and Space menus. Rune adds go-to-definition,
  references, diagnostics, search and the rest around it.
- **Rune's own commands sit behind one leader key**, followed by the same
  letters as niri.

Config: `~/.rune/config.yaml`. Restart Rune (or run `workspacereload` in its
prompt) after editing.

## The leader

Press the **Menu key** (the key between Right Alt and Right Ctrl) or
**Scroll Lock**, then one key. Whatever has focus (Helix, a terminal, a
prompt), the key after the leader always goes to Rune.

| After the leader | Action |
|---|---|
| `e` `h` `t` `d` | go to the window left / below / above / right |
| `E` `H` `T` `D` | move the window that way (tap Right Shift first) |
| `n` | new split |
| Enter | new terminal |
| Backspace | close the window |
| `y` | maximize the window / back |
| `[` / `]` | previous / next tab |
| `k` | close the tab |
| `b` | find an open tab |
| `'` | command prompt (every Rune command, fuzzy-searched) |
| `f` | find a file |
| `/` | search the text of all files |
| `x` | file explorer (move with the arrow keys) |
| `o` | workspaces (projects) |
| `g` | go to definition |
| `r` | references |
| `s` | show the type / docs (hover) |
| `,` / `.` | previous / next problem |
| `c` | every Rune key (cheat sheet) |

These follow niri: e h t d move, Enter is a terminal, Backspace closes, `y`
is full size, `'` is the launcher (here: the command prompt).

## Why a leader

niri takes the Super key and Right Alt (your Mod), and Rune lets a terminal or
Helix keep every Ctrl and Shift key. So Rune's usual Super / Alt shortcuts
aren't reachable one-handed. Rune remaps the Menu and Scroll Lock keys to a
chord nothing else uses (`gui.key_mapping`), and every command is bound to that
chord plus a letter (`command.key_bindings`).

If your keyboard has neither key, pick another in `~/.rune/config.yaml` under
`gui.key_mapping` (an F-key, for example `"<f12>": "<alt-meta-space>"`).

## Notes

- Inside Helix, `:` is Helix's own command line; Rune's prompt is leader + `'`.
- Rune's built-in editors (vim / helix mode) have fixed h j k l keys, which is
  why the kit uses your real Helix instead. The file explorer is one of Rune's
  lists and uses the arrow keys.
- Installed in `/opt/rune` from Rune's GitHub releases, checked against the
  SHA-256 GitHub records for the file. It doesn't update itself there; the
  kit's update package installs the newest release.
- Rune draws through X11 (xwayland-satellite under niri) with OpenGL.
- The first start may ask about Rune's network / account features; they're
  optional.
