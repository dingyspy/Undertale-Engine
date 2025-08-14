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
		pivot = 'center',
		type = 'papyrus'
	}, true)
	await get_tree().create_timer(1).timeout
	end.emit()
