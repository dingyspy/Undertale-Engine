extends Node

func load_font(node : RichTextLabel, font_path : String, size : int):
	var _font = FontFile.new()
	_font.load_dynamic_font(font_path)
	var __font = FontVariation.new()
	__font.base_font = _font
	node.add_theme_font_override("normal_font", __font)
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

# gets all children and subchildren of children, recursive
func get_all_children(node):
	var nodes = []
	
	for i in node.get_children():
		if i.get_child_count() > 0:
			nodes.append(i)
			nodes.append_array(get_all_children(i))
		else: nodes.append(i)
	return nodes

func set_fullscreen(val):
	if val:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('fullscreen'): Utility.set_fullscreen(!DisplayServer.window_get_mode())
	if event.is_action_pressed('restart'): get_tree().reload_current_scene()
	if event.is_action_pressed('border'): Border.set_border(!Border.border_toggled)
