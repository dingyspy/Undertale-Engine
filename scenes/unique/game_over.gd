extends Node2D

# example implementation
func _ready() -> void:
	while true:
		if Input.is_action_just_pressed("accept"): break
		await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/engine/overworld/singleton.tscn")
