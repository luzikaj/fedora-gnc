# lfk: Kubernetes, file-manager style

[lfk](https://github.com/janosmiko/lfk) is a fast terminal UI for Kubernetes
clusters, laid out like a file manager: clusters → resource types → resources
→ containers, in columns, with a preview on the right. Start it with `lfk`.

One-Handed Fedora Remix sets its keys to the same scheme as niri, LazyVim and
Helix. Config: `~/.config/lfk/config.yaml` (only the keys are set there).

## Moving around

| Key | Action | lfk's default | Keycap |
|---|---|---|---|
| `e` | back to the parent column | `h` | [G] |
| `h` | down | `j` | [H] |
| `t` | up | `k` | [J] |
| `d` | open: into the selected item | `l` | [K] |
| `H` / `T` | scroll the preview pane down / up | `J` / `K` | Shift + [H] / [J] |
| Enter | full view of the selected item | | |
| `g` / `G` | top / bottom | | |
| Backspace | jump back | | |
| Esc | clear the selection, search or filter | | |
| `q` | quit (asks first) | | |

Tap Right Shift, then the letter, for the capitals.

## Keys moved to make room

The keys `e h t d` took over move to the keys `h j k l` left free, the same
way LazyVim moves them (d → k, t → j, e → l):

| Key | Action | lfk's default |
|---|---|---|
| `k` | **diff** two resources | `d` |
| `j` | new tab | `t` |
| `l` | Secret / ConfigMap editor | `e` |
| `J` | colour theme; tree view (in the Object / API Explorer) | `T` |
| `K` | show rarely used resource types | `H` |

## Everyday actions (lfk's own keys)

| Key | Action |
|---|---|
| `?` (or F1) | **every key** for the current view |
| `x` | action menu for the selected resource |
| `/` | search · `n` / `N` next / previous match |
| `f` | filter the list |
| `v` | describe |
| Ctrl + l | logs (fullscreen) · `L` live-log preview pane |
| `E` | edit in your editor (Neovim) |
| `S` | scale |
| `D` | delete (asks first) · `X` force delete (pods, jobs) |
| `y` / `Y` | copy the name / the YAML |
| `\` | choose namespace · `A` all namespaces |
| `:` | command bar (type a resource type: `pods`, `deploy` …) |
| `g` then `p` / `d` / `s` / `n` | go to pods / deployments / services / nodes |
| `[` / `]` | previous / next tab |
| `space` | select (several resources at once) |
| Ctrl + r | read-only mode on/off |

## Where lfk keeps its own keys

- **Inside the viewers** (YAML, describe, logs, diff, events) and in **pop-up
  lists**, lfk's cursor keys are fixed: use the **arrow keys** (or `j` / `k`,
  keycaps [5] / [;]). PgDn / PgUp and `g` / `G` work there too.
- In the **Object Explorer** (`O`), `h` still means "back": move with the arrow
  keys there.
- In the **log viewer**, `J` / `K` scroll the preview pane and `T` opens
  "log top".

## Changing it

Edit `~/.config/lfk/config.yaml`; every action can be rebound (the full list is
in lfk's [keybindings reference](https://github.com/janosmiko/lfk/blob/main/docs/keybindings.md)).
Restart lfk after editing. k9s is installed too ([k9s](k9s.md)); use whichever you like.
