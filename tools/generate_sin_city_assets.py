import json
import math
import os
import random
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
ASSETS_JSON = ROOT / "assets" / "stories" / "ink" / "Story_01_assets.json"

# Keep assets reasonably small (web will upscale fine)
BG_SIZE = (540, 960)      # portrait backgrounds
IMG_SIZE = (720, 420)     # overlay images

RED = (210, 30, 40)       # Sin City accent
OFFWHITE = (235, 230, 215)


@dataclass(frozen=True)
class TargetAsset:
    kind: str  # "BG" or "IMG"
    key: str
    path: Path


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _grain(im: Image.Image, amount: int = 18) -> Image.Image:
    """Add subtle film grain."""
    w, h = im.size
    noise = Image.effect_noise((w, h), amount).convert("L")
    noise = noise.point(lambda v: max(0, min(255, int((v - 128) * 0.65 + 128))))
    return Image.blend(im, noise, 0.25)


def _vignette(im: Image.Image, strength: float = 0.65) -> Image.Image:
    w, h = im.size
    mask = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(mask)
    # radial vignette via concentric ellipses
    steps = 24
    for i in range(steps):
        t = i / (steps - 1)
        inset_x = int(t * w * 0.18)
        inset_y = int(t * h * 0.18)
        alpha = int(255 * (t ** 2))
        d.ellipse([inset_x, inset_y, w - inset_x, h - inset_y], fill=alpha)
    mask = mask.filter(ImageFilter.GaussianBlur(radius=int(min(w, h) * 0.06)))
    black = Image.new("L", (w, h), 0)
    return Image.composite(im, black, ImageOps.invert(mask).point(lambda v: int(v * strength)))


def _noir_base(size: tuple[int, int], kind: str) -> Image.Image:
    w, h = size
    # gradient background
    base = Image.new("L", (w, h), 0)
    px = base.load()
    for y in range(h):
        # slightly brighter mid-lower area for readability
        t = y / max(1, h - 1)
        v = int(20 + (55 if kind == "BG" else 65) * (1 - abs(t - 0.55) * 1.25))
        for x in range(w):
            px[x, y] = max(0, min(255, v))
    base = _grain(base, amount=22 if kind == "BG" else 26)
    base = base.filter(ImageFilter.GaussianBlur(radius=0.6))
    base = ImageOps.autocontrast(base, cutoff=4)
    base = _vignette(base, strength=0.9)
    return base


def _draw_hallway(draw: ImageDraw.ImageDraw, w: int, h: int) -> None:
    cx = w // 2
    vp_y = int(h * 0.28)
    # walls
    for i in range(18):
        t = i / 17
        y = int(vp_y + t * (h - vp_y))
        spread = int((t ** 1.7) * (w * 0.48))
        draw.line([(cx - spread, y), (cx + spread, y)], fill=120, width=1)
    # perspective lines
    for s in (-1, 1):
        for i in range(10):
            x = int(cx + s * (w * (0.12 + i * 0.035)))
            draw.line([(x, h), (cx, vp_y)], fill=90, width=1)


def _draw_cracks(draw: ImageDraw.ImageDraw, w: int, h: int, seed: int = 1) -> None:
    rnd = random.Random(seed)
    for _ in range(18):
        x = rnd.randint(int(w * 0.1), int(w * 0.9))
        y = rnd.randint(int(h * 0.1), int(h * 0.9))
        length = rnd.randint(int(min(w, h) * 0.12), int(min(w, h) * 0.28))
        ang = rnd.random() * math.tau
        points = [(x, y)]
        for _seg in range(rnd.randint(6, 10)):
            ang += (rnd.random() - 0.5) * 0.7
            step = length / 10
            x = int(x + math.cos(ang) * step)
            y = int(y + math.sin(ang) * step)
            points.append((x, y))
        draw.line(points, fill=150, width=2)
        # small branches
        if rnd.random() < 0.6 and len(points) > 4:
            bx, by = points[rnd.randint(2, len(points) - 2)]
            ang2 = ang + (rnd.random() - 0.5) * 1.6
            ex = int(bx + math.cos(ang2) * length * 0.35)
            ey = int(by + math.sin(ang2) * length * 0.35)
            draw.line([(bx, by), (ex, ey)], fill=130, width=1)


