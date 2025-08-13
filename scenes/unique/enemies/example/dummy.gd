extends Node2D

# since variables are exported, you technically dont need to duplicate
# enemy scripts for each seperate enemy youre making. if the enemy isnt
# too unique, you can just edit the values on the node itself and save it
# seperately. unfortunately this doesnt apply if you want the enemy to be
# animated, youd have to impletent that yourself

signal finished_player_attack

@export var _name = 'Dummy'
@export var max_health = 20
@export var def = 0
# whether they can be spared. when using spared from the menu, itll spare any enemy with sparable as true
@export var sparable = true
# used for enemy dialog, called in attacks script, function is found in engine
# text should be formatted: [{'text' : 'text', 'override_pause' : {}, 'override_speed' : {0:0.02}}, ...]
# this is used in chronological order unless randomized is set to true in attacks
@export var dialog = [
	[
		{'text' : 'hello i am testing the dialog box', 'override_pause' : {}, 'override_speed' : {}},
		{'text' : 'second dialog', 'override_pause' : {}, 'override_speed' : {}},
	]
]
# formatted: {name : name, msg : [{text : text, override_pause : {}, override_speed : {}}], callback : function in here that you want to be called after the check}
# callback is used if you want a function to be called when acting
@export var acts = [
	{
		'name' : 'Check',
		'msg' : [
			{'text' : 'Testing act messages.', 'override_pause' : {}, 'override_speed' : {}},
			{'text' : 'If you can see this, it works!', 'override_pause' : {}, 'override_speed' : {}},
		],
		'callback' : null
	},
	{
		'name' : 'Other',
		'msg' : [
			{'text' : 'Testing act functions!', 'override_pause' : {}, 'override_speed' : {}},
		],
		'callback' : Callable(self, 'test_act')
	},
]

@onready var healthbar = $healthbar
@onready var num = healthbar.get_node('num')
@onready var front = healthbar.get_node('front')
@onready var grey = healthbar.get_node('grey')
var health = max_health

func _ready() -> void:
	healthbar.visible = false
	Audio.store_audio({'hit':'res://audio/engine/snd_damage.wav'})

func test_act():
	print('test act works!')

# is called when the player finished attacking
func hit(dmg):
	Audio.play('hit')
	health -= dmg
	
	healthbar.visible = true
	num.text = '[center]' + str(int(dmg))
	
	var t = get_tree().create_tween()
	t.tween_property(num, 'position:y', num.position.y - 10, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(num, 'position:y', num.position.y, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	var thb = get_tree().create_tween()
	thb.tween_property(front, 'size:x', (float(health) / float(max_health)) * grey.size.x, 1)
	await thb.finished
	
	finished_player_attack.emit()
	await get_tree().create_timer(0.5).timeout
	
	healthbar.visible = false
