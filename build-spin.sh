#!/usr/bin/env bash
#
# build-spin.sh — build a live ISO ("spin") of your one-handed Fedora + niri setup.
#
# Everything the spin contains is read from fedora-setup.sh and the files/
# folder next to it: packages, repos, COPRs, Flatpaks, things to leave out, and
# your configs (niri, keyboard layout, keyd, Zed, LazyVim, k9s, wallpapers, tutorial).
# Change those and rebuild; you never edit two places.
#
# Usage (on Fedora, as your normal user; sudo is used where needed):
#   ./build-spin.sh                  # build the ISO
#   ./build-spin.sh --generate-only  # only write and check the kickstart
#
# Optional settings via environment variables:
#   RELEASE=45   Fedora release to build (default: the one this machine runs)
#   NAME=...     ISO file name / disc label (default OneHanded-Fedora-Remix)
#   PRODUCT=...  Name in the system, installer and boot menu (default "One-Handed Fedora Remix")

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP="${HERE}/fedora-setup.sh"
BASE_KS="${HERE}/niri-spin-base.ks"
BRANDING_KS="${HERE}/branding.ks"

RELEASE="${RELEASE:-$(rpm -E %fedora 2>/dev/null || echo unknown)}"
NAME="${NAME:-OneHanded-Fedora-Remix}"          # ISO file name and disc label (no spaces)
PRODUCT="${PRODUCT:-One-Handed Fedora Remix}"
VARIANT="${VARIANT:-One-Handed}"     # os-release VARIANT   # name shown in the system, installer and boot menu
ARCH=x86_64
# The kickstart can't hold paths with spaces (e.g. a download folder named
# "fedora-onehand-setup (1)"), so build in a space-free folder in that case.
BUILD_ROOT="$HERE"
if [[ "$BUILD_ROOT" =~ [[:space:]] ]]; then
    BUILD_ROOT="${HOME}/onehand-spin-build"
fi
WORK="${BUILD_ROOT}/build"
FINAL_KS="${WORK}/onehand-spin.ks"
STAMP="$(date +%Y%m%d-%H%M)"
RESULT_DIR="${BUILD_ROOT}/out/${STAMP}"     # livemedia-creator wants a new directory
ISO_NAME="${NAME}-${RELEASE}-${STAMP}.iso"
CLAUDE_KEY_FPR="31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE"   # from code.claude.com/docs/en/setup

GENERATE_ONLY=false
[[ "${1:-}" == "--generate-only" ]] && GENERATE_ONLY=true

info() { printf '\e[1;34m==>\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m !\e[0m  %s\n' "$*" >&2; }
die()  { printf '\e[1;31m ✗\e[0m  %s\n' "$*" >&2; exit 1; }

# Repos used for the build: kickstart "repo" lines, plus name|url pairs for the
# package pre-check. Repo files the installed system keeps go to $WORK/yum.repos.d.
KS_REPOS=()
CHECK_REPOS=()
EXTRA_PKGS=()

# --- checks ------------------------------------------------------------------

preflight() {
    [[ $EUID -ne 0 ]] || die "Run this as your normal user; it uses sudo where needed."
    [[ -f "$SETUP" ]]   || die "fedora-setup.sh must be in the same folder as this script."
    [[ -f "$BASE_KS" ]] || die "niri-spin-base.ks must be in the same folder as this script."
    [[ ! "$BUILD_ROOT" =~ [[:space:]] ]] \
        || die "Your home folder path has a space in it; move this folder to a path without spaces."
    [[ "$BUILD_ROOT" == "$HERE" ]] \
        || info "This folder's path has a space in it, so the build runs in ${BUILD_ROOT} (the ISO still ends up in ./out)."
    # Fedora or a Fedora-based distro such as Ultramarine (livemedia-creator
    # uses this machine's installer, so it must match the release you build).
    # (read in a subshell: os-release sets NAME, which this script also uses)
    local os
    os="$(. /etc/os-release && echo "${ID:-} ${ID_LIKE:-}")"
    [[ " ${os} " == *" fedora "* ]] || die "Build on Fedora or a Fedora-based distro."
    [[ "$(uname -m)" == "$ARCH" ]] || die "Only x86_64 is supported (Chrome and several repos are x86_64-only)."
    local host
    host="$(rpm -E %fedora)"
    [[ "$RELEASE" =~ ^[0-9]+$ ]] || die "RELEASE must be a Fedora release number."
    [[ "$host" == "$RELEASE" ]] \
        || warn "Building Fedora ${RELEASE} on Fedora ${host}: livemedia-creator is most reliable on the same release."
}