def _accent(im: Image.Image, shapes: list[tuple[str, tuple]]) -> Image.Image:
    """Composite red accents onto grayscale base."""
    rgba = im.convert("RGBA")
    overlay = Image.new("RGBA", rgba.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    for kind, data in shapes:
        if kind == "rect":
            (x0, y0, x1, y1, a) = data
            d.rectangle([x0, y0, x1, y1], fill=(*RED, a))
        elif kind == "ellipse":
            (x0, y0, x1, y1, a) = data
            d.ellipse([x0, y0, x1, y1], fill=(*RED, a))
        elif kind == "line":
            (p0, p1, width, a) = data
            d.line([p0, p1], fill=(*RED, a), width=width)
        elif kind == "text":
            (pos, text, size, a) = data
            font = _font(size)
            d.text(pos, text, fill=(*RED, a), font=font)
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius=1.2))
    return Image.alpha_composite(rgba, overlay).convert("RGB")


def _font(size: int) -> ImageFont.FreeTypeFont:
    # Try project fonts, fall back to default
    candidates = [
        ROOT / "assets" / "fonts" / "Mynerve-Regular.ttf",
        ROOT / "assets" / "fonts" / "GrechenFuemen-Regular.ttf",
    ]
    for c in candidates:
        try:
            return ImageFont.truetype(str(c), size=size)
        except Exception:
            pass
    return ImageFont.load_default()


def _label(draw: ImageDraw.ImageDraw, w: int, h: int, key: str) -> None:
    # Subtle identifier, low opacity
    text = key.replace("_", " ").upper()
    font = _font(14)
    draw.text((10, h - 22), text, fill=80, font=font)


