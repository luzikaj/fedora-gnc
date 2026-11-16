# yazi: the file manager

[yazi](https://yazi-rs.github.io) is a fast terminal file manager: folders in
columns, a preview on the right (text, code, images, PDFs, video thumbnails,
archives). Start it with **`y`** in the terminal. When you quit with `q`, the
terminal stays in the folder you were in; `Q` quits back to where you started.

Its keys follow the same scheme as niri, LazyVim, Vimium C and lfk. Config:
`~/.config/yazi/keymap.toml` (only the changed keys; the rest is yazi's own).

## Moving around

| Key | Action | yazi's default | Keycap |
|---|---|---|---|
| `e` | parent folder | `h` | [G] |
| `h` | down | `j` | [H] |
| `t` | up | `k` | [J] |
| `d` | into the folder | `l` | [K] |
| Enter | open the file (in its app; text in Neovim) | | |
| `H` / `T` | scroll the preview down / up | `J` / `K` | Shift + [H] / [J] |
| `E` / `D` | back / forward through folders you visited | `H` / `L` | |
| `g` `g` / `G` | top / bottom | | |
| `g` `h` · `g` `c` · `g` `d` | home · ~/.config · ~/Downloads | | |
| `z` / `Z` | jump anywhere with fzf / to a folder you use often (zoxide) | | |

Tap Right Shift, then the letter, for the capitals.

## Keys moved to make room

| Key | Action | yazi's default |
|---|---|---|
| `k` | **move to trash** | `d` |
| `K` | delete for good | `D` |
| `j` | new tab here | `t` `t` |
| `J` | rename the tab | `t` `r` |

## Files (yazi's own keys)

| Key | Action |
|---|---|
| Space | select (several files at once); `v` select a range |
| `y` / `x` / `p` | copy / cut / paste (`P` paste and overwrite) |
| `a` | new file; end the name with `/` for a folder |
| `r` | rename |
| `o` or Enter | open; `O` choose the app |
| `.` | show / hide hidden files |
| `f` | filter the list as you type |
| `/` · `n` / `N` | find a name · next / previous match |
| `s` / `S` | search names (fd) / contents (ripgrep) below this folder |
| `c` `c` / `c` `f` | copy the path / the file name |
| `,` then a letter | sort (`,m` by date, `,s` by size, `,a` by name) |
| `;` | run a shell command on the selection |
| `[` / `]` · `1`…`9` | previous / next tab · tab number |
| `w` | running jobs (copies, moves) |
| `~` or F1 | **every key**, searchable |
| `q` | quit |

In the help screen and in the job, pick and confirm lists, `h` / `t` move too.
In text boxes (rename, new file), after Esc: `e` / `d` move a character, `l`
to the end of a word, `k` cuts, `h` / `t` go through earlier entries, as in LazyVim.

## Changing it

Add or change keys in `~/.config/yazi/keymap.toml` (every action can be rebound;
yazi's [keymap reference](https://yazi-rs.github.io/docs/configuration/keymap)).
Restart yazi after editing. `nnn` is still installed as a minimal fallback.
