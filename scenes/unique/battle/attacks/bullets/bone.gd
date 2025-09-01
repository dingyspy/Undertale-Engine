extends NinePatchRect

var _position
var _size
var _rotation = 0
var _direction = Vector2.ZERO
var _speed = 150
var _pivot = 'bottom'
var _bone_type = 'sans'

var damage = 1
var kr_damage = 2
# color is handled in the attacks script
var type = 0

@onready var collision = $hitbox/collision

func _ready():
	collision.shape = RectangleShape2D.new()
	collision.shape.size.x = 10.0
	size.y = _size
	rotation_degrees = _rotation
	
	pivot_offset = return_pivot()
	position = _position - pivot_offset
	
	match _bone_type:
		"sans":
			texture = load("res://sprites/engine/battle/bullets/bone/bone_sans.png")
			patch_margin_left = 0; patch_margin_top = 6
			patch_margin_right = 0; patch_margin_bottom = 6
		"papyrus":
			texture = load("res://sprites/engine/battle/bullets/bone/bone_papyrus.png")
			patch_margin_left = 0; patch_margin_top = 4
			patch_margin_right = 0; patch_margin_bottom = 4

func _process(delta: float) -> void:
	_position += _direction * _speed * delta
	
	pivot_offset = return_pivot()
	position = _position - pivot_offset
	
	collision.shape.size.y = _size
	collision.position.y = _size / 2.0
	
	size.y = _size
	
	if (_direction == Vector2.RIGHT and global_position.x > 650) or (_direction == Vector2.LEFT and global_position.x < -10) or (_direction == Vector2.DOWN and global_position.x > 490) or (_direction == Vector2.UP and global_position.x < -10): queue_free()

func return_pivot() -> Vector2:
	match _pivot:
		"center": return Vector2(size.x, _size) / 2.0
		"top": return Vector2(size.x / 2.0, 0.0)
		"bottom": return Vector2(size.x / 2.0, _size)
		_: return Vector2(size.x, _size) / 2.0
