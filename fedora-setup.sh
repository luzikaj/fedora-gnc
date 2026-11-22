#!/usr/bin/env bash
#
# fedora-setup.sh — set up Fedora (or Ultramarine) as your one-handed niri desktop.
#
# Installs your apps, and your one-handed setup from the files/ folder next to
# this script: right-handed Dvorak + Polish letters, keyd (hold Right Alt = Mod,
# tap Right Alt = Polish letter), niri + Dux Shell, Zed, LazyVim, k9s, wallpapers.
#
# Usage:
#   chmod +x fedora-setup.sh
#   ./fedora-setup.sh            # run everything
#   ./fedora-setup.sh --dry-run  # show what would happen, change nothing
#
# Run as your normal user (not root). The script calls sudo where needed,
# and puts your personal config files in your own home folder.
# Safe to re-run: config files it replaces are backed up with a date suffix.

set -euo pipefail

# =============================================================================
#  CONFIGURATION — edit these sections
# =============================================================================

# Upgrade the whole system before installing anything.
DO_SYSTEM_UPGRADE=true

# Enable RPM Fusion (needed for codecs, NVIDIA drivers, Steam, etc.)
ENABLE_RPMFUSION=true

# Enable Flathub and install the Flatpaks listed below.
ENABLE_FLATHUB=true

# Packages from the Fedora (and RPM Fusion, if enabled) repositories.
DNF_PACKAGES=(
    git
    curl
    wget
    vim
    htop
    tmux
    zsh
    fzf
    ripgrep
    fd-find
    bat
    gcc
    make
    python3-pip
    nnn         # terminal file manager (small, always there)
    # yazi's previews: PDFs, video thumbnails, archives, images
    poppler-utils ffmpegthumbnailer 7zip ImageMagick
    awscli2     # AWS CLI v2 (command: aws)
    jq          # used by this script and by niri's force-close shortcut
    # LazyVim (Neovim distribution): Neovim plus what its plugins need
    neovim tree-sitter-cli wl-clipboard unzip nodejs-npm
    helix       # Helix editor (command: hx), keys e h t d like LazyVim and Zed
    # niri desktop
    niri                # compositor (25.11+ comes from duxlabs/dux-repo)
    xwayland-satellite  # lets X11-only apps run under niri
    greetd tuigreet     # text login screen that starts niri
    xdg-desktop-portal-gnome xdg-desktop-portal-gtk   # screen sharing, file pickers
    wev                 # shows which key niri sees (handy for debugging binds)
    tuned-ppd pavucontrol playerctl wireplumber        # power, audio, media keys
    fish zoxide         # Ghostty's shell: autosuggestions, z <folder> jumps
    ydotool             # lets Speech Note type dictated text into any window
    kbd-legacy          # the console keymap "dvorak-r" (text console, login, disk unlock)
    foot                # light terminal for the Welcome window (works in VMs too)
    NetworkManager-tui  # Wi-Fi from the Welcome window (nmtui)
    # Development
    python3 python3-devel pipx uv   # Python 3: headers for native modules, pipx, uv
    dotnet-sdk-10.0                 # .NET 10 SDK (current LTS; command: dotnet)
    libXtst libXi libXrender xcb-util-keysyms gtk3   # what JetBrains Toolbox/IDEs need
    # Virtual machines: KVM + libvirt + virt-manager (3D in guests via virtio-GPU)
    virt-manager virt-install virt-viewer qemu-kvm
    libvirt-daemon-kvm libvirt-daemon-config-network edk2-ovmf swtpm
    # Everyday safety
    swayidle            # idle detection for the break reminders (onehand-breaks)
    snapper libdnf5-plugin-actions   # Btrfs snapshots before/after every dnf change
)

# Packages to remove if installed (done after the new browsers are in place).
DNF_REMOVE=(
    firefox
    helium-bin      # Helium browser (no longer part of the setup)
)

# COPR repositories to turn off again (left over from earlier versions).
COPR_REMOVE=(
    imput/helium
)

# Flatpak apps to remove if installed.
FLATPAK_REMOVE=(
    org.mozilla.firefox
)

# Package groups, e.g. "development-tools". List them with: dnf group list
DNF_GROUPS=(
    # development-tools
)

# Extra third-party repos: "name|repo-file-URL"
# The file is saved as /etc/yum.repos.d/<name>.repo
EXTRA_REPOS=(
    "brave-browser|https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"
    "brave-browser-nightly|https://brave-browser-rpm-nightly.s3.brave.com/brave-browser-nightly.repo"
    # "vscode|https://packages.microsoft.com/yumrepos/vscode/config.repo"
)

# COPR repositories to enable ("owner/project").
# scottames/ghostty is the COPR listed in Ghostty's own install docs.
COPR_REPOS=(
    scottames/ghostty
    duxlabs/dms         # Dux Shell (package dms) and companions (matugen ...)
    duxlabs/dux-repo    # current niri + quickshell builds
    alternateved/keyd   # keyd (not in Fedora's own repositories)
    atim/lazygit        # lazygit, LazyVim's git screen (Space g g)
    lihaohong/yazi      # yazi, the file manager (the COPR yazi's install docs name)
)

# ---- Your one-handed setup: files in the files/ folder next to this script ----
# These are the source of truth for both this script and the spin.

