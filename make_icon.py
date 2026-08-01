#!/usr/bin/env python3
"""Bold single-emblem app icon for Bầu Cua Tôm Cá: a gold medallion/die-token
(rounded square, beveled gradient, soft drop shadow — same "single dimensional
object" formula that reads well on the sibling TienLen/PhomTaLa icons) with a
flat, chunky, embossed crab (Cua) glyph engraved on its face, tilted slightly,
on a deep red-to-black Tet-festival gradient. No text.

Design rationale (see CLAUDE.md icon-quality pass): an earlier version rendered
the crab as a flat gold silhouette assembled from thin separate primitive
shapes (segmented stick legs, ellipse-plus-line claws) directly on the red
background — it read as clip-art with no dimensionality and a cluttered
multi-limbed outline at small sizes. This version borrows the exact recipe that
works for the card-game siblings (rounded shape + real bevel/highlight gradient
+ soft drop shadow + one bold flat glyph on top) instead of trying to shade an
organic creature directly.
"""

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
img = Image.new("RGB", (SIZE, SIZE), "#3a0a0a")
draw = ImageDraw.Draw(img)

# ---------------------------------------------------------------------------
# Background: deep red -> near-black gradient (Tet-festival palette).
# ---------------------------------------------------------------------------
top = (60, 11, 11)
bottom = (14, 3, 3)
for y in range(SIZE):
    t = y / SIZE
    r = int(top[0] + (bottom[0] - top[0]) * t)
    g = int(top[1] + (bottom[1] - top[1]) * t)
    b = int(top[2] + (bottom[2] - top[2]) * t)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b))


def diagonal_gradient(w, h, light, dark, power=1.0):
    """Low-res diagonal (top-left -> bottom-right) gradient, upscaled with
    bicubic resampling for a smooth bevel-style highlight without numpy."""
    base = 96
    small = Image.new("RGB", (base, base))
    px = small.load()
    for j in range(base):
        for i in range(base):
            t = ((i / (base - 1)) + (j / (base - 1))) / 2.0
            t = t ** power
            r = int(light[0] + (dark[0] - light[0]) * t)
            g = int(light[1] + (dark[1] - light[1]) * t)
            b = int(light[2] + (dark[2] - light[2]) * t)
            px[i, j] = (r, g, b)
    return small.resize((w, h), Image.BICUBIC)


cx, cy = SIZE / 2, SIZE / 2

# ---------------------------------------------------------------------------
# Assembly layer: token (medallion) + crab glyph, built unrotated then
# rotated once as a whole so nothing has to be hand-tilted piece by piece.
# ---------------------------------------------------------------------------
assembly = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

# --- Drop shadow for the token, soft and offset down-right for lift. ---
token_w = token_h = SIZE * 0.72
token_radius = token_w * 0.24
shadow_mask = Image.new("L", (SIZE, SIZE), 0)
sd = ImageDraw.Draw(shadow_mask)
sd.rounded_rectangle(
    [cx - token_w / 2, cy - token_h / 2, cx + token_w / 2, cy + token_h / 2],
    radius=token_radius,
    fill=255,
)
shadow_mask = shadow_mask.filter(ImageFilter.GaussianBlur(SIZE * 0.022))
shadow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
shadow_layer.paste((0, 0, 0, 150), (int(SIZE * 0.016), int(SIZE * 0.02)), shadow_mask)
assembly = Image.alpha_composite(assembly, shadow_layer)

# --- Token body: rounded-square gold medallion with a real diagonal bevel. ---
token_mask = Image.new("L", (SIZE, SIZE), 0)
td = ImageDraw.Draw(token_mask)
token_box = [cx - token_w / 2, cy - token_h / 2, cx + token_w / 2, cy + token_h / 2]
td.rounded_rectangle(token_box, radius=token_radius, fill=255)

gold_light = (255, 222, 140)
gold_dark = (140, 78, 22)
bevel = diagonal_gradient(SIZE, SIZE, gold_light, gold_dark, power=1.15)
token_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
token_layer.paste(bevel, (0, 0), token_mask)

# Crisp edge stroke so the token reads clearly against the red background.
edge_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
ed = ImageDraw.Draw(edge_layer)
ed.rounded_rectangle(token_box, radius=token_radius, outline=(112, 58, 14, 255),
                      width=max(2, int(SIZE * 0.006)))
token_layer = Image.alpha_composite(token_layer, edge_layer)

