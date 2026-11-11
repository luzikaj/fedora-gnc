# Changelog

Newest first. Note what changed and why; the ISO name carries the build date.

## 2026-11-11
- Virtual machines: virt-manager on KVM with 3D guests, no password prompts for
  administrators, workspace `vm` on the main screen; `docs/virtualization.md`;
  BUILDING.md tests the ISO in virt-manager.
- README: why niri.
- Kit kept in Git: update package and wallpaper are built from the repository
  (`tools/make-update-package.sh`, `tools/wallpaper/build.sh`).

## 2026-11-10
- One-Handed Fedora Remix name and logo; Welcome window (live installer + first-login checklist).
- Two monitors (ASUS main, BenQ right) with named workspaces and window rules.
- Dictation with Speech Note; Vimium C with one-handed keys (`f` = bookmarks).
- Ghostty with fish, copy/paste without Shift; foot as fallback (`onehand-terminal`).
- Sticky Right Ctrl/Shift (keyd), forgotten after 1 s.
- `onehand-keyboard-check`: right-handed Dvorak everywhere (console, login, disk unlock).
- Development: Python 3 (pipx, uv), .NET 10 SDK, JetBrains Toolbox. Helium removed.
- ISO build: small kickstart (files copied in, not embedded), dependency check
  in `--generate-only`, i3 release identity so the installer avoids Firefox.
- Per-tool shortcut guides in `docs/`.
