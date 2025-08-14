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
	
	engine.border.speed = 200
	border.to([null,200],[150,150])
	
	soul.throw(Vector2.UP)
	
	await get_tree().create_timer(1).timeout
	border.to([null,400],[150,150])
	
	var t = get_tree().create_tween()
	t.tween_property(border, 'rotation_degrees', 90, 1)
	
	attack.spawn(attack.bullets.BONE, {
		_position = border.CENTER,
		_size = border.DISTANCE.y,
		_rotation = 0,
		_pivot = 'center',
		_bone_type = 'papyrus',
		_direction = Vector2.RIGHT,
		_speed = 100,
	}, true)
	
	await get_tree().create_timer(2).timeout
	end.emit()
