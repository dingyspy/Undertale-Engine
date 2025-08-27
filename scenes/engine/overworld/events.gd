extends Node

signal finished_event

@onready var engine = $'../'

@onready var box = $'../../ui/box'
@onready var save = $'../../ui/save'

var buffer = 0

# areas that you want the player to interact with or start an event (cutscene) with
# are defined by the "event" and "interactable" group
# you can find examples of this in the "test" scene
# note: each area with these groups MUST have the reference_node
# export variable attached for the check_area() function to
# work properly
func _process(delta: float) -> void:
	var ray_area = engine.player.ray.get_collider()
	
	if ray_area == null:
		for area in engine.player.hitbox.get_overlapping_areas(): check_area(area)
	else: check_area(ray_area)
	
	if buffer > 0: buffer -= delta * 15

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
	var _return = true
	if (area.is_in_group("event") and area.interactable and Input.is_action_just_pressed("accept")) or (area.is_in_group("event") and !area.interactable): _return = false
	if _return or engine.is_in_event or engine.menu.menu_is_open or buffer > 0: return
	
	engine.is_in_event = true
	match area.name:
		'_save':
			pass
		'_box':
			engine.player.mode = 0
			engine.menu.ui.visible = true
			engine.menu.can_accept = false
			
			engine.menu.dialog([{
				'text' : 'Use the box?',
				'font' : 'main1',
				'override_pause' : {},
				'override_speed' : {},
				'face_animation' : null,
				'question' : {
					'options' : ['Yes','No']
				}
			}], true)
			
			await engine.menu.option_selected
			match engine.menu.last_option:
				'Yes':
					engine.menu.dialogbox.visible = false
					box.visible = true
					engine.menu.menu_no = -2
					
					engine.menu.buffer = 2
					menuitems_box()
					
					while true:
						if Input.is_action_just_pressed("cancel"): break
						await get_tree().process_frame
					engine.menu.ui.visible = false
					box.visible = false
					for i in engine.menu.menuitems.get_children(): i.queue_free()
					engine.menu.menu_no = 0
					engine.player.mode = 1
				'No':
					engine.menu.ui.visible = false
					engine.menu.dialogbox.visible = false
					engine.menu.menu_no = 0
					engine.player.mode = 1
			engine.menu.can_accept = true
		_:
			area.reference_node.call(area.name, engine)
			await finished_event
	if area.oneshot: area.queue_free()
	
	buffer = 2
	engine.is_in_event = false

func menuitems_box():
	for i in Global.inventory_size:
		if Global.items.size() > i:
			var item = Global.items[i]
			engine.menu.create_menuitem(item.full_name, Vector2(65,71 + i * 32))
		else: redline(Vector2(65,92 + i * 32))

	for i in Global.box_size:
		if Global.box.size() > i:
			var item = Global.box[i]
			engine.menu.create_menuitem(item.full_name, Vector2(367,71 + i * 32))
		else: redline(Vector2(381,92 + i * 32))

func redline(pos):
	var line = ColorRect.new()
	line.color = Color(1,0,0)
	line.size = Vector2(180,1)
	line.position = pos
	engine.menu.menuitems.add_child(line)