# Soft glossy specular highlight, upper-left, for a "gem/enamel" pop.
spec_mask = Image.new("L", (SIZE, SIZE), 0)
spd = ImageDraw.Draw(spec_mask)
spec_w, spec_h = token_w * 0.55, token_h * 0.32
spd.ellipse(
    [cx - token_w * 0.28 - spec_w / 2, cy - token_h * 0.28 - spec_h / 2,
     cx - token_w * 0.28 + spec_w / 2, cy - token_h * 0.28 + spec_h / 2],
    fill=140,
)
spec_mask = spec_mask.filter(ImageFilter.GaussianBlur(SIZE * 0.03))
# Clip the specular blob to the token silhouette so it doesn't spill outside.
spec_mask_clipped = Image.new("L", (SIZE, SIZE), 0)
spec_mask_clipped.paste(spec_mask, (0, 0), token_mask)
spec_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
spec_layer.paste((255, 250, 225, 255), (0, 0), spec_mask_clipped)
token_layer = Image.alpha_composite(token_layer, spec_layer)

assembly = Image.alpha_composite(assembly, token_layer)


# ---------------------------------------------------------------------------
# Crab (Cua) glyph: bold, chunky, flat silhouette engraved on the token face,
# drawn twice with a small offset (dark copy down-right, main copy up-left)
# to fake an embossed/engraved bevel without needing per-limb gradients.
# ---------------------------------------------------------------------------

def gpt(x, y, dx=0, dy=0):
    return (cx + x * SIZE + dx, cy + y * SIZE + dy)


def bold_line(d, p0, p1, width, fill):
    d.line([p0, p1], fill=fill, width=int(width))
    r = width / 2
    d.ellipse([p0[0] - r, p0[1] - r, p0[0] + r, p0[1] + r], fill=fill)
    d.ellipse([p1[0] - r, p1[1] - r, p1[0] + r, p1[1] + r], fill=fill)


def draw_crab(d, dx, dy, fill):
    # Body: bold rounded shell — drawn first so leg/claw roots tuck under it.
    bw, bh = SIZE * 0.32, SIZE * 0.225
    body_c = gpt(0, 0.01, dx, dy)
    d.ellipse([body_c[0] - bw / 2, body_c[1] - bh / 2,
               body_c[0] + bw / 2, body_c[1] + bh / 2], fill=fill)

    # Legs: 3 per side, single thick bent stroke each — short and chunky,
    # kept well inside the token's rounded edge for a contained, confident
    # silhouette (no thin sticks reaching toward the corners).
    leg_w = SIZE * 0.046
    for side in (-1, 1):
        for by in (-0.025, 0.025, 0.075):
            hip = gpt(side * 0.135, by, dx, dy)
            foot = gpt(side * 0.225, by + 0.055, dx, dy)
            bold_line(d, hip, foot, leg_w, fill)

    # Claws: shoulder arm + a two-lobe merged pincer blob (main knuckle +
    # smaller, more offset tip lobe so it reads as a pincer, not a cloud) —
    # one continuous silhouette, no separate line, pulled in from the
    # top corners for breathing room against the token edge.
    for side in (-1, 1):
        shoulder = gpt(side * 0.095, -0.075, dx, dy)
        claw_c = gpt(side * 0.195, -0.155, dx, dy)
        bold_line(d, shoulder, claw_c, SIZE * 0.050, fill)
        rx, ry = SIZE * 0.066, SIZE * 0.052
        d.ellipse([claw_c[0] - rx, claw_c[1] - ry, claw_c[0] + rx, claw_c[1] + ry], fill=fill)
        tip_c = gpt(side * 0.255, -0.195, dx, dy)
        tr = SIZE * 0.034
        d.ellipse([tip_c[0] - tr, tip_c[1] - tr, tip_c[0] + tr, tip_c[1] + tr], fill=fill)



crab_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
cd = ImageDraw.Draw(crab_layer)

emboss_shadow = (46, 8, 6, 255)
main_color = (108, 20, 14, 255)

off = SIZE * 0.007
draw_crab(cd, off, off, emboss_shadow)
draw_crab(cd, -off * 0.4, -off * 0.4, main_color)

# Two small bright accent dots for eyes, sitting on the shell between the
# claws — a touch of face detail without any protruding stalk lines.
eye_r = SIZE * 0.017
eye_accent = (200, 150, 90, 255)
for side in (-1, 1):
    e = gpt(side * 0.05, -0.045)
    cd.ellipse([e[0] - eye_r, e[1] - eye_r, e[0] + eye_r, e[1] + eye_r], fill=eye_accent)

assembly = Image.alpha_composite(assembly, crab_layer)

# ---------------------------------------------------------------------------
# Rotate the whole medallion+glyph assembly for a dynamic, confident tilt.
# ---------------------------------------------------------------------------
rotated = assembly.rotate(-6, resample=Image.BICUBIC, expand=False, center=(cx, cy))
img.paste(rotated, (0, 0), rotated)

out = "/Users/q/Projects/BauCua/BauCua/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
img.save(out)
print("wrote", out, img.size)
