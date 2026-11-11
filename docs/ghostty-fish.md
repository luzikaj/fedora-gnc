# Ghostty and fish: the terminal

**Mod + Enter** opens Ghostty. Inside it runs the **fish** shell; your login
shell stays bash, so scripts and the text console are unaffected.

Config: `~/.config/ghostty/config` and `~/.config/fish/conf.d/onehand.fish`.

## Copy and paste without Shift

| Key | Action |
|---|---|
| `Ctrl+C` | **copy** when text is selected; with nothing selected it still stops the running program, as usual |
| `Ctrl+V` | **paste** |
| select text with the mouse | copies it too, so a middle-click pastes it |

With sticky keys, that's **tap Right Ctrl, then `c`** (keycap [L]) or `v`
(keycap [,]).

## fish: typing less

fish suggests the rest of a command in grey as you type, from your history
and the files around you.

| Key | Action |
|---|---|
| → (right arrow) or `Ctrl+F` | accept the whole suggestion |
| `Alt+→` | accept one word of it |
| Tab | complete; Tab again shows a menu |

### Jumping to folders (zoxide)

| Command | Action |
|---|---|
| `z NAME` | jump to a folder you've used before whose path contains NAME (`z proj`) |
| `zi` | pick one of your folders from a list |

### Searching (fzf)

| Key | Action |
|---|---|
| `Ctrl+R` | search your command history |
| `Ctrl+T` | pick a file, insert its path |
| `Alt+C` | pick a folder below this one and go there |

### Short commands

| Type | Becomes |
|---|---|
| `v` | `nvim` (LazyVim) |
| `g` | `git` |
| `lg` | `lazygit` |
| `k` | `kubectl` |

These are fish abbreviations: they expand when you press Space or Enter, so
the history shows the full command.

Neovim is also set as `$EDITOR` (git commit messages, `sudoedit` …).

## Other terminals

**foot** is a lightweight backup that works without 3D graphics. If Ghostty
can't start (for example in a virtual machine), **Mod + Enter opens foot
instead**, automatically, for the rest of that login. foot also runs fish and
pastes with Ctrl+V; copying there is Ctrl+Shift+C (tap Right Ctrl, then Right
Shift, then `c`). The Welcome window uses foot too.

## Changing it

- Ghostty keys: add `keybind = KEYS=ACTION` lines to `~/.config/ghostty/config`;
  `ghostty +list-keybinds --default` lists the built-in ones.
- fish: add abbreviations to `~/.config/fish/conf.d/onehand.fish`, e.g.
  `abbr -a dc docker compose`.
