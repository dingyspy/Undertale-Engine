extends Node2D

var _position = Vector2.ZERO
var _target_position
var _rotation = 90
var _target_rotation = 0
var _scale = Vector2(2,2)
# measured in delta, not seconds/ms
var _pause = 10
# same as above
var _blast_time = 10
# if set, itll shake the screen
var camera
var _z_index = 0

var damage = 1
var kr_damage = 2

@onready var sprite = $sprite
@onready var blast = $blast
@onready var center = $blast/center
@onready var top = $blast/top
@onready var top2 = $blast/top2
@onready var notifier = $sprite/notifier
@onready var collision = $hitbox/collision

var state = -1
var leave_speed = 0
var blast_timer = 0
var sizex = 0
var fade = 1

func _ready():
	sprite.scale = _scale
	center.visible = false
	top.visible = false
	top2.visible = false
	position = _position
	rotation_degrees = _rotation
	state = 0
	if _scale.x >= 2: Audio.play('blaster_summon', 1)
	else: Audio.play('blaster_summon', 1.2)

var siner = 0
func _process(delta: float) -> void:
	match state:
		0:
			var difference = _target_position - position
			var rot_difference = _target_rotation - rotation_degrees
			position += difference / 3
			rotation_degrees += rot_difference / 3
			
			if difference.length() < 0.1 and abs(rotation_degrees) <= 0.01: state = 1
		1:
			_pause -= delta * 30
			if _pause <= 0:
				_pause = 7
				state = 2
		2:
			_pause -= delta * 30
			sprite.play("blast")
			if _pause <= 0:
				state = 3
				if camera and _scale.x >= 2: camera.shake(3)
				Audio.play('blaster_fire')
				Audio.play('gigatalk', 1.18, 0, -5, 2.5)
		3:
			blast_timer += delta * 30
			siner += delta * 30
			
			sprite.play("end")
			
			if blast_timer < 5:
				leave_speed += 60 * delta
				sizex += floor((35.0 * _scale.x) / (_scale.x + 2)) * delta * 30
			else: leave_speed += 120 * delta
			if !notifier.is_on_screen(): leave_speed = 0
			
			if blast_timer > 5 + _blast_time:
				sizex *= pow(0.8, delta * 30)
				if sizex <= 2: queue_free()
				fade -= delta * 3
			
			if fade >= 0.8: collision.disabled = false
			else: collision.disabled = true
			
			var new_sizex = sin(siner / 1.5) * sizex / 4
			var rand_vec = Vector2((randf() * 2) - (randf() * 2),0)
			
			position += (Vector2.UP * leave_speed).rotated(rotation_degrees) * delta * 30
			center.size = Vector2(sizex + new_sizex,5000)
			center.position.x = -center.size.x / 2 + rand_vec.x
			center.position.y = 50 + (_scale.x - 1) * 26
			
			var topsize = sizex / 1.25
			top.size = Vector2(topsize,10)
			top.position = center.position + Vector2(center.size.x / 2 - topsize / 2,-top.size.y) + rand_vec
			
			var topsize2 = sizex / 2.0
			top2.size = Vector2(topsize2,10)
			top2.position = center.position + Vector2(center.size.x / 2 - topsize2 / 2,-top.size.y * 2) + rand_vec
			
			top.visible = true
			top2.visible = true
			center.visible = true
			blast.modulate.a = fade
			
			collision.shape.size.y = center.size.y / 2
			collision.shape.size.x = center.size.x - 10
			collision.position.y = collision.shape.size.y / 2
