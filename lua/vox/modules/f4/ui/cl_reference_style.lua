vox.f4 = vox.f4 or {}

local FALLBACK = {
    bg = Color(3, 11, 24, 246),
    panel = Color(6, 20, 40, 238),
    card = Color(8, 27, 52, 232),
    card2 = Color(10, 36, 68, 232),
    border = Color(0, 174, 255, 110),
    accent = Color(0, 174, 255),
    green = Color(35, 225, 120),
    red = Color(255, 75, 95),
    amber = Color(255, 190, 65),
    text = Color(240, 248, 255),
    soft = Color(145, 172, 200)
}

local function blendColor(a, b, t, alpha)
    a = a or FALLBACK.bg
    b = b or FALLBACK.bg

    return Color(
        math.Clamp(a.r + (b.r - a.r) * t, 0, 255),
        math.Clamp(a.g + (b.g - a.g) * t, 0, 255),
        math.Clamp(a.b + (b.b - a.b) * t, 0, 255),
        alpha or a.a or 255
    )
end

function vox.f4.GetReferenceColors()
    local colors = vox.GetUIThemeColors and vox.GetUIThemeColors() or {}
    local primary = colors.primary or FALLBACK.bg
    local secondary = colors.secondary or FALLBACK.panel

    return {
        bg = blendColor(FALLBACK.bg, primary, .35, 244),
        panel = blendColor(FALLBACK.panel, secondary, .38, 232),
        card = blendColor(FALLBACK.card, secondary, .22, 220),
        card2 = blendColor(FALLBACK.card2, secondary, .22, 216),
        border = ColorAlpha(colors.accent or FALLBACK.accent, 110),
        accent = colors.accent or FALLBACK.accent,
        money = colors.money or colors.positive or FALLBACK.green,
        positive = colors.positive or colors.money or FALLBACK.green,
        negative = colors.negative or FALLBACK.red,
        warning = colors.warning or FALLBACK.amber,
        text = colors.textPrimary or colors.text or FALLBACK.text,
        muted = colors.textSecondary or colors.muted or FALLBACK.soft
    }
end

local function roundedBox(x, y, w, h, r, color)
    draw.RoundedBox(r or 8, math.floor(x), math.floor(y), math.floor(w), math.floor(h), color)
end

function vox.f4.DrawReferencePanel(x, y, w, h, options)
    options = options or {}

    local colors = options.colors or vox.f4.GetReferenceColors()
    local accent = options.accent or colors.accent
    local base = options.color or colors.card
    local radius = options.radius or 8
    local lineAlpha = options.lineAlpha or 82
    local borderAlpha = options.borderAlpha or 58

    roundedBox(x, y, w, h, radius, ColorAlpha(base, options.alpha or base.a or 232))
    roundedBox(x + 1, y + 1, w - 2, h - 2, math.max(radius - 1, 0), ColorAlpha(colors.card2, options.innerAlpha or 32))

    surface.SetDrawColor(ColorAlpha(accent, lineAlpha))
    surface.DrawLine(x + radius, y + 1, x + math.min(w - radius, 170), y + 1)
    surface.SetDrawColor(ColorAlpha(colors.muted, 18))
    surface.DrawLine(x + radius, y + 2, x + w - radius, y + 2)
    surface.SetDrawColor(ColorAlpha(accent, borderAlpha))
    surface.DrawOutlinedRect(x, y, w, h, 1)
end

function vox.f4.DrawReferenceRow(panel, x, y, w, h, options)
    options = options or {}

    local colors = options.colors or vox.f4.GetReferenceColors()
    local hovered = IsValid(panel) and panel:IsHovered()
    options.color = options.color or ColorAlpha(colors.card2, hovered and 235 or 210)
    options.borderAlpha = options.borderAlpha or (hovered and 100 or 42)
    options.radius = options.radius or 7

    vox.f4.DrawReferencePanel(x, y, w, h, options)
end
