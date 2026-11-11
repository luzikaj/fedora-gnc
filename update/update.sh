#!/usr/bin/env bash
#
# update.sh — bring your current one-handed Fedora + niri system up to
# One-Handed Fedora Remix: terminal fallback (foot), sticky-key timeout, keyboard check,
# shortcut guides, development tools (Python, .NET, JetBrains Toolbox), sticky keys, two monitors, window rules, dictation (Speech Note),
# Vimium C, Ghostty with fish, the new wallpaper and the One-Handed Fedora Remix name/logo.
#
# Usage (as your normal user, not with sudo; it asks for sudo itself):
#   tar xzf onehand-update.tar.gz && cd onehand-update
#   ./update.sh --dry-run    # show what it would do
#   ./update.sh
#
# Safe to re-run. Every file it replaces is kept as <file>.bak.<date>.
# If the new niri config doesn't validate, your old one is put back.

set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
F="$HERE/files"
STAMP="$(date +%Y%m%d-%H%M%S)"
DRY=false
[[ "${1:-}" == "--dry-run" ]] && DRY=true

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
ok()   { printf '    \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '    \033[33m!\033[0m %s\n' "$*" >&2; }
run()  { if $DRY; then printf '    [dry-run] %s\n' "$*"; else "$@"; fi; }

# put SRC DEST [sudo] [mode]: copy, backing up a different file that was there
put() {
    local src="$1" dest="$2" s="${3:-}" mode="${4:-644}"
    if $DRY; then printf '    [dry-run] copy %s -> %s\n' "${src#"$F"/}" "$dest"; return 0; fi
    $s mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" ]] && ! $s cmp -s "$src" "$dest"; then
        $s cp -a "$dest" "$dest.bak.$STAMP"; warn "backed up $dest -> $dest.bak.$STAMP"
    fi
    $s install -m "$mode" "$src" "$dest"
}

[[ $EUID -ne 0 ]] || { echo "Run as your normal user (not with sudo)." >&2; exit 1; }
[[ -d "$F/niri" ]] || { echo "Run this from the unpacked folder (files/ is missing)." >&2; exit 1; }
$DRY || sudo -v

# ------------------------------------------------------------------ 1. packages
step "1/9  Packages: fish, zoxide, ydotool, Speech Note"
run sudo dnf install -y --skip-unavailable fish zoxide fzf ydotool jq kbd-legacy foot
if command -v flatpak >/dev/null; then
    run sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    run sudo flatpak install -y --noninteractive flathub net.mkiol.SpeechNote \
        || warn "Speech Note didn't install; later: flatpak install flathub net.mkiol.SpeechNote"
else
    warn "flatpak missing; dictation needs Speech Note from Flathub"
fi

# ------------------------------------------------------------------ 2. development
step "2/9  Development tools: Python 3, .NET 10, JetBrains Toolbox, virt-manager; Helium removed"
run sudo dnf install -y --skip-unavailable python3 python3-devel python3-pip pipx uv dotnet-sdk-10.0 \
    libXtst libXi libXrender xcb-util-keysyms gtk3 curl jq
if $DRY; then
    printf '    [dry-run] download and verify the latest JetBrains Toolbox into /opt/jetbrains-toolbox\n'
else
    sudo bash "$F/jetbrains/install-jetbrains-toolbox" || warn "JetBrains Toolbox didn't install; run files/jetbrains/install-jetbrains-toolbox with sudo later"
fi
if rpm -q helium-bin >/dev/null 2>&1; then run sudo dnf remove -y helium-bin; fi
if compgen -G "/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:imput:helium.repo" >/dev/null; then
    run sudo dnf copr remove -y imput/helium || warn "couldn't turn off Helium's COPR"
fi
ok "python3, uv, pipx, dotnet, jetbrains-toolbox (launcher: JetBrains Toolbox)"

# Virtual machines: KVM + libvirt + virt-manager, no password prompts for admins
run sudo dnf install -y --skip-unavailable virt-manager virt-install virt-viewer qemu-kvm \
    libvirt-daemon-kvm libvirt-daemon-config-network edk2-ovmf swtpm
put "$F/virt/50-onehand-libvirt.rules" /etc/polkit-1/rules.d/50-onehand-libvirt.rules sudo
for s in virtqemud virtnetworkd virtstoraged virtnodedevd virtsecretd virtinterfaced virtnwfilterd; do
    run sudo systemctl enable --now "${s}.socket" 2>/dev/null || true
done
ok "virt-manager: VMs open on the workspace \"vm\" (docs: virtualization.md)"

# ------------------------------------------------------------------ 2. keyboard
step "3/9  Sticky Right Ctrl / Right Shift (keyd)"
put "$F/keyd/default.conf" /etc/keyd/default.conf sudo
run sudo systemctl restart keyd || warn "keyd didn't restart; reboot to apply"
ok "tap Right Ctrl or Right Shift, then the key (a tap is forgotten after 1 s)"

# ------------------------------------------------------------------ 3. niri
step "4/9  niri: two monitors, window rules, dictation keys"
nd="$HOME/.config/niri"
put "$F/bin/onehand-monitors" /usr/local/bin/onehand-monitors sudo 755
put "$F/bin/onehand-keyboard-check" /usr/local/bin/onehand-keyboard-check sudo 755
put "$F/bin/onehand-terminal" /usr/local/bin/onehand-terminal sudo 755
put "$F/niri/onehand-rules.kdl" "$nd/onehand-rules.kdl"
if [[ -e "$nd/onehand-monitors.kdl" ]]; then ok "keeping your onehand-monitors.kdl"
else put "$F/niri/onehand-monitors.kdl" "$nd/onehand-monitors.kdl"; fi
for f in colors layout alttab binds; do
    [[ -e "$nd/dms/$f.kdl" ]] || run install -D -m 644 /dev/null "$nd/dms/$f.kdl"
done
old_cfg=""
[[ -e "$nd/config.kdl" ]] && ! cmp -s "$F/niri/config.kdl" "$nd/config.kdl" && old_cfg="$nd/config.kdl.bak.$STAMP"
put "$F/niri/config.kdl" "$nd/config.kdl"
if ! $DRY && command -v niri >/dev/null; then
    if niri validate -c "$nd/config.kdl" >/tmp/onehand-niri-validate.log 2>&1; then
        ok "niri config is valid"
    else
        warn "niri validate failed (see /tmp/onehand-niri-validate.log)"
        if [[ -n "$old_cfg" ]]; then
            cp "$old_cfg" "$nd/config.kdl"; warn "put your previous config.kdl back; the new one is in $HERE/files/niri/"
        fi
    fi
fi
# niri reloads its config by itself; place the workspaces on your screens now.
if ! $DRY && [[ -n "${NIRI_SOCKET:-}" ]]; then
    /usr/local/bin/onehand-monitors || warn "onehand-monitors failed; it runs again at next login"
fi

# ------------------------------------------------------------------ 4. terminal
step "5/9  Ghostty with fish, copy/paste without Shift"
gd="$HOME/.config/ghostty"
put "$F/ghostty/config" "$gd/config"
[[ -e "$gd/config.ghostty" ]] && warn "you also have $gd/config.ghostty; Ghostty reads both, check it doesn't override these keys"
put "$F/fish/onehand.fish" "$HOME/.config/fish/conf.d/onehand.fish"
put "$F/foot/foot.ini" "$HOME/.config/foot/foot.ini"
ok "new Ghostty windows start fish (your login shell stays as it is)"
ok "Mod + Enter opens foot instead if Ghostty can't start"
for f in "$F"/docs/*.md; do put "$f" "$HOME/Documents/OneHanded-Fedora-Remix-docs/$(basename "$f")"; done
ok "shortcut guides: ~/Documents/OneHanded-Fedora-Remix-docs/"

# ------------------------------------------------------------------ 5. dictation
step "6/9  Dictation: ydotoold virtual keyboard for Speech Note"
if $DRY; then
    printf '    [dry-run] create and start onehand-ydotoold.service; flatpak override for Speech Note\n'
else
    sudo tee /etc/systemd/system/onehand-ydotoold.service >/dev/null <<'UNIT'
[Unit]
Description=ydotoold virtual keyboard (Speech Note dictation)

[Service]
RuntimeDirectory=ydotoold
ExecStart=/usr/bin/ydotoold --socket-path=/run/ydotoold/socket --socket-perm=0666
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
    sudo systemctl daemon-reload
    if [[ -x /usr/bin/ydotoold ]]; then
        sudo systemctl enable --now onehand-ydotoold.service && ok "ydotoold running"
    else
        warn "ydotool isn't installed; dictation can't type into windows"
    fi
    command -v flatpak >/dev/null && sudo flatpak override --system \
        --filesystem=/run/ydotoold --env=YDOTOOL_SOCKET=/run/ydotoold/socket net.mkiol.SpeechNote || true
fi

# ------------------------------------------------------------------ 6. browsers
step "7/9  Vimium C for Brave, Brave Nightly and Chrome"
put "$F/vimium/chromium-policy.json" /etc/brave/policies/managed/onehand-vimium-c.json sudo
put "$F/vimium/chromium-policy.json" /etc/opt/chrome/policies/managed/onehand-vimium-c.json sudo
put "$F/vimium/vimium-c-onehand.json" "$HOME/Documents/vimium-c-onehand.json"
ok "restart the browsers; then Vimium C Options -> Import ~/Documents/vimium-c-onehand.json"

# ------------------------------------------------------------------ 7. name and logo
step "8/9  One-Handed Fedora Remix name and logo"
put "$F/branding/onehanded-remix-logo.svg" /usr/share/icons/hicolor/scalable/apps/onehanded-remix-logo.svg sudo
put "$F/branding/onehanded-remix-logo-256.png" /usr/share/icons/hicolor/256x256/apps/onehanded-remix-logo.png sudo
put "$F/branding/onehanded-remix-logo-256.png" /usr/share/pixmaps/onehanded-remix-logo.png sudo
put "$F/branding/onehanded-remix-wordmark.svg" /usr/share/pixmaps/onehanded-remix-wordmark.svg sudo
run sudo bash "$F/branding/apply-branding.sh"
$DRY || ok "$(. /etc/os-release && echo "$PRETTY_NAME")"

# ------------------------------------------------------------------ 8. wallpaper
step "9/9  One-Handed Fedora Remix wallpaper"
walls="$HOME/Pictures/Wallpapers"
for f in "$F"/wallpapers/*.png; do put "$f" "$walls/$(basename "$f")"; done
put "$F/wallpapers/onehanded-remix-2560x1440.png" /usr/share/backgrounds/onehand/default.png sudo
run sudo restorecon -R /etc/keyd /etc/brave /etc/opt/chrome /usr/local/bin /usr/share/icons/hicolor /usr/share/pixmaps /usr/share/backgrounds/onehand 2>/dev/null || true
pick="$walls/onehanded-remix-2560x1440.png"
if $DRY; then
    printf '    [dry-run] dms ipc call wallpaper set %s\n' "$pick"
elif command -v dms >/dev/null && dms ipc call wallpaper set "$pick" >/dev/null 2>&1; then
    ok "set as wallpaper (per-monitor choice, e.g. 1920x1080 on the BenQ: Mod + PgDn)"
else
    warn "couldn't set it automatically; pick it in Dux settings (Mod + PgDn)"
fi

step "Check: right-handed Dvorak everywhere"
if $DRY; then
    printf '    [dry-run] onehand-keyboard-check\n'
else
    /usr/local/bin/onehand-keyboard-check || warn "fix it with: onehand-keyboard-check --fix"
fi

cat <<'DONE'

    Done. Log out and back in (or reboot) once, so the monitors, Speech Note
    in the tray and fish in Ghostty all start fresh.

    Two things to do by hand, once:
      1. Speech Note: open it, download a Polish speech model (and a voice).
      2. Vimium C (Brave, Brave Nightly, Chrome): Options -> Import settings
         -> ~/Documents/vimium-c-onehand.json
DONE
