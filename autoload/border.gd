extends Node

@onready var border_frame = $border_frame
@onready var black = $black

var border_toggled = false

func _ready() -> void:
	border_frame.visible = false
	black.modulate.a = 0

# smoothly transitions border frames
func smooth_transition(frame):
	var t = get_tree().create_tween()
	t.tween_property(black, 'modulate:a', 1, 0.5)
	await t.finished
	
	border_frame.frame = frame
	if frame == 0: border_frame.material.set('shader_parameter/dark', 0.05)
	else: border_frame.material.set('shader_parameter/dark', 0)
	
	t = get_tree().create_tween()
	t.tween_property(black, 'modulate:a', 0, 0.5)

# toggles the border to the value: enabled
func set_border(enabled : bool = true):
	border_toggled = enabled
	if border_toggled:
		border_frame.visible = true
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		get_window().content_scale_size = Vector2(960,540)
		get_window().position -= Vector2i(960-640,540-480) / 2
		DisplayServer.window_set_size(Vector2(960,540))
	else:
		border_frame.visible = false
		get_window().content_scale_size = Vector2(640,480)
		get_window().position += Vector2i(960-640,540-480) / 2
		DisplayServer.window_set_size(Vector2(640,480))