# Read the configuration section of fedora-setup.sh (everything above
# "END OF CONFIGURATION"): the lists of packages, repos, Flatpaks and binds.
load_config() {
    local cfg
    cfg="$(sed -n '1,/^#  END OF CONFIGURATION/p' "$SETUP")"
    grep -q 'END OF CONFIGURATION' <<<"$cfg" || die "Couldn't find the configuration section in fedora-setup.sh."
    eval "$cfg"
    set -euo pipefail
    # Shared helpers, so the spin is set up exactly like fedora-setup.sh does it.
    eval "$(sed -n '/^user_setup_commands() {/,/^}$/p;/^system_setup_commands() {/,/^}$/p' "$SETUP")"
    declare -F user_setup_commands >/dev/null && declare -F system_setup_commands >/dev/null \
        || die "fedora-setup.sh is older than this build script; use the matching version."
    local entry
    for entry in "${USER_FILES[@]}" "${SYSTEM_FILES[@]}"; do
        [[ -f "${HERE}/files/${entry%%|*}" ]] || die "Missing files/${entry%%|*}"
    done
}

install_tools() {
    info "Installing build tools"
    sudo dnf install -y lorax lorax-lmc-novirt pykickstart createrepo_c gnupg2 curl jq
}

# --- repositories --------------------------------------------------------------

# Latest .rpm from a GitHub release, verified against the release's checksum.
github_rpm() {   # OWNER/REPO ASSET_REGEX per-file|checksums.sha256 OUT_DIR
    local repo="$1" pattern="$2" mode="$3" out="$4" rel url name
    rel="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest")" || return 1
    url="$(jq -r '.assets[].browser_download_url' <<<"$rel" | grep -E "$pattern" | head -n1)"
    [[ -n "$url" ]] || { warn "no release file matching ${pattern} in ${repo}"; return 1; }
    name="$(basename "$url")"
    curl -fsSL -o "${out}/${name}" "$url" || return 1
    if [[ "$mode" == per-file ]]; then
        curl -fsSL -o "${out}/${name}.sha256" "${url}.sha256" || return 1
        [[ "$(sha256sum "${out}/${name}" | cut -d' ' -f1)" == "$(cut -d' ' -f1 "${out}/${name}.sha256")" ]]
    else
        local sums
        sums="$(jq -r '.assets[] | select(.name == "checksums.sha256") | .browser_download_url' <<<"$rel")"
        curl -fsSL -o "${out}/checksums.sha256" "$sums" || return 1
        (cd "$out" && grep " ${name}\$" checksums.sha256 | sha256sum -c --status)
    fi || { warn "checksum mismatch for ${name}"; rm -f "${out}/${name}"; return 1; }
    rm -f "${out}/${name}.sha256" "${out}/checksums.sha256"
    echo "${out}/${name}"
}

# Kickstart repo names get a "spin-" prefix: the installer also reads the build
# machine's own repo files, and a repo with the same name there (Fedora ships a
# disabled google-chrome repo, and every system has "updates") wins and hides ours.
add_repo() {   # name baseurl
    KS_REPOS+=("repo --name=spin-$1 --baseurl=$2")
    CHECK_REPOS+=("$1|$2")
}

repo_reachable() {   # baseurl
    curl -fsSL -o /dev/null "${1%/}/repodata/repomd.xml"
}

