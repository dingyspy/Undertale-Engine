extends Node

# for debugging purposes usually
# this is the attack that is currently being played
@export var current_attack = -1
# used for if you dont want attacks to be in chronological order,
# but instead are in a randomized order
# mainly exists for "filler" enemy encounters
# also randomizes dialog in the enemy script / node
# if you miss when attacking and randomize is true, dialog & attack plays
@export var _randomize = false
# since the var is exported you dont need to change the code, but you can if desired
# put the paths of attacks in chronological order
# takes Strings
@export var attack_paths = [
	'res://scenes/unique/attacks/example/attack0.gd'
]
# this is completely optional. if you want the border to be a specific size
# on setup, you can put the vector2 sizes in chronological order in reference to the attack_paths
# on default, the border is basically just a square
# formatted: [[posx,posy],[sizex,sizey]] or [[null,null],[null,null]] or [null,null]
@export var attack_border_start = []
@export var menu_blitter_texts = [
	'menu text'
]

@onready var engine = $'../'

# this sets up attacks
func setup():
	var to_pos = [null,[140,140]]
	if current_attack != -1 and current_attack <= attack_border_start.size() - 1: to_pos = [attack_border_start[current_attack][0],attack_border_start[current_attack][1]]
	
	engine.border.to(to_pos[0],to_pos[1])
	
	engine.toggle_soul_index()
	engine.menu_no = -1
	
	await get_tree().process_frame
	engine.soul.position = Vector2(320,320)
	engine.soul.visible = true
	engine.soul.mode = 0

func start(attack = null):
	if _randomize: current_attack = randi_range(0,attack_paths.size() - 1)
	if current_attack > attack_paths.size() - 1: return
	
	if !attack: attack = attack_paths[current_attack]
	attack = load(attack)
	
	var node = Node.new()
	node.set_script(attack)
	
	var defined = {
		'battle' : engine.get_node('../'),
		'engine' : engine,
		'border' : engine.border,
		'soul' : engine.soul,
		'bullets' : engine.border.bullets,
		'attack' : self,
	}
	
	#for i in defined.size() - 1: if defined.keys()[i] in node: node.set(defined.keys()[i], defined.values()[i])
	
	node.connect('end', end)
	add_child(node)

func end():
	for i in get_children(): remove_child(i)
	for i in get_tree().get_nodes_in_group('bullets'): i.queue_free()
	
	engine.toggle_soul_index()
	engine.soul.mode = 0
	engine.soul.visible = false
	engine.border.to(null,null)
	
	await engine.border.finished
	engine.menu_no = 0
	engine.menu_posx = engine.prev_menu_posx
	engine.menu_posy = 0
	engine.set_current_text()
	engine.toggle_soul_index()

# this is for when you use acts, spare, items, etc. value is passed from the engine
# 0: turn after acting
# 1: turn after healing
# 2: turn after a failed spare
# 3: a miss
func turn_skip(value):
	match value:
		0:
			engine.menu_no = 0
			engine.menu_posx = engine.prev_menu_posx
			engine.menu_posy = 0
			engine.set_current_text()
			engine.toggle_soul_index()
		1,3:
			setup()
			await engine.border.finished
			
			var healing_attacks = [
				'res://scenes/unique/attacks/example/healing0.gd'
			]
			
			start(healing_attacks[randi_range(0,healing_attacks.size() - 1)])
		2: pass
