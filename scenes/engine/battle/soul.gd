extends CharacterBody2D

# soul modes
# 0: menu, 1: red, 2: blue
var mode = 0
# speed of the soul in all modes
var speed = 150

@onready var sprite = $sprite

var fall_spd = 0
var jump_dir = Vector2.UP
var jump_force = -180

func _process(delta: float) -> void:
	var menu_x = -(int(Input.is_action_pressed("left")) - int(Input.is_action_pressed("right")))
	var menu_y = -(int(Input.is_action_pressed("up")) - int(Input.is_action_pressed("down")))
	var input_vector = Vector2(menu_x,menu_y).normalized()
	
	var cancel_div = (int(Input.is_action_pressed("cancel")) + 1)
	match mode:
		0: velocity = Vector2(0,0)
		1: velocity = input_vector * speed / cancel_div
		2:
			var ang = int(round(rad_to_deg(rotation))) % 360
			var jump_input = false
			
			if fall_spd > 15: fall_spd += 540 * delta
			elif fall_spd > -30: fall_spd += 180 * delta
			elif fall_spd > -120: fall_spd += 450 * delta
			else: fall_spd += 180 * delta
			
			match ang:
				0:
					jump_dir = Vector2.UP
					velocity = Vector2(Input.get_axis("left","right") * speed / cancel_div, fall_spd)
					jump_input = Input.is_action_pressed("up")
				180:
					jump_dir = Vector2.DOWN
					velocity = Vector2(Input.get_axis("left","right") * speed / cancel_div, -fall_spd)
					jump_input = Input.is_action_pressed("down")
				90:
					jump_dir = Vector2.RIGHT
					velocity = Vector2(-fall_spd, Input.get_axis("up","down") * speed / cancel_div)
					jump_input = Input.is_action_pressed("right")
				270:
					jump_dir = Vector2.LEFT
					velocity = Vector2(fall_spd, Input.get_axis("up","down") * speed / cancel_div)
					jump_input = Input.is_action_pressed("left")
			
			if is_on_floor() or (is_on_ceiling() and fall_spd <= 0):
				fall_spd = 0
				if is_on_floor() and jump_input:
					fall_spd = jump_force
			elif not jump_input and fall_spd <= -30:
				fall_spd = -30
	if mode != 0: move_and_slide()

func change_mode(_mode : int):
	mode = _mode
	
	match _mode:
		0,1: sprite.modulate = Color(1,0,0)
		2: sprite.modulate = Color(0,0,1)
	if _mode != 0: Audio.play('bell')