# Copied into your home folder (and, in the spin, into every new user's).
# Format: "file in files/|destination inside the home folder[|keep]"
#   keep = only put it there if you don't have that file yet (never replaced)
# Zed from Flathub may read its config from its own folder (~/.var/app/...),
# so the Zed files go to both places.
USER_FILES=(
    "niri/config.kdl|.config/niri/config.kdl"
    "niri/onehand-rules.kdl|.config/niri/onehand-rules.kdl"
    "niri/onehand-monitors.kdl|.config/niri/onehand-monitors.kdl|keep"
    "ghostty/config|.config/ghostty/config"
    "foot/foot.ini|.config/foot/foot.ini"
    "fish/onehand.fish|.config/fish/conf.d/onehand.fish"
    "yazi/keymap.toml|.config/yazi/keymap.toml"
    "helix/config.toml|.config/helix/config.toml"
    "rune/config.yaml|.rune/config.yaml"
    "nvim/init.lua|.config/nvim/init.lua"
    "nvim/lua/config/lazy.lua|.config/nvim/lua/config/lazy.lua"
    "nvim/lua/config/options.lua|.config/nvim/lua/config/options.lua"
    "nvim/lua/config/keymaps.lua|.config/nvim/lua/config/keymaps.lua"
    "nvim/lua/config/autocmds.lua|.config/nvim/lua/config/autocmds.lua"
    "nvim/lua/plugins/onehand.lua|.config/nvim/lua/plugins/onehand.lua"
    "zed/keymap.json|.config/zed/keymap.json"
    "zed/keymap.json|.var/app/dev.zed.Zed/config/zed/keymap.json"
    "zed/settings.json|.config/zed/settings.json|keep"
    "zed/settings.json|.var/app/dev.zed.Zed/config/zed/settings.json|keep"
    "k9s/plugins.yaml|.config/k9s/plugins.yaml"
    "lfk/config.yaml|.config/lfk/config.yaml"
    "docs/niri-tutorial.pdf|Documents/niri-tutorial.pdf"
    "wallpapers/onehanded-remix-2560x1440.png|Pictures/Wallpapers/onehanded-remix-2560x1440.png"
    "wallpapers/onehanded-remix-1920x1080.png|Pictures/Wallpapers/onehanded-remix-1920x1080.png"
    "wallpapers/niri-lazyvim-2560x1440.png|Pictures/Wallpapers/niri-lazyvim-2560x1440.png"
    "wallpapers/niri-lazyvim-1920x1080.png|Pictures/Wallpapers/niri-lazyvim-1920x1080.png"
    "wallpapers/niri-helix-cheatsheet-1920x1080.png|Pictures/Wallpapers/niri-helix-cheatsheet-1920x1080.png"
    "wallpapers/niri-wallpaper-1920x1080.png|Pictures/Wallpapers/niri-wallpaper-1920x1080.png"
    "wallpapers/niri-wallpaper-2560x1440.png|Pictures/Wallpapers/niri-wallpaper-2560x1440.png"
)

# Installed system-wide. /etc/xkb is where libxkbcommon (niri) looks for extra
# layouts for every user, and system updates never touch it.
# Format: "file in files/|absolute destination"  (files in a bin/ folder are made runnable)
SYSTEM_FILES=(
    "xkb/dvorak_r_pl|/etc/xkb/symbols/dvorak_r_pl"
    "keyd/default.conf|/etc/keyd/default.conf"
    "wallpapers/onehanded-remix-2560x1440.png|/usr/share/backgrounds/onehand/default.png"
    "bin/onehand-monitors|/usr/local/bin/onehand-monitors"
    "bin/onehand-second-screen|/usr/local/bin/onehand-second-screen"
    # Mod + . : find any window by typing; Mod + , : pause the break reminders
    "bin/onehand-windows|/usr/local/bin/onehand-windows"
    "bin/onehand-breaks|/usr/local/bin/onehand-breaks"
    # Snapshots before/after every dnf change, hourly for /home (set up on first boot)
    "bin/onehand-snapshots|/usr/local/bin/onehand-snapshots"
    "snapshots/onehand-snapshots.actions|/etc/dnf/libdnf5-plugins/actions.d/onehand-snapshots.actions"
    "snapshots/onehand-snapshots-setup.service|/etc/systemd/system/onehand-snapshots-setup.service"
    # First boot after installing: put Dvorak back on the console / login screen
    # (the installer writes its own keyboard choice)
    "keyboard/onehand-keyboard-firstboot.service|/etc/systemd/system/onehand-keyboard-firstboot.service"
    # Mod+Enter: Ghostty, or foot when Ghostty can't start (VMs without 3D)
    "bin/onehand-terminal|/usr/local/bin/onehand-terminal"
    # Checks right-handed Dvorak everywhere (console, login, disk unlock, desktop)
    "bin/onehand-keyboard-check|/usr/local/bin/onehand-keyboard-check"
    # Administrators manage VMs without a password prompt (polkit)
    "virt/50-onehand-libvirt.rules|/etc/polkit-1/rules.d/50-onehand-libvirt.rules"
    # Welcome window: install from the live USB, then a first-login checklist
    "bin/onehand-welcome|/usr/local/bin/onehand-welcome"
    "welcome/onehanded-welcome.desktop|/usr/share/applications/onehanded-welcome.desktop"
    # One-Handed Fedora Remix logo (os-release LOGO=onehanded-remix-logo)
    "branding/onehanded-remix-logo.svg|/usr/share/icons/hicolor/scalable/apps/onehanded-remix-logo.svg"
    "branding/onehanded-remix-logo-256.png|/usr/share/icons/hicolor/256x256/apps/onehanded-remix-logo.png"
    "branding/onehanded-remix-logo-256.png|/usr/share/pixmaps/onehanded-remix-logo.png"
    "branding/onehanded-remix-wordmark.svg|/usr/share/pixmaps/onehanded-remix-wordmark.svg"
)

# Set once, on each user's first niri login (through Dux Shell); after that
# change it in Dux settings (Mod + PgDn).
DEFAULT_WALLPAPER=/usr/share/backgrounds/onehand/default.png

