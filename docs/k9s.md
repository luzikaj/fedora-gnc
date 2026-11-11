# k9s: Kubernetes in the terminal

k9s is a terminal UI for Kubernetes clusters (start it with `k9s`). Several
of its most-used actions sit on keys that right-handed Dvorak puts on the
left side of the keyboard. Fedora GNC adds **plugins** that repeat those
actions on right-hand keys with Shift. k9s's own keys keep working too.

Config: `~/.config/k9s/plugins.yaml`.

## Right-hand actions

| Keys | Action | Replaces | Keycap |
|---|---|---|---|
| `Shift+H` | **describe** the selected resource (opens in `less`) | `d` | [H] |
| `Shift+E` | show its **YAML** (opens in `less`) | `y` | [G] |
| `Shift+U` | **delete** the resource (asks first) | `Ctrl+D` | [I] |
| `Shift+W` | **force-kill** the pod, no grace period (asks first, pods only) | `Ctrl+K` | [M] |

Tap Right Shift, then the letter, instead of holding Shift.

Delete and kill are marked dangerous: k9s asks for confirmation, and hides
them in read-only mode.

## Reading the output

Describe and YAML open in `less`:

| Key | Action |
|---|---|
| ↓ / ↑, or `j` / `k` | down / up a line (`j` [5], `k` [;]) |
| Space / `b` | next / previous page (`b` [P]) |
| `/` | search; `n` next match |
| `q` | back to k9s (keycap [E]) |

## k9s keys that already suit the right hand

| Key | Action |
|---|---|
| `:` then a type (`pods`, `deploy`, `svc` …) | switch resource type |
| `/` | filter the list |
| `l` | logs |
| `s` | shell into the container |
| Enter | drill into the selected item |
| Esc | back |
| `?` | all keys for the current view |

## Changing it

Each plugin in `~/.config/k9s/plugins.yaml` has a `shortCut`, a
`description` (shown in k9s's help) and the command it runs. Restart k9s after
editing.
