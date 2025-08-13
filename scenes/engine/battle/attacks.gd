extends Node

# for debugging purposes usually
# this is the attack that is currently being played
@export var current_attack = 0
# used for if you dont want attacks to be in chronological order,
# but instead are in a randomized order
# usefull for "filler" enemies
# also randomizes dialog in the enemy script / node
@export var _randomize = false
# since the var is exported you dont need to change the code, but you can if desired
# put the paths of attacks in chronological order
# takes Strings
@export var attack_paths = []
# this is completely optional. if you want the border to be a specific size
# on setup, you can put the vector2 sizes in chronological order in reference to the attack_paths
# on default, the border is basically just a square
# formatted: [[posx,posy],[sizex,sizey]] or [[null,null],[null,null]] or [null,null]
@export var attack_border_start = []

@onready var engine = $'../'

# this sets up attacks
func setup():
	if _randomize: current_attack = randi_range(0,attack_paths.size() - 1)
	if current_attack > attack_paths.size() - 1: return
	
	var to_pos = [null,[140,140]]
	if current_attack <= attack_border_start.size() - 1: to_pos = [attack_border_start[current_attack][0],attack_border_start[current_attack][1]]
	
	var attack = attack_paths[current_attack]
	engine.border.to(to_pos[0],to_pos[1])
	
	engine.toggle_soul_index()
	engine.menu_no = -1
	
	await get_tree().process_frame
	engine.soul.position = Vector2(320,320)
	engine.soul.visible = true
	engine.soul.mode = 0

func start():
	print('yay')

func end():
	current_attack += 1

# this is for when you use acts, spare, items, etc. value is passed from the engine
# 0: turn after acting
# 1: turn after healing
# 2: turn after a failed spare
func turn_skip(value):
	match value:
		0:
			engine.menu_no = 0
			engine.menu_posx = engine.prev_menu_posx
			engine.menu_posy = 0
			engine.set_current_text()
			engine.toggle_soul_index()
		1: pass
		2: pass
