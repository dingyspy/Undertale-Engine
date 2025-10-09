extends Node

# area name in the saving function is just the name of the scene

# arr 0: x, arr 1: y
# [x min, x max], [y min, y max]
# these vars should be kept in all overworld scripts
@export var camera_clamp_x = Vector2(320,1000) # goes x, x instead of x, y
@export var camera_clamp_y = Vector2(240,1000)

# if any value is in this array, the game will randomly encounter an enemy
# in the sub-array
# once the enemies are encounter, the sub-array will be removed from the array
# formatted [[enemy,enemy], [enemy,enemy,enemy,enemy], ...]
# should also be kept
@export var encounter_enemies = [
	[
		'res://scenes/unique/battle/enemies/example/dummy.tscn',
	]
]

func on_test_interact(engine):
	print('interacted')
	engine.tilemaps.get_node('npc').walk_to_point(Vector2(0,0),1)
	await get_tree().create_timer(1).timeout
	engine.events.finished_event.emit()

func on_test_event(engine):
	print('event')
	await get_tree().create_timer(1).timeout
	engine.events.finished_event.emit()
