#!/usr/bin/env python3
"""Builds the learning aids from tools/learn/drills.json:

  docs/learn/trainer.html       interactive key trainer (open it in a browser)
  docs/learn/cheat-sheets.pdf   one printable A4 page per week, with a daily drill checklist

Needs Python 3 and Playwright with Chromium (only for the PDF):
  pip install --user playwright && python3 -m playwright install chromium
"""
import html, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
OUT = os.path.join(ROOT, "docs", "learn")
data = json.load(open(os.path.join(HERE, "drills.json"), encoding="utf-8"))
os.makedirs(OUT, exist_ok=True)

# ---------------------------------------------------------------- trainer
tpl = open(os.path.join(HERE, "trainer.template.html"), encoding="utf-8").read()
page = tpl.replace("/*DRILLS_JSON*/null", json.dumps(data, ensure_ascii=False))
open(os.path.join(OUT, "trainer.html"), "w", encoding="utf-8").write(page)
print("wrote docs/learn/trainer.html")

# ---------------------------------------------------------------- cheat sheets
# QWERTY keycap for each character on right-handed Dvorak (for the small hints)
ROWS = [
    "` 1 2 3 4 5 6 7 8 9 0 - =".split(), "` 1 2 3 4 j l m f p / [ ]".split(), "~ ! @ # $ J L M F P ? { }".split(),
    "Q W E R T Y U I O P [ ] \\".split(), "5 6 q . o r s u y b ; = \\".split(), "% ^ Q > O R S U Y B : + |".split(),
    "A S D F G H J K L ; '".split(), "7 8 z a e h t d c k -".split(), "& * Z A E H T D C K _".split(),
    "Z X C V B N M , . /".split(), "9 0 x , i n w v g '".split(), "( ) X < I N W V G \"".split(),
]
CAP = {}
for caps, lo, up in zip(ROWS[0::3], ROWS[1::3], ROWS[2::3]):
    for c, l, u in zip(caps, lo, up):
        CAP.setdefault(l, c)
        CAP.setdefault(u, "⇧" + c)
NAMED = {" ": "Space", "Enter": "Enter", "Backspace": "Bksp", "Insert": "Ins", "Delete": "Del", "Home": "Home",
         "End": "End", "PageUp": "PgUp", "PageDown": "PgDn", "ArrowRight": "→", "ScrollLock": "ScrLk"}

def kbd(k):
    if k in NAMED:
        return f'<kbd class="w">{NAMED[k]}</kbd>'
    cap = CAP.get(k, "")
    return f'<kbd>{html.escape(k)}<sub>{html.escape(cap)}</sub></kbd>'

def keys(item, ctx):
    pre = '<kbd class="mod">Mod</kbd>' if ctx == "Mod +" else ""
    return pre + "".join(kbd(k) for k in item["k"])

