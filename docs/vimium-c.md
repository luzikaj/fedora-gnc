# Vimium C: keyboard browsing

Vimium C lets you browse without the mouse: scroll, follow links, switch
tabs and search, all from the right hand. It's installed automatically in
**Brave, Brave Nightly and Chrome** through a browser policy.

The one-handed keys come in a settings file, which you **import once in
each browser**:

1. Open Vimium C's options (puzzle-piece icon → Vimium C → Options).
2. At the bottom: **Import settings**.
3. Choose `~/Documents/vimium-c-onehand.json`.

(The Welcome window's "Browser keys" step opens the options page for you.)

All of Vimium C's default keys are switched off first, so only the keys
below do anything. Everything else types normally.

## Scrolling

| Key | Action | Keycap |
|---|---|---|
| `e` `h` `t` `d` | scroll left / down / up / right | [G H J K] |
| `r` | page down | [Y] |
| `s` | page up | [U] |
| `y` | to the top | [O] |
| `b` | to the bottom | [P] |

## History and tabs

| Key | Action | Keycap |
|---|---|---|
| `o` | back | [T] |
| `u` | forward | [I] |
| `a` | previous tab | [F] |
| `c` | next tab | [L] |
| `k` | close tab | [;] |
| `j` | reopen the closed tab | [5] |
| `=` | reload | []] |

## Links

| Key | Action | Keycap |
|---|---|---|
| `i` | **open a link**: letters appear on every link; type one | [B] |
| `n` | open a link in a new tab | [N] |
| `w` | copy a link's address | [M] |

Link letters use only right-hand keys: `e h t d c o r s u`.

## Address bar, bookmarks, search, input

| Key | Action | Keycap |
|---|---|---|
| `l` | address bar: type a URL, a search, or part of a bookmark | [6] |
| `m` | find an open tab by name | [7] |
| `f` | **search your bookmarks** by name or address; Enter opens one | [8] |
| `/` | find text on the page | [0] |
| `v` / `g` | next / previous match | [, .] |
| `;` | jump to the first text field | [[] |
| `'` | show all Vimium C keys | [/] |

## Leaving a text field

Vimium C's keys don't work while you're typing in a text field. To leave it,
press **Esc**, or **Ctrl + [** (tap Right Ctrl, then `[` on the `-` keycap).

## Changing it

Vimium C's options → **Custom key mappings**. The imported list starts with
`unmapAll`, then one `map KEY COMMAND` per line; the source file is
`files/vimium/vimium-c-onehand.json` in the kit.
