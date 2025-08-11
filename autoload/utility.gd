extends Node

func load_font(node : RichTextLabel, font_path : String, size : int):
	var _font = FontFile.new()
	_font.load_dynamic_font(font_path)
	node.add_theme_font_override("normal_font", _font)
	node.add_theme_font_size_override("normal_font_size", size)
