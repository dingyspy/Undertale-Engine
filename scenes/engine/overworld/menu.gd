extends Node

# in a seperate script unlike battle system
# this is bc main overworld engine script
# uses multiple systems (menu included) to
# do its thing

@onready var engine = $'../'

@onready var ui = $'../../ui'
@onready var blur = $'../../ui/blur'
@onready var dialogbox = $'../../ui/dialogbox'
@onready var dialogbox_text = $'../../ui/dialogbox/text'
@onready var dialogbox_bullet = $'../../ui/dialogbox/bullet'
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

@onready var menuitem = preload('res://scenes/engine/battle/menuitem.tscn')

var menu_is_open = false
var engine_can_open_menu = true
var prev_player_mode = 0
var buffer = 0
var menu_no = 0
var prev_menu_posy = 0
var menu_posy = 0
var menu_posx = 0
var selections = []
var stat_selections = []

func _ready() -> void:
	for i in menu_selections.get_children(): selections.append(i)
	for i in items_node_selections.get_children(): stat_selections.append(i)
	
	ui.visible = false
	dialogbox.visible = false
	items_node.visible = false
	stat_node.visible = false
	cell_node.visible = false
	
	Audio.store_audio({
		'move' : 'res://audio/engine/snd_squeak.wav',
		'select' : 'res://audio/engine/snd_select.wav',
		'heal' : 'res://audio/engine/snd_heal_c.wav',
		'hurt' : 'res://audio/engine/snd_hurt1.wav',
	})

func _process(delta: float) -> void:
	var accept = Input.is_action_just_pressed("accept")
	var cancel = Input.is_action_just_pressed('cancel')
	
	var menu_x = -(int(Input.is_action_just_pressed("left")) - int(Input.is_action_just_pressed("right")))
	var menu_y = -(int(Input.is_action_just_pressed("up")) - int(Input.is_action_just_pressed("down")))
	
	var menu_open = Input.is_action_just_pressed('menu')
	
	# if you can open the menu, open it
	if menu_open and engine.can_open_menu and engine_can_open_menu:
		menu_is_open = !menu_is_open
		buffer = 2
		
		# if its open now, set the stats, make visible, and set player mode to 0 (cant move)
		if menu_is_open:
			menu_mini_name = Global.player_name
			menu_mini_stats_lv = str(Global.lv)
			menu_mini_stats_hp = str(Global.hp) + '/' + str(Global.maxhp)
			menu_mini_stats_g = str(Global.gold)
			ui.visible = true
			
			menu_posy = 0
			prev_menu_posy = 0
			menu_no = 0
			
			prev_player_mode = engine.player.mode
			engine.player.mode = 0
			engine.player.sprite.stop()
			Audio.play('move')
		else:
			ui.visible = false
			engine.player.mode = prev_player_mode
	
	if menu_is_open:
		if accept and buffer <= 0:
			buffer = 2
			match menu_no:
				0:
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
							
							dialog()
		
		if cancel and buffer <= 0 and menu_no != 0:
			buffer = 2
			Audio.play('move')
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
			menu_no -= 1
		
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
	
	# prevent bugs
	if buffer > 0: buffer -= delta * 30

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
func dialog(dialog_array):
	dialogbox.visible = true
