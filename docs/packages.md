# Packages the kit adds

Everything One-Handed Fedora Remix installs on top of Fedora, and what it
removes. The ISO and `fedora-setup.sh` install exactly these lists; the
update package brings existing machines the same tools. **Generated** from
`fedora-setup.sh` and `niri-spin-base.ks` by
`tools/list-packages.py`; edit those, then run it (CI checks this page is
current).

On a running system: `rpm -q <package>` shows the installed version,
`flatpak list --app` the Flatpaks, `onehand-version` the kit version.

| What | How many |
|---|---|
| Fedora packages | 65 |
| From other repositories (COPR, vendors) | 11 |
| Downloaded releases (GitHub, JetBrains) | 5 |
| Flatpaks (Flathub) | 4 |
| Removed | 3 |

## Fedora packages

From Fedora's own repositories (and RPM Fusion). niri is the exception:
the newer build from the `duxlabs/dux-repo` COPR wins when that's enabled.

### Basics

Command-line tools.

| Package | What it's for |
|---|---|
| `git` | version control |
| `curl` | downloads from the command line |
| `wget` | downloads from the command line |
| `vim` | classic Vim (for quick edits as root) |
| `htop` | process viewer |
| `tmux` | terminal multiplexer |
| `zsh` | Z shell (fish is the default in Ghostty) |
| `fzf` | fuzzy finder (shell history, file pickers, window finder Mod + .) |
| `ripgrep` | fast text search (rg); LazyVim and yazi use it |
| `fd-find` | fast file search (fd); LazyVim and yazi use it |
| `bat` | cat with syntax colours |
| `gcc` | C compiler (native modules, Neovim plugins) |
| `make` | build tool |
| `python3-pip` | Python package installer |
| `nnn` | terminal file manager (small, always there) |

### yazi's previews

PDFs, video thumbnails, archives, images.

| Package | What it's for |
|---|---|
| `poppler-utils` | yazi: PDF previews |
| `ffmpegthumbnailer` | yazi: video thumbnails |
| `7zip` | yazi: archive previews; 7z archives |
| `ImageMagick` | yazi: image previews and conversions |

### Cloud and scripting

| Package | What it's for |
|---|---|
| `awscli2` | AWS CLI v2 (command: aws) |
| `jq` | used by this script and by niri's force-close shortcut |

### LazyVim (Neovim distribution)

Neovim plus what its plugins need.

| Package | What it's for |
|---|---|
| `neovim` | Neovim, with LazyVim on top |
| `tree-sitter-cli` | LazyVim: syntax parsers |
| `wl-clipboard` | clipboard from the command line (wl-copy, wl-paste) |
| `unzip` | LazyVim: plugin and tool downloads |
| `nodejs-npm` | LazyVim: language servers installed with npm |
| `helix` | Helix editor (command: hx), keys e h t d like LazyVim and Zed |

### niri desktop

| Package | What it's for |
|---|---|
| `niri` | compositor (25.11+ comes from duxlabs/dux-repo) |
| `xwayland-satellite` | lets X11-only apps run under niri |
| `greetd` | text login screen that starts niri |
| `tuigreet` | text login screen that starts niri |
| `xdg-desktop-portal-gnome` | screen sharing, file pickers |
| `xdg-desktop-portal-gtk` | screen sharing, file pickers |
| `wev` | shows which key niri sees (handy for debugging binds) |
| `tuned-ppd` | power, audio, media keys |
| `pavucontrol` | power, audio, media keys |
| `playerctl` | power, audio, media keys |
| `wireplumber` | power, audio, media keys |
| `fish` | Ghostty's shell: autosuggestions, z <folder> jumps |
| `zoxide` | Ghostty's shell: autosuggestions, z <folder> jumps |
| `ydotool` | lets Speech Note type dictated text into any window |
| `kbd-legacy` | the console keymap "dvorak-r" (text console, login, disk unlock) |
| `foot` | light terminal for the Welcome window (works in VMs too) |
| `NetworkManager-tui` | Wi-Fi from the Welcome window (nmtui) |
| `python3` | Python 3: headers for native modules, pipx, uv |
| `python3-devel` | Python 3: headers for native modules, pipx, uv |
| `pipx` | Python 3: headers for native modules, pipx, uv |
| `uv` | Python 3: headers for native modules, pipx, uv |
| `dotnet-sdk-10.0` | .NET 10 SDK (current LTS; command: dotnet) |
| `libXtst` | what JetBrains Toolbox/IDEs need |
| `libXi` | what JetBrains Toolbox/IDEs need |
| `libXrender` | what JetBrains Toolbox/IDEs need |
| `xcb-util-keysyms` | what JetBrains Toolbox/IDEs need |
| `gtk3` | what JetBrains Toolbox/IDEs need |

### Virtual machines

KVM + libvirt + virt-manager (3D in guests via virtio-GPU).

| Package | What it's for |
|---|---|
| `virt-manager` | virtual machines (window) |
| `virt-install` | virtual machines (command line) |
| `virt-viewer` | virtual machine screens |
| `qemu-kvm` | the virtual machine engine |
| `libvirt-daemon-kvm` | libvirt for KVM |
| `libvirt-daemon-config-network` | the VMs' default network |
| `edk2-ovmf` | UEFI firmware for VMs |
| `swtpm` | TPM for VMs (Windows 11 guests) |

### Everyday safety

