# One-Handed Fedora Remix: keyboard shortcut guides

One-Handed Fedora Remix is set up to be used with **one hand, the right one**. Every tool
that has its own shortcuts follows the same idea:

- **`e h t d` = left, down, up, right** (the right hand's resting keys)
- the row above (`o r s u`) **moves** things in the same directions
- one modifier plus one key; **no Shift** in the window manager
- the keys a normal layout keeps under the left hand are re-placed under the right

| Guide | What it covers |
|---|---|
| [Keyboard](keyboard.md) | The layout, Mod key, Polish letters, sticky Ctrl/Shift, the key map |
| [niri (desktop)](niri.md) | Windows, workspaces, monitors, launcher, panels, screenshots, audio |
| [Mango](mango.md) | The second session (login screen F3): scrolling + tiling, the same keys |
| [Speech Note (voice)](speech-note.md) | Dictation into any window, reading text aloud |
| [LazyVim (Neovim)](lazyvim.md) | Editor keys |
| [Zed](zed.md) | Editor keys (Helix mode), matching LazyVim |
| [Helix](helix.md) | The Helix editor (`hx`), the same keys as Zed |
| [Rune](rune.md) | IDE around your Helix; Rune's commands behind the Menu / Scroll Lock key |
| [Ghostty and fish (terminal)](ghostty-fish.md) | Copy/paste, shell shortcuts, autosuggestions |
| [yazi (files)](yazi.md) | The file manager (`y` in the terminal), moved with e h t d |
| [lfk (Kubernetes)](lfk.md) | Clusters and resources in columns, moved with e h t d |
| [k9s (Kubernetes)](k9s.md) | Right-hand replacements for k9s's left-hand actions |
| [Welcome window](welcome.md) | The installer and first-steps checklist |
| [Virtual machines](virtualization.md) | virt-manager (KVM): keys, 3D guests, keyboard inside guests |
| [niri Dojo](dojo.md) | Hands-on niri lessons that check each step live (two screens / laptop) |
| [Commands](commands.md) | Every `onehand-*` command (and installer): what it does, its keys, sudo or not, full help |
| [Packages](packages.md) | Every package the kit adds or removes, and where it comes from |
| [Snapshots](snapshots.md) | Undo a bad update or get back a deleted file (system before/after every dnf run, home hourly) |

**Learning the system:** the **niri Dojo** ([dojo.md](dojo.md)): hands-on lessons that check each step live; [printable cheat sheets](learn/cheat-sheets.pdf) (one A4 page per week, with a
daily drill checklist) and an [interactive key trainer](learn/trainer.html) (open it in a browser).

## How keys are written here

Shortcuts are named by the **letter the layout types** (right-handed Dvorak),
not by what is printed on the keycap. Where it helps, the **QWERTY keycap**
it sits on is shown in brackets, e.g. `e` [G].

- **Mod** = hold **Right Alt** (or the Win key).
- `Ctrl` + key can be typed as **tap Right Ctrl, then the key** (sticky Ctrl);
  the same goes for Shift with Right Shift.

## The right-hand key map

What each key types on right-handed Dvorak (`dvorak_r_pl`), right half of
the keyboard:

| Row | QWERTY keycaps → what they type |
|---|---|
| Numbers | `5`→j `6`→l `7`→m `8`→f `9`→p `0`→/ `-`→[ `=`→] |
| Top | `T`→o `Y`→r `U`→s `I`→u `O`→y `P`→b `[`→; `]`→= |
| Home | `G`→**e** `H`→**h** `J`→**t** `K`→**d** `L`→c `;`→k `'`→- |
| Bottom | `B`→i `N`→n `M`→w `,`→v `.`→g `/`→' |

```
        l  m  f  p  /  [  ]        numbers: sizes and panels
      o  r  s  u  y  b  ;  =       top row: MOVE  (o r s u)
      e  h  t  d  c  k  -          home row: GO   (e h t d)
      i  n  w  v  g  '             bottom row: workspaces, launcher
```

The full layout, including the left half, is in [Keyboard](keyboard.md).

Everything here comes straight from the config files in the kit
(`files/`), so if you change a shortcut there, update its guide too.
