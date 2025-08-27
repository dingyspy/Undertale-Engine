extends Node

# in a seperate script unlike battle system
# this is bc main overworld engine script
# uses multiple systems (menu included) to
# do its thing

# emits when dialog is finished
signal dialog_finished
# when sub dialog is finished
signal sub_dialog_finished
# emits when a dialog option is selected
signal option_selected

@onready var engine = $'../'

@onready var ui = $'../../ui'
@onready var blur = $'../../ui/blur'
@onready var dialogbox = $'../../ui/dialogbox'
@onready var dialogbox_text = $'../../ui/dialogbox/text'
@onready var dialogbox_bullet = $'../../ui/dialogbox/bullet'
@onready var dialogbox_sprite = $'../../ui/dialogbox/sprite'
@onready var dialogbox_options = $'../../ui/dialogbox/options'
@onready var menu = $'../../ui/menu'
@onready var menu_mini = $'../../ui/menu/mini'
@onready var menu_mini_name = $'../../ui/menu/mini/name'
@onready var menu_mini_desc = $'../../ui/menu/mini/desc'
@onready var menu_mini_stats = $'../../ui/menu/mini/stats'
@onready var menu_mini_stats_lv = $'../../ui/menu/mini/stats/lv'
@onready var menu_mini_stats_hp = $'../../ui/menu/mini/stats/hp'
@onready var menu_mini_stats_g = $'../../ui/menu/mini/stats/g'
@onready var menu_selection = $'../../ui/menu/selection'
@onready var menu_selections = $'../../ui/menu/selection/selections'
@onready var menu_selection_item = $'../../ui/menu/selection/selections/item'
@onready var menu_selection_stat = $'../../ui/menu/selection/selections/stat'
@onready var menu_selection_cell = $'../../ui/menu/selection/selections/cell'
@onready var menuitems = $'../../ui/menu/menuitems'
@onready var items_node = $'../../ui/menu/types/items'
@onready var items_node_selections = $'../../ui/menu/types/items/selections'
@onready var items_panel = $'../../ui/menu/types/items/panel'
@onready var stat_node = $'../../ui/menu/types/stat'
@onready var stat_name = $'../../ui/menu/types/stat/name'
@onready var stat_lv = $'../../ui/menu/types/stat/lv'
@onready var stat_hp = $'../../ui/menu/types/stat/hp'
@onready var stat_baseatk = $'../../ui/menu/types/stat/baseatk'
@onready var stat_basedef = $'../../ui/menu/types/stat/basedef'
@onready var stat_exp = $'../../ui/menu/types/stat/exp'
@onready var stat_next = $'../../ui/menu/types/stat/next'
@onready var stat_weapon = $'../../ui/menu/types/stat/weapon'
@onready var stat_armor = $'../../ui/menu/types/stat/armor'
@onready var stat_gold = $'../../ui/menu/types/stat/gold'
@onready var cell_node = $'../../ui/menu/types/cell'
@onready var cell_panel = $'../../ui/menu/types/cell/panel'
@onready var soul = $'../../ui/soul'

@onready var box = $'../../ui/box'
@onready var save = $'../../ui/save'
@onready var save_options = $'../../ui/save/text/options'

@onready var menuitem = preload('res://scenes/engine/battle/menuitem.tscn')

var menu_is_open = false
var engine_can_open_menu = true
var prev_player_mode = 0
var buffer = 0
# -3 save, -2 box, -1 dialog options, 0,1,2 menu
var menu_no = 0
var prev_menu_posy = 0
var menu_posy = 0
var menu_posx = 0
var selections = []
var stat_selections = []
var option_selections = []
var default_dialogbox_position = Vector2(0,0)
var last_option = ''
var can_accept = true

