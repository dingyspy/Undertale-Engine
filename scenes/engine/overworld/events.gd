extends Node

signal finished_event

@onready var engine = $'../'

# areas that you want the player to interact with or start an event (cutscene) with
# are defined by the "event" and "interactable" group
# you can find examples of this in the "test" scene
# note: each area with these groups MUST have the reference_node
# export variable attached for the check_area() function to
# work properly
func _process(delta: float) -> void:
	for area in engine.player.hitbox.get_overlapping_areas():
		if (area.is_in_group("event") and area.interactable and Input.is_action_just_pressed("accept")) or area.is_in_group("event"): check_area(area)
#
# events or interactions that will be reused in multiple scenes
# should be stored here. the use of the save star and item box is implemented here
# custom functions are called if none of the pre-stored events / interactions are found

# custom functions can be called in any node, as long as the area with the
# event group has reference to the node holding the functions
# this is found under the node's reference_node export variable

# in addition to the reference_node, there are also export bools
# named "interactable" and "oneshot"
# interactable is self explanatory, toggle to true if you want the player to press
# interact button to interact, oneshot is if you want the function to be called once
# and never again (the area frees iteself)
func check_area(area):
	engine.is_in_event = true
	match area.name:
		'_save':
			pass
		'_box':
			pass
		_:
			area.reference_node.call(area.name, engine)
			await finished_event
	if area.oneshot: area.queue_free()
	engine.is_in_event = false
