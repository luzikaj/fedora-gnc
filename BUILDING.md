# Building One-Handed Fedora Remix

How to turn this repository into a bootable installer ISO, test it and install
it, plus how to update machines that are already set up. Every step here has
been done end to end; the timings are from a real build in a VirtualBox VM.

| You want to… | Go to |
|---|---|
| make a new installer ISO | [1–5](#1-prepare-a-build-machine) |
| test the ISO in a VM | [6](#6-test-it-in-a-vm) |
| install on a PC or laptop | [7](#7-install-on-real-hardware) |
| update a machine that's already set up | [8](#8-update-machines-that-are-already-set-up) |
| set up an existing Fedora/Ultramarine without reinstalling | [9](#9-set-up-an-existing-machine-without-the-iso) |
| fix a failed build | [Troubleshooting](#troubleshooting) |

---

## How the build works

```
fedora-setup.sh (package lists)  ─┐
files/ (configs, scripts)          ├─► build-spin.sh ─► kickstart ─► livemedia-creator ─► ISO
niri-spin-base.ks, branding.ks   ─┘                     (≈450 lines)   (Fedora's installer,
                                                                        run on this machine)
```

- `build-spin.sh` reads the package lists from `fedora-setup.sh` and the files
  from `files/`, and writes one kickstart (`build/onehand-spin.ks`).
- **livemedia-creator** (Fedora's own tool for live images) runs Fedora's
  installer to install that system into a disk image, then compresses it into a
  live ISO.
- Your configs and big files (the JetBrains Toolbox) are copied into the image
  straight from the build folder; they're never written into the kickstart.

**The ISO's Fedora release is the build machine's release.** Build on Fedora 45
to get One-Handed Fedora Remix 45. Building another release from the same machine isn't
supported by Fedora's tools.

---

## 1. Prepare a build machine

A Fedora installation of the release you want to build: a real machine or a
VM. Building in a VM keeps your own system untouched, and that's how it's been
done so far.

| | Minimum | Recommended |
|---|---|---|
| OS | Fedora (the release to build) | a fresh Fedora VM, fully updated |
| CPUs | 2 | 4+ (compression is CPU-bound) |
| RAM | 4 GB | **8 GB** (4 GB works but swaps and is much slower) |
| Free disk | 30 GB | 40 GB+ (VM disk of 90 GB has been comfortable) |
| Network | needed | wired or fast Wi-Fi: ≈ 3–4 GB of packages are downloaded |
| 3D graphics | not needed for building | |

On Windows, close other VMs first; VirtualBox on Windows' hypervisor fails to
start a VM when memory runs out (`WHvSetupPartition failed: ERROR_NO_SYSTEM_RESOURCES`).

Bring the system up to date before building:

```
sudo dnf upgrade --refresh -y && sudo reboot
```

## 2. Get the repository

```
git clone git@github.com:YOUR-NAME/one-handed-fedora-remix.git
cd one-handed-fedora-remix
```

(Or unpack `onehanded-remix-repo.tar.gz`.) A folder path **without spaces** is best.
If it has spaces, the build automatically works in `~/onehand-spin-build`
instead.

Note the commit you build from, so you can find it again later:

```
git log -1 --oneline
```

## 3. Decide what goes in (optional)

Everything is read from the repository; change it there before building.

| To change | Edit |
|---|---|
| apps, repositories, Flatpaks, removed packages | the lists at the top of `fedora-setup.sh` |
| configs (keys, niri, editors, terminal …) | the files in `files/` |
| language, time zone, live-image size | `niri-spin-base.ks` |
| name in the system, installer, boot menu | `PRODUCT="…" ./build-spin.sh` (default `One-Handed Fedora Remix`) |
| ISO file name / disc label | `NAME=… ./build-spin.sh` (default `OneHanded-Fedora-Remix`, no spaces) |
| free-space limit | `MIN_FREE_GB=… ./build-spin.sh` (default 28) |

Commit changes before building, so the ISO matches a commit.

## 4. Check everything first (a few minutes)

```
./build-spin.sh --generate-only
```

This builds nothing big, but checks everything the long build depends on.
The first run takes ≈ 10–15 minutes and later runs are faster.

1. Installs the build tools (lorax, livemedia-creator, pykickstart), the first
   time only.
2. Sets up every third-party repository and checks it has packages for this
   Fedora release.
3. Downloads the latest k9s, lfk, Fresh and JetBrains Toolbox, and checks their checksums.
4. Writes the kickstart and validates it.
5. Checks every package **exists**.
6. Checks all packages **install together** (dnf's dependency solver, nothing
   installed).

It ends with:

```
==> The package set resolves cleanly
==> Kickstart ready: …/build/onehand-spin.ks
```

If it stops, the message says what's wrong: see
[Troubleshooting](#troubleshooting). Fix it before starting the long build.

## 5. Build the ISO (≈ 1–1½ hours)

```
./build-spin.sh
```

It repeats the checks, cleans up leftovers from earlier builds, checks free
space, sets SELinux to permissive for the build (it's restored afterwards,
even on failure), and runs livemedia-creator. Leave the terminal alone: long
stretches print nothing.

What you'll see, with times from a 4-CPU / 4 GB VM:

| Stage | Last lines on screen | Took |
|---|---|---|
| installer starts | `anaconda 45.x for One-Handed Fedora Remix 45 started` | 1 min |
| packages download and install | progress lines, then `Konfigurowanie zainstalowanego systemu` / `Configuring installed system` | ≈ 35 min |
| boot image | `Tworzenie initramfs` / `Creating initramfs` | ≈ 3 min |
| your setup steps | (configs, Toolbox, keyboard check, branding) | 1 min |
| image installed | `Disk Image install successful` | |
| **compression** | `Creating a squashfs only runtime` (silent, CPU at 100 %) | **≈ 30 min** |
| live boot image | `Rebuilding initrds` | ≈ 5 min |
| done | `Done: …/out/OneHanded-Fedora-Remix-45-<date>-<time>.iso` | |

The ISO ends up in **`out/`** (about 3.4 GB). To see whether a quiet stage is
still working: `top` (look for `mksquashfs` or `dnf`), or
`sudo du -sh /var/tmp/lmc-work-*` twice a minute apart.

Then:

```
cd out
sha256sum OneHanded-Fedora-Remix-45-*.iso > OneHanded-Fedora-Remix-45.sha256    # note the checksum
git tag iso-45-$(date +%Y%m%d) && git push --tags       # mark the commit it came from
```

## 6. Test it in a VM

### Test it in virt-manager (recommended on Linux)

On a One-Handed Fedora Remix (or any Fedora) machine, virt-manager gives the test VM real
3D graphics, so niri and Ghostty work exactly as on hardware:

```
virt-install --name remix-test --memory 6144 --vcpus 4 --disk size=40 \
  --cdrom out/OneHanded-Fedora-Remix-45-*.iso --osinfo fedora-unknown --boot uefi \
  --video model.type=virtio,model.acceleration.accel3d=yes \
  --graphics spice,listen=none,gl.enable=yes
```

Or in virt-manager: new VM from the ISO, "Customize configuration before
install", then Firmware **UEFI**, Video **Virtio + 3D acceleration**, Display
Spice **Listen: None + OpenGL**. Details: [docs/virtualization.md](docs/virtualization.md).
Remove the test VM afterwards with `virsh undefine remix-test --nvram --remove-all-storage`.

### Test it in VirtualBox (on Windows)

1. **Copy the ISO out of the build VM** (e.g. through a shared folder) and
   **check the copy**. A cut-short copy has happened before. In PowerShell:
   ```
   Get-FileHash .\OneHanded-Fedora-Remix-45-*.iso -Algorithm SHA256
   ```
   The hash must equal the `sha256sum` from the build VM.
2. **Create a VM:** type Fedora (64-bit), 4–8 GB RAM, 2–4 CPUs, 60 GB disk,
   **EFI on**. "Skip unattended installation" may be greyed out; that's fine.
3. **Before the first start:** Settings → switch to **Expert** → Display:
   graphics controller **VMSVGA**, **3D acceleration on**, maximum video memory.
   (niri needs it. If VirtualBox can't offer 3D, test on real hardware instead.)
4. **Boot.** The live session logs into niri and the **Welcome** window opens:
   - `h` / `t` or the arrows move, Enter chooses, Esc goes back.
   - Choose **Install One-Handed Fedora Remix on this computer**.
5. In VirtualBox, **Ghostty doesn't start** (no GPU). Mod + Enter opens
   **foot** instead.

## 7. Install on real hardware

1. **Write the ISO to a USB stick** (8 GB+; it will be erased):
   - **Windows:** Rufus. Pick the stick and the ISO, click START, and when asked,
     choose **DD image mode**. Afterwards Windows shows a "RAW" partition and
     offers to format it: **cancel**.
   - **Linux:** Fedora Media Writer, or
     `sudo dd if=OneHanded-Fedora-Remix-45-….iso of=/dev/sdX bs=4M status=progress oflag=sync`
     (sdX = the stick; check with `lsblk`).
2. **Boot from the stick:** boot menu key at power-on (often F8, F11 or F12).
   Secure Boot can stay on.
3. **Try first if you like:** the live session changes nothing on the disk.
4. **Install** from the Welcome window, or the launcher (Mod + ') → *Install
   One-Handed Fedora Remix*. In the installer:
   - keep the keyboard as it is (right-handed Dvorak)
   - "use the whole disk" **erases** it; choose custom partitioning to keep data
   - create your user with **administrator** ticked
   - passwords and disk passphrase: **plain characters only**, no ą ę ś, because
     the login screen and the disk-unlock prompt have no Polish letters
5. **Restart** and remove the stick. Log in on the text screen; niri starts.
6. **The Welcome checklist** opens at each login until you choose *All done*:
   - Wi-Fi
   - Flathub apps
   - the Polish dictation model
   - screens
   - the keyboard check
   - updates

## 8. Update machines that are already set up

No reinstall needed. From the repository, on the machine to update:

```
git pull
tools/make-update-package.sh
tar xzf dist/onehand-update.tar.gz -C /tmp
/tmp/onehand-update/update.sh --dry-run    # what it would do
/tmp/onehand-update/update.sh
```

Then log out and in. Replaced files are kept as `.bak.<date>`, and a niri
config that doesn't validate is rolled back. It also renames the system to
"One-Handed Fedora Remix" (step 8 of the script). On Ultramarine, see
`update/README.txt` for how to undo that if you prefer the Ultramarine name.

## 9. Set up an existing machine without the ISO

On a running Fedora or Ultramarine (any desktop), as your normal user:

```
./fedora-setup.sh --dry-run
./fedora-setup.sh
```

This installs the same apps and configs on top of what's there. An existing
login screen (GDM, SDDM) is kept: choose **niri** there.

---

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `--generate-only` hangs at **"Checking kickstart file"** | Something large was written into the kickstart. Big files belong in `$WORK/bigfiles` (see `make_payload` in `build-spin.sh`); the kickstart should be ≈ 450 lines. |
| **"The packages don't install together"** | dnf's explanation is printed above it. Typically a package needs something another one excludes; adjust the lists in `fedora-setup.sh` or `niri-spin-base.ks`. |
| **"No Fedora NN repository at …"** | A COPR or vendor repo isn't built for that release yet. Wait, drop the package, or build on the release before. |
| **"These packages aren't available for Fedora NN"** | A package was renamed or dropped in that release; fix the list in `fedora-setup.sh`. |
| **"The installer stopped"** | The error lines from all installer logs are printed above it. Full logs: `build/installer-logs/` and `build/livemedia-creator.log`. |
| **"Only N GB free"** | Delete old `out/` folders, or enlarge the VM disk (`MIN_FREE_GB` lowers the limit at your own risk). |
| `anaconda … pre-release` in the log | Older kits; the build now passes `--isfinal`. |
| `Calling import-environment without a list…` on the VM screen | Harmless warning. If the screen stays black, the VM has no 3D graphics (see step 6). |
| Installer says **"root Wayland socket not found"** | It was started with `sudo`. Start it as the desktop user: `liveinst` (the Welcome window does this). |
| **Ghostty doesn't start** | No GPU (VMs). Mod + Enter falls back to foot. |
| **Typed text comes out with stray capitals** | A sticky Shift tap was still active; it's forgotten after 1 s. Wait a moment, or press Backspace and retype. |
| **ISO doesn't boot / hash differs** | The copy was incomplete. Copy again, compare `sha256sum` / `Get-FileHash`, write with DD mode. |
| **Keyboard is QWERTY** on the console or login screen | `onehand-keyboard-check --fix` |

---

## Release checklist

1. [ ] Changes committed, `CHANGELOG.md` updated.
2. [ ] `./build-spin.sh --generate-only` ends with "resolves cleanly".
3. [ ] `./build-spin.sh` ends with `Done: …iso`.
4. [ ] Checksum noted; tag pushed (`iso-<release>-<date>`).
5. [ ] Live session boots, Welcome window opens, the installer starts.
6. [ ] Installed system: login, niri, Welcome checklist, `onehand-keyboard-check` all ✓.
7. [ ] Set-up machines updated with `tools/make-update-package.sh`.
