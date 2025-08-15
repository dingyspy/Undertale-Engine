extends Node2D

var _border
var _size = 70
var _direction = Vector2.DOWN
var _bone_type = 'sans'
var _wait_time = 50
var _stab_time = 50

var damage = 1
var kr_damage = 2
var type = 0
var state = -1
var shake = 6

@onready var bones = $bones
@onready var warning = $warning
@onready var collision = $hitbox/collision

func _ready() -> void:
	bones.size.x = 700
	match _direction:
		Vector2.DOWN:
			position = Vector2(640,_border.DOWN + 1)
			rotation_degrees = 0
			
			warning.position = Vector2(_border.LEFT + 5 - 640,-_size + 10)
			warning.size = Vector2(_border.DISTANCE.x - 10,_size - 15)
		Vector2.UP:
			position = Vector2(0,_border.UP - 1)
			rotation_degrees = 180
			
			warning.position = Vector2(_border.LEFT + 5 - 640,-_size + 10)
			warning.size = Vector2(_border.DISTANCE.x - 10,_size - 15)
		Vector2.LEFT:
			position = Vector2(_border.LEFT - 1,480)
			rotation_degrees = 90
			
			warning.position = Vector2(_border.LEFT + 5 - 480,-_size + 10)
			warning.size = Vector2(_border.DISTANCE.y - 10,_size - 15)
		Vector2.RIGHT:
			position = Vector2(_border.RIGHT + 1,0)
			rotation_degrees = -90
			
			warning.position = Vector2(-_border.RIGHT + 5,-_size + 10)
			warning.size = Vector2(_border.DISTANCE.y - 10,_size - 15)
	match _bone_type:
		'sans':
			bones.texture = load('res://sprites/engine/battle/bullets/bone/bone_sans.png')
			bones.patch_margin_left = 0
			bones.patch_margin_top = 6
			bones.patch_margin_right = 0
			bones.patch_margin_bottom = 6
		'papyrus':
			bones.texture = load('res://sprites/engine/battle/bullets/bone/bone_papyrus.png')
			bones.patch_margin_left = 0
			bones.patch_margin_top = 4
			bones.patch_margin_right = 0
			bones.patch_margin_bottom = 4
	state = 0

func _process(delta: float) -> void:
	match state:
		0:
			if _wait_time > 0: _wait_time -= delta * 30
			else:
				state = 1
				warning.visible = false
		1:
			bones.size += floor(bones.size / 3)
			if bones.size.y > _size:
				bones.size.y = _size
				state = 2
		2:
			_stab_time -= delta * 30
			
			if shake > 0: shake -= delta * 30
			else: shake = 0
			
			var rand0 = (randf() * shake) - (randf() * shake)
			var rand1 = (randf() * shake) - (randf() * shake)
			
			bones.position = Vector2(40 + rand0,12 + rand1)
			if _stab_time <= 0: state = 3
		3:
			bones.size -= floor(bones.size / 3)
			#if bones.size.y <= 0: queue_free()
