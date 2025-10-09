extends CharacterBody2D

# soul modes
# 0: menu, 1: red, 2: blue
var mode = 0
# speed of the soul in all modes
var speed = 150

@onready var sprite = $sprite
@onready var hitbox = $hitbox

var fall_spd = 0
var jump_dir = Vector2.UP
var jump_force = -180
var prev_position = position
var iframes = 0
var iframes_toggle = false
var kr_time = 0
var dmg_time = 0
var in_air = false
var engine

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(-(int(Input.is_action_pressed("left")) - int(Input.is_action_pressed("right"))),-(int(Input.is_action_pressed("up")) - int(Input.is_action_pressed("down"))))
	
	var cancel_div = (int(Input.is_action_pressed("cancel")) + 1)
	# add custom modes here
	match mode:
		0: velocity = Vector2.ZERO
		1: velocity = input_vector * speed / cancel_div
		2:
			var rot = int(sprite.rotation_degrees) % 360
			var jump_input = false
			
			# 100% accurate... sob sob
			if fall_spd > 15: fall_spd += 540 * delta
			elif fall_spd > -30: fall_spd += 180 * delta
			elif fall_spd > -120: fall_spd += 450 * delta
			else: fall_spd += 180 * delta
			
			var on_ground = false
			match rot:
				0:
					jump_dir = Vector2.UP
					velocity = Vector2(input_vector.x * speed / cancel_div, fall_spd)
					jump_input = Input.is_action_pressed("up")
					on_ground = is_on_floor()
				180:
					jump_dir = Vector2.DOWN
					velocity = Vector2(input_vector.x * speed / cancel_div, -fall_spd)
					jump_input = Input.is_action_pressed("down")
					on_ground = is_on_ceiling()
				90:
					jump_dir = Vector2.RIGHT
					velocity = Vector2(-fall_spd, input_vector.y * speed / cancel_div)
					jump_input = Input.is_action_pressed("right")
					var col = get_last_slide_collision()
					on_ground = is_on_wall() and col and col.get_normal() == Vector2.RIGHT
				270:
					jump_dir = Vector2.LEFT
					velocity = Vector2(fall_spd, input_vector.y * speed / cancel_div)
					jump_input = Input.is_action_pressed("left")
					var col = get_last_slide_collision()
					on_ground = is_on_wall() and col and col.get_normal() == Vector2.LEFT
			
			if on_ground:
				if in_air:
					in_air = false
					Audio.play('impact')
					if engine: engine.camera.shake(4)
				
				fall_spd = 0
				if jump_input:
					fall_spd = jump_force
			elif not jump_input and fall_spd <= -30:
				fall_spd = -30
	if mode != 0: move_and_slide()
	
	# checks if soul hitbox is overlapping with any bullet,
	# if so checks bullet type and calls take_damage()
	for found in hitbox.get_overlapping_areas():
		if found.get_parent().is_in_group("bullets") and iframes <= 0:
			var bullet = found.get_parent()
			if 'damage' in bullet:
				var damage = 0
				if 'type' in bullet:
					match bullet.type:
						0: damage = bullet.damage
						1: if abs(position - prev_position).normalized() != Vector2.ZERO: damage = bullet.damage
						2: if abs(position - prev_position).normalized() == Vector2.ZERO: damage = bullet.damage
				else: damage = bullet.damage
				take_damage(damage, bullet.kr_damage if 'kr_damage' in bullet else 0)
	prev_position = position
	
	# for the iframes when hit
	if iframes > 0:
		iframes -= delta
		sprite.play("default")
	else:
		if iframes_toggle:
			iframes_toggle = false
			sprite.stop()
			sprite.frame = 0
	
	# delay between hits
	dmg_time += delta
	
	# handles the entire kr system
	Global.kr = clamp(Global.kr, -1, 40)
	Global.kr = clamp(Global.kr, -1, Global.hp - 1)
	if Global.kr > 0 and Global.hp > 1:
		kr_time += delta
		
		# toby why :'(
		var kr_threshold = [
			{"time": 0.05, "val": 40},
			{"time": 0.1,  "val": 30},
			{"time": 0.25, "val": 20},
			{"time": 0.75, "val": 10},
			{"time": 1.5,  "val": 0},
		]
		
		for i in kr_threshold:
			if kr_time > i.time and Global.kr >= i.val:
				Global.hp -= 1
				Global.kr -= 1
				kr_time = 0
				break
		Global.hp = clamp(Global.hp, 0, Global.maxhp)

# self explanatory, changes mode
# mode colors can be changed here
func change_mode(_mode : int, rot : int = 0):
	mode = _mode
	
	match _mode:
		0,1: sprite.modulate = Color(1,0,0)
		2: sprite.modulate = Color(0,0,1)
	if _mode != 0: Audio.play('bell')
	sprite.rotation_degrees = rot

# use vector.left, up, r, ... for direction, similar to spawning bones / bone stabs
func throw(vector : Vector2 = Vector2.DOWN, speed : int = 700):
	var rot = 0
	match vector:
		Vector2.LEFT: rot = 90
		Vector2.UP: rot = 180
		Vector2.RIGHT: rot = 270
	
	change_mode(2,rot)
	
	await get_tree().process_frame
	fall_spd = speed
	in_air = true

# if kr is -1, its basically inactive
func take_damage(damage, kr_damage):
	if damage == 0: return
	
	if dmg_time >= 1.0 / 30.0:
		dmg_time = 0
		if iframes <= 0:
			Global.hp -= damage
			if Global.kr > -1: Global.kr += kr_damage
			else:
				if Global.hp > 0:
					iframes = 2
					iframes_toggle = true
			Audio.play('hurt')
