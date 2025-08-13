extends Node2D

@onready var text = $box/text
@onready var ref = $box/ref
@onready var box = $box
@onready var tail = $tail
# if you dont want the bubble to automatically scale with text, set to true
var fixed = false
# values for above boolean
# fixed x is used for auto scaling
@export var fixed_x = 120
@export var fixed_y = 100
# flips the dialog box
# cant be undone during runtime
@export var flipped = false

var prev_text = ''

func _process(delta):
	ref.text = text.text
	if ref.get_theme_font("normal_font") != text.get_theme_font("normal_font"): ref.add_theme_font_override("normal_font", text.get_theme_font("normal_font"))
	
	if flipped:
		scale.x = -1
		text.scale.x = -1
	
	if !fixed:
		if prev_text != text.text:
			prev_text = text.text
			
			var font = text.get_theme_font("normal_font")
			var font_size = text.get_theme_font_size("normal_font_size")
			var chr_est_size = font.get_string_size('a', HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			
			text.size.x = fixed_x
			text.position.x = 12
			await get_tree().process_frame
			text.size = Vector2(fixed_x,chr_est_size.y * ref.get_line_count())
			ref.size = text.size
			if ref.get_line_count() > 1: box.size = Vector2(clamp(fixed_x + chr_est_size.x * 2, 47.0, 1000),clamp(chr_est_size.y * (ref.get_line_count() + 1), 60.0, 1000))
			else: box.size = Vector2(clamp(chr_est_size.x * (ref.text.length() * 1.3), 47.0, 1000),clamp(chr_est_size.y * (ref.get_line_count() + 1), 60.0, 1000))
			if flipped: text.position.x += text.size.x - 12
	else:
		text.position.x = 12
		text.size.x = fixed_x
		text.size.y = fixed_y