collect_repos() {
    # The installer writes its logs as root into build/anaconda, so a plain rm
    # can't remove a previous build folder.
    rm -rf "$WORK" 2>/dev/null || sudo rm -rf "$WORK"
    mkdir -p "$WORK/yum.repos.d" "$WORK/localrepo" "$WORK/keys"

    # Fedora itself (the kickstart uses mirrors; the pre-check uses the host's repos)
    KS_REPOS+=("url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-${RELEASE}&arch=${ARCH}")
    KS_REPOS+=("repo --name=spin-updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f${RELEASE}&arch=${ARCH}")

    if $ENABLE_RPMFUSION; then
        info "RPM Fusion"
        local kind
        for kind in free nonfree; do
            KS_REPOS+=("repo --name=spin-rpmfusion-${kind} --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=${kind}-fedora-${RELEASE}&arch=${ARCH}")
            KS_REPOS+=("repo --name=spin-rpmfusion-${kind}-updates --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=${kind}-fedora-updates-released-${RELEASE}&arch=${ARCH}")
            CHECK_REPOS+=("rpmfusion-${kind}|https://download1.rpmfusion.org/${kind}/fedora/releases/${RELEASE}/Everything/${ARCH}/os/")
            CHECK_REPOS+=("rpmfusion-${kind}-updates|https://download1.rpmfusion.org/${kind}/fedora/updates/${RELEASE}/${ARCH}/")
            # These packages put RPM Fusion's repo files on the installed system.
            EXTRA_PKGS+=("rpmfusion-${kind}-release")
        done
    fi

    # Third-party repos from their official .repo files (Brave etc.)
    local entry name url file baseurl
    for entry in "${EXTRA_REPOS[@]}"; do
        IFS='|' read -r name url <<<"$entry"
        info "Repo ${name}"
        file="$WORK/yum.repos.d/${name}.repo"
        curl -fsSL -o "$file" "$url" || die "Couldn't download ${url}"
        baseurl="$(awk -F= '/^baseurl[[:space:]]*=/ {sub(/^[^=]*=[[:space:]]*/, ""); print; exit}' "$file")"
        [[ -n "$baseurl" ]] || die "No baseurl in ${url}"
        baseurl="${baseurl//\$basearch/$ARCH}"
        baseurl="${baseurl//\$releasever/$RELEASE}"
        add_repo "$name" "$baseurl"
    done

    if $ENABLE_GOOGLE_CHROME_REPO; then
        info "Repo google-chrome"
        add_repo google-chrome "https://dl.google.com/linux/chrome/rpm/stable/x86_64"
        cat > "$WORK/yum.repos.d/google-chrome.repo" <<'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
    fi

    if $ENABLE_CLAUDE_CODE_REPO; then
        info "Repo claude-code (${CLAUDE_CODE_CHANNEL}); checking its signing key"
        local key="$WORK/keys/RPM-GPG-KEY-claude-code" fpr
        curl -fsSL -o "$key" https://downloads.claude.ai/keys/claude-code.asc \
            || die "Couldn't download the Claude Code signing key"
        fpr="$(gpg --show-keys --with-colons "$key" 2>/dev/null | awk -F: '/^fpr:/ {print $10; exit}')"
        [[ "$fpr" == "$CLAUDE_KEY_FPR" ]] || die "Claude Code key fingerprint mismatch (got '${fpr}')"
        add_repo claude-code "https://downloads.claude.ai/claude-code/rpm/${CLAUDE_CODE_CHANNEL}"
        cat > "$WORK/yum.repos.d/claude-code.repo" <<EOF
[claude-code]
name=Claude Code
baseurl=https://downloads.claude.ai/claude-code/rpm/${CLAUDE_CODE_CHANNEL}
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-claude-code
EOF
    fi

    local copr owner project id
    for copr in "${COPR_REPOS[@]}"; do
        owner="${copr%%/*}"; project="${copr#*/}"
        id="copr-${owner}-${project}"
        info "COPR ${copr}"
        add_repo "$id" "https://download.copr.fedorainfracloud.org/results/${owner}/${project}/fedora-${RELEASE}-${ARCH}/"
        cat > "$WORK/yum.repos.d/_copr:copr.fedorainfracloud.org:${owner}:${project}.repo" <<EOF
[copr:copr.fedorainfracloud.org:${owner}:${project}]
name=Copr repo for ${project} owned by ${owner}
baseurl=https://download.copr.fedorainfracloud.org/results/${owner}/${project}/fedora-\$releasever-\$basearch/
type=rpm-md
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/${owner}/${project}/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF
    done

    # Fresh and k9s have no repo: put their release RPMs (checksum-verified)
    # in a small local repo for the build.
    local local_pkgs=()
    if $INSTALL_FRESH_EDITOR; then
        info "Fresh editor (latest GitHub release)"
        github_rpm sinelaw/fresh "\.${ARCH}\.rpm$" per-file "$WORK/localrepo" >/dev/null \
            || die "Couldn't get a verified Fresh RPM"
        local_pkgs+=(fresh-editor)
    fi
    if $INSTALL_K9S; then
        info "k9s (latest GitHub release)"
        github_rpm derailed/k9s "/k9s_linux_amd64\.rpm$" checksums.sha256 "$WORK/localrepo" >/dev/null \
            || die "Couldn't get a verified k9s RPM"
        local_pkgs+=(k9s)
    fi
    if ((${#local_pkgs[@]})); then
        createrepo_c -q "$WORK/localrepo"
        add_repo local-extras "file://${WORK}/localrepo"
        EXTRA_PKGS+=("${local_pkgs[@]}")
    fi

    info "Checking every repository has Fedora ${RELEASE} packages"
    local pair bad=()
    for pair in "${CHECK_REPOS[@]}"; do
        IFS='|' read -r name url <<<"$pair"
        [[ "$url" == file://* ]] && continue
        repo_reachable "$url" || bad+=("${name} (${url})")
    done
    ((${#bad[@]} == 0)) || die "No Fedora ${RELEASE} repository at: ${bad[*]}
   A new Fedora release often takes a while to reach third-party repos; try RELEASE=$((RELEASE - 1))."
}

# --- kickstart -------------------------------------------------------------------

all_packages() {
    printf '%s\n' "${DNF_PACKAGES[@]}" "${EXTRA_REPO_PACKAGES[@]}" "${EXTRA_PKGS[@]}"
}

# Your files, laid out as they go into the image: /etc/skel for every new user,
# system paths, and the whole kit (so `fedora-setup` works on installed machines).
make_payload() {
    local stage="$WORK/payload" entry f dest
    rm -rf "$stage"; mkdir -p "$stage/root" "$stage/skel"
    for entry in "${USER_FILES[@]}"; do
        IFS='|' read -r f dest _ <<<"$entry"
        install -D -m 644 "${HERE}/files/${f}" "$stage/skel/${dest}"
    done
    for entry in "${SYSTEM_FILES[@]}"; do
        IFS='|' read -r f dest <<<"$entry"
        local mode=644
        [[ "$dest" == */bin/* ]] && mode=755
        install -D -m "$mode" "${HERE}/files/${f}" "$stage/root${dest}"
    done
    # Big files (JetBrains Toolbox, ~100 MB) don't go into the kickstart as
    # text: they're copied straight from this folder into the image during the
    # build (see the "--nochroot" step in generate_ks).
    rm -rf "$WORK/bigfiles"; mkdir -p "$WORK/bigfiles"
    if $INSTALL_JETBRAINS_TOOLBOX; then
        info "JetBrains Toolbox (latest release from JetBrains)"
        bash "${HERE}/files/jetbrains/install-jetbrains-toolbox" "$WORK/bigfiles" \
            || warn "Couldn't get a verified JetBrains Toolbox; building without it (fedora-setup can add it later)"
        chmod -R u=rwX,go=rX "$WORK/bigfiles"
    fi
    local kit="$stage/root/usr/local/share/fedora-onehand-setup"
    mkdir -p "$kit"
    cp -r "${HERE}/files" "$SETUP" "$kit/"
    for f in mount-internal-drives.sh README.md; do
        [[ -f "${HERE}/${f}" ]] && cp "${HERE}/${f}" "$kit/"
    done
    chmod -R u=rwX,go=rX "$stage"
    tar -C "$stage" --owner=0 --group=0 -czf "$WORK/payload.tar.gz" root skel
    local mb=$(( $(stat -c %s "$WORK/payload.tar.gz") / 1048576 ))
    info "Configs and scripts for the image: ${mb} MB"
}

generate_ks() {
    info "Writing ${FINAL_KS}"
    local f pkg flatpaks="${FLATPAKS[*]}"
    {
        echo "# Generated by build-spin.sh on $(date -Iseconds) for Fedora ${RELEASE}."
        echo "# Edit fedora-setup.sh and niri-spin-base.ks, not this file."
        echo
        echo "# --- repositories used for the build ---"
        printf '%s\n' "${KS_REPOS[@]}"
        echo
        echo "# --- keyboard: stock right-handed Dvorak for the console, login screen and"
        echo "# installer; niri uses your dvorak_r_pl layout (installed below) ---"
        echo "keyboard --vckeymap=${CONSOLE_KEYMAP} --xlayouts='${BASE_XKB_LAYOUT} (${BASE_XKB_VARIANT})'"
        echo
        # The base kickstart with your apps put into its single %packages section
        # (a kickstart may only have one).
        local apps="$WORK/apps.list" g
        {
            for g in "${DNF_GROUPS[@]}"; do echo "@${g}"; done
            all_packages | sort -u
            for pkg in "${DNF_REMOVE[@]}"; do echo "-${pkg}"; done
        } > "$apps"
        grep -q '^# @APPS@$' "$BASE_KS" || die "niri-spin-base.ks has no '# @APPS@' line in %packages."
        awk -v apps="$apps" '/^# @APPS@$/ { while ((getline l < apps) > 0) print l; next } { print }' "$BASE_KS"
        echo
        # Your files and the big files are NOT written into this kickstart (that
        # made it 100+ MB and very slow to read). A --nochroot script, which runs
        # on this machine outside the image, copies them in from the build folder.
        cat <<POST_EOF
%post --nochroot --erroronfail
set -eu
img="\${ANA_INSTALL_PATH:-/mnt/sysimage}"
test -d "\$img/usr"
mkdir -p "\$img/root"
cp "$WORK/payload.tar.gz" "\$img/root/onehand-payload.tar.gz"
# Big files: contents, modes and links only (not this machine's owners or SELinux labels).
if [ -n "\$(ls -A "$WORK/bigfiles" 2>/dev/null)" ]; then
    cp -R --preserve=mode,timestamps,links "$WORK/bigfiles/." "\$img/"
    echo "Copied into the image: \$(cd "$WORK/bigfiles" && echo *)"
fi
%end

POST_EOF
        # Your files: home-folder files into /etc/skel, system files into place
        echo "%post --erroronfail"
        echo "set -euo pipefail"
        echo "test -s /root/onehand-payload.tar.gz"
        echo "mkdir -p /etc/skel"
        echo "tar -xzf /root/onehand-payload.tar.gz -C /etc/skel --strip-components=1 skel"
        echo "tar -xzf /root/onehand-payload.tar.gz -C / --strip-components=1 root"
        echo "rm -f /root/onehand-payload.tar.gz"
        echo "mkdir -p /usr/local/bin"
        echo "ln -sf /usr/local/share/fedora-onehand-setup/fedora-setup.sh /usr/local/bin/fedora-setup"
        user_setup_commands /etc/skel
        echo "%end"
        echo
        echo "%post --erroronfail"
        echo "# keyd, greetd login screen, Dux autostart, first-login wallpaper"
        system_setup_commands greetd
        echo "# Check the niri config (warning only)"
        echo "niri validate -c /etc/skel/.config/niri/config.kdl || echo 'WARNING: niri validate failed for the shipped config (needs niri 25.11+)' >&2"
        echo "%end"
        echo

        # Repo files and keys for updates on the installed system
        echo "%post --erroronfail"
        echo "set -euo pipefail"
        for f in "$WORK"/yum.repos.d/*.repo; do
            [[ -e "$f" ]] || continue
            echo "cat > '/etc/yum.repos.d/$(basename "$f")' <<'REPO_EOF'"
            cat "$f"
            echo "REPO_EOF"
        done
        if [[ -f "$WORK/keys/RPM-GPG-KEY-claude-code" ]]; then
            echo "cat > /etc/pki/rpm-gpg/RPM-GPG-KEY-claude-code <<'KEY_EOF'"
            cat "$WORK/keys/RPM-GPG-KEY-claude-code"
            echo "KEY_EOF"
            echo "rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-claude-code"
        fi
        echo "%end"
        echo

        # Label the big files copied in above the way the image's policy expects.
        if [[ -n "$(ls -A "$WORK/bigfiles" 2>/dev/null)" ]]; then
            cat <<'POST_EOF'
%post --erroronfail
# Label the copied files the way the image's SELinux policy expects.
chown -R root:root /opt/jetbrains-toolbox 2>/dev/null || true
restorecon -R /opt /usr/local/bin /usr/share/applications 2>/dev/null || true
%end

POST_EOF
        fi

        # Keyboard safety net: if the console keymap named above isn't in the
        # image, switch to Fedora's identical "us-dvorak-r" instead of silently
        # ending up with US QWERTY on the console, the login screen and the
        # disk-unlock prompt. Then confirm every layer is right-handed Dvorak.
        cat <<POST_EOF
%post --erroronfail
set -eu
want="${CONSOLE_KEYMAP}"
have_map() { find /usr/lib/kbd/keymaps -name "\$1.map*" | grep -q .; }
if ! have_map "\$want"; then
    for m in us-dvorak-r dvorak-r; do have_map "\$m" && { want="\$m"; break; }; done
fi
have_map "\$want" || { echo "No right-handed Dvorak console keymap in the image" >&2; exit 1; }
if grep -q '^KEYMAP=' /etc/vconsole.conf 2>/dev/null; then
    sed -i "s/^KEYMAP=.*/KEYMAP=\"\$want\"/" /etc/vconsole.conf
else
    echo "KEYMAP=\"\$want\"" >> /etc/vconsole.conf
fi
echo "Keyboard: console \$want; desktop \$(test -f /etc/xkb/symbols/dvorak_r_pl && echo dvorak_r_pl || echo MISSING)"
test -f /etc/xkb/symbols/dvorak_r_pl
grep -q 'layout "dvorak_r_pl"' /etc/skel/.config/niri/config.kdl
%end

POST_EOF

        # The spin's own name (os-release, installer profile)
        if [[ -f "$BRANDING_KS" ]]; then
            sed -e "s|@PRODUCT@|${PRODUCT}|g" -e "s|@VARIANT@|${VARIANT}|g" "$BRANDING_KS"
            echo
        fi

        # Flatpaks: installed on the first boot of the installed system (they
        # are downloaded from Flathub, so not baked into the ISO).
        if $ENABLE_FLATHUB; then
        cat <<POST_EOF
%post --erroronfail
set -euo pipefail
mkdir -p /usr/libexec/niri-spin
cat > /usr/libexec/niri-spin/install-flatpaks <<'SH_EOF'
#!/bin/bash
set -euo pipefail
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
apps=(${flatpaks})
if ((\${#apps[@]})); then
    flatpak install -y --noninteractive flathub "\${apps[@]}"
fi
mkdir -p /var/lib/niri-spin
touch /var/lib/niri-spin/flatpaks-done
SH_EOF
chmod 755 /usr/libexec/niri-spin/install-flatpaks
cat > /etc/systemd/system/niri-spin-flatpaks.service <<'UNIT_EOF'
[Unit]
Description=Install Flatpak apps from Flathub (first boot)
Wants=network-online.target
After=network-online.target
ConditionPathExists=!/var/lib/niri-spin/flatpaks-done
ConditionKernelCommandLine=!rd.live.image

[Service]
Type=oneshot
ExecStart=/usr/libexec/niri-spin/install-flatpaks
Restart=on-failure
RestartSec=120

[Install]
WantedBy=multi-user.target
UNIT_EOF
systemctl enable niri-spin-flatpaks.service
%end

POST_EOF
        fi

    } > "$FINAL_KS"

    if command -v ksvalidator &>/dev/null; then
        ksvalidator "$FINAL_KS" || die "The generated kickstart didn't validate (see above)."
    else
        warn "ksvalidator not found; skipping kickstart validation"
    fi
}

# Catch missing packages now instead of 20 minutes into the build.
check_packages() {
    info "Checking all packages exist for Fedora ${RELEASE}"
    local args=("--releasever=${RELEASE}" --refresh) repos=(fedora updates) pair name url
    for pair in "${CHECK_REPOS[@]}"; do
        IFS='|' read -r name url <<<"$pair"
        # Own prefix: the build machine may already have a repo with the same
        # name (Fedora Workstation ships a disabled google-chrome repo), and
        # dnf refuses two repos with one name.
        args+=("--repofrompath=spincheck-${name},${url}")
        repos+=("spincheck-${name}")
    done
    args+=("--repo=$(IFS=,; echo "${repos[*]}")")

    local wanted found missing log="$WORK/repoquery.log"
    wanted="$(all_packages | sort -u)"
    # Saved so it can be re-run by hand: bash build/repoquery-command.sh
    printf 'dnf repoquery %s --qf %q %s\n' "$(printf '%q ' "${args[@]}")" '%{name}\n' "$(echo $wanted)" \
        > "$WORK/repoquery-command.sh"
    # shellcheck disable=SC2086  # $wanted is a list of package names
    if ! found="$(dnf repoquery "${args[@]}" --qf '%{name}\n' $wanted 2>"$log")"; then
        echo >&2
        tail -n 20 "$log" >&2
        die "dnf repoquery failed (its message is above; full log: ${log})."
    fi
    found="$(sort -u <<<"$found")"
    missing="$(comm -23 <(echo "$wanted") <(echo "$found"))"

    # Some names are aliases ("vim" is vim-enhanced, "wget" is wget2-wget).
    # dnf and the kickstart install them fine, so only flag names nothing provides.
    if [[ -n "$missing" ]]; then
        local really_missing="" p
        while IFS= read -r p; do
            [[ -z "$p" ]] && continue
            if [[ -z "$(dnf repoquery "${args[@]}" --whatprovides "$p" --qf '%{name}\n' 2>>"$log")" ]]; then
                really_missing+="${p}"$'\n'
            fi
        done <<<"$missing"
        missing="${really_missing%$'\n'}"
    fi
    [[ -z "$missing" ]] || die "These packages aren't available for Fedora ${RELEASE}:
$(sed 's/^/     /' <<<"$missing")
   Remove them from fedora-setup.sh or build an earlier RELEASE."

    # Do they also install TOGETHER? (Each package can exist and the set still
    # conflict, as anaconda-webui did with the release identity.) Resolve the
    # whole image's package set without installing anything.
    info "Checking all packages install together (dependency check, no download)"
    local root="$WORK/depcheck-root" dlog="$WORK/depcheck.log" spec=() excl=() line
    while IFS= read -r line; do
        line="${line%%#*}"; line="${line//[[:space:]]/}"
        [[ -z "$line" ]] && continue
        if [[ "$line" == -* ]]; then excl+=("--exclude=${line#-}"); else spec+=("$line"); fi
    done < <(sed -n '/^%packages/,/^%end/{/^%/d;p}' "$BASE_KS"; all_packages; for p in "${DNF_REMOVE[@]}"; do echo "-$p"; done)
    sudo rm -rf "$root"; mkdir -p "$root"
    if LC_ALL=C sudo dnf install --assumeno --installroot="$root" --use-host-config \
            "${args[@]}" "${excl[@]}" "${spec[@]}" >"$dlog" 2>&1 \
       || ! grep -qE 'Failed to resolve|Problem|No match for argument|conflicting requests' "$dlog"; then
        info "The package set resolves cleanly"
    else
        echo >&2
        grep -E -A14 'Failed to resolve|Problem' "$dlog" | head -n 40 | cut -c1-220 >&2
        die "The packages don't install together (reason above; full log: ${dlog})."
    fi
    sudo rm -rf "$root"
}

build_iso() {
    # The installed system goes into a 16 GB image file next to the ISO, then gets
    # compressed in /var/tmp. Running out of space mid-way breaks the installer
    # or leaves a truncated ISO, so check first.
    # About 25 GB is used at the peak (installed system, package downloads,
    # compressed image, ISO); MIN_FREE_GB=... overrides the limit.
    local need="${MIN_FREE_GB:-28}" free_out free_tmp
    mkdir -p "${BUILD_ROOT}/out"

    # Clean up what earlier (failed) builds left behind: working folders and the
    # downloaded-package cache in /var/tmp, and the 16 GB disk images in out/.
    # Finished ISOs are kept.
    if ! pgrep -x anaconda >/dev/null && ! pgrep -f livemedia-creator >/dev/null; then
        info "Removing leftovers from earlier builds"
        sudo rm -rf /var/tmp/lmc-work-* /var/tmp/lorax.* /var/tmp/dnf.package.cache 2>/dev/null || true
        sudo rm -f "${BUILD_ROOT}"/out/*/lmc-disk-*.img 2>/dev/null || true
    fi
    free_out="$(df --output=avail -BG "${BUILD_ROOT}/out" | tail -1 | tr -dc 0-9)"
    free_tmp="$(df --output=avail -BG /var/tmp | tail -1 | tr -dc 0-9)"
    if [[ "$(df --output=source "${BUILD_ROOT}/out" | tail -1)" == "$(df --output=source /var/tmp | tail -1)" ]]; then
        (( free_out >= need )) || die "Only ${free_out} GB free; the build needs about ${need} GB. Free up space (old out/ folders, /var/tmp/lmc-*) or enlarge the VM's disk."
    else
        (( free_out >= 20 )) || die "Only ${free_out} GB free in ${BUILD_ROOT}/out; the build needs about 20 GB there."
        (( free_tmp >= 15 )) || die "Only ${free_tmp} GB free in /var/tmp; the build needs about 15 GB there."
    fi
    info "Free space: ${free_out} GB (enough)"

    # A previous run that was stopped (Ctrl+C) leaves the installer's lock file
    # behind, and the next installer then refuses to start.
    if pgrep -x anaconda >/dev/null; then
        die "The installer from an earlier build is still running. Restart the VM, then build again."
    fi
    sudo rm -f /run/anaconda.pid /var/run/anaconda.pid

    # livemedia-creator --no-virt installs into a plain folder, where SELinux
    # (Enforcing) blocks the installer from setting up accounts ("Unable to set
    # password ... status=1"). Relax it for the build only, and always restore it.
    if command -v getenforce >/dev/null && [[ "$(getenforce)" == Enforcing ]]; then
        info "Setting SELinux to Permissive for the build (restored afterwards)"
        sudo setenforce 0
        # Restore on success, failure and Ctrl+C alike.
        trap 'sudo setenforce 1 && echo "SELinux set back to Enforcing" >&2' EXIT
        trap 'exit 130' INT TERM
    fi

    info "Building the ISO (this takes a while)"
    if ! sudo livemedia-creator --make-iso --no-virt \
        --ks "$FINAL_KS" \
        --resultdir "$RESULT_DIR" \
        --project "$PRODUCT" \
        --releasever "$RELEASE" \
        --volid "${NAME}-${RELEASE}" \
        --iso-only --iso-name "$ISO_NAME" \
        --isfinal \
        --logfile "$WORK/livemedia-creator.log"; then
        # The installer's own logs say why; livemedia-creator doesn't.
        local f
        sudo chown -R "$(id -u):$(id -g)" "$WORK" 2>/dev/null || true
        for f in "$WORK"/anaconda/anaconda.log "$WORK"/anaconda/packaging.log "$WORK"/anaconda/dnf.log \
                 "$WORK"/anaconda/program.log /tmp/anaconda.log /tmp/packaging.log; do
            if sudo test -s "$f"; then
                echo >&2
                echo "----- last lines of ${f} -----" >&2
                sudo tail -n 15 "$f" | cut -c1-200 >&2
            fi
        done
        sudo mkdir -p "$WORK/installer-logs"
        sudo cp /tmp/*.log "$WORK/installer-logs/" 2>/dev/null || true
        sudo chown -R "$(id -u):$(id -g)" "$WORK/installer-logs" 2>/dev/null || true
        # The reason is usually an ERROR/Traceback line somewhere in these logs.
        echo >&2
        echo "----- error lines from all installer logs (the cause is usually here) -----" >&2
        grep -s -h -n -E 'ERR |CRIT|Traceback|[Ee]rror:|Exception|exited with|failed|No match for' \
            "$WORK/livemedia-creator.log" "$WORK"/anaconda/*.log "$WORK"/installer-logs/*.log \
            | grep -v -E 'DBG|DEBUG|Return code: 0' | tail -n 40 | cut -c1-220 >&2
        die "The installer stopped (error lines above; all logs: ${WORK}/installer-logs and ${WORK}/livemedia-creator.log)."
    fi
    sudo chown -R "$(id -u):$(id -g)" "$RESULT_DIR" "$WORK"
    if [[ "$BUILD_ROOT" != "$HERE" ]]; then
        # Bring the ISO back next to the scripts (same disk, so this is instant).
        mkdir -p "${HERE}/out"
        mv "${RESULT_DIR}/${ISO_NAME}" "${HERE}/out/" && RESULT_DIR="${HERE}/out"
    fi
    info "Done: ${RESULT_DIR}/${ISO_NAME}"
}

main() {
    preflight
    load_config
    install_tools
    collect_repos
    make_payload
    generate_ks
    check_packages
    if $GENERATE_ONLY; then
        info "Kickstart ready: ${FINAL_KS}"
        exit 0
    fi
    build_iso
}

main "$@"
