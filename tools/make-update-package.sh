#!/bin/bash
# Builds the update package for machines that are already set up
# (dist/onehand-update-gnc.tar.gz) from the same files the ISO and
# fedora-setup.sh use, so the three never drift apart.
#
#   tools/make-update-package.sh [PRODUCT_NAME]     default: "Fedora GNC"
set -euo pipefail
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
PRODUCT="${1:-Fedora GNC}"
NAME=onehand-update-gnc
OUT="$ROOT/dist"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
P="$STAGE/$NAME"; F="$P/files"
mkdir -p "$F/wallpapers" "$F/docs"

cp "$ROOT/update/update.sh" "$ROOT/update/README.txt" "$P/"
chmod 755 "$P/update.sh"
for d in keyd niri ghostty fish foot vimium bin branding jetbrains; do
    cp -r "$ROOT/files/$d" "$F/"
done
cp "$ROOT"/files/wallpapers/fedora-gnc-*.png "$F/wallpapers/"
cp "$ROOT"/docs/*.md "$ROOT/FEDORA-GNC.md" "$F/docs/"

# The name and logo step: the ISO's branding.ks %post, minus the installer profile.
sed -n '/^%post/,/^%end/p' "$ROOT/branding.ks" | sed '1d;$d' \
    | sed -e "s|@PRODUCT@|${PRODUCT}|g" -e "s|@VARIANT@|${PRODUCT##* }|g" \
    | awk '/^cat > \/etc\/anaconda\/profile.d/{exit} {print}' \
    | sed 's|mkdir -p /usr/libexec/onehand /etc/anaconda/profile.d|mkdir -p /usr/libexec/onehand|' \
    > "$STAGE/branding.body"
{ echo '#!/bin/bash'; echo "# Gives this system the ${PRODUCT} name and logo (same as the ISO)."; cat "$STAGE/branding.body"; } \
    > "$F/branding/apply-branding.sh"
bash -n "$F/branding/apply-branding.sh"
bash -n "$P/update.sh"

mkdir -p "$OUT"
tar -C "$STAGE" --owner=0 --group=0 -czf "$OUT/$NAME.tar.gz" "$NAME"
echo "Built $OUT/$NAME.tar.gz ($(du -h "$OUT/$NAME.tar.gz" | cut -f1))"
