extends Node

signal end

var battle
var engine
var border
var soul
var bullets
var attack

func _ready() -> void:
	print('turn forfeit attack')
	await get_tree().create_timer(1).timeout
	end.emit()
