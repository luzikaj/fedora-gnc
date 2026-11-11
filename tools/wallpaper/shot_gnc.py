import os
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "..", "files", "wallpapers")
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b = p.chromium.launch()
    for name, scale in [("fedora-gnc-2560x1440.png", 1), ("fedora-gnc-1920x1080.png", 0.75)]:
        pg = b.new_page(viewport={"width": 2560, "height": 1440}, device_scale_factor=scale)
        pg.goto("file://" + os.path.join(HERE, "wallpaper-gnc.html")); pg.wait_for_timeout(400)
        over = pg.evaluate("""() => [...document.querySelectorAll('.row, .card, .legend div, footer div')].filter(r => r.scrollWidth > r.clientWidth + 1).map(r=>r.textContent.slice(0,40))""")
        h = pg.evaluate("document.querySelector('footer').getBoundingClientRect().bottom")
        print(name, "overflow:", over, "content bottom:", round(h))
        pg.screenshot(path=os.path.join(OUT, name)); pg.close()
    b.close()
