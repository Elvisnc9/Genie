"""Builds Genie's placeholder illustrations from the mockups in design/.

The mockups are flat screenshots: pins, cards, text and controls are baked into
the room renders. This script cuts the renders out and inpaints the baked UI so
the app can draw that UI live (and animate it) on top.

These are stand-ins until real, layered art exists. Re-run after changing a
region:  python tool/extract_art.py
Needs Pillow and numpy (dev only, not app dependencies).
"""

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
DESIGN = ROOT / "design"
OUT = ROOT / "assets" / "images"
OUT.mkdir(parents=True, exist_ok=True)

# Full-size mockups are 1170 px wide; coordinates below are written in the
# 924 px "display" space they were measured in, then scaled.
K = 1170 / 924


def load(name):
    return np.asarray(Image.open(DESIGN / name).convert("RGB")).astype(np.float32)


def rect_mask(shape, rects, scale=K, pad=0):
    m = Image.new("L", (shape[1], shape[0]), 0)
    d = ImageDraw.Draw(m)
    for x0, y0, x1, y1 in rects:
        d.rectangle([x0 * scale - pad, y0 * scale - pad, x1 * scale + pad, y1 * scale + pad], fill=255)
    return np.asarray(m) > 0


def ellipse_mask(shape, ellipses, scale=K):
    m = Image.new("L", (shape[1], shape[0]), 0)
    d = ImageDraw.Draw(m)
    for x0, y0, x1, y1 in ellipses:
        d.ellipse([x0 * scale, y0 * scale, x1 * scale, y1 * scale], fill=255)
    return np.asarray(m) > 0


def _relax(img, mask, iters):
    """Jacobi iterations of Laplace's equation inside the mask."""
    out = img.copy()
    for _ in range(iters):
        p = np.pad(out, ((1, 1), (1, 1), (0, 0)), mode="edge")
        avg = (p[:-2, 1:-1] + p[2:, 1:-1] + p[1:-1, :-2] + p[1:-1, 2:]) / 4
        out[mask] = avg[mask]
    return out


