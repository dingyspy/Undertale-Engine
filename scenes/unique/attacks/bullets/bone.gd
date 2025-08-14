extends NinePatchRect

var _position
var _size
var _rotation
var _direction
var _speed
var _pivot
var _bone_type = 'sans'

var damage = 1
var kr_damage = 2

@onready var collision = $hitbox/collision

func _ready():
	size.y = _size
	position = _position - size / 2
	rotation_degrees = _rotation
	
	match _bone_type:
		'sans':
			texture = load('res://sprites/engine/battle/bullets/bone/bone_sans.png')
			patch_margin_left = 0
			patch_margin_top = 6
			patch_margin_right = 0
			patch_margin_bottom = 6
		'papyrus':
			texture = load('res://sprites/engine/battle/bullets/bone/bone_papyrus.png')
			patch_margin_left = 0
			patch_margin_top = 4
			patch_margin_right = 0
			patch_margin_bottom = 4

func _process(delta: float) -> void:
	position += _direction * delta * _speed
	match _pivot:
		'center': pivot_offset = size / 2
		'top': pivot_offset = Vector2(size.x / 2, position.y)
		'bottom': pivot_offset = Vector2(size.x / 2, position.y + size.y)
	collision.shape.size.y = size.y
	collision.position.y = size.y / 2
	
	if global_position.x > 650 or global_position.x < -10 or global_position.y > 490 or global_position.y < -10: queue_free()
