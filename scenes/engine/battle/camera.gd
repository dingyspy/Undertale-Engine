extends Camera2D

# 0 uses sin and cos
# 1 uses offset
@export var type = 0
# if false, the screen will keep shaking
var subtract = true

var _shake = 0
var _rotation = 0

var target_position = Vector2(320,240)
var target_rotation = 0

var siner = 0
func _process(delta: float) -> void:
	siner += delta * 30
	
	if _shake > 0:
		if subtract: _shake -= delta * 7
		
		match type:
			0: position = target_position + Vector2(sin(siner / 0.1) * _shake,cos(siner / 0.2) * _shake)
			1: position = target_position + Vector2([-1,1][randi() % 2] * _shake,[-1,1][randi() % 2] * _shake)
	
	if _rotation > 0:
		if subtract: _rotation -= delta * 5
		
		match type:
			0: rotation_degrees = target_rotation + cos(siner / 0.2) * _rotation
			1: rotation_degrees = target_rotation + [-1,1][randi() % 2] * _rotation

func shake(val, valr=0):
	_shake = val
	_rotation = valr
