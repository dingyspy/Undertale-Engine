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
	print('attacking')
	await get_tree().create_timer(2).timeout
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
