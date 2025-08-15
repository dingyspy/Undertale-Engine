extends Node

signal end

var battle
var engine
var border
var soul
var bullets
var attack

func _ready() -> void:
	soul.change_mode(2)
	
	border.speed = 200
	border.toggle_attack_render()
	await get_tree().create_timer(1).timeout
	#border.to([null,200],[150,150])
	print(border.CENTER)
	
	soul.throw(Vector2.DOWN)
	attack.spawn(attack.bullets.GASTER_BLASTER, {
		_target_position = border.CENTER,
		camera = engine.camera,
		z_index = 2
	}, true)
	
	await get_tree().create_timer(12).timeout
	border.to([null,400],[150,150])
	
	var t = get_tree().create_tween()
	t.tween_property(border, 'target_rotation', 90, 1)
	
	attack.spawn(attack.bullets.BONE, {
		_position = border.CENTER,
		_size = border.DISTANCE.y,
		_rotation = 0,
		_pivot = 'center',
		_bone_type = 'papyrus',
		_direction = Vector2.RIGHT,
		_speed = 100,
	}, true)
	
	await get_tree().create_timer(10).timeout
	end.emit()
