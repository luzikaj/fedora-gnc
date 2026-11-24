# Welcome window

A small window that opens:

- on the **live USB**: to install One-Handed Fedora Remix, connect to Wi-Fi or learn the keys;
- on an **installed system**: at every login, until you choose "All done",
  as a checklist of first steps.

Open it again any time from the launcher (Mod + `'`): **Welcome to One-Handed Fedora Remix**.
On the live USB, **Install One-Handed Fedora Remix** in the launcher goes straight to installing.

## Keys

| Key | Action | Keycap |
|---|---|---|
| `h` or ↓ | next item | [H] |
| `t` or ↑ | previous item | [J] |
| Enter | choose | |
| Esc | close / go back | |

`j` / `k` also work, for Vim habits.

## On the live USB

| Item | What it does |
|---|---|
| Install One-Handed Fedora Remix on this computer | explains the steps, then starts Fedora's installer |
| Connect to Wi-Fi | opens `nmtui` (arrow keys, Enter) |
| Learn the one-handed keys | a one-page summary |
| Just try it | closes the window |

## After installing

Each step gets a ✓ when done:

| Item | What it does |
|---|---|
| Network and Wi-Fi | `nmtui` |
| Apps from Flathub | shows which apps are installed and installs the missing ones |
| Dictation | opens Speech Note with the steps to download the Polish model |
| Screens | sets up the two monitors now (`onehand-monitors`) |
| The one-handed keys, the niri tutorial and Dojo | the key summary; then `d` starts the niri Dojo ([dojo.md](dojo.md)), Enter opens the niri tutorial PDF |
| Check right-handed Dvorak everywhere | runs `onehand-keyboard-check`; Enter fixes what's wrong |
| Check for updates | `dnf upgrade` and `flatpak update` |
| All done | stops it opening at login |

The window uses the foot terminal, so it also works in virtual machines
without 3D graphics. Its script is `/usr/local/bin/onehand-welcome`.
