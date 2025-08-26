extends CharacterBody2D

# mode for movement, similar to soul
# 0: cant move
# 1: regular
# 2: slide (ice sliding or whatevz)
var mode = 1
# player speed
var speed = 150

@onready var sprite = $sprite
@onready var hitbox = $hitbox
@onready var ray = $ray
var engine

var prev_vector = Vector2(0,0)
var dir = ''
const dirs = {
	[0.0,0.0] : '',
	[0.0,-1.0] : 'up',
	[1.0,0.0] : 'right',
	[0.0,1.0] : 'down',
	[-1.0,0.0] : 'left',
}


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var input_vector = Vector2(-(int(Input.is_action_pressed("left")) - int(Input.is_action_pressed("right"))),-(int(Input.is_action_pressed("up")) - int(Input.is_action_pressed("down"))))
	var sprint_mult = (int(Input.is_action_pressed("cancel")) * 0.5) + 1
	
	# for the spr update
	var real_speed = speed * sprint_mult
	match mode:
		0:
			velocity = Vector2.ZERO
			dir = ''
			prev_vector = Vector2.ZERO
			sprite.stop()
		1:
			velocity = input_vector * real_speed
	move_and_slide()
	if mode != 0: update_sprite(input_vector, real_speed)
	
	sprite.speed_scale = real_speed / 150.0
	# ray makes interactions / events more realistic & accurate
	match dir:
		'up':
			ray.rotation_degrees = 180
			ray.target_position.y = 16
		'down':
			ray.rotation_degrees = 0
			ray.target_position.y = 16
		'left':
			ray.rotation_degrees = 90
			ray.target_position.y = 36
		'right':
			ray.rotation_degrees = -90
			ray.target_position.y = 36
	
	# updates engine camera position, has to be called from here to prevent latency
	if engine: engine.update_camera(delta)

func update_sprite(input_vector, real_speed):
	# check if player is colliding with object
	if input_vector != velocity / real_speed:
		var difference = input_vector - velocity / real_speed
		# check if player is facing the collision, if true, set animation to player's direction
		if (input_vector.x == 0 and difference.y != 0) or (input_vector.y == 0 and difference.x != 0):
			if dirs.has([difference.x,difference.y]): sprite.animation = dirs[[difference.x,difference.y]]
		
		# set the input_vector to the new vector based on collisions
		input_vector = velocity / real_speed
	
	if prev_vector != input_vector:
		var formatted = [input_vector.x,input_vector.y]
		var set_dir = false
		
		# check if input_vector is found in dirs (down, up, left, right)
		if dirs.has(formatted): set_dir = true
		else:
			# if it's not, check if the player is switching directions
			if -input_vector.x == prev_vector.x and (dir == 'left' or dir == 'right'):
				formatted = [input_vector.x,0.0]
				set_dir = true
			if -input_vector.y == prev_vector.y and (dir == 'up' or dir == 'down'):
				formatted = [0.0,input_vector.y]
				set_dir = true
		
		if set_dir: dir = dirs[formatted]
		if prev_vector == Vector2.ZERO and !set_dir:
			if formatted[0] < 0.0: dir = dirs[[-1.0,0.0]]
			else: dir = dirs[[1.0,0.0]]
		
		# play / stop dir
		if dir != '':
			# to mimic the latency in undertale
			await get_tree().create_timer(0.04).timeout
			
			# check if mode was changed while waiting for latency
			if mode == 0:
				prev_vector = input_vector
				return
			
			# extra code for continuous playing
			var prev_frame = 0
			var prev_progress = 0
			if sprite.is_playing():
				prev_frame = sprite.frame
				prev_progress = sprite.frame_progress
			
			sprite.play(dir)
			sprite.set_frame_and_progress(prev_frame, prev_progress)
		else: sprite.stop()
	prev_vector = input_vector
