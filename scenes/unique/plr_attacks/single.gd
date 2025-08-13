extends Node2D

# note: * bordersetup must be emitted to setup the border / progress the menu
#       * you must use queue_free when finished

# emit this when the attack is finished
signal bordersetup

# tells the engine how much damage the enemy should take
# -1 == miss
var dmg = 0

@onready var slider = $slider
@onready var target = $target
@onready var strike = $strike

# set by the engine
var enemy
var border
var direction = 0
var pressed = 0

func _ready():
	target.modulate.a = 0
	Audio.store_audio({'laz':'res://audio/engine/snd_laz.wav'})
	start()

# start() is called through the engine
# attack is handled here
func start():
	target.modulate.a = 1
	
	slider.position.x = target.position.x + 275 * [1, -1][randi() % 2]
	slider.visible = true
	direction = sign(target.position.x - slider.position.x)

func hit_enemy():
	slider.play("default")
	Audio.play('laz')
	
	# damage calculation
	var b = 0
	if slider.position.x >= target.position.x - 12 and slider.position.x <= target.position.x + 12: b = 2.2
	else: b = clamp(1 - abs(target.position.x - slider.position.x) / 275, 0, 1)
	dmg = round((Global.atk + Global.weapon_equipped['item_params']['atk'] - enemy.def + randi_range(0,2)) * b)
	
	strike.frame = 0
	strike.play("default")
	await get_tree().process_frame
	strike.visible = true
	
	await strike.animation_finished
	strike.visible = false
	enemy.hit(dmg)
	
	await enemy.finished_player_attack
	slider.visible = false
	target.z_index = 5
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property(target, 'scale:x', 0.3, 0.5)
	t.tween_property(target, 'modulate:a', 0, 0.5)
	bordersetup.emit()
	
	await t.finished
	queue_free()

func _process(delta: float) -> void:
	global_position = border.position + border.size / 2
	strike.rotation_degrees = -border.rotation_degrees
	strike.global_position = enemy.position + enemy.get_node('positions/hit').position
	if pressed == 2: return
	
	var accept = Input.is_action_just_pressed("accept")
	if accept: pressed = 1
	
	if direction != 0 and pressed == 0:
		if slider.position.x >= target.position.x - 275 and slider.position.x <= target.position.x + 275: slider.position.x += delta * direction * 350
		else:
			enemy.miss()
			dmg = -1
			slider.visible = false
	
	if pressed == 1:
		pressed = 2
		hit_enemy()