def inpaint(img, mask, levels=5, iters=60):
    """Multi-scale harmonic inpainting: smooth fills that match the edges.
    Great for walls, gradients and soft fabric; textures blur slightly."""
    if levels == 0 or min(mask.shape) < 32:
        seed = img.copy()
        seed[mask] = img[~mask].mean(axis=0) if (~mask).any() else 0
        return _relax(seed, mask, iters * 4)
    h, w = mask.shape
    small_img = np.asarray(
        Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).resize((w // 2, h // 2), Image.BILINEAR)
    ).astype(np.float32)
    small_mask = np.asarray(Image.fromarray((mask * 255).astype(np.uint8)).resize((w // 2, h // 2), Image.BILINEAR)) > 0
    coarse = inpaint(small_img, small_mask, levels - 1, iters)
    up = np.asarray(Image.fromarray(np.clip(coarse, 0, 255).astype(np.uint8)).resize((w, h), Image.BILINEAR)).astype(
        np.float32
    )
    seed = img.copy()
    seed[mask] = up[mask]
    return _relax(seed, mask, iters)


def circle_masks(shape, cx, cy, r_out, rim):
    yy, xx = np.mgrid[0 : shape[0], 0 : shape[1]]
    d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
    return d <= r_out, (d <= r_out) & (d > r_out - rim)


def inpaint_around(img, mask, circle):
    """Inpaints masked wall pixels outside [circle] without letting the dark
    object bleed into the fill."""
    return inpaint(img, mask | circle)


def fit_circle(points):
    """Least-squares circle through (x, y) points -> (cx, cy, r)."""
    x, y = points[:, 0].astype(float), points[:, 1].astype(float)
    A = np.c_[2 * x, 2 * y, np.ones_like(x)]
    b = x**2 + y**2
    cx, cy, c = np.linalg.lstsq(A, b, rcond=None)[0]
    return cx, cy, np.sqrt(c + cx**2 + cy**2)


def ring_alpha(shape, cx, cy, r_out, width, ss=4):
    """Anti-aliased ring coverage (0..1), drawn supersampled."""
    h, w = shape[:2]
    big = Image.new("L", (w * ss, h * ss), 0)
    d = ImageDraw.Draw(big)
    d.ellipse([(cx - r_out) * ss, (cy - r_out) * ss, (cx + r_out) * ss, (cy + r_out) * ss], fill=255)
    ri = r_out - width
    d.ellipse([(cx - ri) * ss, (cy - ri) * ss, (cx + ri) * ss, (cy + ri) * ss], fill=0)
    return np.asarray(big.resize((w, h), Image.LANCZOS)).astype(np.float32) / 255


def rebuild_rim(out, img, hidden, dark_thresh=45, search=None, rim_width=None):
    """Fits the mirror's dark rim from visible pixels and redraws it where
    [hidden] covered it. Returns (cx, cy, r_out, width)."""
    lum = img.mean(axis=2)
    rim_px = (lum < dark_thresh) & ~grow(hidden, 3)
    if search is not None:
        rim_px &= search
    ys, xs = np.nonzero(rim_px)
    cx, cy, r_mid = fit_circle(np.c_[xs, ys])
    d = np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2)
    width = rim_width if rim_width else max(2.0, np.percentile(d, 95) - np.percentile(d, 5))
    r_out = r_mid + width / 2
    colour = np.median(img[rim_px], axis=0)
    a = ring_alpha(img.shape, cx, cy, r_out, width) * hidden
    out[:] = out * (1 - a[..., None]) + colour * a[..., None]
    return cx, cy, r_out, width


def save(arr, name, quality=90):
    im = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    path = OUT / name
    if name.endswith(".jpg"):
        im.convert("RGB").save(path, quality=quality, optimize=True, progressive=True)
    else:
        im.save(path, optimize=True)
    print(f"{name}: {im.size[0]}x{im.size[1]}, {path.stat().st_size // 1024} KB")


def grow(mask, px):
    return np.asarray(Image.fromarray((mask * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(px * 2 + 1))) > 0


# ---------------------------------------------------------------- onboarding 1
def onboarding_room():
    img = load("02-onboarding-1.png")
    mask = rect_mask(
        img.shape,
        [
            (50, 130, 292, 200),  # wordmark
            (780, 130, 880, 195),  # Skip
            (44, 266, 864, 493),  # headline (incl. descenders)
            (212, 1222, 892, 1450),  # product card + its shadow
            (736, 1050, 814, 1134),  # pin on the chair
            (672, 930, 724, 984),  # sparkle on sofa
            (836, 988, 876, 1028),  # sparkle on chair
            (48, 1515, 880, 1700),  # body copy
            (40, 1760, 900, 1930),  # dots + Next
        ],
    )
    # Keep the mirror out of the fill, or its dark rim bleeds into the wall
    # where the headline was.
    circle, _ = circle_masks(img.shape, 467 * K, 661 * K, 165 * K, 0)
    out = inpaint(img, mask | circle)
    out[circle & ~mask] = img[circle & ~mask]
    save(out, "onboarding_room.jpg")
    return img, mask


# ---------------------------------------------------------------- onboarding 3
def onboarding_ai_room():
    img = load("04-onboarding-3-ai.png")
    h, w, _ = img.shape
    mask = rect_mask(
        img.shape,
        [
            (50, 130, 292, 200),
            (780, 130, 880, 195),
            (44, 266, 864, 493),  # headline
            (76, 1012, 406, 1098),  # "Sage sofa" pin + pill
            (36, 1338, 890, 1660),  # suggestion card + shadow
            (48, 1675, 880, 1780),  # body copy
            (40, 1760, 900, 1930),  # dots + Next
        ],
    )
    pill = rect_mask(img.shape, [(436, 704, 836, 783)])  # "Soft sage wall" pin + pill
    # Dashed suggestion box + sparkle: only the teal strokes, not the table.
    R, G, B = img[..., 0], img[..., 1], img[..., 2]
    teal = (G - R > 25) & (B - R > 15) & (R < 140)
    box = rect_mask(img.shape, [(700, 892, 888, 1266)])
    mask |= grow(teal & box, 4)

    # The mirror: rebuild what the pill covers from its left/right symmetry.
    cx, cy, r_out = 467 * K, 661 * K, 162 * K
    circle, _ = circle_masks(img.shape, cx, cy, r_out + 3, 9)
    out = inpaint_around(img, mask | pill, circle)  # wall + everything outside the mirror
    yy, xx = np.nonzero(pill & circle)
    src_x = np.clip((2 * cx - xx).round().astype(int), 0, w - 1)
    ok = ~pill[yy, src_x]
    out[yy[ok], xx[ok]] = img[yy[ok], src_x[ok]]
    # The narrow strip on the axis of symmetry has no clean source: fill it from
    # the repaired mirror around it.
    rest = np.zeros_like(pill)
    rest[yy[~ok], xx[~ok]] = True
    out = inpaint(out, rest)
    # The poster sits on that axis too: redraw its cream card and green disc
    # from their measured geometry.
    vis = circle & ~pill
    cream = vis & (np.minimum(np.minimum(R, G), B) > 200)
    cy_, cx_ = np.nonzero(cream)
    px0, px1, py0, py1 = cx_.min(), cx_.max(), cy_.min(), cy_.max()
    green = vis & (G - R > 8) & (G - B > 15) & (R < 150)
    gy, gx = np.nonzero(green)
    gcx = (px0 + px1) / 2
    gr = gcx - gx.min()
    gcy = gy.min() + gr
    yy2, xx2 = np.mgrid[0:h, 0:w]
    in_card = (xx2 >= px0) & (xx2 <= px1) & (yy2 >= py0) & (yy2 <= py1)
    in_disc = (xx2 - gcx) ** 2 + (yy2 - gcy) ** 2 <= gr**2
    # Glass below the card on the axis: interpolate across each row.
    glass_rest = rest & ~in_card
    for y in np.unique(np.nonzero(glass_rest)[0]):
        xs = np.nonzero(glass_rest[y])[0]
        xl, xr = xs.min() - 2, xs.max() + 2
        t = ((xs - xl) / (xr - xl))[:, None]
        out[y, xs] = out[y, xl] * (1 - t) + out[y, xr] * t
    fix = rest & in_card
    out[fix & ~in_disc] = np.median(img[cream], axis=0)
    out[fix & in_disc] = np.median(img[green], axis=0)
    out[circle & ~pill & ~mask] = img[circle & ~pill & ~mask]

    # Crop off the baked teal edge glow, then scale back to full size.
    band = int(26 * K)
    inner = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).crop((band, band, w - band, h - band))
    save(np.asarray(inner.resize((w, h), Image.LANCZOS)).astype(np.float32), "onboarding_ai_room.jpg")



def _fabric_bbox(arr):
    R, G, B = arr[..., 0], arr[..., 1], arr[..., 2]
    m = (R - B > 45) & (R > 150)
    ys, xs = np.nonzero(m)
    return xs.min(), ys.min(), xs.max(), ys.max()


def patch_chair_from_detail(clean, original):
    """Where the onboarding chips overlapped the chair, the inpaint leaves a
    smudge. The detail mockup has the same render with nothing on top, so
    scale it onto this chair and use it for those spots."""
    det = np.asarray(Image.open(DESIGN / "08-detail.png").convert("RGB")).astype(np.float32)
    det = det[180:600, 120:480]  # chair area in the detail crop
    dx0, dy0, dx1, dy1 = _fabric_bbox(det)
    # Fabric bbox of the onboarding chair, measured away from the chips.
    region = original.copy()
    px0, py0, px1, py1 = _fabric_bbox(region[int(560 * K):int(1260 * K), int(140 * K):int(800 * K)])
    px0 += int(140 * K); px1 += int(140 * K); py0 += int(560 * K); py1 += int(560 * K)
    sx = (px1 - px0) / (dx1 - dx0)
    sy = (py1 - py0) / (dy1 - dy0)
    big = Image.fromarray(det.astype(np.uint8)).resize((int(det.shape[1] * sx), int(det.shape[0] * sy)), Image.LANCZOS)
    big = np.asarray(big).astype(np.float32)
    ox = int(round(px0 - dx0 * sx))
    oy = int(round(py0 - dy0 * sy))

    damaged = rect_mask(clean.shape, [(380, 612, 545, 692), (130, 636, 795, 664), (150, 980, 250, 1080)])
    h, w = big.shape[:2]
    window = np.zeros(clean.shape[:2], bool)
    window[max(0, oy):oy + h, max(0, ox):ox + w] = True
    target = damaged & window
    ys, xs = np.nonzero(target)
    src = big[ys - oy, xs - ox]
    # Only take chair pixels from the detail render; leave background alone.
    R, G, B = src[:, 0], src[:, 1], src[:, 2]
    chairish = (R - B > 30) | (np.abs(R - G) + np.abs(G - B) > 40) | (src.mean(axis=1) < 200)
    out = clean.copy()
    out[ys[chairish], xs[chairish]] = src[chairish]
    # Soften the seam.
    seam = grow(target, 3) & ~grow(target, -1) if False else grow(target, 2) & ~target
    blur = np.asarray(Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2))).astype(np.float32)
    out[seam] = blur[seam]
    return out

# ---------------------------------------------------------------- onboarding 2
FABRICS = {
    # Target colours for the recoloured chair (catalog fabric hexes).
    "terracotta": None,  # the source render
    "oat": (226, 214, 196),
    "sage": (142, 158, 128),
    "navy": (52, 62, 82),
}


def onboarding_chair():
    img = load("03-onboarding-2.png")
    # Remove the "80 cm" line + chip, the "360°" chip and the turntable's teal
    # dashes before cutting out.
    mask = rect_mask(img.shape, [(130, 640, 795, 660), (392, 616, 532, 686), (50, 990, 242, 1072)])
    R0, G0, B0 = img[..., 0], img[..., 1], img[..., 2]
    mask |= grow((G0 - R0 > 25) & (B0 - R0 > 15) & (R0 < 140), 3)
    clean = inpaint(img, mask)
    clean = patch_chair_from_detail(clean, img)

    # Chair region (display coords) -> crop.
    x0, y0, x1, y1 = (int(v * K) for v in (150, 585, 790, 1250))
    crop = clean[y0:y1, x0:x1]
    h, w, _ = crop.shape

    # Soft rectangular feather so the plate melts into the app background.
    yy, xx = np.mgrid[0:h, 0:w]
    f = 0.08
    ax = np.clip(np.minimum(xx / (w * f), (w - 1 - xx) / (w * f)), 0, 1)
    ay = np.clip(np.minimum(yy / (h * f), (h - 1 - yy) / (h * f)), 0, 1)
    alpha = ax * ay

    # Fabric weight: soft on the edges so blended pixels recolour partially.
    R, G, B = crop[..., 0], crop[..., 1], crop[..., 2]
    fabric = np.clip(((R - B) - 15) / 30, 0, 1) * (R > 120)
    # Wooden legs: inside the leg areas, by their green/red ratio.
    legs = np.zeros(fabric.shape, bool)
    for lx0, ly0, lx1, ly1 in [(240, 990, 290, 1150), (500, 1060, 545, 1245), (624, 1012, 668, 1118)]:
        legs[int(ly0 * K) - y0 : int(ly1 * K) - y0, int(lx0 * K) - x0 : int(lx1 * K) - x0] = True
    ratio = G / np.maximum(R, 1)
    legs &= (R < 200) & (ratio > 0.66) & (ratio < 0.78)
    fabric = fabric * ~grow(legs, 1)
    fabric_soft = np.asarray(Image.fromarray((fabric * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8))) / 255.0
    fabric = fabric_soft > 0.5

    lum = 0.2126 * R + 0.7152 * G + 0.0722 * B
    ref = np.median(lum[fabric])
    for name, target in FABRICS.items():
        out = crop.copy()
        if target is not None:
            t = np.array(target, np.float32)
            shade = (lum / ref)[..., None]
            recol = np.clip(t * shade**1.1, 0, 255)
            out = out * (1 - fabric_soft[..., None]) + recol * fabric_soft[..., None]
        rgba = np.dstack([out, alpha * 255])
        save(rgba, f"chair_lune_{name}.png")
    print("chair crop origin (display):", x0 / K, y0 / K, "size:", w / K, h / K)


# ---------------------------------------------------------------- onboarding 4
def camera_preview():
    img = load("05-onboarding-4-camera.png")
    x0, y0, x1, y1 = (int(v * K) for v in (57, 255, 867, 848))
    save(img[y0:y1, x0:x1], "camera_preview.jpg")


# ---------------------------------------------------------------- home
def home_room():
    im = Image.open(DESIGN / "06-home.png").convert("RGB")
    # Screen area inside the phone frame (crop space, ~1.5 px/pt).
    sx0, sy0, sx1, sy1 = 12, 12, 597, 1280
    img = np.asarray(im.crop((sx0, sy0, sx1, sy1))).astype(np.float32)
    h, w, _ = img.shape
    S = 1.0

    def r(x0, y0, x1, y1):
        return (x0 - sx0, y0 - sy0, x1 - sx0, y1 - sy0)

    mask = rect_mask(
        img.shape,
        [
            r(36, 88, 116, 166),  # settings button
            r(392, 88, 572, 166),  # AI pill
            r(46, 1116, 136, 1206),  # thumbnail
            r(224, 1086, 380, 1238),  # + button
            r(468, 1112, 562, 1202),  # shutter
        ],
        scale=S,
    )
    chip = rect_mask(img.shape, [r(112, 184, 496, 252), r(200, 168, 440, 190)], scale=S)  # status chip + rim above it
    mask |= grow(ellipse_mask(img.shape, [r(184, 856, 426, 940)], scale=S), 3)  # reticle, just its ellipse
    # Floor outline and dots: pure white strokes (the rug is warm off-white).
    R, G, B = img[..., 0], img[..., 1], img[..., 2]
    white = np.minimum(np.minimum(R, G), B) > 244
    floor = np.zeros(mask.shape, bool)
    floor[715 - sy0 : 1065 - sy0, 10:-10] = True
    mask |= grow(white & floor, 3)
    # On the wooden boards the dots are softer; catch them with a looser test.
    boards = np.zeros(mask.shape, bool)
    boards[960 - sy0 : 1065 - sy0, 10:-10] = True
    mask |= grow((np.minimum(np.minimum(R, G), B) > 205) & boards, 3)
    # Phone frame: rounded corners and any dark frame pixels near the border.
    corner = Image.new("L", (w, h), 0)
    ImageDraw.Draw(corner).rounded_rectangle([3, 3, w - 4, h - 4], radius=80, fill=255)
    mask |= np.asarray(corner) == 0
    border = np.ones(mask.shape, bool)
    border[14:-14, 14:-14] = False
    mask |= border & (np.maximum(np.maximum(R, G), B) < 90)

    # Mirror: the chip hides its top. Fit the rim from what is visible, fill
    # the glass from the nearest clean pixel below, then redraw the rim arc.
    search = rect_mask(img.shape, [r(190, 160, 450, 440)], scale=S)
    lum = img.mean(axis=2)
    ys, xs = np.nonzero((lum < 45) & ~grow(chip, 3) & search)
    cx, cy, r_mid = fit_circle(np.c_[xs, ys])
    circle, _ = circle_masks(img.shape, cx, cy, r_mid + 6, 0)
    clean = inpaint_around(img, mask | chip, circle)
    clean[circle & ~chip] = img[circle & ~chip]
    glass = circle_masks(img.shape, cx, cy, r_mid - 2, 0)[0]
    poster = (np.minimum(np.minimum(R, G), B) > 150) & glass
    for x in np.unique(np.nonzero(glass & chip)[1]):
        col = np.nonzero(glass[:, x] & ~chip[:, x] & ~poster[:, x])[0]
        holes = np.nonzero(glass[:, x] & chip[:, x])[0]
        if len(col) and len(holes):
            clean[holes, x] = img[col[np.argmin(np.abs(col - holes.max()))], x]
    sm = np.asarray(Image.fromarray(np.clip(clean, 0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(2))).astype(np.float32)
    clean[glass & chip] = sm[glass & chip]
    rebuild_rim(clean, img, chip.astype(np.float32), search=search, rim_width=5.5)
    up = Image.fromarray(np.clip(clean, 0, 255).astype(np.uint8)).resize((w * 2, h * 2), Image.LANCZOS)
    save(np.asarray(up).astype(np.float32), "home_room.jpg", quality=88)


# ---------------------------------------------------------------- catalog art
def catalog_art():
    sheet = Image.open(DESIGN / "07-furniture-sheet.png").convert("RGB")

    def tile(box, cover, name):
        arr = np.asarray(sheet.crop(box)).astype(np.float32)
        m = rect_mask(arr.shape, [(c[0] - box[0], c[1] - box[1], c[2] - box[0], c[3] - box[1]) for c in cover], scale=1)
        save(inpaint(arr, m), name)

    # Nord chair tile (inner tile area), with the 3D button removed. The Lune
    # armchair uses the full-size chair renders instead.
    tile((327, 845, 554, 1012), [(495, 852, 548, 904)], "piece_nord.png")
    # Collection card: remove the baked label.
    tile((42, 474, 417, 667), [(56, 590, 300, 655)], "collection_living_room.jpg")

    # Lamp thumbnail from the onboarding 3 card.
    ob3 = load("04-onboarding-3-ai.png")
    x0, y0, x1, y1 = (int(v * K) for v in (86, 1466, 214, 1596))
    save(ob3[y0:y1, x0:x1], "piece_arc_lamp.png")

    # Reading corner: left part of the onboarding 1 room.
    room = np.asarray(Image.open(OUT / "onboarding_room.jpg").convert("RGB")).astype(np.float32)
    save(room[int(560 * K) : int(1260 * K), 0 : int(560 * K)], "collection_reading_corner.jpg")


if __name__ == "__main__":
    onboarding_room()
    onboarding_ai_room()
    onboarding_chair()
    camera_preview()
    home_room()
    catalog_art()