func _ready() -> void:
	for i in menu_selections.get_children(): selections.append(i)
	for i in items_node_selections.get_children(): stat_selections.append(i)
	for i in dialogbox_options.get_children(): option_selections.append(i)
	
	ui.visible = false
	dialogbox.visible = false
	items_node.visible = false
	stat_node.visible = false
	cell_node.visible = false
	box.visible = false
	save.visible = false
	soul.visible = false
	menu_mini.visible = false
	menu_selection.visible = false
	
	Audio.store_audio({
		'move' : 'res://audio/engine/snd_squeak.wav',
		'select' : 'res://audio/engine/snd_select.wav',
		'heal' : 'res://audio/engine/snd_heal_c.wav',
		'hurt' : 'res://audio/engine/snd_hurt1.wav',
		'phone' : 'res://audio/engine/snd_phone.wav',
		'swallow' : 'res://audio/engine/snd_swallow.wav',
		'item' : 'res://audio/engine/snd_item.wav',
		'save' : 'res://audio/engine/snd_save.wav',
		'encounter' : 'res://audio/engine/snd_b.wav',
		'battlefall' : 'res://audio/engine/snd_battlefall.wav',
		'chk' : 'res://audio/engine/snd_noise.wav'
	})

func _process(delta: float) -> void:
	var accept = Input.is_action_just_pressed("accept")
	var cancel = Input.is_action_just_pressed('cancel')
	
	var menu_x = -(int(Input.is_action_just_pressed("left")) - int(Input.is_action_just_pressed("right")))
	var menu_y = -(int(Input.is_action_just_pressed("up")) - int(Input.is_action_just_pressed("down")))
	
	var menu_open = Input.is_action_just_pressed('menu')
	
	if Global.items.size() < 1: selections[0].modulate = Color(0.5,0.5,0.5)
	else: selections[0].modulate = Color(1,1,1)
	if Global.cell.size() < 1: selections[2].modulate = Color(0.5,0.5,0.5)
	else: selections[2].modulate = Color(1,1,1)
	
	# if you can open the menu, open it
	if menu_open and engine.can_open_menu and engine_can_open_menu and !engine.is_in_event:
		menu_is_open = !menu_is_open
		buffer = 2
		
		# if its open now, set the stats, make visible, and set player mode to 0 (cant move)
		if menu_is_open:
			if engine.background_blur_on_menuopen: blur.material.set('shader_parameter/lod', 1.0)
			menu_mini_name.text = Global.player_name
			menu_mini_stats_lv.text = str(Global.lv)
			menu_mini_stats_hp.text = str(Global.hp) + '/' + str(Global.maxhp)
			menu_mini_stats_g.text = str(Global.gold)
			ui.visible = true
			soul.visible = true
			box.visible = false
			save.visible = false
			menu_mini.visible = true
			menu_selection.visible = true
			
			menu_posy = 0
			prev_menu_posy = 0
			menu_no = 0
			
			prev_player_mode = engine.player.mode
			engine.player.mode = 0
			engine.player.sprite.stop()
			Audio.play('move')
		else:
			blur.material.set('shader_parameter/lod', 0.0)
			ui.visible = false
			soul.visible = false
			box.visible = false
			save.visible = false
			menu_mini.visible = false
			menu_selection.visible = false
			engine.player.mode = prev_player_mode
	
	if menu_is_open and !engine.is_in_event and can_accept:
		if accept and buffer <= 0:
			buffer = 2
			match menu_no:
				0:
					# dont accept if items / cell size is less than 1
					if (menu_posy == 0 and Global.items.size() < 1) or (menu_posy == 2 and Global.cell.size() < 1): return
					
					prev_menu_posy = menu_posy
					engine_can_open_menu = false
					
					menu_no += 1
					Audio.play('select')
					
					match prev_menu_posy:
						0:
							# create menuitems based on items array
							items_node.visible = true
							for i in Global.items.size():
								var item = Global.items[i]
								create_menuitem(item.full_name, items_panel.position + Vector2(42,28 + i * 32))
						1:
							# set the stats
							stat_name.text = '"' + Global.player_name + '"'
							stat_lv.text = str(Global.lv)
							stat_hp.text = str(Global.hp) + ' / ' + str(Global.maxhp)
							stat_baseatk.text = str(Global.atk) + '(' + str(Global.weapon_equipped.item_params.atk) + ')'
							stat_basedef.text = str(Global.def) + '(' + str(Global.armor_equipped.item_params.def) + ')'
							stat_exp.text = str(Global.xp)
							stat_next.text = str(int(pow(Global.lv - 1, 2) * 100))
							stat_weapon.text = Global.weapon_equipped.full_name
							stat_armor.text = Global.armor_equipped.full_name
							stat_gold.text = str(Global.gold)
							
							stat_node.visible = true
							soul.visible = false
						2:
							# create menuitems based on cell array
							cell_node.visible = true
							for i in Global.cell.size():
								var cell = Global.cell[i]
								create_menuitem(cell.name, items_panel.position + Vector2(42,28 + i * 32))
				1:
					match prev_menu_posy:
						0:
							# go to the "use, info, drop"
							menu_posx = 0
							menu_no += 1
							Audio.play('select')
						2:
							# play the selected cell dialog
							soul.visible = false
							cell_node.visible = false
							
							for i in menuitems.get_children(): i.queue_free()
							Audio.play('select')
							Audio.play('phone')
							
							can_accept = false
							menu_no += 1
							
							dialog([{
								'text' : 'Dialing...',
								'font' : 'main1',
								'override_pause' : {},
								'override_speed' : {},
								'face_animation' : null,
								'question' : {
									'options' : null,
								}
							}], true)
							await dialog_finished
							
							dialog(Global.cell[menu_posy].dialog, false, default_dialogbox_position)
							await dialog_finished
							# when all dialog is finished, go back to cell menu
							buffer = 2
							menu_no = 1
							
							cell_node.visible = true
							soul.visible = true
							for i in Global.cell.size():
								var cell = Global.cell[i]
								create_menuitem(cell.name, items_panel.position + Vector2(42,28 + i * 32))
							can_accept = true
				2:
					soul.visible = false
					items_node.visible = false
					for i in menuitems.get_children(): i.queue_free()
					
					can_accept = false
					menu_no += 1
					
					var item = Global.items[menu_posy]
					var text
					match menu_posx:
						0:
							Global.items.remove_at(menu_posy)
							
							match item.item_type:
								0:
									Global.hp = clamp(Global.hp + item.item_params.health, 0, Global.maxhp)
									
									Audio.play('swallow')
									Audio.play('heal')
									
									var _text = '* You eat the ' + item.full_name + '.'
									if Global.hp == Global.maxhp: _text += '\n* Your HP was maxed out.'
									else: _text += '\n* You recovered ' + str(item.item_params.health) + 'HP!'
									text = [{
										'text' : _text,
										'font' : 'main1',
										'override_pause' : {},
										'override_speed' : {},
										'face_animation' : null,
										'question' : {
											'options' : null,
										}
									}]
								1:
									Global.items.append(Global.weapon_equipped)
									Global.weapon_equipped = item
									
									Audio.play('item')
									
									text = [{
										'text' : 'You equipped the ' + item.full_name + '.',
										'font' : 'main1',
										'override_pause' : {},
										'override_speed' : {},
										'face_animation' : null,
										'question' : {
											'options' : null,
										}
									}]
								2:
									Global.items.append(Global.armor_equipped)
									Global.armor_equipped = item
									
									Audio.play('item')
									
									text = [{
										'text' : 'You equipped the ' + item.full_name + '.',
										'font' : 'main1',
										'override_pause' : {},
										'override_speed' : {},
										'face_animation' : null,
										'question' : {
											'options' : null,
										}
									}]
						1:
							var _text = []
							for i in item.info_dialog:
								_text.append({
									'text' : i,
									'font' : 'main1',
									'override_pause' : {},
									'override_speed' : {},
									'face_animation' : null,
									'question' : {
										'options' : null,
									}
								})
							text = _text
						2:
							Global.items.remove_at(menu_posy)
							text = [{
								'text' : 'The ' + item.full_name + ' was thrown away.',
								'font' : 'main1',
								'override_pause' : {},
								'override_speed' : {},
								'face_animation' : null,
								'question' : {
									'options' : null,
								}
							}]
					
					dialogbox_bullet.visible = false
					dialogbox_text.position = Vector2(60,340)
					dialogbox_text.size = Vector2(524,101)
					if menu_posx == 0 and item.item_type == 0: dialog(text, false, default_dialogbox_position, false, true)
					else: dialog(text, false, default_dialogbox_position, false, false)
					await dialog_finished
					
					if Global.items.size() >= 1:
						menu_no = 1
						soul.visible = true
						items_node.visible = true
						for i in Global.items.size():
							var _item = Global.items[i]
							create_menuitem(_item.full_name, items_panel.position + Vector2(42,28 + i * 32))
					else:
						menu_no = 0
						soul.visible = true
					can_accept = true
		
		if cancel and buffer <= 0 and menu_no != 0:
			buffer = 2
			match menu_no:
				1:
					# go back to the main menu
					cell_node.visible = false
					items_node.visible = false
					stat_node.visible = false
					for i in menuitems.get_children(): i.queue_free()
					soul.visible = true
					
					menu_posy = prev_menu_posy
					engine_can_open_menu = true
					Audio.play('move')
					menu_no -= 1
				2:
					match prev_menu_posy:
						0,1:
							Audio.play('move')
							menu_no = 1
		
		match menu_no:
			0:
				menu_posy = posmod(menu_posy + menu_y, selections.size())
				if menu_y != 0: Audio.play('move')
				
				# sets the soul pos to the selection pos, you can set the offset here
				soul.position = selections[menu_posy].position + Vector2(-19,17)
			1:
				match prev_menu_posy:
					0:
						# sets the soul position to the selected menu item position
						# changes the menu position depending on input
						var item_size = Global.items.size()
						menu_posy = posmod(menu_posy + menu_y, item_size)
						soul.position = items_panel.position + Vector2(29,45 + menu_posy * 32)
						if menu_y != 0 and item_size > 1: Audio.play('move')
					2:
						# same as above
						# sets the soul position to the selected menu item position
						# changes the menu position depending on input
						var cell_size = Global.cell.size()
						menu_posy = posmod(menu_posy + menu_y, cell_size)
						soul.position = cell_panel.position + Vector2(29,45 + menu_posy * 32)
						if menu_y != 0 and cell_size > 1: Audio.play('move')
			2:
				match prev_menu_posy:
					0:
						# for the "use, info, drop"
						# same as above
						menu_posx = posmod(menu_posx + menu_x, stat_selections.size())
						soul.position = stat_selections[menu_posx].position + Vector2(-12,17)
						if menu_x != 0: Audio.play('move')
	
	match menu_no:
		-1:
			# exclusively for dialogbox options
			menu_posx = posmod(menu_posx + menu_x, option_selections.size())
			soul.position = option_selections[menu_posx].global_position + Vector2(-24,17)
			if menu_x != 0: Audio.play('move')
		-2:
			# box
			menu_posx = posmod(menu_posx + menu_x, 2)
			
			match menu_posx:
				0:
					menu_posy = posmod(menu_posy + menu_y, Global.items.size())
					if (menu_y != 0 and Global.items.size() > 0): pass #Audio.play('move')
					elif Global.items.size() <= 0: menu_posx = 1
				1:
					menu_posy = posmod(menu_posy + menu_y, Global.box.size())
					if (menu_y != 0 and Global.box.size() > 0): pass #Audio.play('move')
					elif Global.box.size() <= 0: menu_posx = 0
			soul.position = Vector2(48 + 302 * menu_posx,90 + menu_posy * 32)
			
			#if menu_posx != prev_menu_posy: Audio.play('move')
			prev_menu_posy = menu_posx
			
			var arr = [Global.items, Global.box]
			if accept and buffer <= 0:
				match menu_posx:
					1: if Global.items.size() + 1 > Global.inventory_size: return
					0: if Global.box.size() + 1 > Global.box_size: return
				
				buffer = 2
				var item = arr[menu_posx][menu_posy]
				arr[menu_posx].remove_at(menu_posy)
				arr[posmod(menu_posx + 1, arr.size())].append(item)
				
				for i in menuitems.get_children(): i.queue_free()
				engine.events.menuitems_box()
				#Audio.play('select')
		-3:
			# save
			menu_posx = posmod(menu_posx + menu_x, 2)
			soul.position = save_options.get_children()[menu_posx].position + Vector2(-17,15)
			if menu_x != 0: Audio.play('move')
	
	# prevent bugs
	if buffer > 0: buffer -= delta * 15

