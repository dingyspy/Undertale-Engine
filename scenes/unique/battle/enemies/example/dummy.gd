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
@export var spareable = false
# gold you get when killing / sparing
@export var gold = 25
# xp you get from killing
@export var xp = 75
# used for making animations
# match statement is found in process
@export var anim = 1
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
# name : {sprite : [frame, offset]}
@export var expressions = {
	'shrug' : {'head' : [1, Vector2(0,0)], 'torso' : [1, Vector2(-8,0)], 'legs' : [1, Vector2(0,0)]},
}
# used to shake the enemy
var shake = 0

@onready var healthbar = $healthbar
@onready var num = healthbar.get_node('num')
@onready var front = healthbar.get_node('front')
@onready var grey = healthbar.get_node('grey')
@onready var spare_particle = $particles/spare
@onready var dust_particle = $particles/dust
@onready var character = $character
var health = max_health
var shake_flip = 1
var shake_buffer = 0

func _ready() -> void:
	healthbar.visible = false

var animation_siner = 0.0
func _process(delta: float) -> void:
	animation_siner += delta * 30
	
	match anim:
		# MUST make all character sprites invisible for spare function to work
		0:
			for i in character.get_children(): i.visible = false
		1:
			for i in character.get_children(): i.visible = true
			$character/dummy.position.x = 0 + sin(animation_siner / 4) * 2
	
	character.position.x = shake * shake_flip
	shake -= delta * 8
	if shake_buffer > -1: shake_buffer -= delta * 30
	if shake > 0 and shake_buffer <= 0:
		shake_buffer = 1.5
		shake_flip = -shake_flip
	elif shake <= 0: shake = 0

func test_act():
	print('test act works!')
	spareable = true

# is called when the player finished attacking
func hit(dmg):
	Audio.play('hit')
	health -= dmg
	shake = 8
	
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

func miss():
	pass

func spare():
	var sprpart = spare_particle.get_node('spare')
	var sprspr = spare_particle.get_node('spare_spr')
	anim = 0
	sprspr.visible = true
	sprpart.restart()
	sprpart.emitting = true
	
	Audio.play('vapor')
	
	for i in 4:
		var text = load('res://sprites/engine/battle/core/spare/sprite_' + str(i) + '.png')
		sprpart.texture = text
		await get_tree().create_timer(0.15).timeout

func dust():
	anim = 0
	dust_particle.restart()
	dust_particle.emitting = true
	dust_particle.one_shot = true
	dust_particle.process_material.set('shader_parameter/progress', 0.0)
	dust_particle.visible = true
	
	Audio.play('vapor')
	
	var t = get_tree().create_tween()
	t.tween_property(dust_particle, 'process_material:shader_parameter/progress', 1.0, 0.8)
	await t.finished
	
	await get_tree().create_timer(1).timeout
	dust_particle.emitting = false
	dust_particle.visible = false
