extends Node2D

func _ready() -> void:
	$attacks/border.toggle_attack_render()
	$attacks/border.to([null,50],null)
	await get_tree().create_timer(2).timeout
	$attacks/border.to(null,null)
	$attacks/border.toggle_attack_render()
	await $attacks/border.finished
	var t = get_tree().create_tween()
	t.tween_property($attacks/border, 'rotation_degrees', 50, 5)
