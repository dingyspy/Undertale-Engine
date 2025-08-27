extends Node2D

# arr 0: x, arr 1: y
# [x min, x max], [y min, y max]
# these vars should be kept in all overworld scripts
@export var camera_clamp_x = Vector2(320,1000) # goes x, x instead of x, y
@export var camera_clamp_y = Vector2(240,1000)
# same with this, this should be kept for the saving function
@export var area_name = 'Test - Test'

func on_test_interact(engine):
	print('interacted')
	await get_tree().create_timer(1).timeout
	engine.events.finished_event.emit()

func on_test_event(engine):
	print('event')
	await get_tree().create_timer(1).timeout
	engine.events.finished_event.emit()