| Package | What it's for |
|---|---|
| `swayidle` | idle detection for the break reminders (onehand-breaks) |
| `snapper` | Btrfs snapshots before/after every dnf change |
| `libdnf5-plugin-actions` | Btrfs snapshots before/after every dnf change |

## From other repositories

Repositories the kit enables, then these packages from them:

| Package | What it's for | From |
|---|---|---|
| `brave-browser` | Brave | Brave's repository |
| `brave-browser-nightly` | Brave Nightly | Brave's nightly repository |
| `google-chrome-stable` | Google Chrome | Google's Chrome repository |
| `ghostty` | the terminal (Mod + Enter), with fish | COPR scottames/ghostty |
| `claude-code` | Claude Code (command: claude) | Anthropic's Claude Code repository |
| `dms` | Dux Shell: bar, launcher, notifications, lock, wallpaper | COPR duxlabs/dms |
| `quickshell` | Dux Shell's toolkit | COPR duxlabs/dux-repo |
| `matugen` | Dux Shell: colours from the wallpaper | COPR duxlabs/dms |
| `keyd` | Right Alt: hold = Mod, tap = Polish letter | COPR alternateved/keyd |
| `lazygit` | git screen (Space g g in LazyVim, lg in fish) | COPR atim/lazygit |
| `yazi` | file manager, keys e h t d (y in fish) | COPR lihaohong/yazi |

## Downloaded releases

No Fedora or COPR package exists for these; the kit downloads the newest
release and checks it before installing.

| Tool | How |
|---|---|
| JetBrains Toolbox | JetBrains Toolbox App (installs and updates IntelliJ IDEA, PyCharm, Rider ...): latest release from JetBrains, checksum-verified, into /opt/jetbrains-toolbox. |
| Rune | Rune (rune.build): keyboard-driven IDE around your Helix; latest GitHub release into /opt/rune (checked against GitHub's SHA-256 for the file). |
| k9s | k9s (Kubernetes TUI): latest .rpm from its GitHub releases, checksum-verified. |
| lfk | lfk (Kubernetes TUI, file-manager style, keys set to e h t d): latest .rpm from its GitHub releases, checksum-verified. |
| Fresh | Install the Fresh editor from its latest GitHub release RPM, checksum-verified (it has no Fedora or COPR package). |

## Flatpaks (Flathub)

| App ID | What it is |
|---|---|
| `com.ktechpit.typingtutor` | Typing Tutor |
| `md.obsidian.Obsidian` | Obsidian |
| `dev.zed.Zed` | Zed editor (Flathub; command: flatpak run dev.zed.Zed) |
| `net.mkiol.SpeechNote` | Speech Note: offline dictation and read-aloud (Mod + c / a) |

## Repositories enabled

| Repository | For |
|---|---|
| RPM Fusion (free + nonfree) | codecs, drivers |
| Flathub | the Flatpaks above |
| brave-browser | https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo |
| brave-browser-nightly | https://brave-browser-rpm-nightly.s3.brave.com/brave-browser-nightly.repo |
| google-chrome | Google Chrome |
| Claude Code | Anthropic's dnf repository (channel: stable) |
| COPR `scottames/ghostty` | Ghostty (the COPR Ghostty's own install docs name) |
| COPR `duxlabs/dms` | Dux Shell (package dms) and companions (matugen ...) |
| COPR `duxlabs/dux-repo` | current niri + quickshell builds |
| COPR `alternateved/keyd` | keyd (not in Fedora's own repositories) |
| COPR `atim/lazygit` | lazygit, LazyVim's git screen (Space g g) |
| COPR `lihaohong/yazi` | yazi, the file manager (the COPR yazi's install docs name) |

## Removed

| What | Kind | Why |
|---|---|---|
| `firefox` | package | replaced by Brave, Brave Nightly and Chrome |
| `helium-bin` | package | Helium browser (no longer part of the setup) |
| `org.mozilla.firefox` | Flatpak | replaced by Brave, Brave Nightly and Chrome |
| `imput/helium` | COPR turned off | Helium browser's COPR (Helium is no longer part of the setup) |

## Only in the ISO

The live image's base, before the lists above are added (from
`niri-spin-base.ks`). An existing Fedora set up with `fedora-setup.sh`
already has its own base.

- **Base system: package groups and the kernel**: `@core`, `@standard`, `@hardware-support`, `@fonts`, `@multimedia`, `@networkmanager-submodules`, `kernel`, `kernel-modules`, `kernel-modules-extra`
- **Fedora's identity package**: `fedora-release-i3`, `fedora-release-identity-i3`, `fedora-release-identity-basic` (left out)  
  The installer's web interface (anaconda-webui) uses the light "slitherer" browser only on a spin identity, and needs Firefox otherwise. The i3 one only adds /usr/lib/os-release (which branding.ks rewrites to "One-Handed Fedora Remix") and Fedora's desktop service presets: no i3.
- **Live boot and the "Install to Hard Drive" installer**: `dracut-live`, `dracut-config-generic`, `dracut-config-rescue` (left out), `livesys-scripts`, `anaconda`, `anaconda-install-env-deps`, `anaconda-live`, `slitherer`, `@anaconda-tools`, `glibc-all-langpacks`
- **Bootloaders for the ISO (UEFI and BIOS)**: `grub2-efi-x64`, `grub2-efi-x64-cdboot`, `shim-x64`, `grub2-pc`, `grub2-pc-modules`, `grub2-tools-extra`, `efibootmgr`
