import html
def k(x, cls=""):  # a key cap
    return f'<kbd class="{cls}">{html.escape(x)}</kbd>'
def niri(*keys):  # Mod + keys
    return k("Mod", "mod") + "".join(k(x) for x in keys)
def keys(*ks):
    return "".join(k(x) for x in ks)
D = '<i class="dot"></i>'   # custom one-handed key marker

niri_cards = [
 ("Basics", [(niri("'"), "Launcher"), (niri("Enter"), "Terminal"), (niri("Bksp"), "Close"),
             (niri("-"), "Overview"), (niri("Ins"), "All shortcuts"), (niri("Del"), "Lock"),
             (niri("."), "Find window")]),
 ("Focus · Move", [(niri("e","d"), "Focus column ← →"), (niri("h","t"), "Focus window ↓ ↑"),
             (niri("o","u"), "Move column ← →"), (niri("r","s"), "Move window ↓ ↑"),
             (niri(";","="), "Stack / unstack"), (niri("k"), "Floating"), (niri("j"), "Focus float ↔ tiled")]),
 ("Size", [(niri("l"), "Width ⅓ ½ ⅔ full"), (niri("m","f"), "Narrower / wider"), (niri("p"), "Center"),
             (niri("/"), "Tabs"), (niri("b"), "Maximize"), (niri("y"), "Fullscreen")]),
 ("Workspaces · Monitors", [(niri("n","w"), "Workspace ↑ ↓"), (niri("v","g"), "Send column ↑ ↓"),
             (niri("PgUp"), "Previous"), (niri("Home"), "Other monitor"), (niri("End"), "Send column there"),
             (niri("z"), "Send workspace there")]),
 ("Sound · Dux", [(niri("↑","↓"), "Volume"), (niri("←"), "Mute"), (niri("→"), "Play / pause"),
             (niri("F11"), "Audio devices"), (niri("[","]"), "Notifs / clipboard"), (niri("PgDn"), "Settings")]),
 ("Emergency · Misc", [(niri("Pause"), "Force close app"), (niri("ScrLk"), "Unblock shortcuts"), (niri("F9","F10"), "Shot: window / area"),
             (niri("F12"), "Shot: screen"), (niri("F8"), "Power menu"), (niri(","), "Pause breaks")]),
]
nvim_cards = [
 ("Move", [(keys("e","h","t","d"), "← ↓ ↑ →"+D), (keys("w","b"), "Next word / back"),
           (keys("l","L"), "Word end / WORD"+D), (keys("f"), "Find char"), (keys("j"), "Till char"+D),
           (keys("gg","G"), "Top / bottom")]),
 ("Edit", [(keys("i","a"), "Insert / append"), (keys("o"), "New line below"), (keys("c"), "Change"),
           (keys("k"), "Delete"+D), (keys("kk"), "Delete line"+D), (keys("u","Ctrl","r"), "Undo / redo")]),
 ("Select · Copy", [(keys("v","V"), "Select / lines"), (keys("y","yy"), "Yank / line"), (keys("p"), "Paste"),
           (keys("."), "Repeat"), (keys("/","n"), "Search / next"), (keys("s"), "Jump (flash)")]),
 ("Insert · View", [(keys("Ctrl","t"), "Back to normal"+D), (keys("zh","zt"), "Scroll ↓ ↑"+D),
           (keys("zH","zT"), "Half page ↓ ↑"+D), (keys("zu"), "Cursor line to top"+D),
           (keys("zz"), "Center line")]),
 ("Windows · Buffers", [(keys("␣","w","e h t d"), "Go to window"+D), (keys("␣","w","E H T D"), "Move window"+D),
           (keys("␣","wk"), "Close window"+D), (keys("E","D"), "Buffer ← →"+D), (keys("␣","bd"), "Close buffer")]),
 ("LazyVim · Files", [(keys("␣","␣"), "Find files"), (keys("␣","e"), "Explorer"), (keys("␣","/"), "Grep"),
           (keys("␣","gg"), "Lazygit"), (keys("␣"), "Menu: wait"), (keys(":w",":q"), "Save / quit")]),
]
C = lambda *x: k("Ctrl","ctl") + "".join(k(y) for y in x)
voice_rows = [(niri("c"), "Dictate into window"), (niri("i"), "Stop dictating"), (niri("a"), "Read clipboard aloud"),
              (niri("x"), "Stop reading / cancel"), ('<span class="note">Polish model: download once in Speech Note</span>', "")]
