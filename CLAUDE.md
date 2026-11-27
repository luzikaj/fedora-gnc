# Context for Claude (and other helpers) working on this repo

- **User:** one-handed, **right hand only**, types **right-handed Dvorak**
  (`us(dvorak-r)`, kit layout `dvorak_r_pl` with Polish letters via a tap of
  Right Alt). Every shortcut must be reachable with the right hand; the
  directions are **e h t d** (left / down / up / right) everywhere; displaced
  commands follow LazyVim (d -> k, t -> j, e -> l).
- **Keyboard:** **Logitech G413 TKL** (tenkeyless: F-row, nav cluster with
  Print / Scroll Lock / Pause, Insert … PgDn, arrows; no numpad). Right-hand
  modifiers are what keyd turns into the one-handed layer: Right Alt = hold
  Mod (Super) / tap Polish, Right Ctrl and Right Shift = sticky. Keys on the
  far left (digits, Esc, Tab, left modifiers) are hard to reach: prefer
  F-keys, the nav cluster, and Mod + one key.
- **Screens:** ASUS = main (in front), BenQ = second (right of it), shows the
  cheat-sheet wallpaper.
- **Machines:** this kit on a Fedora-based system (one machine is Ultramarine
  44 updated with `update/`), a Lenovo laptop (Ryzen 7 PRO 4750U, 16 GB) and an
  ISO built by the private repo `luzikaj/onehand-iso` (GitHub Actions running
  `tools/ci-build-iso.sh`) or in a VM (`build-spin.sh`).
  VMs are **VMware Workstation** on Windows (not VirtualBox).
- **Personal use only**: the ISO is not redistributed. This repo is public;
  ISOs live only in the private `onehand-iso` repo, never here.
- **Sessions:** niri (main) and Mango (second, `files/mango/config.conf`,
  login screen F3). Their keys mirror each other: when a niri key changes,
  change Mango's too (and `docs/mango.md`).
- **Conventions:** every user-facing change updates the docs (`docs/`, README,
  DIFFERENCES, CHANGELOG), the wallpaper (`tools/wallpaper/build.sh`) and the
  trainer (`tools/learn/build.py`) when shortcuts change; new files go into
  `fedora-setup.sh` (setup + ISO), `update/update.sh` and
  `tools/make-update-package.sh`; after changing a package list in
  `fedora-setup.sh` or `niri-spin-base.ks`, run `tools/list-packages.py`
  (writes `docs/packages.md`); after adding or changing a command's help
  header (`files/bin/onehand-*`, `files/*/install-*`), run
  `tools/list-commands.py` (writes `docs/commands.md`). Run the checks in
  `.github/workflows/check.yml`.
