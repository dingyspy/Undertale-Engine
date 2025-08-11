extends Node2D

func _ready() -> void:
	
	#$attacks/border.to(Vector2(0,0))
	await get_tree().create_timer(2).timeout
	$attacks/border.to(0,0,true)