def render_asset(asset: TargetAsset) -> Image.Image:
    size = BG_SIZE if asset.kind == "BG" else IMG_SIZE
    base = _noir_base(size, asset.kind)
    w, h = base.size
    im = base.copy()
    d = ImageDraw.Draw(im)

    k = asset.key
    path_name = asset.path.name.lower()

    # --- Templates (simple, consistent noir silhouettes) ---
    # Prefer explicit filename hints (mapping uses descriptive names).
    if asset.kind == "BG":
        if "apartment" in path_name:
            # Apartment night: big window + rain + distant blocks
            d.rectangle([int(w * 0.12), int(h * 0.1), int(w * 0.88), int(h * 0.78)], outline=175, width=3)
            # rain streaks
            for i in range(40):
                x = int(w * 0.14 + i * (w * 0.018))
                d.line([(x, int(h * 0.12)), (x + 10, int(h * 0.76))], fill=115, width=1)
            # city blocks silhouettes
            for i in range(7):
                bw = int(w * 0.08 + i * (w * 0.01))
                bx = int(w * 0.14 + i * (w * 0.11))
                by = int(h * 0.62 + (i % 2) * 10)
                d.rectangle([bx, by, bx + bw, int(h * 0.78)], fill=35, outline=70, width=1)
            im = _accent(im, [("text", ((int(w * 0.34), int(h * 0.18)), "02:17", 30, 210))])

        elif "bathroom" in path_name:
            # Bathroom: mirror + sink
            d.rounded_rectangle([int(w * 0.18), int(h * 0.12), int(w * 0.82), int(h * 0.62)], radius=22, outline=175, width=3)
            d.rectangle([int(w * 0.22), int(h * 0.66), int(w * 0.78), int(h * 0.9)], outline=175, width=3)
            d.ellipse([int(w * 0.34), int(h * 0.72), int(w * 0.66), int(h * 0.86)], outline=140, width=2)
            im = _accent(im, [("ellipse", (int(w * 0.47), int(h * 0.2), int(w * 0.53), int(h * 0.26), 140))])

        elif "bedroom" in path_name:
            # Bedroom: bed + shadow
            d.rectangle([int(w * 0.12), int(h * 0.55), int(w * 0.88), int(h * 0.82)], outline=175, width=3)
            d.rectangle([int(w * 0.18), int(h * 0.48), int(w * 0.42), int(h * 0.58)], outline=145, width=2)
            for i in range(10):
                x0 = int(-w * 0.1 + i * (w * 0.14))
                d.line([(x0, int(h * 0.35)), (x0 + int(w * 0.8), int(h * 0.98))], fill=90, width=22)
            im = _accent(im, [("ellipse", (int(w * 0.7), int(h * 0.44), int(w * 0.78), int(h * 0.52), 120))])

        elif "kitchen" in path_name:
            # Kitchen morning: counter + window (brighter)
            d.rectangle([int(w * 0.1), int(h * 0.62), int(w * 0.9), int(h * 0.88)], outline=175, width=3)
            d.rectangle([int(w * 0.2), int(h * 0.18), int(w * 0.8), int(h * 0.54)], outline=175, width=3)
            # window panes
            d.line([(w // 2, int(h * 0.18)), (w // 2, int(h * 0.54))], fill=140, width=2)
            d.line([(int(w * 0.2), int(h * 0.36)), (int(w * 0.8), int(h * 0.36))], fill=140, width=2)
            im = _accent(im, [("rect", (int(w * 0.2), int(h * 0.18), int(w * 0.8), int(h * 0.3), 60))])

        elif "livingroom" in path_name:
            # Living room memory: couch + notebook hint
            d.rectangle([int(w * 0.18), int(h * 0.6), int(w * 0.82), int(h * 0.82)], outline=175, width=3)
            d.rectangle([int(w * 0.22), int(h * 0.54), int(w * 0.42), int(h * 0.68)], outline=145, width=2)
            d.rectangle([int(w * 0.58), int(h * 0.54), int(w * 0.78), int(h * 0.68)], outline=145, width=2)
            im = _accent(im, [("ellipse", (int(w * 0.22), int(h * 0.22), int(w * 0.3), int(h * 0.3), 120))])

        elif "wall_close" in path_name:
            _draw_cracks(d, w, h, seed=13)
            d.rectangle([int(w * 0.12), int(h * 0.12), int(w * 0.88), int(h * 0.88)], outline=120, width=2)
            im = _accent(im, [("line", ((int(w * 0.18), int(h * 0.35)), (int(w * 0.82), int(h * 0.65)), 3, 110))])

        elif "phone_close" in path_name:
            # background phone close: huge phone silhouette
            d.rounded_rectangle([int(w * 0.18), int(h * 0.12), int(w * 0.82), int(h * 0.88)], radius=26, outline=175, width=3)
            d.rectangle([int(w * 0.26), int(h * 0.2), int(w * 0.74), int(h * 0.36)], outline=140, width=2)
            im = _accent(im, [("text", ((int(w * 0.32), int(h * 0.22)), "04:17", 30, 210))])

        elif "end_split" in path_name:
            # symbolic split (diagonal)
            d.line([(int(w * 0.15), int(h * 0.15)), (int(w * 0.85), int(h * 0.85))], fill=170, width=6)
            d.rectangle([int(w * 0.18), int(h * 0.18), int(w * 0.82), int(h * 0.82)], outline=140, width=2)
            im = _accent(im, [("line", ((int(w * 0.2), int(h * 0.82)), (int(w * 0.82), int(h * 0.2)), 4, 120))])

        elif "end_open" in path_name:
            # door slightly open with light
            d.rectangle([int(w * 0.25), int(h * 0.18), int(w * 0.75), int(h * 0.88)], outline=175, width=3)
            d.polygon([(int(w * 0.75), int(h * 0.22)), (int(w * 0.9), int(h * 0.3)), (int(w * 0.9), int(h * 0.82)), (int(w * 0.75), int(h * 0.84))], fill=60)
            im = _accent(im, [("rect", (int(w * 0.77), int(h * 0.24), int(w * 0.9), int(h * 0.84), 90))])

        elif "end_wall" in path_name:
            # breathing wall: wavy lines
            for i in range(24):
                y = int(h * 0.15 + i * (h * 0.03))
                pts = []
                for x in range(0, w + 1, 20):
                    dy = int(math.sin((x / 60) + i * 0.35) * 6)
                    pts.append((x, y + dy))
                d.line(pts, fill=115, width=2)
            im = _accent(im, [("ellipse", (int(w * 0.46), int(h * 0.45), int(w * 0.54), int(h * 0.53), 110))])

        elif "end_truth" in path_name:
            # stark window + rain + red dot
            d.rectangle([int(w * 0.1), int(h * 0.12), int(w * 0.9), int(h * 0.82)], outline=175, width=3)
            for i in range(34):
                x = int(w * 0.12 + i * (w * 0.023))
                d.line([(x, int(h * 0.14)), (x + 8, int(h * 0.8))], fill=110, width=1)
            im = _accent(im, [("ellipse", (int(w * 0.48), int(h * 0.22), int(w * 0.52), int(h * 0.26), 200))])

        else:
            # fall through to generic BG / later key-based handling
            pass

    if "hallway" in k or "endless_hall" in k or "hallway" in path_name:
        _draw_hallway(d, w, h)
        im = _accent(im, [("ellipse", (int(w * 0.47), int(h * 0.22), int(w * 0.53), int(h * 0.28), 180))])

    elif "stairs" in k or "stairs" in path_name:
        # repeating stairs
        for i in range(14):
            y = int(h * 0.25 + i * (h * 0.045))
            x0 = int(w * (0.18 + i * 0.01))
            x1 = int(w * (0.82 - i * 0.01))
            d.rectangle([x0, y, x1, y + 6], outline=150, width=2)
        im = _accent(im, [("line", ((int(w * 0.2), int(h * 0.24)), (int(w * 0.8), int(h * 0.24)), 3, 120))])

    elif "wall_cracks" in k or "cracks" in path_name:
        _draw_cracks(d, w, h, seed=7)
        im = _accent(im, [("line", ((int(w * 0.15), int(h * 0.35)), (int(w * 0.85), int(h * 0.65)), 2, 90))])

    elif "mirrorfracture" in k or "fracture" in path_name or "mirror_fracture" in path_name:
        # fractured mirror shards
        d.rectangle([int(w * 0.18), int(h * 0.12), int(w * 0.82), int(h * 0.88)], outline=170, width=3)
        for i in range(11):
            x0 = int(w * 0.2 + i * (w * 0.055))
            d.line([(x0, int(h * 0.14)), (int(w * 0.78), int(h * 0.86))], fill=140, width=2)
            d.line([(int(w * 0.22), int(h * 0.86)), (x0, int(h * 0.14))], fill=110, width=1)
        im = _accent(im, [("ellipse", (int(w * 0.45), int(h * 0.46), int(w * 0.55), int(h * 0.56), 110))])

    elif "phone" in k or "phone" in path_name or "dial" in k:
        # phone close-up
        d.rounded_rectangle([int(w * 0.22), int(h * 0.18), int(w * 0.78), int(h * 0.9)], radius=18, outline=170, width=3)
        d.rectangle([int(w * 0.28), int(h * 0.26), int(w * 0.72), int(h * 0.46)], outline=130, width=2)
        # keypad
        for r in range(3):
            for c in range(3):
                x = int(w * 0.32 + c * (w * 0.12))
                y = int(h * 0.52 + r * (h * 0.1))
                d.ellipse([x, y, x + 18, y + 18], outline=120, width=2)
        accents = [("rect", (int(w * 0.29), int(h * 0.27), int(w * 0.71), int(h * 0.45), 55))]
        if "0217" in k:
            accents.append(("text", ((int(w * 0.34), int(h * 0.29)), "02:17", 28, 210)))
        elif "dial" in k:
            accents.append(("ellipse", (int(w * 0.6), int(h * 0.78), int(w * 0.66), int(h * 0.84), 170)))
        else:
            accents.append(("text", ((int(w * 0.34), int(h * 0.29)), "MARA", 28, 210)))
        im = _accent(im, accents)

    elif "window" in k or "rain" in path_name:
        # rainy window
        d.rectangle([int(w * 0.12), int(h * 0.14), int(w * 0.88), int(h * 0.86)], outline=170, width=3)
        for i in range(32):
            x = int(w * 0.14 + i * (w * 0.023))
            d.line([(x, int(h * 0.16)), (x + 10, int(h * 0.84))], fill=115, width=1)
        im = _accent(im, [("text", ((int(w * 0.34), int(h * 0.2)), "02:17", 28, 200))])

    elif "ear" in k:
        # ear to wall silhouette
        d.rectangle([int(w * 0.55), int(h * 0.08), int(w * 0.86), int(h * 0.92)], outline=120, width=2)
        d.ellipse([int(w * 0.18), int(h * 0.32), int(w * 0.42), int(h * 0.62)], outline=170, width=3)
        d.ellipse([int(w * 0.26), int(h * 0.4), int(w * 0.38), int(h * 0.56)], outline=140, width=2)
        im = _accent(im, [("line", ((int(w * 0.44), int(h * 0.47)), (int(w * 0.55), int(h * 0.47)), 3, 140))])

    elif "door" in path_name or "neighbor_door" in k or "chain" in k:
        # door + chain
        d.rectangle([int(w * 0.22), int(h * 0.1), int(w * 0.78), int(h * 0.9)], outline=170, width=3)
        d.ellipse([int(w * 0.7), int(h * 0.5), int(w * 0.74), int(h * 0.54)], outline=140, width=2)
        # chain
        for i in range(10):
            x0 = int(w * 0.44 + i * (w * 0.02))
            y0 = int(h * 0.3 + (i % 2) * 3)
            d.ellipse([x0, y0, x0 + 10, y0 + 10], outline=150, width=2)
        im = _accent(im, [("line", ((int(w * 0.44), int(h * 0.31)), (int(w * 0.62), int(h * 0.33)), 3, 120))])

    elif "key" in path_name or "key_" in k:
        # key silhouette
        d.rectangle([int(w * 0.46), int(h * 0.18), int(w * 0.54), int(h * 0.68)], outline=170, width=3)
        d.ellipse([int(w * 0.42), int(h * 0.12), int(w * 0.58), int(h * 0.28)], outline=170, width=3)
        # teeth
        d.rectangle([int(w * 0.54), int(h * 0.55), int(w * 0.62), int(h * 0.6)], fill=150)
        d.rectangle([int(w * 0.54), int(h * 0.62), int(w * 0.68), int(h * 0.67)], fill=150)
        im = _accent(im, [("ellipse", (int(w * 0.44), int(h * 0.14), int(w * 0.56), int(h * 0.26), 140))])

    elif "notebook" in path_name or "open_note" in path_name or "note_" in k:
        # open notebook / note
        d.rectangle([int(w * 0.16), int(h * 0.2), int(w * 0.84), int(h * 0.82)], outline=170, width=3)
        d.line([(w // 2, int(h * 0.2)), (w // 2, int(h * 0.82))], fill=140, width=2)
        for i in range(8):
            y = int(h * 0.28 + i * (h * 0.06))
            d.line([(int(w * 0.2), y), (int(w * 0.46), y)], fill=120, width=1)
            d.line([(int(w * 0.54), y), (int(w * 0.8), y)], fill=120, width=1)
        im = _accent(im, [("line", ((int(w * 0.22), int(h * 0.32)), (int(w * 0.78), int(h * 0.32)), 3, 110))])

    elif "hands" in path_name or "sink" in path_name:
        # sink + hands
        d.rectangle([int(w * 0.2), int(h * 0.4), int(w * 0.8), int(h * 0.85)], outline=170, width=3)
        d.ellipse([int(w * 0.32), int(h * 0.48), int(w * 0.68), int(h * 0.78)], outline=140, width=2)
        d.ellipse([int(w * 0.28), int(h * 0.55), int(w * 0.44), int(h * 0.8)], outline=150, width=2)
        d.ellipse([int(w * 0.56), int(h * 0.55), int(w * 0.72), int(h * 0.8)], outline=150, width=2)
        im = _accent(im, [("rect", (int(w * 0.48), int(h * 0.32), int(w * 0.52), int(h * 0.42), 150))])

    elif "bed" in path_name or "bedroom" in path_name:
        # bed silhouette
        d.rectangle([int(w * 0.15), int(h * 0.58), int(w * 0.85), int(h * 0.82)], outline=170, width=3)
        d.rectangle([int(w * 0.18), int(h * 0.52), int(w * 0.42), int(h * 0.6)], outline=140, width=2)
        im = _accent(im, [("ellipse", (int(w * 0.72), int(h * 0.48), int(w * 0.78), int(h * 0.54), 130))])

    elif "shadow" in path_name or "shadowline" in k:
        # dramatic diagonal shadow
        for i in range(16):
            x0 = int(-w * 0.2 + i * (w * 0.12))
            d.line([(x0, 0), (x0 + int(w * 0.8), h)], fill=120, width=18)
        im = _accent(im, [("line", ((int(w * 0.1), int(h * 0.2)), (int(w * 0.9), int(h * 0.8)), 6, 80))])

    else:
        # generic noir scene
        d.rectangle([int(w * 0.1), int(h * 0.12), int(w * 0.9), int(h * 0.88)], outline=120, width=2)
        im = _accent(im, [("ellipse", (int(w * 0.45), int(h * 0.22), int(w * 0.55), int(h * 0.32), 110))])

    # subtle label for debugging (can be removed later)
    _label(ImageDraw.Draw(im), w, h, asset.key)

    # Sharpen for crisp comic look
    im = im.filter(ImageFilter.UnsharpMask(radius=2, percent=140, threshold=3))
    return im


def main() -> None:
    if not ASSETS_JSON.exists():
        raise SystemExit(f"Missing assets mapping: {ASSETS_JSON}")

    data = json.loads(ASSETS_JSON.read_text(encoding="utf-8"))
    targets: list[TargetAsset] = []
    for kind in ("BG", "IMG"):
        for key, rel in data.get(kind, {}).items():
            targets.append(TargetAsset(kind=kind, key=key, path=ROOT / rel))

    # Ensure directories required by pubspec exist
    _ensure_dir(ROOT / "assets" / "bg")
    _ensure_dir(ROOT / "assets" / "sfx")
    _ensure_dir(ROOT / "assets" / "img")
    (ROOT / "assets" / "bg" / ".gitkeep").write_text("", encoding="utf-8")
    (ROOT / "assets" / "sfx" / ".gitkeep").write_text("", encoding="utf-8")

    created = 0
    for t in targets:
        _ensure_dir(t.path.parent)

        # Backup only the first time (if we haven't backed it up before).
        # If an original backup exists already, assume current file is generated and overwrite it.
        if t.kind == "IMG":
            backup_dir = ROOT / "assets" / "img" / "originals"
            _ensure_dir(backup_dir)
            if t.path.exists():
                dest = backup_dir / t.path.name
                if not dest.exists() and (ROOT / ".git").exists():
                    # Move the pre-existing file into backups once.
                    t.path.replace(dest)

        im = render_asset(t)

        ext = t.path.suffix.lower()
        if ext in (".jpg", ".jpeg"):
            im.save(t.path, format="JPEG", quality=88, optimize=True, progressive=True)
        else:
            im.save(t.path, format="PNG", optimize=True)
        created += 1

    print(f"Generated {created} noir placeholder assets into assets/bg and assets/img.")


if __name__ == "__main__":
    main()


