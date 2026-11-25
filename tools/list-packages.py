#!/usr/bin/env python3
"""Write docs/packages.md: every package the kit adds (or removes), read from
fedora-setup.sh (the source of truth for setup, ISO and update) and
niri-spin-base.ks (what only the ISO adds).

    tools/list-packages.py           rewrite docs/packages.md
    tools/list-packages.py --check   exit 1 if docs/packages.md is out of date (CI)
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SETUP = (ROOT / "fedora-setup.sh").read_text()
KS = (ROOT / "niri-spin-base.ks").read_text()
OUT = ROOT / "docs" / "packages.md"
CONFIG = SETUP.split("#  END OF CONFIGURATION")[0]

# Short descriptions for packages whose line in fedora-setup.sh has no comment.
DESCRIBE = {
    "git": "version control",
    "curl": "downloads from the command line",
    "wget": "downloads from the command line",
    "vim": "classic Vim (for quick edits as root)",
    "htop": "process viewer",
    "tmux": "terminal multiplexer",
    "zsh": "Z shell (fish is the default in Ghostty)",
    "fzf": "fuzzy finder (shell history, file pickers, window finder Mod + .)",
    "ripgrep": "fast text search (rg); LazyVim and yazi use it",
    "fd-find": "fast file search (fd); LazyVim and yazi use it",
    "bat": "cat with syntax colours",
    "gcc": "C compiler (native modules, Neovim plugins)",
    "make": "build tool",
    "python3-pip": "Python package installer",
    "poppler-utils": "yazi: PDF previews",
    "ffmpegthumbnailer": "yazi: video thumbnails",
    "7zip": "yazi: archive previews; 7z archives",
    "ImageMagick": "yazi: image previews and conversions",
    "neovim": "Neovim, with LazyVim on top",
    "tree-sitter-cli": "LazyVim: syntax parsers",
    "wl-clipboard": "clipboard from the command line (wl-copy, wl-paste)",
    "unzip": "LazyVim: plugin and tool downloads",
    "nodejs-npm": "LazyVim: language servers installed with npm",
    "greetd": "login manager",
    "tuigreet": "the text login screen greetd shows",
    "xdg-desktop-portal-gnome": "screen sharing, file pickers",
    "xdg-desktop-portal-gtk": "file pickers and settings for GTK apps",
    "tuned-ppd": "power profiles (balanced, power saver, performance)",
    "pavucontrol": "audio devices (Mod + F11)",
    "playerctl": "media keys",
    "wireplumber": "audio session manager",
    "fish": "the shell in Ghostty: autosuggestions",
    "zoxide": "z <folder> jumps",
    "python3": "Python 3",
    "python3-devel": "Python headers for native modules",
    "pipx": "Python apps in their own environments",
    "uv": "fast Python package and project manager",
    "libXtst": "JetBrains Toolbox / IDEs", "libXi": "JetBrains Toolbox / IDEs",
    "libXrender": "JetBrains Toolbox / IDEs", "xcb-util-keysyms": "JetBrains Toolbox / IDEs",
    "gtk3": "JetBrains Toolbox / IDEs",
    "virt-manager": "virtual machines (window)", "virt-install": "virtual machines (command line)",
    "virt-viewer": "virtual machine screens", "qemu-kvm": "the virtual machine engine",
    "libvirt-daemon-kvm": "libvirt for KVM", "libvirt-daemon-config-network": "the VMs' default network",
    "edk2-ovmf": "UEFI firmware for VMs", "swtpm": "TPM for VMs (Windows 11 guests)",
    "snapper": "Btrfs snapshots (onehand-snapshots)",
    "xdg-desktop-portal-wlr": "Mango: screen sharing",
    "slurp": "Mango: picks the screen or area to share",
    "libdnf5-plugin-actions": "snapshot before/after every dnf change",
    "brave-browser": "Brave", "brave-browser-nightly": "Brave Nightly",
    "google-chrome-stable": "Google Chrome",
    "dms": "Dux Shell: bar, launcher, notifications, lock, wallpaper",
    "quickshell": "Dux Shell's toolkit", "matugen": "Dux Shell: colours from the wallpaper",
    "ghostty": "the terminal (Mod + Enter), with fish",
    "lazygit": "git screen (Space g g in LazyVim, lg in fish)",
    "yazi": "file manager, keys e h t d (y in fish)",
    # removed / COPRs without a comment
    "firefox": "replaced by Brave, Brave Nightly and Chrome",
    "org.mozilla.firefox": "replaced by Brave, Brave Nightly and Chrome",
    "imput/helium": "Helium browser's COPR (Helium is no longer part of the setup)",
    "scottames/ghostty": "Ghostty (the COPR Ghostty's own install docs name)",
}
# Shared or vague comments in fedora-setup.sh that the entries above replace.
PREFER_OWN = {"quickshell", "matugen", "ghostty", "lazygit", "yazi"}
# Where packages outside Fedora come from.
SOURCE = {
    "brave-browser": "Brave's repository", "brave-browser-nightly": "Brave's nightly repository",
    "google-chrome-stable": "Google's Chrome repository",
    "ghostty": "COPR scottames/ghostty", "claude-code": "Anthropic's Claude Code repository",
    "dms": "COPR duxlabs/dms", "quickshell": "COPR duxlabs/dux-repo", "matugen": "COPR duxlabs/dms",
    "keyd": "COPR alternateved/keyd", "lazygit": "COPR atim/lazygit", "yazi": "COPR lihaohong/yazi",
    "niri": "COPR duxlabs/dux-repo (newer than Fedora's)",
    "mangowm": "Terra (Fyra Labs), limited to this package",
}


def bash_array(name, text=CONFIG):
    """[(group_comment, package, inline_comment)] for NAME=( ... ), commented-out lines skipped."""
    m = re.search(r"^%s=\(\n(.*?)^\)" % name, text, re.S | re.M)
    if not m:
        return []
    out, group = [], ""
    for line in m.group(1).splitlines():
        s = line.strip()
        if not s:
            continue
        if s.startswith("#"):
            body = s.lstrip("#").strip()
            # "# code" style lines are disabled entries, not headings
            if body and not re.fullmatch(r"[\w.@/+-]+", body) and not re.match(r'"[^"]*\|', body):
                group = body
            continue
        code, _, comment = s.partition("#")
        words = code.split()
        comment = comment.strip()
        for w in words:
            out.append((group, w.strip('"'), comment if len(words) == 1 else ""))
        # a comment on a multi-package line describes them all
        if len(words) > 1 and comment:
            out[-len(words):] = [(g, p, comment) for g, p, _ in out[-len(words):]]
    return out


def flag(name):
    m = re.search(r"^%s=(\w+)" % name, CONFIG, re.M)
    return bool(m and m.group(1) == "true")


def comment_above(name):
    """The comment block right above NAME= in the configuration."""
    lines = CONFIG.split("\n")
    for i, l in enumerate(lines):
        if l.startswith(name + "="):
            j, buf = i - 1, []
            while j >= 0 and lines[j].startswith("#"):
                buf.insert(0, lines[j].lstrip("#").strip())
                j -= 1
            return " ".join(buf)
    return ""


def describe(pkg, comment):
    if pkg in PREFER_OWN or not comment:
        return DESCRIBE.get(pkg, comment)
    return comment


def md_escape(s):
    return s.replace("|", "\\|")


def table(rows, head):
    out = ["| " + " | ".join(head) + " |", "|" + "---|" * len(head)]
    out += ["| " + " | ".join(md_escape(c) for c in r) + " |" for r in rows]
    return "\n".join(out)


def build():
    dnf = bash_array("DNF_PACKAGES")
    extra = bash_array("EXTRA_REPO_PACKAGES")
    flat = bash_array("FLATPAKS")
    coprs = bash_array("COPR_REPOS")
    repos = bash_array("EXTRA_REPOS")
    remove = bash_array("DNF_REMOVE")
    fremove = bash_array("FLATPAK_REMOVE")
    cremove = bash_array("COPR_REMOVE")

    p = ["# Packages the kit adds",
         "",
         "Everything One-Handed Fedora Remix installs on top of Fedora, and what it",
         "removes. The ISO and `fedora-setup.sh` install exactly these lists; the",
         "update package brings existing machines the same tools. **Generated** from",
         "`fedora-setup.sh` and `niri-spin-base.ks` by",
         "`tools/list-packages.py`; edit those, then run it (CI checks this page is",
         "current).",
         "",
         "On a running system: `rpm -q <package>` shows the installed version,",
         "`flatpak list --app` the Flatpaks, `onehand-version` the kit version.",
         ""]
    n_tools = sum(flag(f) for f in ("INSTALL_JETBRAINS_TOOLBOX", "INSTALL_RUNE", "INSTALL_K9S",
                                    "INSTALL_LFK", "INSTALL_FRESH_EDITOR"))
    p += [table([["Fedora packages", str(len(dnf))],
                 ["From other repositories (COPR, vendors)", str(len(extra) + flag("INSTALL_MANGO"))],
                 ["Downloaded releases (GitHub, JetBrains)", str(n_tools)],
                 ["Flatpaks (Flathub)", str(len(flat))],
                 ["Removed", str(len(remove) + len(fremove))]],
                ["What", "How many"]), ""]

    # ---- Fedora packages, grouped by their heading comment
    p += ["## Fedora packages", "",
          "From Fedora's own repositories (and RPM Fusion). niri is the exception:",
          "the newer build from the `duxlabs/dux-repo` COPR wins when that's enabled.", ""]
    groups = {}
    for group, pkg, comment in dnf:
        groups.setdefault(group or "Basics", []).append([f"`{pkg}`", describe(pkg, comment)])
    for group, rows in groups.items():
        head, _, rest = group.partition(":")
        p += [f"### {head.strip()}", ""]
        if rest.strip():
            p += [rest.strip()[0].upper() + rest.strip()[1:] + ".", ""]
        p += [table(rows, ["Package", "What it's for"]), ""]

    # ---- other repositories
    p += ["## From other repositories", "",
          "Repositories the kit enables, then these packages from them:", ""]
    rows = [[f"`{pkg}`", describe(pkg, comment), SOURCE.get(pkg, group or "")]
            for group, pkg, comment in extra]
    if flag("INSTALL_MANGO"):
        rows.append(["`mangowm`", "MangoWM, the second session (login screen: F3 -> Mango)", SOURCE["mangowm"]])
    p += [table(rows, ["Package", "What it's for", "From"]), ""]

    # ---- downloaded releases
    p += ["## Downloaded releases", "",
          "No Fedora or COPR package exists for these; the kit downloads the newest",
          "release and checks it before installing.", ""]
    rows = []
    for f, name in (("INSTALL_JETBRAINS_TOOLBOX", "JetBrains Toolbox"), ("INSTALL_RUNE", "Rune"),
                    ("INSTALL_K9S", "k9s"), ("INSTALL_LFK", "lfk"), ("INSTALL_FRESH_EDITOR", "Fresh")):
        if flag(f):
            rows.append([name, comment_above(f)])
    p += [table(rows, ["Tool", "How"]), ""]

    # ---- Flatpaks
    p += ["## Flatpaks (Flathub)", ""]
    p += [table([[f"`{pkg}`", comment] for _, pkg, comment in flat], ["App ID", "What it is"]), ""]

    # ---- repositories
    p += ["## Repositories enabled", ""]
    rows = []
    if flag("ENABLE_RPMFUSION"):
        rows.append(["RPM Fusion (free + nonfree)", "codecs, drivers"])
    if flag("ENABLE_FLATHUB"):
        rows.append(["Flathub", "the Flatpaks above"])
    for _, r, _c in repos:
        name, _, url = r.partition("|")
        rows.append([name, url])
    if flag("ENABLE_GOOGLE_CHROME_REPO"):
        rows.append(["google-chrome", "Google Chrome"])
    if flag("INSTALL_MANGO"):
        rows.append(["Terra", "MangoWM only (`includepkgs=mangowm`); left as is where Terra is already set up (Ultramarine)"])
    if flag("ENABLE_CLAUDE_CODE_REPO"):
        rows.append(["Claude Code", "Anthropic's dnf repository (channel: "
                     + (re.search(r"^CLAUDE_CODE_CHANNEL=(\w+)", CONFIG, re.M) or [None, "stable"])[1] + ")"])
    for _, c, comment in coprs:
        rows.append([f"COPR `{c}`", describe(c, comment)])
    p += [table(rows, ["Repository", "For"]), ""]

    # ---- removed
    p += ["## Removed", ""]
    rows = [[f"`{pkg}`", "package", describe(pkg, comment)] for _, pkg, comment in remove]
    rows += [[f"`{pkg}`", "Flatpak", describe(pkg, comment)] for _, pkg, comment in fremove]
    rows += [[f"`{pkg}`", "COPR turned off", describe(pkg, comment)] for _, pkg, comment in cremove]
    p += [table(rows, ["What", "Kind", "Why"]), ""]

    # ---- ISO only: one line per comment block in %packages
    m = re.search(r"^%packages\n(.*?)^%end", KS, re.S | re.M)
    blocks, note, pk = [], "", []
    def flush():
        if pk:
            blocks.append((note or "Base system: package groups and the kernel", list(pk)))
    for line in (m.group(1) if m else "").splitlines() + [""]:
        s2 = line.strip()
        if not s2:
            flush(); note, pk = "", []
            continue
        if s2.startswith("#"):
            if "@APPS@" in s2 or "inserted here" in s2 or s2.lstrip("# ").startswith("("):
                continue
            note = (note + " " + s2.lstrip("#").strip()).strip()
            continue
        pk.append(f"`{s2[1:]}` (left out)" if s2.startswith("-") else f"`{s2}`")
    p += ["## Only in the ISO", "",
          "The live image's base, before the lists above are added (from",
          "`niri-spin-base.ks`). An existing Fedora set up with `fedora-setup.sh`",
          "already has its own base.", ""]
    for note, pk in blocks:
        first = re.split(r"(?<=\.)\s", note, maxsplit=1)
        p += [f"- **{first[0].rstrip('.')}**: " + ", ".join(pk)
              + (f"  \n  {first[1]}" if len(first) > 1 else "")]
    p += [""]
    return "\n".join(p)


if __name__ == "__main__":
    text = build()
    if "--check" in sys.argv:
        if not OUT.exists() or OUT.read_text() != text:
            print("docs/packages.md is out of date: run tools/list-packages.py", file=sys.stderr)
            sys.exit(1)
        print("docs/packages.md is current")
    else:
        OUT.write_text(text)
        print(f"Wrote {OUT.relative_to(ROOT)}")
