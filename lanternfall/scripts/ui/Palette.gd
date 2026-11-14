class_name Palette
## Central colour + sizing tokens for the minimalist vector look.

const BG := Color("10121a")
const BG_2 := Color("171a26")
const PANEL := Color("1f2333")
const PANEL_2 := Color("2a2f45")
const LINE := Color("3a4160")
const TEXT := Color("eef1fa")
const TEXT_DIM := Color("9aa3c0")
const GOLD := Color("f2b84b")
const HP := Color("e5484d")
const HP_BG := Color("3b1a22")
const BLOCK := Color("5ab0ff")
const ENERGY := Color("ffcf4a")
const GOOD := Color("46c37b")
const BAD := Color("ff6b6b")
const BUFF := Color("7ee0a1")
const DEBUFF := Color("c38bff")

const ATTACK := Color("e8664f")
const SKILL := Color("4f9be8")
const POWER := Color("e8c14f")
const CURSE := Color("7a6a8a")

const RARITY := {
	"starter": Color("8a93ad"),
	"common": Color("b8c0d8"),
	"uncommon": Color("4fc3e8"),
	"rare": Color("f2b84b"),
	"special": Color("c38bff"),
	"boss": Color("ff6b9a"),
	"shop": Color("7ee0a1"),
}

const NODE_COLORS := {
	"monster": Color("e8664f"),
	"elite": Color("ff4f7b"),
	"rest": Color("46c37b"),
	"shop": Color("f2b84b"),
	"event": Color("8f7bff"),
	"treasure": Color("ffd56b"),
	"boss": Color("ff2f55"),
}

static func type_color(card_type: String) -> Color:
	match card_type:
		"attack": return ATTACK
		"skill": return SKILL
		"power": return POWER
	return CURSE

static func flat(bg: Color, radius: int = 14, border: Color = Color(0, 0, 0, 0), border_w: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	if border_w > 0:
		sb.border_color = border
		sb.set_border_width_all(border_w)
	sb.anti_aliasing = true
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb

static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 20
	t.set_color("font_color", "Label", TEXT)
	var face := Color("2b3150")
	var rim := Color("7c88b4")
	t.set_stylebox("normal", "Button", UISkin.button_box(face, rim, "normal"))
	t.set_stylebox("hover", "Button", UISkin.button_box(face, GOLD, "hover"))
	t.set_stylebox("pressed", "Button", UISkin.button_box(face, GOLD, "pressed"))
	t.set_stylebox("disabled", "Button", UISkin.button_box(face, rim, "disabled"))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_outline_color", "Button", Color(0, 0, 0, 0.75))
	t.set_constant("outline_size", "Button", 5)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", GOLD)
	t.set_color("font_pressed_color", "Button", GOLD)
	t.set_color("font_disabled_color", "Button", TEXT_DIM.darkened(0.3))
	t.set_font_size("font_size", "Button", 22)
	t.set_stylebox("panel", "PanelContainer", UISkin.panel_box(PANEL, LINE))
	t.set_stylebox("panel", "Panel", UISkin.panel_box(PANEL, LINE))
	# Touch friendly scrollbars.
	var grabber := flat(LINE, 6)
	t.set_stylebox("grabber", "VScrollBar", grabber)
	t.set_stylebox("grabber_highlight", "VScrollBar", flat(GOLD, 6))
	t.set_stylebox("grabber_pressed", "VScrollBar", flat(GOLD, 6))
	t.set_stylebox("scroll", "VScrollBar", flat(BG_2, 6))
	t.set_stylebox("grabber", "HScrollBar", grabber)
	t.set_stylebox("grabber_highlight", "HScrollBar", flat(GOLD, 6))
	t.set_stylebox("grabber_pressed", "HScrollBar", flat(GOLD, 6))
	t.set_stylebox("scroll", "HScrollBar", flat(BG_2, 6))
	return t
