extends RichTextLabel

var font = 'main1'
var rdy = false

func _ready() -> void:
	while rdy == false: await get_tree().process_frame
	
	var blitter_info = Global.blitter_info[font]
	var _font = FontFile.new()
	_font.load_dynamic_font(blitter_info[0])
	add_theme_font_override("normal_font", _font)
	add_theme_font_size_override("normal_font_size", blitter_info[2])
