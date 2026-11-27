#!/usr/bin/env bash
#
# ci-build-iso.sh — build the ISO inside a Fedora container (GitHub Actions).
#
# The build-iso workflow of the private repository luzikaj/onehand-iso runs
# this as root in a privileged fedora:<release> container, with the kit at /src
# and the host's /dev (loop devices).
# It builds as an ordinary user with sudo (build-spin.sh refuses root), checks
# the ISO (SELinux labels, size) and leaves it in /src/dist with SHA256SUMS
# and version.txt. You don't run this yourself (BUILDING.md, "Build it on GitHub").
#
set -euo pipefail

SRC="${SRC:-/src}"
RELEASE="${RELEASE:-$(rpm -E %fedora)}"
info() { printf '\e[1;34m==>\e[0m %s\n' "$*"; }
die()  { printf '\e[1;31m ✗\e[0m  %s\n' "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Run as root inside the build container."
[[ -x "$SRC/build-spin.sh" ]] || die "No repository at $SRC."

info "Container tools"
dnf install -y --setopt=install_weak_deps=False \
    sudo git-core procps-ng util-linux findutils which squashfs-tools attr e2fsprogs
git config --system --add safe.directory '*'

# build-spin.sh runs as a normal user and uses sudo where it needs root.
id builder >/dev/null 2>&1 || useradd -m builder
echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
chmod 440 /etc/sudoers.d/builder
chown -R builder: "$SRC"

info "Building Fedora ${RELEASE}"
df -h "$SRC" /var/tmp
sudo -u builder -H env RELEASE="$RELEASE" bash -c "cd '$SRC' && ./build-spin.sh"

iso="$(ls -t "$SRC"/out/*/*.iso "$SRC"/out/*.iso 2>/dev/null | head -1)"
[[ -s "$iso" ]] || die "No ISO in $SRC/out."
info "ISO: $iso ($(du -h "$iso" | cut -f1))"

# --- check: every file has an SELinux label (else nobody can log in) ---------
info "Checking SELinux labels inside the ISO"
mnt="$(mktemp -d)" ex="$(mktemp -d)" rootfs=""
mount -o loop,ro "$iso" "$mnt"
sq="$mnt/LiveOS/squashfs.img"
[[ -f "$sq" ]] || die "No LiveOS/squashfs.img in the ISO."
if unsquashfs -l "$sq" | grep -q 'LiveOS/rootfs.img$'; then
    unsquashfs -q -d "$ex/sq" "$sq" LiveOS/rootfs.img
    rootfs="$(mktemp -d)"
    mount -o loop,ro "$ex/sq/LiveOS/rootfs.img" "$rootfs"
    root="$rootfs"
else
    unsquashfs -q -d "$ex/sq" "$sq" usr/bin/bash etc/shadow
    root="$ex/sq"
fi
bash_label="$(getfattr --only-values -n security.selinux "$root/usr/bin/bash" 2>/dev/null || true)"
shadow_label="$(getfattr --only-values -n security.selinux "$root/etc/shadow" 2>/dev/null || true)"
[[ -n "$rootfs" ]] && umount "$rootfs"
umount "$mnt"
rm -rf "$ex"
echo "  /usr/bin/bash: ${bash_label:-none}"
echo "  /etc/shadow:   ${shadow_label:-none}"
[[ "$bash_label" == *shell_exec_t* && "$shadow_label" == *shadow_t* ]] \
    || die "The image has no SELinux labels; it would boot but refuse every login."

# --- hand over -----------------------------------------------------------------
mkdir -p "$SRC/dist"
mv "$iso" "$SRC/dist/"
iso="$SRC/dist/$(basename "$iso")"
bash "$SRC/files/bin/onehand-version" --of "$SRC" | sed -n 's/^VERSION=//p' > "$SRC/dist/version.txt"
(cd "$SRC/dist" && sha256sum "$(basename "$iso")" > SHA256SUMS)
cp "$SRC/build/onehand-spin.ks" "$SRC/dist/" 2>/dev/null || true
chmod -R a+rwX "$SRC/dist"
info "Done: $(cat "$SRC/dist/version.txt"), $(cat "$SRC/dist/SHA256SUMS")"
