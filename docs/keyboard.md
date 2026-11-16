# Keyboard: layout, Mod, Polish letters, sticky keys

Two pieces work together:

- the **layout** `dvorak_r_pl` decides which letter each key types
  (file: `/etc/xkb/symbols/dvorak_r_pl`, from `files/xkb/dvorak_r_pl`);
- **keyd** changes how a few modifier keys behave
  (file: `/etc/keyd/default.conf`, from `files/keyd/default.conf`).

## The layout: right-handed Dvorak with Polish letters

It's Xorg's right-handed Dvorak (`us(dvorak-r)`): the most-used letters sit
under the right hand, and digits move to the left side of the keyboard.

| QWERTY keycap | types | | QWERTY keycap | types |
|---|---|---|---|---|
| `1` `2` `3` `4` | 1 2 3 4 | | `5` `6` `7` `8` `9` `0` `-` `=` | j l m f p / [ ] |
| `Q` `W` `E` `R` | 5 6 q . | | `T` `Y` `U` `I` `O` `P` `[` `]` | o r s u y b ; = |
| `A` `S` `D` `F` | 7 8 z a | | `G` `H` `J` `K` `L` `;` `'` | e h t d c k - |
| `Z` `X` `C` `V` | 9 0 x , | | `B` `N` `M` `,` `.` `/` | i n w v g ' |

The resting position for the right hand is **`e h t d`** (keycaps G H J K):
these are the four directions in every tool.

The **text console**, the **login screen** and the **disk-unlock prompt** use
plain right-handed Dvorak (same keys, no Polish letters; see the table below).
The Menu key works as an extra Win key.

## Where it applies

Right-handed Dvorak is set in every place Fedora reads a keyboard layout:

| Where | Layout | Polish letters | Set by |
|---|---|---|---|
| Desktop: niri, Dux (launcher, lock screen, password pop-ups), every app incl. Flatpak and X11 apps | `dvorak_r_pl` | yes | `~/.config/niri/config.kdl` + `/etc/xkb/symbols/dvorak_r_pl` |
| Installer on the live USB (runs inside niri) | `dvorak_r_pl` | yes | niri |
| Text console (Ctrl+Alt+F3 …) and the login screen | `dvorak-r` | no | `/etc/vconsole.conf` |
| Disk-unlock prompt at boot (encrypted disk) | `dvorak-r` | no | the console keymap, copied into the boot image |
| GDM or another desktop, if installed | `us (dvorak-r)` | no | `localectl` X11 setting |
| Right Alt as Mod, sticky Ctrl/Shift | all of the above | | keyd, below the layouts |

All of them put every letter, digit and symbol on the same key. Only the
Polish letters are missing outside the desktop, so **use plain characters
(no ą ć ę …) in your login password and disk passphrase**: you type those on
the login screen and at boot.

The boot menu (GRUB) always uses US QWERTY; it needs no typing unless you
edit a boot entry.

**Check it** any time, or fix whatever is wrong:

```
onehand-keyboard-check          # ✓ / ✗ for every place above
onehand-keyboard-check --fix    # set it again where it's wrong
```

It's also in the Welcome window's checklist. The ISO build checks the same
when it builds the image, and stops if no right-handed Dvorak console keymap
is available.

## Mod: hold Right Alt

| Do this | Result |
|---|---|
| **Hold Right Alt** + key | **Mod** (Super/Win) + key: all desktop shortcuts |
| Win key + key | the same, if you can reach it |

## Polish letters: tap Right Alt, then the letter

Tap **Right Alt** (press and release on its own), then the letter:

| Letter | Tap Right Alt, then | QWERTY keycap |
|---|---|---|
| ą Ą | a | `F` |
| ć Ć | c | `L` |
| ę Ę | e | `G` |
| ł Ł | l | `6` |
| ń Ń | n | `N` |
| ó Ó | o | `T` |
| ś Ś | s | `U` |
| ż Ż | z | `D` |
| ź Ź | x | `C` |

Capitals: hold Shift as well (or tap Right Shift first, see below).

## Sticky Ctrl and Shift

| Do this | Result |
|---|---|
| **Tap Right Ctrl**, then a key | Ctrl + that key (e.g. tap Right Ctrl, then `c` = copy) |
| **Tap Right Shift**, then a key | Shift + that key (a capital letter, `:` and so on) |
| Hold Right Ctrl / Right Shift | works as normal |

"Sticky" means one-shot: it applies to the next key only. A tap is forgotten
if no key follows **within 1 second**, so a stray tap can't turn a later
letter into a capital. (Same for tapping Right Alt before a Polish letter.)
The time is `oneshot_timeout` in `/etc/keyd/default.conf`.

## Safety

- **keyd stuck or misbehaving:** press **Backspace + Escape + Enter** at the
  same time to stop keyd. The keyboard goes back to the plain layout.
- `systemctl status keyd` shows whether it's running;
  `sudo systemctl restart keyd` starts it again.
- Dictation types through a virtual keyboard that keyd deliberately leaves
  alone, so dictated text isn't remapped.

## Changing it

- Behaviour of keys (Mod, sticky keys): edit `/etc/keyd/default.conf`, then
  `sudo systemctl restart keyd`.
- Letters: edit `/etc/xkb/symbols/dvorak_r_pl`, then log out and in.
- In the kit, change `files/keyd/default.conf` or `files/xkb/dvorak_r_pl`
  so the next install or ISO build gets it too.

## The keyboard this was set up on

A **Logitech G413 TKL** (tenkeyless). Everything here works on any keyboard,
but the choices lean on what a TKL has near the right hand: the F-row
(screenshots on Mod + F9 / F10 / F12, audio on Mod + F11), the nav cluster
(Insert … PgDn, Print, Scroll Lock, Pause) and the arrows. Logitech's G HUB
software doesn't exist for Linux and isn't needed: the keyboard works as a
standard one, and its lighting stays as last set (OpenRGB can change it, if
wanted).

