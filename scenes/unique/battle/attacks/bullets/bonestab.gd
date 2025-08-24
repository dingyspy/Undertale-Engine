extends Node2D

var _border
var _size = 70
var _direction = Vector2.DOWN
var _bone_type = 'sans'
var _wait_time = 10
var _stab_time = 100

var damage = 1
var kr_damage = 2
var type = 0
var state = -1
var shake = 6
var prev_pos

@onready var bones = $bones
@onready var warning = $warning
@onready var collision = $hitbox/collision

func _ready() -> void:
	collision.shape = RectangleShape2D.new()
	bones.size.x = 700
	Audio.play('warning')
	match _direction:
		Vector2.DOWN:
			bones.position = Vector2(640,_border.DOWN + 1 + 15)
			
			warning.position = Vector2(_border.LEFT + 5,_border.DOWN - 5)
			warning.size = Vector2(_border.DISTANCE.x - 10,_size - 20)
			warning.scale.y = -1
		Vector2.UP:
			bones.position = Vector2(640,_border.UP - 1 - 15)
			bones.scale.y = -1
			
			warning.position = Vector2(_border.LEFT + 5,_border.UP + 5)
			warning.size = Vector2(_border.DISTANCE.x - 10,_size - 20)
		Vector2.LEFT:
			bones.position = Vector2(_border.LEFT - 1 - 15,0)
			bones.rotation_degrees = 90
			bones.scale.y = -1
			
			warning.position = Vector2(_border.LEFT + 5,_border.UP + 5)
			warning.size = Vector2(_size - 20,_border.DISTANCE.y - 10)
		Vector2.RIGHT:
			bones.position = Vector2(_border.RIGHT + 1 + 15,480)
			bones.rotation_degrees = -90
			bones.scale.y = -1
			
			warning.position = Vector2(_border.RIGHT -5,_border.UP + 5)
			warning.size = Vector2(_size - 20,_border.DISTANCE.y - 10)
			warning.scale.x = -1
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
				prev_pos = bones.position
				Audio.play('spear_rise')
				state = 2
		2:
			_stab_time -= delta * 30
			
			if shake > 0: shake -= delta * 30
			else: shake = 0
			
			var rand0 = (randf() * shake) - (randf() * shake)
			var rand1 = (randf() * shake) - (randf() * shake)
			
			bones.position = Vector2(prev_pos.x + rand0,prev_pos.y + rand1)
			if _stab_time <= 0: state = 3
		3:
			bones.size -= floor(bones.size / 3)
			if bones.size.y <= 0: queue_free()
	if bones.rotation_degrees == 90: collision.position = bones.position - Vector2(bones.size.y / 2,0) + Vector2(bones.size.y,0)
	elif bones.rotation_degrees == -90: collision.position = bones.position - Vector2(bones.size.y / 2,0)
	else:
		if bones.scale.y != -1: collision.position = bones.position - bones.size / 2
		else: collision.position = bones.position - bones.size / 2 + Vector2(0,bones.size.y)
	collision.shape.size = bones.size
	collision.rotation_degrees = bones.rotation_degrees
