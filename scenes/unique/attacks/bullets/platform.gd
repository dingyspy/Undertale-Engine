extends Node2D

var _position
var _size
var _rotation = 0
var _direction
var _speed = 0
var type = 0

@onready var white = $white
@onready var green = $green
@onready var collision = $hitbox/collision
@onready var stick_collision = $stick_hitbox/collision

func setup():
	position = _position
	rotation_degrees = _rotation
	
	white.size.x = _size
	green.size.x = _size
	
	green.position -= green.size / 2
	white.position -= white.size / 2

func _process(delta: float) -> void:
	position.x += delta * _speed
	
	match type:
		0:
			green.modulate = Color(0,0.5,0)
			collision.disabled = true
			stick_collision.disabled = false
		1:
			green.modulate = Color(0.5,0,0.5)
			collision.disabled = false
			stick_collision.disabled = true
	
	collision.shape.size.x = _size
	collision.position = white.position + white.size / 2
	stick_collision.shape.size.x = _size
	stick_collision.position = white.position + white.size / 2
	
	if global_position.x > 650 or global_position.x < -10 or global_position.y > 490 or global_position.y < -10: queue_free()
