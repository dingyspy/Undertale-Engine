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
	#border.toggle_attack_render()
	await get_tree().create_timer(1).timeout
	border.to([null,200],[250,150])
	print(border.CENTER)
	
	await get_tree().create_timer(2).timeout
	soul.throw(Vector2.DOWN)
	var a = attack.spawn(attack.bullets.BONE, {
		_position = Vector2(border.LEFT + 10, border.UP),
		_size = border.DISTANCE.y,
		_speed = 10,
		_direction = Vector2.RIGHT,
		_pivot = 'top'
	}, true)
	
	var t = get_tree().create_tween()
	t.tween_property(a, '_size', 20, 1)
	
	await get_tree().create_timer(12).timeout
	border.to([null,400],[150,150])
	
	var g = attack.spawn(attack.bullets.GASTER_BLASTER, {
		_target_position = Vector2(320,100),
	}, false)
	engine.get_node('../other').add_child(g)
	
	#var t = get_tree().create_tween()
	#t.tween_property(border, 'target_rotation', 90, 1)
	
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
