# LazyVim (Neovim)

LazyVim is a ready-made Neovim setup (file tree, fuzzy finder, language
servers, git). Fedora GNC keeps all of LazyVim and changes only the keys that a
right-handed Dvorak layout puts in awkward places. Start it with `nvim`, or
`v` in the fish shell.

The same scheme is used in **Zed** ([Zed](zed.md)), so both editors move and
edit the same way.

Config: `~/.config/nvim/lua/config/keymaps.lua` (loaded after LazyVim's own
keys, so these win).

## Movement: the resting keys

| Key | Action | Keycap | Replaces Vim's |
|---|---|---|---|
| `e` | left | [G] | `h` |
| `h` | down (by screen line) | [H] | `j` |
| `t` | up (by screen line) | [J] | `k` |
| `d` | right | [K] | `l` |

They work in normal and visual mode and after operators (`k h` deletes this
line and the one below, as `dj` would). A count jumps whole lines: `5h`.

## Commands that moved

The four movement keys pushed out Vim's own commands, which went to these keys:

| Key | Action | Vim's original |
|---|---|---|
| `k` | **delete** (operator: `kw`, `kl`, `k$` …) | `d` |
| `kk` | delete line | `dd` |
| `j` | **till** character (`jx` = up to before x) | `t` |
| `l` | end of word | `e` |
| `L` | end of WORD | `E` |
| `E` | previous buffer (tab) | LazyVim's `Shift+h` |
| `D` | next buffer | LazyVim's `Shift+l` |

`H` is back to Vim's "top of screen", since buffers moved to `E` / `D`.

## Insert mode

| Key | Action |
|---|---|
| `Ctrl+t` | back to normal mode (no reach for Esc). With sticky keys: tap Right Ctrl, then `t` |

## Scrolling

| Key | Action | Vim's original |
|---|---|---|
| `z h` | scroll one line down | `Ctrl+e` |
| `z t` | scroll one line up | `Ctrl+y` |
| `z H` | half a page down | `Ctrl+d` |
| `z T` | half a page up | `Ctrl+u` |
| `z u` | put the cursor line at the top | `zt` |

## Windows (splits)

| Key | Action |
|---|---|
| `Space w e` / `h` / `t` / `d` | go to the window left / below / above / right |
| `Space w E` / `H` / `T` / `D` | move the window that way |
| `Space w k` | close the window |
| `Ctrl+w` + the same keys | the same, the Vim way |

## Everything else

All other LazyVim keys are unchanged. Press **Space** and wait: a menu lists
every leader key (`Space f f` find files, `Space /` search text,
`Space g g` lazygit, `Space e` file tree, `Space q q` quit …).

## Changing it

Edit `~/.config/nvim/lua/config/keymaps.lua`; each line is
`map(mode, key, action, { desc = "…" })`. The description is what LazyVim's
Space menu shows.