# Keyboard: niri uses dvorak_r_pl (from niri/config.kdl). The text console and
# the login screen can't load custom layouts, so they get stock right-handed
# Dvorak: same keys, no Polish letters (fine for passwords and commands).
SET_KEYBOARD=true
CONSOLE_KEYMAP=dvorak-r
BASE_XKB_LAYOUT=us
BASE_XKB_VARIANT=dvorak-r

# Login: if no login manager is set up, use greetd with tuigreet (a text login
# screen that starts niri). An existing one (e.g. GDM) is kept; pick "niri" there.
SETUP_LOGIN=true

# JetBrains Toolbox App (installs and updates IntelliJ IDEA, PyCharm, Rider ...):
# latest release from JetBrains, checksum-verified, into /opt/jetbrains-toolbox.
INSTALL_JETBRAINS_TOOLBOX=true

# Rune (rune.build): keyboard-driven IDE around your Helix; latest GitHub
# release into /opt/rune (checked against GitHub's SHA-256 for the file).
INSTALL_RUNE=true

# k9s (Kubernetes TUI): latest .rpm from its GitHub releases, checksum-verified.
INSTALL_K9S=true

# lfk (Kubernetes TUI, file-manager style, keys set to e h t d): latest .rpm
# from its GitHub releases, checksum-verified.
INSTALL_LFK=true

# Install the Fresh editor from its latest GitHub release RPM, checksum-verified
# (it has no Fedora or COPR package).
INSTALL_FRESH_EDITOR=true

# Add Anthropic's official Claude Code dnf repo.
# "stable" is about a week behind and skips bad releases; "latest" gets every release.
ENABLE_CLAUDE_CODE_REPO=true
CLAUDE_CODE_CHANNEL=stable

# Add Google's Chrome repo (or enable the one Fedora Workstation ships disabled).
ENABLE_GOOGLE_CHROME_REPO=true

# Packages that come from those extra repos.
EXTRA_REPO_PACKAGES=(
    brave-browser
    brave-browser-nightly
    google-chrome-stable
    ghostty     # from the COPR above
    claude-code # Claude Code (command: claude)
    dms quickshell matugen   # Dux Shell: bar, launcher, notifications, lock, wallpaper
    keyd                     # Right Alt: hold = Mod, tap = Polish letter
    lazygit                  # from the COPR above
    yazi                     # file manager, keys e h t d (from the COPR above)
    # code
)

# Flatpak application IDs from Flathub.
FLATPAKS=(
    com.ktechpit.typingtutor    # Typing Tutor
    # com.spotify.Client
    md.obsidian.Obsidian        # Obsidian
    dev.zed.Zed                 # Zed editor (Flathub; command: flatpak run dev.zed.Zed)
    net.mkiol.SpeechNote        # Speech Note: offline dictation and read-aloud (Mod + c / a)
)

# Configuration scripts to fetch from GitHub and run, in order.
# Format:  "owner/repo|ref|path/to/script.sh|args"
#   ref   - branch, tag or commit SHA. Pin a tag or SHA for reproducibility.
#   args  - optional arguments passed to the script.
# The whole repo is cloned, so scripts can use files next to them
# (dotfiles, templates, etc.). Private repos work if your git/SSH auth does.
GITHUB_SCRIPTS=(
    # "yourname/dotfiles|main|install.sh|"
    # "yourname/fedora-config|v1.2.0|scripts/gnome-settings.sh|--quiet"
)

# Where repos are cloned. Kept after the run so you can inspect or re-run.
CLONE_DIR="${HOME}/.local/src/fedora-setup"

# =============================================================================
#  END OF CONFIGURATION
# =============================================================================

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

LOG_FILE="${HOME}/fedora-setup-$(date +%Y%m%d-%H%M%S).log"
FAILED=()

# --- helpers -----------------------------------------------------------------

c_blue=$'\e[1;34m'; c_green=$'\e[1;32m'; c_yellow=$'\e[1;33m'; c_red=$'\e[1;31m'; c_off=$'\e[0m'

info()  { printf '%s==>%s %s\n' "$c_blue"   "$c_off" "$*" | tee -a "$LOG_FILE"; }
ok()    { printf '%s ✓ %s %s\n' "$c_green"  "$c_off" "$*" | tee -a "$LOG_FILE"; }
warn()  { printf '%s !  %s %s\n' "$c_yellow" "$c_off" "$*" | tee -a "$LOG_FILE"; }
error() { printf '%s ✗ %s %s\n' "$c_red"    "$c_off" "$*" | tee -a "$LOG_FILE" >&2; }

run() {
    if $DRY_RUN; then
        printf '   [dry-run] %s\n' "$*" | tee -a "$LOG_FILE"
    else
        "$@" 2>&1 | tee -a "$LOG_FILE"
        return "${PIPESTATUS[0]}"
    fi
}

# Run a step; on failure record it and keep going instead of aborting.
step() {
    local name="$1"; shift
    info "$name"
    if "$@"; then
        ok "$name"
    else
        error "$name failed (see $LOG_FILE)"
        FAILED+=("$name")
    fi
}

# --- preflight ---------------------------------------------------------------