vim_rows1 = [(keys("e","h","t","d"), "Parent ↓ ↑ open"), (keys("H","T"), "Preview ↓ ↑"), (keys("E","D"), "Back / forward"),
             (keys("␣"), "Select"), (keys("y","x","p"), "Copy / cut / paste"), (keys("a"), "New (end / = folder)")]
vim_rows2 = [(keys("k","K"), "Trash / delete"), (keys("r"), "Rename"), (keys("j","[","]"), "New tab / ← →"),
             (keys("f","/"), "Filter / find"), (keys("z","Z"), "Jump: fzf / zoxide"), (keys("."), "Hidden files")]
term_rows = [(C("c"), "Copy (if selected)"), (C("v"), "Paste"), (keys("→")+'<span class="or">or</span>'+C("f"), "Take suggestion"),
             (keys("z","name"), "Jump to folder"), (C("r"), "History search"), (C("t"), "Pick a file")]
def rows(rs):
    return "".join(f'<div class="row"><span class="keys">{a}</span><span class="what">{b}</span></div>' for a,b in rs)
def cards(cs, side):
    out=[]
    for title, rows in cs:
        r="".join(f'<div class="row"><span class="keys">{a}</span><span class="what">{b}</span></div>' for a,b in rows)
        out.append(f'<div class="card {side}"><h3>{title}</h3>{r}</div>')
    return "\n".join(out)

