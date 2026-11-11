# Virtual machines: virt-manager (KVM)

Fedora GNC runs virtual machines with **KVM** (built into the kernel),
**libvirt** and **virt-manager**: Fedora's own virtualization stack. Guests get
**3D graphics** (virtio-GPU with OpenGL), so a guest running niri, Ghostty
or GNOME works properly inside the VM.

Open **Virtual Machine Manager** from the launcher (Mod + `'`, type `virt`).
Its windows, and every VM's screen, open on the workspace **`vm`** on the
main screen, below `code`. With one screen, `vm` is the last of the four.

## No password prompts

Administrators (the user created in the installer, group `wheel`) can create
and run VMs without typing a password. A polkit rule allows it:
`/etc/polkit-1/rules.d/50-onehand-libvirt.rules`. libvirt's services start by
themselves when virt-manager connects.

## Keys

| Keys | Action |
|---|---|
| **Mod + Scroll Lock** | **send all keys to the VM**, including Mod + … shortcuts. Press again to get your shortcuts back. |
| Mod + `n` / `w` | from another workspace: up / down to `vm` |
| F10 | open the menu bar of virt-manager (then arrows, Enter) |
| Tab / Shift+Tab, arrows, Space, Enter | move through dialogs (Shift: tap Right Shift) |
| Enter (in the VM list) | open the selected VM's window |

Two things the one-handed setup changes:

- **Right Alt is Mod**, so there's no right-hand Alt. Menu shortcuts like
  Alt+F don't reach virt-manager from the right hand; use **F10** to open the
  menus instead.
- virt-manager's default key to **release a grabbed keyboard** is
  **Left Ctrl + Left Alt**, both on the left. Change it once:
  **Edit → Preferences → Console → Grab keys**, then press a combination
  you can reach (for example Right Ctrl + Menu). Or simply leave the VM
  window: with Mod + Scroll Lock off, Mod + `e h t d` always works.

## Keyboard inside the guest

keyd remaps keys **before** the VM sees them, so a guest receives what your
desktop receives: holding Right Alt arrives as Super, tapping it as AltGr.
Give the guest the same layout, and the letters match:

- **any Linux guest:** keyboard layout **English (US) – Dvorak, right-handed**
  (`us`, variant `dvorak-r`)
- **Polish letters in a Fedora guest:** copy `files/xkb/dvorak_r_pl` to the
  guest's `/etc/xkb/symbols/` and choose the layout `dvorak_r_pl`, or run
  `fedora-setup.sh` inside it
- **a Fedora GNC guest:** nothing to do

## Creating a VM with 3D graphics

1. **File → New Virtual Machine → Local install media**, pick the ISO,
   memory (4–8 GB) and CPUs (2–4).
2. On the last page, tick **Customize configuration before install**.
3. **Overview → Firmware:** UEFI.
4. **Video:** model **Virtio**, tick **3D acceleration**.
5. **Display Spice:** Listen type **None**, tick **OpenGL**.
6. **Begin Installation**.

Steps 4 and 5 give the guest 3D graphics. Without them it still works, but
a niri guest won't start its desktop, and Ghostty won't start in any guest.

From a terminal, the same in one command:

```
virt-install --name test --memory 6144 --vcpus 4 --disk size=40 \
  --cdrom ~/Downloads/some.iso --osinfo detect=on,require=off --boot uefi \
  --video model.type=virtio,model.acceleration.accel3d=yes \
  --graphics spice,listen=none,gl.enable=yes
```

To test a freshly built Fedora GNC ISO this way, see [BUILDING.md](../BUILDING.md#test-it-in-virt-manager-recommended-on-linux).

## Simpler alternative: GNOME Boxes

For a quick throwaway VM, **GNOME Boxes** (`flatpak install flathub
org.gnome.Boxes`) uses the same KVM underneath with almost no settings:
choose an ISO, start. Its 3D switch is under the VM's **Preferences →
3D acceleration**. Its windows open on `vm` too.

## Troubleshooting

| Symptom | Fix |
|---|---|
| "Unable to connect to libvirt" | `sudo systemctl start virtqemud.socket`, then reconnect (File → Add connection → QEMU/KVM) |
| A password prompt after all | your user isn't in `wheel`: `sudo usermod -aG wheel $USER`, log out and in |
| Black screen in a niri guest, or Ghostty closes | 3D is off: Video → Virtio + 3D acceleration, Display → OpenGL |
| "OpenGL is not supported" when starting with 3D | the host's GPU driver lacks it: turn 3D off for that VM |
| Mod + key goes to the host instead of the VM | press **Mod + Scroll Lock** first |
| Wrong letters in the guest | the guest's layout isn't right-handed Dvorak (see above) |
| No network in the guest | `sudo virsh net-start default && sudo virsh net-autostart default` |
