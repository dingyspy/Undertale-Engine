extends Node2D

signal finished

var base_spd = 100

@onready var sprite = $sprite

func return_anim(val):
	# returns the normalized val converted to str for sprite animation
	match val:
		Vector2(1,0), Vector2(1,1), Vector2(1,-1): return 'right'
		Vector2(-1,0), Vector2(-1,1), Vector2(-1,-1): return 'left'
		Vector2(0,1): return 'down'
		Vector2(0,-1): return 'up'

func walk_to_point(pos : Vector2, spd):
	# normalized so it matches with return_anim values, this basically gets the move direction
	var normalized = Vector2(round((pos - position).normalized().x), round((pos - position).normalized().y))
	sprite.play(return_anim(normalized))
	sprite.speed_scale = spd
	
	# tweens to the position with the spd val in mind
	var t = get_tree().create_tween()
	t.tween_property(self, 'position', pos, position.distance_to(pos) / (base_spd * spd))
	
	# when done, stop
	await t.finished
	sprite.stop()
	sprite.frame = 0
	finished.emit()