preflight() {
    if [[ $EUID -eq 0 ]]; then
        error "Run this as your normal user, not root. It will use sudo when needed."
        exit 1
    fi
    # Accept Fedora and Fedora-based distros such as Ultramarine Linux
    # (ID=ultramarine, ID_LIKE=fedora).
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    if [[ "$DISTRO_ID" != fedora && " ${ID_LIKE:-} " != *" fedora "* ]]; then
        error "This doesn't look like Fedora or a Fedora-based distro (ID=${DISTRO_ID})."
        exit 1
    fi

    # Atomic editions (Silverblue, Kinoite, Ultramarine Atomic...) use rpm-ostree,
    # where 'dnf install' doesn't work.
    if [[ -e /run/ostree-booted ]]; then
        error "This is an atomic (rpm-ostree) system; this script only supports the regular editions."
        exit 1
    fi

    FEDORA_VERSION="$(rpm -E %fedora)"
    if [[ ! "$FEDORA_VERSION" =~ ^[0-9]+$ ]]; then
        error "Couldn't work out the Fedora release this system is based on."
        exit 1
    fi
    info "${NAME:-$DISTRO_ID} (Fedora ${FEDORA_VERSION} base) detected. Log: ${LOG_FILE}"

    $DRY_RUN && warn "Dry run — nothing will be changed."

    # Ask for the sudo password once and keep the ticket alive.
    if ! $DRY_RUN; then
        sudo -v
        while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
        SUDO_KEEPALIVE_PID=$!
        trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
    fi

    # Terra is Fyra Labs' repo, enabled by default on Ultramarine. Its mirrors
    # are sometimes briefly out of sync ("Usable URL not found"), so check it
    # actually loads before relying on it for Ghostty.
    TERRA_ENABLED=false
    if grep -qs '^\[terra\]' /etc/yum.repos.d/*.repo; then
        if $DRY_RUN; then
            TERRA_ENABLED=true
            info "Terra repository found"
        elif sudo dnf makecache --refresh --repo=terra -q &>>"$LOG_FILE"; then
            TERRA_ENABLED=true
            info "Terra repository found and reachable"
        else
            warn "Terra repository isn't loading right now; packages from it are skipped this run"
        fi
    fi
}

# --- your one-handed setup ---------------------------------------------------

# Folder holding files/ (works through a symlink, as in the spin's fedora-setup).
KIT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
FILES_DIR="${KIT_DIR}/files"
STAMP="$(date +%Y%m%d-%H%M%S)"

# Copy a file into place, backing up a different file that was there before.
place_file() {   # place_file SRC DEST [sudo]
    local src="$1" dest="$2" s="${3:-}"
    if $DRY_RUN; then run "copy ${src#"$KIT_DIR"/} -> ${dest}"; return 0; fi
    $s mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" ]] && ! cmp -s "$src" "$dest"; then
        $s cp -a "$dest" "${dest}.bak.${STAMP}"
        warn "backed up ${dest} -> ${dest}.bak.${STAMP}"
    fi
    $s cp "$src" "$dest"
    if [[ "$dest" == */bin/* ]]; then $s chmod 755 "$dest"; else $s chmod 644 "$dest"; fi
}

check_files() {
    local entry f missing=0
    for entry in "${USER_FILES[@]}" "${SYSTEM_FILES[@]}"; do
        f="${entry%%|*}"
        [[ -f "${FILES_DIR}/${f}" ]] || { error "missing files/${f}"; missing=1; }
    done
    return $missing
}

install_system_files() {
    check_files || return 1
    local entry f dest
    for entry in "${SYSTEM_FILES[@]}"; do
        IFS='|' read -r f dest <<<"$entry"
        place_file "${FILES_DIR}/${f}" "$dest" sudo
    done
}

install_user_files() {
    check_files || return 1
    # LazyVim replaces the whole Neovim config. If you have a different one,
    # move it aside (as LazyVim's own install guide does) instead of mixing them.
    local nvdir="${HOME}/.config/nvim"
    if [[ -d "$nvdir" ]] && ! grep -qs 'LazyVim' "${nvdir}/lua/config/lazy.lua"; then
        if $DRY_RUN; then run "move your current Neovim config to ${nvdir}.bak.${STAMP}"
        else mv "$nvdir" "${nvdir}.bak.${STAMP}"; warn "moved your old Neovim config to ${nvdir}.bak.${STAMP}"; fi
    fi

    local entry f dest mode
    for entry in "${USER_FILES[@]}"; do
        IFS='|' read -r f dest mode <<<"$entry"
        if [[ "$mode" == keep && -e "${HOME}/${dest}" ]]; then
            # Your own settings stay; just check the one setting the keymap needs.
            if [[ "$f" == zed/settings.json ]] && ! grep -q '"helix_mode"[[:space:]]*:[[:space:]]*true' "${HOME}/${dest}"; then
                warn "Add  \"helix_mode\": true  to ${HOME}/${dest} (your Zed keymap needs it)"
            fi
            continue
        fi
        place_file "${FILES_DIR}/${f}" "${HOME}/${dest}"
    done
    if $DRY_RUN; then run "create niri's Dux include files and ~/Pictures/Screenshots"; return 0; fi
    user_setup_commands "$HOME" | bash -s
    if command -v niri &>/dev/null; then
        niri validate -c "${HOME}/.config/niri/config.kdl" &>>"$LOG_FILE" \
            || warn "niri validate reported problems (details in ${LOG_FILE}); needs niri 25.11+"
    fi
}

# Shell commands that prepare a home folder (yours, or /etc/skel in the spin).
user_setup_commands() {   # user_setup_commands HOME
    cat <<EOF
# niri's config.kdl includes these Dux-managed files and refuses to load if one
# is missing; Dux fills them in on its first start.
mkdir -p "$1/.config/niri/dms" "$1/Pictures/Screenshots"
for f in colors layout alttab binds; do
    [ -e "$1/.config/niri/dms/\$f.kdl" ] || : > "$1/.config/niri/dms/\$f.kdl"
done
EOF
}

# Shell commands run as root: keyd, login screen, Dux autostart, first-login
# wallpaper. Also used by build-spin.sh, so the spin gets exactly the same.
system_setup_commands() {   # system_setup_commands LOGIN(auto|greetd|none)
    cat <<EOF
set -e
systemctl enable keyd.service 2>/dev/null || echo "keyd not installed; Right Alt stays plain AltGr" >&2

# Login screen
login="$1"
if [ "\$login" = auto ] && systemctl is-enabled --quiet display-manager.service 2>/dev/null; then
    echo "Keeping the existing login manager; pick the niri session there."
    login=none
fi
if [ "\$login" != none ] && command -v tuigreet >/dev/null 2>&1; then
    mkdir -p /etc/greetd
    [ -f /etc/greetd/config.toml ] && cp -a /etc/greetd/config.toml /etc/greetd/config.toml.bak.$STAMP
    cat > /etc/greetd/config.toml <<'GREETD'
# greetd: text login on tty1 that starts niri (written by fedora-setup.sh)
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --asterisks --cmd niri-session"
user = "greetd"
GREETD
    systemctl enable greetd.service
    systemctl set-default graphical.target
fi

# Dux Shell starts with every niri session, for every user.
systemctl --global add-wants niri.service dms.service 2>/dev/null \
    || echo "couldn't register dms with niri.service; per user: systemctl --user add-wants niri.service dms" >&2

# Default wallpaper: set once per user through Dux, on the first niri login.
mkdir -p /usr/libexec/onehand /etc/systemd/user
cat > /usr/libexec/onehand/set-default-wallpaper <<'SH'
#!/bin/bash
# Dux Shell draws the wallpaper. Wait for it to start, then set ours once.
for i in \$(seq 1 30); do
    if dms ipc call wallpaper set "$DEFAULT_WALLPAPER" >/dev/null 2>&1; then
        mkdir -p "\$HOME/.local/state/onehand"
        touch "\$HOME/.local/state/onehand/wallpaper-set"
        exit 0
    fi
    sleep 2
done
exit 1
SH
chmod 755 /usr/libexec/onehand/set-default-wallpaper
cat > /etc/systemd/user/onehand-wallpaper.service <<'UNIT'
[Unit]
Description=Set the default wallpaper on the first niri login
After=dms.service
ConditionPathExists=!%h/.local/state/onehand/wallpaper-set

[Service]
Type=oneshot
ExecStart=/usr/libexec/onehand/set-default-wallpaper

[Install]
WantedBy=niri.service
UNIT
systemctl --global enable onehand-wallpaper.service

# Welcome window: opens at login until you tick "All done" (and on the live USB).
mkdir -p /etc/onehand
printf '%s\n' ${FLATPAKS[*]} > /etc/onehand/flatpaks
cat > /etc/systemd/user/onehand-welcome.service <<'UNIT'
[Unit]
Description=One-Handed Fedora Remix welcome window (live USB and first logins)
After=dms.service
ConditionPathExists=!%h/.local/state/onehand/welcome-done

[Service]
Type=oneshot
ExecStart=/usr/local/bin/onehand-welcome --launch

[Install]
WantedBy=niri.service
UNIT
systemctl --global enable onehand-welcome.service

# Virtual machines: start libvirt's services on demand (socket activation).
for s in virtqemud virtnetworkd virtstoraged virtnodedevd virtsecretd virtinterfaced virtnwfilterd; do
    systemctl enable "\${s}.socket" 2>/dev/null || true
    systemctl start "\${s}.socket" 2>/dev/null || true   # no-op while building the ISO
done

# Dictation: Speech Note types text through ydotoold (a virtual keyboard).
# The socket is open to every local user, which is fine on a personal machine.
cat > /etc/systemd/system/onehand-ydotoold.service <<'UNIT'
[Unit]
Description=ydotoold virtual keyboard (Speech Note dictation)

[Service]
RuntimeDirectory=ydotoold
ExecStart=/usr/bin/ydotoold --socket-path=/run/ydotoold/socket --socket-perm=0666
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
if [ -x /usr/bin/ydotoold ]; then systemctl enable onehand-ydotoold.service; else echo "ydotool not installed; dictation can't type into windows" >&2; fi
# Let the Speech Note Flatpak reach that socket (works before the app is installed).
if command -v flatpak >/dev/null 2>&1; then
    flatpak override --system --filesystem=/run/ydotoold --env=YDOTOOL_SOCKET=/run/ydotoold/socket net.mkiol.SpeechNote || true
fi

# Btrfs snapshots: set up once, on the first boot of the installed system
# (or right now on a machine that's already installed).
systemctl enable onehand-snapshots-setup.service 2>/dev/null || true
# Vimium C is no longer part of the kit: drop its install policy (older setups).
rm -f /etc/brave/policies/managed/onehand-vimium-c.json /etc/opt/chrome/policies/managed/onehand-vimium-c.json

# Keyboard: once, on the first boot after installing (no-op where it's already set).
systemctl enable onehand-keyboard-firstboot.service 2>/dev/null || true
systemctl start onehand-snapshots-setup.service 2>/dev/null || true   # no-op while building the ISO

command -v restorecon >/dev/null 2>&1 && restorecon -R /etc/onehand /etc/dnf/libdnf5-plugins /etc/systemd/system /usr/share/applications /etc/xkb /etc/brave /etc/opt/chrome /usr/local/bin /etc/keyd /etc/greetd /usr/libexec/onehand /usr/share/backgrounds/onehand 2>/dev/null || true
EOF
}

setup_keyboard() {
    # "dvorak-r" comes from kbd-legacy; Fedora's own "us-dvorak-r" (converted
    # from the desktop layout) types exactly the same, so it's the fallback.
    local map="$CONSOLE_KEYMAP" m
    if ! $DRY_RUN && ! localectl list-keymaps 2>/dev/null | grep -qx "$map"; then
        for m in "$CONSOLE_KEYMAP" us-dvorak-r dvorak-r; do
            localectl list-keymaps 2>/dev/null | grep -qx "$m" && { map="$m"; break; }
        done
        [[ "$map" != "$CONSOLE_KEYMAP" ]] && warn "console keymap ${CONSOLE_KEYMAP} not found; using ${map}"
    fi
    run sudo localectl set-keymap --no-convert "$map"
    run sudo localectl set-x11-keymap --no-convert "$BASE_XKB_LAYOUT" "" "$BASE_XKB_VARIANT"
    # SDDM on Wayland (KDE-based systems) ignores the X11 setting: give its own user the layout.
    if [[ "$(basename "$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null)")" == sddm.service ]]; then
        local kx; kx="$(getent passwd sddm | cut -d: -f6)/.config/kxkbrc"
        run sudo install -d -o sddm -g sddm -m 755 "$(dirname "$kx")"
        if ! $DRY_RUN; then
            printf '[Layout]\nLayoutList=%s\nVariantList=%s\nUse=true\n' "$BASE_XKB_LAYOUT" "$BASE_XKB_VARIANT" \
                | sudo install -o sddm -g sddm -m 644 /dev/stdin "$kx"
        fi
    fi
    # Encrypted disk: rebuild the boot image so its unlock prompt uses the new keymap.
    if ! $DRY_RUN && grep -qvE '^[[:space:]]*(#|$)' /etc/crypttab 2>/dev/null; then
        info "Rebuilding the boot image for the disk-unlock prompt"
        run sudo dracut -f
    fi
}

setup_system() {
    local login=none
    $SETUP_LOGIN && login=auto
    if $DRY_RUN; then
        run "enable keyd, login screen (${login}), Dux autostart, first-login wallpaper, dictation (ydotoold)"
        return 0
    fi
    system_setup_commands "$login" | sudo bash -s 2>&1 | tee -a "$LOG_FILE"
    [[ "${PIPESTATUS[1]}" -eq 0 ]] || return 1
    sudo systemctl restart keyd 2>/dev/null || true
    sudo systemctl start onehand-ydotoold.service 2>/dev/null || true
    # Also register Dux for this user right away (the global one covers new users).
    systemctl --user add-wants niri.service dms.service &>/dev/null || true
}

# Latest .rpm from a GitHub release, verified against the release's checksum.
# github_rpm OWNER/REPO ASSET_REGEX CHECKSUM_MODE(per-file|checksums.sha256) OUT_DIR
github_rpm() {
    local repo="$1" pattern="$2" mode="$3" out="$4" rel url name
    rel="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest")" || return 1
    url="$(jq -r '.assets[].browser_download_url' <<<"$rel" | grep -E "$pattern" | head -n1)"
    [[ -n "$url" ]] || { error "no release file matching ${pattern} in ${repo}"; return 1; }
    name="$(basename "$url")"
    curl -fsSL -o "${out}/${name}" "$url" || return 1
    if [[ "$mode" == per-file ]]; then
        curl -fsSL -o "${out}/${name}.sha256" "${url}.sha256" || return 1
        [[ "$(sha256sum "${out}/${name}" | cut -d' ' -f1)" == "$(cut -d' ' -f1 "${out}/${name}.sha256")" ]]
    else
        local sums
        # mode = the name of the release's checksum file (checksums.sha256, checksums.txt ...)
        sums="$(jq -r --arg m "$mode" '.assets[] | select(.name == $m) | .browser_download_url' <<<"$rel")"
        curl -fsSL -o "${out}/${mode}" "$sums" || return 1
        (cd "$out" && grep " \*\?${name}\$" "$mode" | sha256sum -c --status)
    fi || { error "checksum mismatch for ${name}; not installing"; rm -f "${out}/${name}"; return 1; }
    rm -f "${out}/${name}.sha256" "${out}/${mode}"
    echo "${out}/${name}"
}

# All dnf calls go through here. skip_if_unavailable stops one broken
# third-party repo (e.g. a Terra mirror hiccup) from failing every install.
dnf_() {
    run sudo dnf --setopt=skip_if_unavailable=True "$@"
}

# --- steps -------------------------------------------------------------------

speed_up_dnf() {
    # Parallel downloads make a big difference on a fresh install.
    if ! grep -q '^max_parallel_downloads' /etc/dnf/dnf.conf 2>/dev/null; then
        run sudo sh -c 'echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf'
    fi
}

system_upgrade() {
    dnf_ upgrade --refresh -y
}

enable_rpmfusion() {
    # Ultramarine ships RPM Fusion already, possibly via its own release package,
    # so look for the repo files rather than only the Fedora release RPM.
    if rpm -q rpmfusion-free-release &>/dev/null \
        || compgen -G '/etc/yum.repos.d/rpmfusion-free*.repo' >/dev/null; then
        info "RPM Fusion already enabled"
        return 0
    fi
    dnf_ install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"
}

add_extra_repos() {
    local entry name url
    for entry in "${EXTRA_REPOS[@]}"; do
        IFS='|' read -r name url <<<"$entry"
        if [[ -f "/etc/yum.repos.d/${name}.repo" ]]; then
            info "Repo '${name}' already present"
            continue
        fi
        run sudo curl -fsSL -o "/etc/yum.repos.d/${name}.repo" "$url"
    done
}

enable_coprs() {
    # 'dnf copr' comes from dnf5-plugins (usually preinstalled on Workstation).
    rpm -q dnf5-plugins &>/dev/null || dnf_ install -y dnf5-plugins
    local copr rc=0
    for copr in "${COPR_REPOS[@]}"; do
        # Terra already packages Ghostty; a second source would just compete with it.
        if $TERRA_ENABLED && [[ "$copr" == scottames/ghostty ]]; then
            info "Skipping COPR $copr (Ghostty comes from Terra)"
            continue
        fi
        dnf_ copr enable -y "$copr" || { error "COPR $copr failed"; rc=1; }
    done
    return $rc
}

install_fresh_editor() {
    if $DRY_RUN; then run "download and verify the latest Fresh .rpm, then dnf install it"; return 0; fi
    local tmp rpm rc=0
    tmp="$(mktemp -d)"
    if rpm="$(github_rpm sinelaw/fresh "\.$(uname -m)\.rpm$" per-file "$tmp")"; then
        # dnf (not rpm) pulls in dependencies and upgrades an older Fresh.
        dnf_ install -y "$rpm" || rc=1
    else
        rc=1
    fi
    rm -rf "$tmp"
    return $rc
}

# Download LazyVim and its plugins now, so the first start of nvim is instant.
setup_lazyvim() {
    command -v nvim &>/dev/null || { error "Neovim isn't installed"; return 1; }
    if $DRY_RUN; then run "nvim --headless +'Lazy! sync' +qa  (downloads LazyVim's plugins)"; return 0; fi
    timeout 600 nvim --headless "+Lazy! sync" +qa &>>"$LOG_FILE" \
        || warn "LazyVim's plugins didn't all download; they'll finish on the first start of nvim"
}

install_jetbrains_toolbox() {
    if $DRY_RUN; then run "download and verify the latest JetBrains Toolbox, install it in /opt/jetbrains-toolbox"; return 0; fi
    sudo bash "${FILES_DIR}/jetbrains/install-jetbrains-toolbox" 2>&1 | tee -a "$LOG_FILE"
    return "${PIPESTATUS[0]}"
}

install_rune() {
    if $DRY_RUN; then run "download and verify the latest Rune, install it in /opt/rune"; return 0; fi
    sudo bash "${FILES_DIR}/rune/install-rune" 2>&1 | tee -a "$LOG_FILE"
    return "${PIPESTATUS[0]}"
}

install_k9s() {
    if $DRY_RUN; then run "download and verify the latest k9s .rpm, then dnf install it"; return 0; fi
    local arch tmp rpm rc=0
    case "$(uname -m)" in x86_64) arch=amd64 ;; aarch64) arch=arm64 ;; *) error "no k9s build for $(uname -m)"; return 1 ;; esac
    tmp="$(mktemp -d)"
    if rpm="$(github_rpm derailed/k9s "/k9s_linux_${arch}\.rpm$" checksums.sha256 "$tmp")"; then
        dnf_ install -y "$rpm" || rc=1
    else
        rc=1
    fi
    rm -rf "$tmp"
    return $rc
}

install_lfk() {
    if $DRY_RUN; then run "download and verify the latest lfk .rpm, then dnf install it"; return 0; fi
    local tmp rpm rc=0
    tmp="$(mktemp -d)"
    if rpm="$(github_rpm janosmiko/lfk "/lfk[-_][0-9][^/]*[-_.]($(uname -m)|$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/'))\.rpm$" checksums.txt "$tmp")"; then
        dnf_ install -y "$rpm" || rc=1
    else
        rc=1
    fi
    rm -rf "$tmp"
    return $rc
}

setup_claude_code_repo() {
    # Fingerprint published at https://code.claude.com/docs/en/setup
    local expected="31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE"
    local key_url="https://downloads.claude.ai/keys/claude-code.asc"
    local repo_file=/etc/yum.repos.d/claude-code.repo

    if $DRY_RUN; then
        run "verify ${key_url} has fingerprint ${expected}, rpm --import it, write ${repo_file} (${CLAUDE_CODE_CHANNEL})"
        return 0
    fi

    # Check the signing key before trusting it, since dnf -y would accept it silently.
    local key fpr
    key="$(mktemp)"
    curl -fsSL "$key_url" -o "$key" || { rm -f "$key"; return 1; }
    fpr="$(gpg --show-keys --with-colons "$key" 2>/dev/null | awk -F: '/^fpr:/ {print $10; exit}')"
    if [[ "$fpr" != "$expected" ]]; then
        error "Claude Code key fingerprint mismatch (got '${fpr}'), not adding repo"
        rm -f "$key"; return 1
    fi
    run sudo rpm --import "$key"
    rm -f "$key"

    run sudo tee "$repo_file" >/dev/null <<EOF
[claude-code]
name=Claude Code
baseurl=https://downloads.claude.ai/claude-code/rpm/${CLAUDE_CODE_CHANNEL}
enabled=1
gpgcheck=1
gpgkey=${key_url}
EOF
}

setup_google_chrome_repo() {
    local repo_file=/etc/yum.repos.d/google-chrome.repo
    if [[ -f "$repo_file" ]]; then
        # Fedora Workstation ships this repo (fedora-workstation-repositories) but disabled.
        dnf_ config-manager setopt google-chrome.enabled=1
    else
        run sudo tee "$repo_file" >/dev/null <<'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
    fi
}

install_dnf_packages() {
    local pkgs=("${DNF_PACKAGES[@]}" "${EXTRA_REPO_PACKAGES[@]}")
    if ((${#DNF_GROUPS[@]})); then
        dnf_ group install -y "${DNF_GROUPS[@]}"
    fi
    if ((${#pkgs[@]})); then
        # --skip-unavailable: one typo'd package name won't sink the whole batch
        dnf_ install -y --skip-unavailable "${pkgs[@]}"
    fi
}

remove_packages() {
    local pkg installed=() app
    # Don't leave the machine without a browser if the new ones failed to install.
    if ! $DRY_RUN && ! rpm -q brave-browser google-chrome-stable brave-browser-nightly 2>/dev/null | grep -qv 'not installed'; then
        warn "No replacement browser installed, so Firefox is kept"
        return 1
    fi
    for pkg in "${COPR_REMOVE[@]}"; do
        if compgen -G "/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:${pkg/\//:}.repo" >/dev/null; then
            run sudo dnf copr remove -y "$pkg" || warn "couldn't turn off the COPR ${pkg}"
        fi
    done
    for pkg in "${DNF_REMOVE[@]}"; do
        rpm -q "$pkg" &>/dev/null && installed+=("$pkg")
    done
    if ((${#installed[@]})); then
        dnf_ remove -y "${installed[@]}"
    else
        info "Nothing from DNF_REMOVE is installed"
    fi

    if command -v flatpak &>/dev/null; then
        for app in "${FLATPAK_REMOVE[@]}"; do
            if flatpak info "$app" &>/dev/null; then
                run flatpak uninstall -y --noninteractive "$app" \
                    || run sudo flatpak uninstall -y --noninteractive "$app"
            fi
        done
    fi
}

setup_flathub() {
    run sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    if ((${#FLATPAKS[@]})); then
        # sudo: system-wide install without a separate password pop-up mid-run
        run sudo flatpak install -y --noninteractive flathub "${FLATPAKS[@]}"
    fi
}

run_github_scripts() {
    command -v git &>/dev/null || dnf_ install -y git
    run mkdir -p "$CLONE_DIR"

    local entry repo ref script args dest rc=0
    for entry in "${GITHUB_SCRIPTS[@]}"; do
        IFS='|' read -r repo ref script args <<<"$entry"
        dest="${CLONE_DIR}/${repo//\//__}"
        info "GitHub: ${repo}@${ref} → ${script} ${args}"

        if [[ -d "$dest/.git" ]]; then
            run git -C "$dest" fetch --depth 1 origin "$ref" || { rc=1; continue; }
        else
            run git clone --no-checkout --depth 1 --branch "$ref" \
                "https://github.com/${repo}.git" "$dest" 2>/dev/null \
            || {
                # --branch doesn't accept commit SHAs; fall back to fetch-by-SHA
                run git init -q "$dest" &&
                run git -C "$dest" remote add origin "https://github.com/${repo}.git" &&
                run git -C "$dest" fetch --depth 1 origin "$ref"
            } || { error "Could not fetch ${repo}@${ref}"; rc=1; continue; }
        fi
        run git -C "$dest" checkout -q FETCH_HEAD 2>/dev/null || run git -C "$dest" checkout -q "$ref" \
            || { rc=1; continue; }

        if ! $DRY_RUN && [[ ! -f "${dest}/${script}" ]]; then
            error "Script not found: ${repo}/${script}"
            rc=1; continue
        fi

        # Run from the repo root so relative paths inside the script work.
        # shellcheck disable=SC2086  # args intentionally word-split
        ( cd "$dest" && run bash "./${script}" $args ) \
            || { error "${repo}/${script} exited non-zero"; rc=1; }
    done
    return $rc
}

# --- main --------------------------------------------------------------------

main() {
    preflight

    step "Configure dnf"                 speed_up_dnf
    $DO_SYSTEM_UPGRADE && step "Upgrade system"        system_upgrade
    $ENABLE_RPMFUSION  && step "Enable RPM Fusion"     enable_rpmfusion
    ((${#EXTRA_REPOS[@]}))  && step "Add extra repos"  add_extra_repos
    $ENABLE_GOOGLE_CHROME_REPO && step "Add Google Chrome repo" setup_google_chrome_repo
    $ENABLE_CLAUDE_CODE_REPO   && step "Add Claude Code repo"   setup_claude_code_repo
    ((${#COPR_REPOS[@]})) && step "Enable COPR repos"  enable_coprs
    step "Install packages"              install_dnf_packages
    $INSTALL_FRESH_EDITOR && step "Install Fresh editor" install_fresh_editor
    $INSTALL_K9S       && step "Install k9s"             install_k9s
    $INSTALL_LFK       && step "Install lfk"             install_lfk
    $INSTALL_JETBRAINS_TOOLBOX && step "Install JetBrains Toolbox" install_jetbrains_toolbox
    $INSTALL_RUNE      && step "Install Rune"            install_rune
    step "Remove unwanted packages"      remove_packages
    $ENABLE_FLATHUB    && step "Set up Flathub/Flatpaks" setup_flathub
    $SET_KEYBOARD      && step "Set console keyboard"    setup_keyboard
    step "Install system files (layout, keyd, wallpaper)" install_system_files
    step "Set up keyd, login, Dux, wallpaper"            setup_system
    step "Install your configs (niri, Zed, LazyVim, k9s ...)" install_user_files
    step "Download LazyVim's plugins"                    setup_lazyvim
    ((${#GITHUB_SCRIPTS[@]})) && step "Run GitHub config scripts" run_github_scripts

    echo
    if ((${#FAILED[@]})); then
        warn "Finished with failures: ${FAILED[*]}"
        warn "Details in ${LOG_FILE}"
        exit 1
    fi
    ok "All done. Reboot, then log in: niri starts with Dux Shell."
    info "Mod = hold Right Alt (or Win). Tap Right Alt, then a letter, for ą ć ę ł ń ó ś ż ź."
    info "Mod + Insert lists every shortcut; tutorial: ~/Documents/niri-tutorial.pdf"
}

main "$@"
