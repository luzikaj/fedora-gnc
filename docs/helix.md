# Helix

[Helix](https://helix-editor.com) is a modal editor where you select first and
then act (`w` selects a word, then `k` deletes it). Start it with `hx`.
One-Handed Fedora Remix gives it exactly the same keys as [Zed](zed.md) (which
runs in Helix mode) and the same moves as [LazyVim](lazyvim.md).

Config: `~/.config/helix/config.toml`. Run `:config-reload` after editing it.

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
| `z c` / `z b` | cursor line to the centre / bottom |

`Z` (sticky view mode) takes the same keys and stays on until Esc.

## Splits

| Key | Action |
|---|---|
| `Space w e` / `h` / `t` / `d` | go to the split left / below / above / right |
| `Space w E` / `H` / `T` / `D` | swap the split with its neighbour that way |
| `Ctrl+w` + the same keys | the same |

## Everything else

Helix's other keys are unchanged: `Space f` file picker, `Space /` search,
`x` select line, `w` / `b` words, `u` undo, `y` / `p` copy and paste, `:`
commands, `Space ?` every command. Goto mode keeps `g e` (last line),
`g t` (top of screen), `g d` (definition) and `g h` / `g l` (line start / end).
