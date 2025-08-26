extends Node

func load_font(node : RichTextLabel, font_path : String, size : int):
	var _font = FontFile.new()
	_font.load_dynamic_font(font_path)
	node.add_theme_font_override("normal_font", _font)
	node.add_theme_font_size_override("normal_font_size", size)

# used for linear "lerping"
func calculate_diff(val, newval, add):
	if abs(val - newval) <= add: val = newval
	elif val > newval: val -= add
	else: val += add
	return val

func time_format(seconds: int) -> String:
	var hours   = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var _seconds = seconds % 60
	
	if hours > 0: return "%d:%02d:%02d" % [hours, minutes, _seconds]
	else: return "%d:%02d" % [minutes, _seconds]
