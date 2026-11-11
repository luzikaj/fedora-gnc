# niri-spin-base.ks — the live-system basics of the one-handed niri spin.
#
# Don't build from this file directly: build-spin.sh adds the repositories,
# your apps and their configuration (all read from fedora-setup.sh) and
# produces the final kickstart.

# --- language and time (change to taste) ---------------------------------------
# The keyboard line is added by build-spin.sh from KEYBOARD_* in fedora-setup.sh.
lang pl_PL.UTF-8
timezone Europe/Warsaw

# --- system -------------------------------------------------------------------
selinux --enforcing
firewall --enabled --service=mdns
network --bootproto=dhcp --device=link --activate
services --enabled=NetworkManager --disabled=sshd
# Root login stays disabled. (Giving root a placeholder password, as Fedora's
# old live images did, makes the Fedora 45 installer fail with "Unable to set password".)
rootpw --lock
bootloader --location=none
zerombr
clearpart --all
# Size of the live root filesystem image (MB). Raise it if the build runs out of space.
part / --size=16384 --fstype=ext4
shutdown

%packages
@core
@standard
@hardware-support
@fonts
@multimedia
@networkmanager-submodules
kernel
kernel-modules
kernel-modules-extra

# Fedora's identity package. The installer's web interface (anaconda-webui)
# uses the light "slitherer" browser only on a spin identity, and needs Firefox
# otherwise. The i3 one only adds /usr/lib/os-release (which branding.ks
# rewrites to "Fedora GNC") and Fedora's desktop service presets: no i3.
fedora-release-i3
fedora-release-identity-i3
-fedora-release-identity-basic

# Live boot and the "Install to Hard Drive" installer
dracut-live
dracut-config-generic
-dracut-config-rescue
livesys-scripts
anaconda
anaconda-install-env-deps
anaconda-live
slitherer
@anaconda-tools
glibc-all-langpacks

# Bootloaders for the ISO (UEFI and BIOS)
grub2-efi-x64
grub2-efi-x64-cdboot
shim-x64
grub2-pc
grub2-pc-modules
grub2-tools-extra
efibootmgr

# (The login screen, greetd + tuigreet, comes from fedora-setup.sh's list.)

# Your apps from fedora-setup.sh are inserted here by build-spin.sh:
# @APPS@
%end

%post --erroronfail
# Live-media housekeeping (as Fedora's own live images did it)
systemctl enable livesys.service livesys-late.service
systemctl enable tmp.mount || true
echo "vartmp   /var/tmp    tmpfs   defaults   0  0" >> /etc/fstab
rm -f /var/lib/systemd/random-seed /boot/*-rescue* /core*
echo 'File created by kickstart. See systemd-update-done.service(8).' \
    | tee /etc/.updated > /var/.updated
rm -f /etc/machine-id
touch /etc/machine-id

# Live session only: log the live user straight into niri. livesys runs this
# file at live boot; installed systems are copied from the clean image, so
# they get the normal text login screen instead.
mkdir -p /var/lib/livesys /etc/systemd/system/greetd.service.d
cat > /etc/systemd/system/greetd.service.d/after-livesys.conf <<'DROPIN_EOF'
# On the live USB, wait for livesys to add the auto-login (no effect when installed)
[Unit]
After=livesys.service livesys-late.service
DROPIN_EOF
cat >> /var/lib/livesys/livesys-session-extra <<'LIVESYS_EOF'
# The stock "Install to Hard Drive" entry doesn't start under niri; hide it and
# offer the Welcome window's installer instead (live USB only).
for f in /usr/share/applications/liveinst.desktop /usr/share/applications/anaconda.desktop; do
    [ -f "$f" ] && sed -i '/^NoDisplay=/d; /^\[Desktop Entry\]/a NoDisplay=true' "$f" || true
done
cat > /usr/share/applications/gnc-install.desktop <<'DESKTOP_EOF'
[Desktop Entry]
Type=Application
Name=Install Fedora GNC
Comment=Install this system on the computer's disk
Exec=/usr/local/bin/onehand-welcome --launch install
Icon=fedora-gnc-logo
Terminal=false
Categories=System;
Keywords=install;installer;anaconda;liveinst;disk;
DESKTOP_EOF
cat >> /etc/greetd/config.toml <<'GREETD_EOF'

[initial_session]
command = "niri-session"
user = "liveuser"
GREETD_EOF
LIVESYS_EOF
%end
