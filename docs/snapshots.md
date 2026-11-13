# Snapshots: undo a bad update or a deleted file

The system disk uses **Btrfs**, so snapshots are cheap: only what changes
afterwards takes space. **snapper** takes them by itself:

| What | When | Kept |
|---|---|---|
| The system (`/`) | **before and after every dnf install, update or removal** | the last 10 |
| Your home folder (`/home`) | **every hour** | the last 6 hours, 7 days and 2 weeks |

VM disk images (`/var/lib/libvirt/images`) sit in their own subvolume, so
system snapshots don't keep old copies of big VM disks.

It's set up once by itself, on the first boot after installing (or by the
update package). Check it with `onehand-snapshots list`.

## Commands

| Command | What it does |
|---|---|
| `onehand-snapshots list` | all snapshots: system (pre/post pairs per dnf run) and home (hourly) |
| `onehand-snapshots changes N` | which files the dnf run with pre-snapshot **N** changed |
| `onehand-snapshots undo N` | put the system's files back as they were **before** dnf run N (asks first; then restart) |
| `onehand-snapshots files PATH` | the older copies of a file or folder in your home, with dates |
| `onehand-snapshots files PATH K` | copy the one from home snapshot **K** next to the original (`name.from-snapshot-K`) |

## A bad update

1. First try dnf's own undo: `sudo dnf history undo last`.
2. If the system is still in a mess: `onehand-snapshots list`, find the
   **pre** snapshot of that update (its description is the dnf command), then
   `onehand-snapshots undo N` and restart.

If the desktop doesn't start at all, log in on the text console
(Ctrl + Alt + F3) and run the same commands there.

## A deleted or broken file in your home

```
onehand-snapshots files ~/Projects/app/main.py
onehand-snapshots files ~/Projects/app/main.py 42
```

The second line copies the version from snapshot 42 to
`main.py.from-snapshot-42`; nothing is overwritten.

## Notes

- Snapshots are **not a backup**: they live on the same disk. Keep a copy of
  important work elsewhere too (Git remote, cloud, external disk).
- There's no "boot into a snapshot" menu (that needs grub-btrfs, which Fedora
  doesn't ship); `undo` plus a restart does the same job.
- The limits are in `/etc/snapper/configs/root` and `/etc/snapper/configs/home`
  (`sudo snapper -c home set-config TIMELINE_LIMIT_DAILY=14`, for example).
- On a machine whose disk isn't Btrfs, nothing is set up and nothing changes.
