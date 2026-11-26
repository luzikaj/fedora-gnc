#!/usr/bin/env python3
"""Write docs/commands.md: every command the kit installs (files/bin/onehand-*
and the files/*/install-* helpers), from each script's own header comment,
with its keys (from the niri config) and the doc page that covers it.

    tools/list-commands.py           rewrite docs/commands.md
    tools/list-commands.py --check   exit 1 if docs/commands.md is out of date (CI)
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "commands.md"
NIRI = (ROOT / "files/niri/config.kdl").read_text()

# The doc page that explains each command in context.
DOC = {
    "onehand-breaks": "niri.md#break-reminders",
    "onehand-dojo": "dojo.md", "onehand-dojo-solo": "dojo.md",
    "onehand-keyboard-check": "keyboard.md",
    "onehand-monitors": "niri.md", "onehand-second-screen": "niri.md",
    "onehand-snapshots": "snapshots.md",
    "onehand-version": "../BUILDING.md",
    "onehand-welcome": "welcome.md",
    "onehand-windows": "niri.md#finding-a-window",
    "install-rune": "rune.md", "install-lfk": "lfk.md",
}
# What needs root (sudo), and when.
ROOT_NOTE = {
    "onehand-keyboard-check": "`--fix` asks for sudo; `--firstboot` runs as root (service)",
    "onehand-snapshots": "`setup`, `undo` (sudo); `list` / `files` work as you (wheel group)",
    "install-jetbrains-toolbox": "yes (run with sudo)",
    "install-lfk": "yes (run with sudo)",
    "install-rune": "yes (run with sudo)",
}
# Started by themselves (not by you).
AUTO = {
    "onehand-breaks": "`daemon` at every niri / Mango login",
    "onehand-monitors": "`--login` at every niri login",
    "onehand-version": "`--notify` once a day after login",
    "onehand-keyboard-check": "`--firstboot` once after installing (onehand-keyboard-firstboot.service)",
    "onehand-snapshots": "`setup` once (onehand-snapshots-setup.service); `dnf-pre` / `dnf-post` by dnf",
    "onehand-welcome": "on the live USB and at the first login",
}
# One line for the table (the full help is in each section).
SUMMARY = {
    "onehand-breaks": "break reminders for the working hand; pause, status, a break now",
    "onehand-dojo": "hands-on niri lessons, checked live (two screens; one-screen course by itself)",
    "onehand-dojo-solo": "the one-screen (laptop) niri lessons",
    "onehand-keyboard-check": "is right-handed Dvorak set everywhere? `--fix` repairs it",
    "onehand-monitors": "screen layout for niri (main / second screen, workspaces)",
    "onehand-second-screen": "send a window to the second screen and back; sleep / wake it",
    "onehand-snapshots": "Btrfs snapshots: list, undo an update, get back a file",
    "onehand-terminal": "Ghostty, or foot when Ghostty can't start (VMs)",
    "onehand-version": "installed kit version; is a newer one available?",
    "onehand-welcome": "the Welcome window: install, first steps, keys, updates",
    "onehand-windows": "find any open window by typing, jump to it",
    "install-jetbrains-toolbox": "install / update JetBrains Toolbox (checksum-verified)",
    "install-lfk": "install / update lfk (checksum-verified)",
    "install-rune": "install / update Rune (checked against GitHub's SHA-256)",
}
INSTALLED_AT = {
    "install-jetbrains-toolbox": "the kit's `files/jetbrains/` (not on the PATH)",
    "install-lfk": "the kit's `files/lfk/` (not on the PATH)",
    "install-rune": "the kit's `files/rune/` (not on the PATH)",
}


def header(path):
    """The comment block at the top of a script, without '#' and decoration."""
    lines = path.read_text().splitlines()[1:]
    out = []
    for l in lines:
        if not l.startswith("#"):
            break
        t = l[1:]
        t = t[1:] if t.startswith(" ") else t
        if re.fullmatch(r"=+", t.strip()):
            continue
        out.append(t.rstrip())
    while out and not out[0].strip():
        out.pop(0)
    while out and not out[-1].strip():
        out.pop()
    return out


def keys_for(name):
    keys = []
    for m in re.finditer(r'^\s*(\S+)[^\n{]*\{\s*spawn "%s"([^;]*);' % re.escape(name), NIRI, re.M):
        args = " ".join(a.strip('"') for a in m.group(2).split())
        k = m.group(1).replace("Mod+", "Mod + ").replace("period", ".").replace("comma", ",") \
                      .replace("Return", "Enter")
        keys.append(f"{k}" + (f" (`{args}`)" if args else ""))
    return ", ".join(keys)


def summary(name, head):
    first = head[0] if head else ""
    first = re.sub(r"^%s(\s*\[[^\]]*\])?:?\s*" % re.escape(name), "", first).strip()
    if not first and len(head) > 2:
        first = head[2].strip()
    return first.rstrip(".")


def build():
    scripts = sorted((ROOT / "files/bin").glob("onehand-*")) + sorted((ROOT / "files").glob("*/install-*"))
    p = ["# Commands",
         "",
         "Every command One-Handed Fedora Remix adds. The `onehand-*` commands are in",
         "`/usr/local/bin`, so they work in any terminal; the `install-*` helpers stay in",
         "the kit's folder. Each section below is the command's own help text (the",
         "comment at the top of the script). **Generated** by `tools/list-commands.py`;",
         "CI checks this page is current.",
         "",
         "| Command | What it does | Key | Needs sudo | Runs by itself |",
         "|---|---|---|---|---|"]
    sections = []
    for path in scripts:
        name = path.name
        head = header(path)
        doc = DOC.get(name)
        link = f"[`{name}`](#{name})"
        p.append("| " + " | ".join([
            link,
            SUMMARY.get(name) or summary(name, head).replace("|", "\\|"),
            keys_for(name),
            ROOT_NOTE.get(name, "no"),
            AUTO.get(name, ""),
        ]) + " |")
        where = INSTALLED_AT.get(name, f"`/usr/local/bin/{name}`")
        sec = [f"## {name}", "", f"Installed as {where}."
               + (f" More in [{doc.split('#')[0]}]({doc})." if doc else ""), ""]
        if keys_for(name):
            sec += [f"Key: {keys_for(name)}.", ""]
        sec += ["```", *head, "```", ""]
        sections += sec
    p += [""]
    return "\n".join(p + sections)


if __name__ == "__main__":
    text = build()
    if "--check" in sys.argv:
        if not OUT.exists() or OUT.read_text() != text:
            print("docs/commands.md is out of date: run tools/list-commands.py", file=sys.stderr)
            sys.exit(1)
        print("docs/commands.md is current")
    else:
        OUT.write_text(text)
        print(f"Wrote {OUT.relative_to(ROOT)}")
