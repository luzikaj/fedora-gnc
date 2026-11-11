One-Handed Fedora Remix update for your current system
=========================================

Adds to your running one-handed Fedora + niri setup:
  - sticky keys: tap Right Ctrl / Right Shift, then the key
  - two monitors: ASUS (main) gets "code", BenQ (right) gets "web" + "notes";
    apps open on their screen by themselves; Mod + z moves a whole workspace
  - dictation with Speech Note: Mod + c dictate, Mod + i stop,
    Mod + a read clipboard aloud, Mod + x stop reading
  - Vimium C in Brave, Brave Nightly and Chrome
  - Ghostty runs fish; Ctrl+C / Ctrl+V copy and paste without Shift
  - the One-Handed Fedora Remix name, logo and cheat-sheet wallpaper
  - development: Python 3 (pipx, uv), .NET 10 SDK, JetBrains Toolbox
  - virtual machines: virt-manager (KVM), 3D guests, workspace "vm"
  - Helium browser removed
  - sticky keys forget a tap after 1 second (no stray capitals)
  - Mod + Enter opens foot when Ghostty can't start
  - onehand-keyboard-check: is right-handed Dvorak set everywhere? (--fix)
  - shortcut guides in ~/Documents/OneHanded-Fedora-Remix-docs/

Run (as your normal user):
  tar xzf onehand-update.tar.gz && cd onehand-update
  ./update.sh --dry-run
  ./update.sh
Then log out and back in once.

Every replaced file is kept as <file>.bak.<date>. If niri rejects the new
config, your previous config.kdl is put back automatically.

By hand, once:
  1. Speech Note: download a Polish speech model (and a voice).
  2. Vimium C: Options -> Import settings -> ~/Documents/vimium-c-onehand.json