import os
HERE = os.path.dirname(os.path.abspath(__file__))
LOGO = "file://" + os.path.join(HERE, "..", "..", "files", "branding", "onehanded-remix-logo.svg")
page = f"""<!doctype html><html><head><meta charset="utf-8"><style>
:root {{ --bg1:#0f1b2d; --bg2:#0b1220; --card:#121c2c; --line:#1e2b40; --text:#e8eef7; --muted:#9fb0c6;
        --niri:#6cb6ff; --vim:#7ee08a; --web:#f5b86b; --term:#c9a2ff; --voice:#ff8fa3; }}
* {{ box-sizing:border-box; margin:0; padding:0; }}
body {{ width:2560px; height:1440px; overflow:hidden; font-family:'DejaVu Sans',sans-serif; color:var(--text);
        background: radial-gradient(1400px 700px at 15% 0%, #1b3150 0%, transparent 60%), linear-gradient(160deg,var(--bg1),var(--bg2));
        padding: 150px 96px 0; }}
header {{ display:flex; justify-content:space-between; align-items:center; margin-bottom:30px; }}
.brand {{ display:flex; align-items:center; gap:28px; }}
.brand img {{ width:112px; height:112px; }}
.brand .name {{ font-size:30px; color:#c9d6e8; font-weight:300; letter-spacing:1px; line-height:1; }}
.brand .name b {{ display:block; font-size:66px; font-weight:700; letter-spacing:4px; color:var(--niri); margin-top:4px; }}
.brand .sub {{ font-size:22px; color:var(--muted); margin-top:8px; }}
.brand .sub .n {{ color:var(--niri); }} .brand .sub .v {{ color:var(--vim); }}
.legend {{ display:grid; grid-template-columns:auto auto; gap:10px 34px; font-size:22px; color:var(--muted); }}
.legend div {{ white-space:nowrap; }}
.legend .hl {{ color:var(--text); }}
.sticky {{ grid-column: 1 / 3; background:#2a2414; border:1px solid #6b5626; border-radius:12px; padding:9px 16px; color:#f3dca5; }}
.sticky b {{ color:#ffd479; }}
.halves {{ display:grid; grid-template-columns:1fr 1fr; gap:48px; }}
h2 {{ font-size:28px; margin-bottom:14px; font-weight:700; }}
.zed {{ font-size:18px; color:var(--muted); font-weight:400; }}
.half.niri h2 {{ color:var(--niri); }} .half.vim h2 {{ color:var(--vim); }}
.grid {{ display:grid; grid-template-columns:repeat(3,1fr); gap:16px; }}
.card {{ background:var(--card); border:1px solid var(--line); border-radius:16px; padding:16px 18px 8px; }}
.half .card {{ min-height:296px; }}
.card h3 {{ font-size:23px; margin-bottom:8px; }}
.row {{ display:flex; justify-content:space-between; align-items:center; gap:10px; padding:6px 0; border-bottom:1px solid #182436; font-size:19.5px; }}
.row:last-child {{ border-bottom:none; }}
.what {{ color:var(--muted); text-align:right; white-space:nowrap; }}
.keys {{ white-space:nowrap; }}
.note {{ color:#7f91aa; font-size:17px; font-style:italic; }}
.or {{ color:#7f91aa; font-size:16px; margin:0 8px 0 2px; }}
kbd {{ font-family:'DejaVu Sans Mono',monospace; font-size:16px; display:inline-block; min-width:25px; text-align:center;
       padding:2px 7px; margin-right:5px; border-radius:6px; border:1px solid #3a4a63; background:#1a2638; color:var(--text); }}
kbd.mod {{ color:var(--niri); border-color:#2f5a86; background:#152a42; }}
kbd.ctl {{ color:#ffd479; border-color:#6b5626; background:#2a2414; }}
.card.vim kbd {{ border-color:#3c5a45; background:#18291f; }}
.dot {{ display:inline-block; width:12px; height:12px; border-radius:50%; background:var(--vim); margin-left:8px; vertical-align:middle; }}
.bottom {{ display:grid; grid-template-columns: 1.05fr 2fr 1.15fr 1.3fr; gap:16px; margin-top:26px; }}
.bottom .card {{ min-height:276px; }}
.bottom h3 small {{ font-size:17px; font-weight:400; color:var(--muted); margin-left:8px; }}
.card.voice h3 {{ color:var(--voice); }} .card.web h3 {{ color:var(--web); }} .card.term h3 {{ color:var(--term); }} .card.mon h3 {{ color:var(--niri); }}
.card.web kbd {{ border-color:#6b5230; background:#2a2116; }}
.card h3 code {{ font-family:'DejaVu Sans Mono',monospace; font-size:16px; color:#cfe3ff; background:#152033; border-radius:5px; padding:1px 6px; }}
.cols2 {{ display:grid; grid-template-columns:1fr 1fr; gap:0 26px; }}
.screens {{ display:flex; align-items:flex-end; gap:14px; margin:10px 0 12px; }}
.scr {{ border:2px solid #2f5a86; border-radius:10px; background:#0e1828; padding:10px 12px; font-size:18px; color:var(--muted); }}
.scr b {{ display:block; color:var(--text); font-size:19px; margin-bottom:6px; }}
.scr .ws {{ display:block; margin-top:4px; }} .scr .ws i {{ font-style:normal; color:var(--niri); font-family:'DejaVu Sans Mono',monospace; }}
.scr.main {{ width:56%; height:150px; border-color:var(--niri); }}
.scr.side {{ width:44%; height:122px; margin-bottom:14px; }}
footer {{ display:grid; grid-template-columns: 1.45fr 1fr 1fr; gap:16px; margin-top:16px; }}
footer div {{ background:#0e1726; border:1px solid var(--line); border-radius:12px; padding:11px 18px; font-size:18px; color:var(--muted); min-width:0; line-height:1.5; }}
footer b {{ color:var(--text); margin-right:10px; }}
footer code {{ font-family:'DejaVu Sans Mono',monospace; font-size:16.5px; color:#cfe3ff; background:#152033; border-radius:5px; padding:1px 6px; }}
footer .sep {{ color:#4b5d78; margin:0 8px; }}
.mon .tip {{ font-size:17.5px; color:var(--muted); line-height:1.55; }}
</style></head><body>
<header>
  <div class="brand"><img src="{LOGO}">
    <div><div class="name">Fedora Remix <b>One-Handed</b></div>
    <div class="sub"><span class="n">niri</span> + <span class="v">LazyVim</span> · right hand only</div></div></div>
  <div class="legend">
    <div><span class="hl">Mod</span> = hold <kbd>Right Alt</kbd></div>
    <div>Same directions everywhere: <kbd>e</kbd>← <kbd>h</kbd>↓ <kbd>t</kbd>↑ <kbd>d</kbd>→</div>
    <div><span class="hl">Polish</span>: tap <kbd>Right Alt</kbd>, then a c e l n o s z x</div>
    <div><i class="dot"></i> = your one-handed key &nbsp;·&nbsp; <kbd>␣</kbd> = Space &nbsp;·&nbsp; <kbd class="mod">Mod</kbd><kbd>Ins</kbd> = all</div>
    <div class="sticky"><b>Sticky keys:</b> tap <kbd class="ctl">Right Ctrl</kbd> or <kbd class="ctl">Right Shift</kbd>, then the key → Ctrl / Shift + key &nbsp;(hold them as usual too)</div>
  </div>
</header>
<div class="halves">
  <div class="half niri"><h2>niri · Mod + one key</h2><div class="grid">{cards(niri_cards,"niri")}</div></div>
  <div class="half vim"><h2>LazyVim · normal mode <small class='zed'>(Zed: same moves and edits)</small></h2><div class="grid">{cards(nvim_cards,"vim")}</div></div>
</div>
<div class="bottom">
  <div class="card voice"><h3>Voice <small>Speech Note</small></h3>{rows(voice_rows)}</div>
  <div class="card web"><h3>Files <small>yazi · <code>y</code> in the terminal · <kbd>~</kbd> all keys · <kbd>q</kbd> quit here</small></h3>
    <div class="cols2"><div>{rows(vim_rows1)}</div><div>{rows(vim_rows2)}</div></div></div>
  <div class="card term"><h3>Terminal <small>Ghostty + fish</small></h3>{rows(term_rows)}</div>
  <div class="card mon"><h3>Screens</h3>
    <div class="screens">
      <div class="scr main"><b>Main · you work here</b><span class="ws"><i>code</i> Zed, Ghostty</span><span class="ws"><i>web</i> browsers</span><span class="ws"><i>notes</i> Obsidian · <i>vm</i></span></div>
      <div class="scr side"><b>Second</b><span class="ws">shows this sheet</span><span class="ws">+ windows you send</span></div>
    </div>
    <div class="tip"><kbd class="mod">Mod</kbd><kbd>End</kbd> send window there / back · <kbd>q</kbd> sleep / wake · <kbd>Home</kbd> jump</div></div>
</div>
<footer>
  <div><b>First time</b> Speech Note: download a Polish model<span class="sep">·</span>Welcome window: Mod + ' → <code>Welcome</code></div>
  <div><b>If stuck</b> <kbd>Bksp</kbd><kbd>Esc</kbd><kbd>Enter</kbd> together stops keyd<span class="sep">·</span>new screen? run <code>onehand-monitors</code></div>
  <div><b>fish</b> <code>v</code> nvim <code>g</code> git <code>lg</code> lazygit<span class="sep">·</span><code>zi</code> pick a folder<span class="sep">·</span><kbd>Alt</kbd><kbd>c</kbd> cd</div>
</footer>
</body></html>"""
open(os.path.join(HERE, "wallpaper.html"), "w").write(page)
