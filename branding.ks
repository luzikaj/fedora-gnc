# branding.ks — the spin's own identity. build-spin.sh adds this to the
# kickstart and replaces @PRODUCT@ with the name (default "Fedora GNC").
#
# - /etc/os-release gets the name (a small boot service keeps it there, since
#   Fedora updates rewrite /usr/lib/os-release, which it is copied from)
# - the installer gets a profile for VARIANT_ID=gnc, so it shows this name
#   and uses the lightweight installer browser like Fedora's other spins

%post --erroronfail
set -euo pipefail
mkdir -p /usr/libexec/onehand /etc/anaconda/profile.d

cat > /usr/libexec/onehand/branding <<'SH_END'
#!/bin/bash
# Writes /etc/os-release from Fedora's /usr/lib/os-release, with this spin's name.
set -euo pipefail
src=/usr/lib/os-release
tmp="$(mktemp)"
ver="$(. "$src" && echo "${VERSION_ID:-}")"
grep -v -E '^(NAME|PRETTY_NAME|VARIANT|VARIANT_ID|LOGO)=' "$src" > "$tmp"
{
    echo 'NAME="@PRODUCT@"'
    echo "PRETTY_NAME=\"@PRODUCT@ ${ver}\""
    echo 'VARIANT="@VARIANT@"'
    echo 'VARIANT_ID=gnc'
    echo 'LOGO=fedora-gnc-logo'
} >> "$tmp"
if [ -L /etc/os-release ] || ! cmp -s "$tmp" /etc/os-release; then
    rm -f /etc/os-release
    install -m 644 "$tmp" /etc/os-release
    if command -v restorecon >/dev/null; then restorecon /etc/os-release || true; fi
fi
rm -f "$tmp"
SH_END
chmod 755 /usr/libexec/onehand/branding
/usr/libexec/onehand/branding

cat > /etc/systemd/system/onehand-branding.service <<'UNIT_END'
[Unit]
Description=Keep the @PRODUCT@ name in /etc/os-release
DefaultDependencies=no
After=local-fs.target
Before=sysinit.target

[Service]
Type=oneshot
ExecStart=/usr/libexec/onehand/branding

[Install]
WantedBy=sysinit.target
UNIT_END
systemctl enable onehand-branding.service

cat > /etc/anaconda/profile.d/fedora-gnc.conf <<'CONF_END'
# Anaconda configuration file for @PRODUCT@.
[Profile]
profile_id = fedora-gnc
base_profile = fedora

[Profile Detection]
os_id = fedora
variant_id = gnc

[User Interface]
# Same lightweight installer browser as Fedora's other spins (no Firefox here).
webui_web_engine = slitherer
CONF_END

# The logo (installed with the other system files) in the icon cache
if command -v gtk-update-icon-cache >/dev/null; then gtk-update-icon-cache -f -q /usr/share/icons/hicolor || true; fi
%end
