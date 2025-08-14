extends Node2D

@onready var border = $'../attacks/border'
@onready var attack_script = $'../engine/attacks'
@onready var alive = $alive

# if you dont want to add the enemies into the scene, you can do it here by putting their
# paths in the export var. useful for transitioning from overworld to battle
@export var enemy_paths = []
# corresponding to attacks script. if randomized is true, one will be chosen at random in the engine
@export var dialog = [
	[
		{'enemy' : 'dummy0', 'text' : 'hello i am dummy0', 'override_pause' : {}, 'override_speed' : {}},
		{'enemy' : 'dummy1', 'text' : 'hello i am dummy1', 'override_pause' : {}, 'override_speed' : {}},
	]
]

func _ready() -> void:
	var checked_arr = []
	
	if !enemy_paths.is_empty():
		for i in 3:
			if i > enemy_paths.size() - 1: return
			var inst = load(enemy_paths[i])
			inst = inst.instantiate()
			inst.name = inst.name + str(i)
			alive.add_child(inst)
			
			checked_arr.append(enemy_paths[i])
			
			match i:
				0: inst.position = Vector2(320,border.position.y - 10)
				1: inst.position = Vector2(320 - 160,border.position.y - 10)
				2: inst.position = Vector2(320 + 160,border.position.y - 10)
