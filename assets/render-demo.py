#!/usr/bin/env python3
"""Render assets/demo.gif: a mock terminal session showing the plugin's four flows.

All app names, paths and findings are fictional. Requires Pillow and macOS system
fonts (SF Mono, Menlo). Run from the repo root:  python3 assets/render-demo.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = Path(__file__).resolve().parent / "demo.gif"

# ---------------------------------------------------------------- look
W, H = 1100, 652
WIN = (30, 24, 1070, 626)          # x0, y0, x1, y1
TITLE_H = 38
PAD_X, PAD_Y = 24, 18
FONT_SIZE, LINE_H = 15, 22

C = {
    "bg": (30, 30, 46), "bar": (24, 24, 37), "border": (49, 50, 68),
    "text": (205, 214, 244), "sub": (166, 173, 200), "dim": (108, 112, 134),
    "red": (243, 139, 168), "yellow": (249, 226, 175), "green": (166, 227, 161),
    "blue": (137, 180, 250), "mauve": (203, 166, 247), "peach": (250, 179, 135),
    "teal": (148, 226, 213), "ink": (17, 17, 27),
}

SF = "/System/Library/Fonts/SFNSMono.ttf"
MENLO = "/System/Library/Fonts/Menlo.ttc"


def font(weight="Regular"):
    f = ImageFont.truetype(SF, FONT_SIZE)
    f.set_variation_by_name(weight)
    return f


F_REG, F_BOLD, F_SEMI = font("Regular"), font("Bold"), font("Semibold")
F_FALLBACK = ImageFont.truetype(MENLO, FONT_SIZE)
F_TITLE = font("Medium")
CHAR_W = F_REG.getlength("M")


def has_glyph(f, ch):
    return ch == " " or f.getmask(ch).getbbox() is not None


# ---------------------------------------------------------------- static frame
def make_base():
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    top, bottom = (36, 24, 66), (16, 14, 32)
    for y in range(H):
        t = y / (H - 1)
        d.line([(0, y), (W, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(top, bottom)))
    shadow = Image.new("L", (W, H), 0)
    ImageDraw.Draw(shadow).rounded_rectangle(
        (WIN[0] + 4, WIN[1] + 14, WIN[2] - 4, WIN[3] + 10), 16, fill=170)
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))
    img.paste((6, 4, 14), (0, 0), shadow)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(WIN, 14, fill=C["bg"], outline=C["border"])
    d.rounded_rectangle((WIN[0], WIN[1], WIN[2], WIN[1] + TITLE_H), 14, fill=C["bar"])
    d.rectangle((WIN[0] + 1, WIN[1] + TITLE_H - 14, WIN[2] - 1, WIN[1] + TITLE_H), fill=C["bar"])
    d.line((WIN[0], WIN[1] + TITLE_H, WIN[2], WIN[1] + TITLE_H), fill=C["border"])
    for i, col in enumerate([(255, 95, 87), (254, 188, 46), (40, 200, 64)]):
        cx, cy = WIN[0] + 22 + i * 20, WIN[1] + TITLE_H // 2
        d.ellipse((cx - 6, cy - 6, cx + 6, cy + 6), fill=col)
    return img


BASE = make_base()


# ---------------------------------------------------------------- text model
# A line is a list of segments: (text, color, style) with style in {"", "b", "s", "badge:<color>"}.
def seg(text, color="text", style=""):
    return (text, color, style)


def draw_line(d, x, y, segs):
    for text, color, style in segs:
        if style.startswith("badge:"):
            bg = C[style.split(":")[1]]
            wpx = CHAR_W * len(text)
            d.rounded_rectangle((x, y + 2, x + wpx, y + LINE_H - 3), 4, fill=bg)
            d.text((x, y + 3), text, font=F_BOLD, fill=C["ink"])
            x += wpx
            continue
        if style == "panel":
            d.rectangle((x, y, x + CHAR_W * len(text), y + LINE_H - 1), fill=C["bar"])
        f = {"b": F_BOLD, "s": F_SEMI}.get(style, F_REG)
        for ch in text:
            ff = f if has_glyph(f, ch) else F_FALLBACK
            d.text((x, y + 3), ch, font=ff, fill=C[color])
            x += CHAR_W
    return x


def render(lines, title, label, cursor_at=None):
    img = BASE.copy()
    d = ImageDraw.Draw(img)
    tw = F_TITLE.getlength(title)
    d.text(((WIN[0] + WIN[2]) / 2 - tw / 2, WIN[1] + 11), title, font=F_TITLE, fill=C["sub"])
    lw = F_TITLE.getlength(label)
    d.text((WIN[2] - 20 - lw, WIN[1] + 11), label, font=F_TITLE, fill=C["dim"])
    x0, y0 = WIN[0] + PAD_X, WIN[1] + TITLE_H + PAD_Y
    end_x = x0
    for i, segs in enumerate(lines):
        end_x = draw_line(d, x0, y0 + i * LINE_H, segs)
    if cursor_at is not None:
        cy = y0 + cursor_at * LINE_H
        d.rectangle((end_x + 1, cy + 3, end_x + CHAR_W - 1, cy + LINE_H - 3), fill=C["mauve"])
    return img


# ---------------------------------------------------------------- scene builder
class Scene:
    SPIN = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

    def __init__(self, title, label):
        self.title, self.label = title, label
        self.lines, self.frames = [], []

    def frame(self, ms, cursor=False):
        cur = len(self.lines) - 1 if cursor else None
        self.frames.append((render(self.lines, self.title, self.label, cur), ms))

    def prompt(self, command, extra=None):
        self.lines.append([seg("› ", "mauve", "b")])
        self.frame(450, cursor=True)
        self.frame(350)
        self.frame(350, cursor=True)
        for i in range(0, len(command), 2):
            self.lines[-1] = [seg("› ", "mauve", "b"), seg(command[: i + 2], "text", "s")]
            self.frame(45, cursor=True)
        if extra:
            self.lines[-1] = self.lines[-1] + [seg(" "), *extra]
            self.frame(500, cursor=True)
        self.frame(380)
        self.lines.append([])

    def step(self, running, done, wait=4, detail=None):
        """A progress line: spinner while running, then a green dot and the result."""
        self.lines.append([])
        for k in range(wait):
            self.lines[-1] = [seg(self.SPIN[k % len(self.SPIN)] + " ", "yellow"), seg(running, "sub")]
            self.frame(110)
        self.lines[-1] = [seg("● ", "green"), seg(done)] + (detail or [])
        self.frame(160)

    def parallel(self, rows, wait=10):
        """Three subagents spinning together and finishing one by one."""
        start = len(self.lines)
        for branch, name, _ in rows:
            self.lines.append([seg(f"  {branch} ", "dim"), seg(name, "sub")])
        finish = [wait - 4, wait - 1, wait]
        for k in range(wait + 1):
            for j, (branch, name, result) in enumerate(rows):
                if k >= finish[j]:
                    self.lines[start + j] = [seg(f"  {branch} ", "dim"), seg("✓ ", "green"),
                                             seg(f"{name:<28}"), seg(result, "dim")]
                else:
                    self.lines[start + j] = [seg(f"  {branch} ", "dim"),
                                             seg(self.SPIN[(k + j) % len(self.SPIN)] + " ", "yellow"),
                                             seg(name, "sub")]
            self.frame(110)

    def show(self, segs, ms=110):
        self.lines.append(segs)
        self.frame(ms)

    def blank(self):
        self.lines.append([])

    def hold(self, ms):
        self.frame(ms)


def finding(sev, rule, text, where):
    color = {"CRITICAL": "red", "WARNING": "yellow", "INFO": "blue"}[sev]
    return [seg(" "), seg(f" {sev:<8} ", style=f"badge:{color}"), seg("  "),
            seg(f"{rule:<12}", "peach", "s"), seg(f"{text:<48}"), seg(where, "dim")]


# ---------------------------------------------------------------- the four scenes
def scene_review():
    s = Scene("claude · ~/apps/pulse", "1/4  pre-submission audit")
    s.prompt("/appstore-review --build build/Pulse.ipa")
    s.step("Detecting project", "Expo SDK 57, managed", detail=[seg("  com.pulsefit.app · iOS 16.0", "dim")])
    s.step("Inspecting Pulse.ipa", "Inspected Pulse.ipa", detail=[seg("  24 frameworks · 1 possible ITMS-91053", "dim")])
    s.show([seg("● ", "green"), seg("Auditing in 3 parallel slices")], 120)
    s.parallel([("├─", "A  Safety + Performance", "1 finding"),
                ("├─", "B  Business + Design", "2 findings"),
                ("└─", "C  Privacy + Legal", "3 findings")])
    s.step("Verifying critical findings", "Verified 3 critical findings at file:line", wait=5)
    s.blank()
    s.show([seg("App Store Review Compliance Report", "text", "b"), seg("   guidelines: Oct 16, 2026", "dim")], 300)
    s.blank()
    s.show(finding("CRITICAL", "4.8", "Google sign-in, no Sign in with Apple", "app/(auth)/login.tsx:23"))
    s.show(finding("CRITICAL", "5.1.1(v)", "Account creation without in-app deletion", "searched app/, lib/"))
    s.show(finding("CRITICAL", "5.1.1", "ITMS-91053: disk space API not declared", "ExpoFileSystem"))
    s.show(finding("WARNING", "3.1.2(c)", "Renewal terms not shown before purchase", "app/paywall.tsx:88"))
    s.show(finding("WARNING", "2.3.10", "\"Get it on Google Play\" in onboarding copy", "locales/en.json:41"))
    s.show(finding("INFO", "1.5", "Support link only in App Store metadata", "app/settings.tsx"))
    s.blank()
    s.show([seg("  Manual checks  ", "dim"), seg("4", "text", "b"),
            seg("   demo account, privacy labels, review notes, screenshots", "sub")], 200)
    s.show([seg("  Verdict        ", "dim"), seg(" HIGH RISK ", style="badge:red")], 400)
    s.blank()
    s.show([seg("  Run "), seg("/appstore-review --fix", "mauve", "s"), seg(" to apply 3 safe fixes.")], 200)
    s.hold(3800)
    return s.frames


def scene_fix():
    s = Scene("claude · ~/apps/pulse", "2/4  --fix")
    s.prompt("/appstore-review --fix")
    s.step("Applying safe fixes", "Applied 3 safe fixes", wait=6)
    for text, where in [("Declared DiskSpace API (reason E174.1)", "app.json  ios.privacyManifests"),
                        ("Rewrote generic photo library purpose string", "app.json  ios.infoPlist"),
                        ("Added .env to .gitignore", ".gitignore")]:
        s.show([seg("    ✓ ", "green"), seg(f"{text:<48}"), seg(where, "dim")], 220)
    s.blank()
    s.show([seg("● ", "yellow"), seg("2 changes need your OK")], 250)
    s.show([seg("    1 ", "peach", "b"), seg(f"{'Sign in with Apple':<26}"),
            seg("expo-apple-authentication + button in login.tsx", "dim")], 220)
    s.show([seg("    2 ", "peach", "b"), seg(f"{'Delete account flow':<26}"),
            seg("Settings > Account + Supabase delete-user function", "dim")], 220)
    s.blank()
    s.show([seg("  Apply both? ", "text", "s"), seg("(y/n)", "dim")], 400)
    s.lines[-1] = s.lines[-1] + [seg(" y", "mauve", "b")]
    s.frame(500)
    s.blank()
    s.step("Implementing and re-checking", "Fix Summary", wait=8)
    s.show([seg("    4.8       ", "peach", "s"), seg("Fixed     ", "green", "b"), seg("app/(auth)/login.tsx, app.json", "dim")], 160)
    s.show([seg("    5.1.1(v)  ", "peach", "s"), seg("Fixed     ", "green", "b"), seg("app/settings/account.tsx, supabase/functions/delete-user", "dim")], 160)
    s.show([seg("    5.1.1     ", "peach", "s"), seg("Fixed     ", "green", "b"), seg("app.json", "dim")], 160)
    s.blank()
    s.show([seg("  Rebuild with "), seg("npx expo prebuild --clean", "mauve", "s"), seg(" and run the audit again.")], 200)
    s.hold(3400)
    return s.frames


def scene_play():
    s = Scene("claude · ~/apps/stride-android", "3/4  google play")
    s.prompt("/playstore-review --build app/build/outputs/bundle/release/app-release.aab")
    s.step("Detecting project", "Native Kotlin", detail=[seg("  com.striderun.app · targetSdk 35", "dim")])
    s.step("Reading merged manifest", "Read merged manifest", detail=[seg("  14 permissions, 3 added by SDKs", "dim")])
    s.show([seg("● ", "green"), seg("Auditing in 3 parallel slices")], 120)
    s.parallel([("├─", "A  Privacy + Permissions", "2 findings"),
                ("├─", "B  Monetization + Content", "1 finding"),
                ("└─", "C  Families + Technical", "1 finding")], wait=9)
    s.blank()
    s.show([seg("Google Play Policy Compliance Report", "text", "b"), seg("   policies: Oct 29, 2026", "dim")], 300)
    s.blank()
    s.show(finding("CRITICAL", "Target API", "targetSdk 35, Play requires 36", "app/build.gradle.kts:14"))
    s.show(finding("CRITICAL", "Packages", "QUERY_ALL_PACKAGES injected by an ads SDK", "merged manifest"))
    s.show(finding("WARNING", "Location", "Fine location needs a declaration (API 37+)", "AndroidManifest.xml:9"))
    s.show(finding("WARNING", "Billing", "Student plan hides post-eligibility price", "PaywallScreen.kt:57"))
    s.blank()
    s.show([seg("  Declarations   ", "dim"), seg("Data safety: Analytics, Crashlytics · Location permissions", "sub")], 200)
    s.show([seg("  Verdict        ", "dim"), seg(" HIGH RISK ", style="badge:red")], 400)
    s.hold(3600)
    return s.frames


def scene_rejection():
    s = Scene("claude · ~/apps/ledger-ios", "4/4  rejection reply")
    s.prompt("/appstore-rejection", extra=[seg("[Pasted text +18 lines]", "dim")])
    s.step("Parsing rejection", "Found 2 issues", detail=[seg("  5.1.1(v) · 2.1 Information Needed", "dim")])
    s.step("Searching the code for root causes", "Root causes", wait=8)
    s.show([seg("    5.1.1(v)  ", "peach", "s"), seg(" CODE FIX ", style="badge:peach"),
            seg("  DeleteAccountView only reachable for premium users", "text")], 220)
    s.show([seg("                          SettingsView.swift:58  ", "dim"), seg("if user.isPremium { ... }", "teal")], 220)
    s.show([seg("    2.1       ", "peach", "s"), seg(" METADATA ", style="badge:blue"),
            seg("  Demo account missing from App Review Information", "text")], 220)
    s.blank()
    s.show([seg("  Draft reply for the Resolution Center", "text", "b")], 250)
    box = [
        "Hello App Review team,",
        "",
        "1. Guideline 5.1.1(v): Account deletion is now available to every",
        "   user in Settings > Account > Delete Account (build [build number]).",
        "2. Guideline 2.1: Demo credentials are now in App Review Information:",
        "   [demo account] / [password].",
        "",
        "Thank you for reviewing our app.",
    ]
    s.show([seg("  "), seg(" " * 78, "sub", "panel")], 80)
    for row in box:
        s.show([seg("  "), seg(f"   {row:<75}", "sub", "panel")], 140)
    s.show([seg("  "), seg(" " * 78, "sub", "panel")], 80)
    s.blank()
    s.show([seg("  Apply the 5.1.1(v) fix now? ", "text", "s"), seg("(y/n)", "dim")], 300)
    s.hold(4200)
    return s.frames


# ---------------------------------------------------------------- encode
def main():
    frames = scene_review() + scene_fix() + scene_play() + scene_rejection()
    # One shared palette (built from the last frame of every scene) keeps colors stable.
    keys = [frames[i][0] for i in range(len(frames)) if i == len(frames) - 1 or frames[i + 1][1] == 450]
    # Swatches of every theme color (and its blends with the background) so small
    # colored glyphs keep their exact color after quantization.
    accents = [v for k, v in C.items() if k not in ("bg", "bar", "border")]
    accents += [(255, 95, 87), (254, 188, 46), (40, 200, 64)]
    sw = 40
    swatch = Image.new("RGB", (W, sw * 4), C["bg"])
    sd = ImageDraw.Draw(swatch)
    for i, col in enumerate(accents):
        for j, t in enumerate((1.0, 0.75, 0.5, 0.25)):
            mix = tuple(int(c * t + b * (1 - t)) for c, b in zip(col, C["bg"]))
            sd.rectangle((i * sw, j * sw, i * sw + sw - 1, j * sw + sw - 1), fill=mix)
    sheet = Image.new("RGB", (W, H * len(keys) + swatch.height * 6))
    for i, im in enumerate(keys):
        sheet.paste(im, (0, i * H))
    for r in range(6):
        sheet.paste(swatch, (0, H * len(keys) + r * swatch.height))
    pal = sheet.quantize(colors=192, method=Image.Quantize.MEDIANCUT)
    out = [im.quantize(palette=pal, dither=Image.Dither.NONE) for im, _ in frames]
    out[0].save(OUT, save_all=True, append_images=out[1:], duration=[ms for _, ms in frames],
                loop=0, optimize=True, disposal=1)
    total = sum(ms for _, ms in frames) / 1000
    print(f"{OUT}: {len(frames)} frames, {total:.1f}s, {OUT.stat().st_size / 1e6:.2f} MB")


if __name__ == "__main__":
    main()
