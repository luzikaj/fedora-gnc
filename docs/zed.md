# Zed

Zed (from Flathub) runs in **Helix mode**: you select first, then act (`w`
selects a word, then `k` deletes it). On top of Helix's keys, Fedora GNC moves
the directions to the right hand's resting keys, exactly like in
[LazyVim](lazyvim.md).

Config: `~/.config/zed/keymap.json`, and `~/.config/zed/settings.json` with
`"helix_mode": true`. Both are also installed where the Flatpak
version may look for it: `~/.var/app/dev.zed.Zed/config/zed/`.

## Movement

| Key | Action | Keycap | Helix's |
|---|---|---|---|
| `e` | left | [G] | `h` |
| `h` | down (by screen line) | [H] | `j` |
| `t` | up (by screen line) | [J] | `k` |
| `d` | right | [K] | `l` |

In select mode (`v`) the same keys extend the selection.

## Commands that moved

| Key | Action | Helix's |
|---|---|---|
| `k` | delete the selection | `d` |
| `D` | delete without copying it | `Alt+d` |
| `j` | till character | `t` |
| `l` | end of word | `e` |
| `L` | end of WORD | `E` |

## Insert mode

| Key | Action |
|---|---|
| `Ctrl+t` | back to normal mode (tap Right Ctrl, then `t`) |

## View and scrolling

| Key | Action |
|---|---|
| `z h` / `z t` | scroll one line down / up |
| `z H` / `z T` | scroll half a page down / up |
| `z u` | cursor line to the top |
| `z c` | cursor line to the centre |
| `z b` | cursor line to the bottom |

## Panes (splits)

| Key | Action |
|---|---|
| `Space w e` / `h` / `t` / `d` | go to the pane left / below / above / right |
| `Space w E` / `H` / `T` / `D` | swap the pane with its neighbour that way |
| `Ctrl+w` + the same keys | the same |

## Everything else

Helix's other keys and Zed's own shortcuts are unchanged: `Space f` file
picker, `Space /` search, `x` select line, `w` / `b` words, `u` undo, `y` / `p`
copy and paste, `:` commands, Ctrl+Shift+P command palette.

## Changing it

Edit `~/.config/zed/keymap.json` (Zed reloads it on save). Each binding
pairs a key with a Zed action; the command palette shows action names.