# same func as the one used in the battle engine
func create_menuitem(text, position, color=Color(1,1,1)):
	var inst = menuitem.instantiate()
	inst.position = position
	inst.text = text
	inst.rdy = true
	inst.modulate = color
	menuitems.add_child(inst)
	return inst

# handles dialogbox
# position is automatically set to the bottom position (where it is originally in undertale)
# this can be changed through the position argument, but the offset must take the origin
# into account
# formatted: {text, font, override_pause, override_speed, face_animation (if null, none), question}
# if the question "bool" is true, dialogbox will prompt a yes/no selection (or option0, option1)
# option0 and option1 dialog is selected according to what is selected by the player
# unfortunately you cant really nest this function within selected dialog lol, that would be chaos
# "yes" and "no" option text can be changed in the dialog box manually
# options can also be added, just make sure to add it in the dialogbox node and format the next option as
# as option prev number + 1
# the engine should automatically handle the rest
# sub_dialog is for when options are selected, this isnt intended to be used manually
# manual is if you want the bullet text to not be set & positions to be set manually
func dialog(dialog_array, stay_visible : bool = false, position : Vector2 = default_dialogbox_position, sub_dialog : bool = false, manual : bool = false):
	dialogbox.position = position
	dialogbox_text.stop()
	dialogbox_text.text = ''
	dialogbox.visible = true
	
	can_accept = false
	
	for dialog in dialog_array:
		dialogbox_options.visible = false
		soul.visible = false
		
		Utility.load_font(dialogbox_bullet, Global.blitter_info[dialog.font][0], Global.blitter_info[dialog.font][2])
		dialogbox_text.font = dialog.font
		
		if dialog.face_animation != null:
			if !manual:
				dialogbox_text.position = Vector2(206,340)
				dialogbox_text.size = Vector2(379,101)
			dialogbox_bullet.position = Vector2(176,340)
			dialogbox_sprite.play(dialog.face_animation)
			dialogbox_sprite.visible = true
		else:
			if !manual:
				dialogbox_text.position = Vector2(90,340)
				dialogbox_text.size = Vector2(524,101)
			dialogbox_bullet.position = Vector2(60,340)
			dialogbox_sprite.visible = false
		
		dialogbox_text.reset()
		dialogbox_text.text = dialog.text
		dialogbox_text.override_pause = dialog.override_pause
		dialogbox_text.override_speed = dialog.override_speed
		
		if !manual: dialogbox_bullet.visible = true
		
		await dialogbox_text.completed
		if dialog.face_animation != null: dialogbox_sprite.stop()
		
		# y/n can be changed manually
		if dialog.question.options != null:
			menu_posx = 0
			menu_no = -1
			dialogbox_options.visible = true
			soul.visible = true
			
			for i in dialog.question.options.size(): option_selections[i].text = dialog.question.options[i]
			
			soul.position = option_selections[menu_posx].global_position + Vector2(-24,17)
		
		while true:
			if Input.is_action_just_pressed("accept") and buffer <= 0:
				buffer = 2
				break
			await get_tree().process_frame
		
		if dialog.question.options != null:
			#Audio.play('select')
			menu_no = -99
			
			# uses sub_dialog argument
			if dialog.question.has(dialog.question.options[menu_posx]): dialog(dialog.question[dialog.question.options[menu_posx]], true, position, true)
			# sets var to the option currently selected
			# useful for interpreting option selection from another s cript
			last_option = dialog.question.options[menu_posx]
			option_selected.emit()
			await sub_dialog_finished
	if !stay_visible: dialogbox.visible = false
	if !sub_dialog: dialog_finished.emit()
	else: sub_dialog_finished.emit()
	can_accept = true
