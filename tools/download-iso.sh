#!/usr/bin/env bash
#
# download-iso.sh — fetch an ISO built by GitHub Actions, join it, check it.
#
#   tools/download-iso.sh            # the newest ISO release
#   tools/download-iso.sh iso-TAG    # a specific one (gh release list)
#
# Needs the GitHub CLI signed in to an account that can read the (private)
# repository: `gh auth login` once. The ISO lands in ./out/ next to the kit.
# REPO=owner/name overrides the repository (default: luzikaj/onehand-iso, the
# private repository that builds and keeps the ISOs).
#
set -euo pipefail

REPO="${REPO:-luzikaj/onehand-iso}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
die() { printf '\e[1;31m ✗\e[0m  %s\n' "$*" >&2; exit 1; }

command -v gh >/dev/null || die "Install the GitHub CLI first: sudo dnf install gh, then gh auth login"
tag="${1:-}"
if [[ -z "$tag" ]]; then
    tag="$(gh release list -R "$REPO" --limit 50 --json tagName -q '.[].tagName' | grep -m1 '^iso-' || true)"
    [[ -n "$tag" ]] || die "No ISO releases yet: run build-iso in luzikaj/onehand-iso first."
fi

out="${HERE}/out/${tag}"
mkdir -p "$out"
cd "$out"
echo "==> Downloading ${tag} into ${out}"
gh release download "$tag" -R "$REPO" --clobber --pattern '*.part*' --pattern SHA256SUMS
iso="$(awk '{print $2}' SHA256SUMS)"
[[ -n "$iso" ]] || die "SHA256SUMS is empty."
echo "==> Joining the parts"
cat "${iso}".part* > "$iso"
echo "==> Checking"
sha256sum -c SHA256SUMS || die "Checksum mismatch: delete ${out} and download again."
rm -f "${iso}".part*
echo
echo "Ready: ${out}/${iso}"
echo "Write it to a USB stick in DD mode (Fedora Media Writer), e.g.:"
echo "  sudo dd if='${out}/${iso}' of=/dev/sdX bs=4M status=progress oflag=sync"