pages = []
for d in data["decks"]:
    groups = []
    for g in d["groups"]:
        ctx = g["ctx"]
        label = {"Mod +": "Mod + key", "Vimium": "in the browser", "fish": "in the terminal",
                 "LazyVim": "normal mode", "tap Right Alt, then": "tap Right Alt, then", "type": "type"}.get(ctx, "")
        rows = "".join(f'<tr><td class="k">{keys(it, ctx)}</td><td>{html.escape(it["a"])}</td></tr>' for it in g["items"])
        groups.append(f'<section class="grp"><h3>{html.escape(g["name"])} <span>{label}</span></h3><table>{rows}</table></section>')
    days = "".join(f"<th>{x}</th>" for x in ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
    drill = "".join(f'<tr><td>{html.escape(t)}</td>' + '<td class="box"></td>' * 7 + "</tr>" for t in d["drill"])
    pages.append(f"""
<div class="page">
  <header><div class="wk">Week {d['week']}</div><div><h1>{html.escape(d['title'])}</h1><p>{html.escape(d['goal'])}</p></div></header>
  <div class="groups">{''.join(groups)}</div>
  <section class="drill"><h2>Daily drill <span>about 10 minutes · tick a box each day</span></h2>
    <table><tr><th></th>{days}</tr>{drill}</table></section>
  <footer><b>One-Handed Fedora Remix</b> · Mod = hold Right Alt · small grey letter = QWERTY keycap · ⇧ = Shift (tap Right Shift) ·
    one new shortcut a day until it sticks · forgot one? Mod + Insert</footer>
</div>""")

sheet = f"""<!doctype html><html><head><meta charset="utf-8"><title>One-Handed cheat sheets</title><style>
@page {{ size: A4; margin: 0; }}
* {{ box-sizing: border-box; }}
body {{ margin: 0; font-family: "IBM Plex Sans", "DejaVu Sans", sans-serif; color: #142033; font-size: 9.5pt; }}
.page {{ width: 210mm; height: 297mm; padding: 12mm 14mm 10mm; display: flex; flex-direction: column; gap: 4mm; page-break-after: always; overflow: hidden; }}
.page:last-child {{ page-break-after: auto; }}
header {{ display: grid; grid-template-columns: auto 1fr; gap: 6mm; align-items: center; border-bottom: 2px solid #1f6fd1; padding-bottom: 4mm; }}
.wk {{ font: 700 13pt "IBM Plex Mono", "DejaVu Sans Mono", monospace; color: #fff; background: #1f6fd1; border-radius: 3mm; padding: 2.5mm 4mm; }}
h1 {{ margin: 0; font-size: 20pt; }} header p {{ margin: 1mm 0 0; color: #5a6a80; }}
.brand {{ text-align: right; font-weight: 600; color: #1f6fd1; font-size: 9pt; }} .brand span {{ font-weight: 400; color: #5a6a80; }}
.groups {{ columns: 2; column-gap: 8mm; flex: 1; }}
.grp {{ break-inside: avoid; margin-bottom: 3mm; }}
h3 {{ margin: 0 0 1.5mm; font-size: 11pt; }} h3 span {{ font-weight: 400; color: #5a6a80; font-size: 9pt; }}
table {{ border-collapse: collapse; width: 100%; }}
.grp td {{ padding: 0.55mm 1mm; border-bottom: 0.3mm solid #e1e7f0; vertical-align: middle; }}
td.k {{ width: 38%; white-space: nowrap; }}
kbd {{ display: inline-block; min-width: 6mm; text-align: center; font: 600 9pt "IBM Plex Mono", "DejaVu Sans Mono", monospace;
  border: 0.3mm solid #b9c6d8; border-bottom-width: 0.7mm; border-radius: 1.2mm; padding: 0.2mm 1.2mm; margin-right: 0.8mm; background: #f7f9fc; }}
kbd sub {{ font-size: 6.5pt; color: #8a98ab; font-weight: 400; margin-left: 0.6mm; vertical-align: -0.3mm; }}
kbd.mod {{ background: #dbe8fa; border-color: #1f6fd1; color: #1f6fd1; }} kbd.w {{ font-size: 8.5pt; }}
.drill h2 {{ font-size: 12pt; margin: 0 0 2mm; }} .drill h2 span {{ font-weight: 400; font-size: 9pt; color: #5a6a80; }}
.drill th {{ font-size: 8.5pt; color: #5a6a80; font-weight: 600; padding: 1mm; }}
.drill td {{ border: 0.3mm solid #c7d2e1; padding: 1.3mm 2mm; font-size: 9pt; }}
.drill td.box {{ width: 10mm; }}
footer {{ font-size: 8.5pt; color: #5a6a80; border-top: 0.3mm solid #e1e7f0; padding-top: 2mm; }}
</style></head><body>{''.join(pages)}</body></html>"""
sheet_path = os.path.join(HERE, "cheat-sheets.html")
open(sheet_path, "w", encoding="utf-8").write(sheet)

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    sys.exit("Playwright isn't installed: wrote the trainer only (see the top of this file).")
with sync_playwright() as p:
    b = p.chromium.launch()
    pg = b.new_page()
    pg.goto("file://" + sheet_path)
    pg.wait_for_timeout(300)
    pg.pdf(path=os.path.join(OUT, "cheat-sheets.pdf"), format="A4", print_background=True)
    b.close()
os.remove(sheet_path)
print("wrote docs/learn/cheat-sheets.pdf")
