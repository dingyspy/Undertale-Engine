extends Node

# blurs the background when menu is opened
var background_blur_on_menuopen = true
var can_open_menu = true

@onready var overworld = $'../'
@onready var player = $'../player'

@onready var ui = $'../ui'
@onready var blur = $'../ui/blur'
@onready var dialogbox = $'../ui/dialogbox'
@onready var dialogbox_text = $'../ui/dialogbox/text'
@onready var dialogbox_bullet = $'../ui/dialogbox/bullet'
@onready var menu = $'../ui/menu'
@onready var menu_mini = $'../ui/menu/mini'
@onready var menu_mini_name = $'../ui/menu/mini/name'
@onready var menu_mini_desc = $'../ui/menu/mini/desc'
@onready var menu_mini_stats = $'../ui/menu/mini/stats'
@onready var menu_mini_stats_lv = $'../ui/menu/mini/stats/lv'
@onready var menu_mini_stats_hp = $'../ui/menu/mini/stats/hp'
@onready var menu_mini_stats_g = $'../ui/menu/mini/stats/g'
@onready var menu_selection = $'../ui/menu/selection'
@onready var menu_selections = $'../ui/menu/selection/selections'
@onready var menu_selection_item = $'../ui/menu/selection/selections/item'
@onready var menu_selection_stat = $'../ui/menu/selection/selections/stat'
@onready var menu_selection_cell = $'../ui/menu/selection/selections/cell'
@onready var menuitems = $'../ui/menu/menuitems'
@onready var items_node = $'../ui/menu/types/items'
@onready var items_node_selections = $'../ui/menu/types/items/selections'
@onready var items_panel = $'../ui/menu/types/items/panel'
@onready var soul = $'../ui/soul'

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
	if menu_open and can_open_menu and engine_can_open_menu:
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
			
			prev_player_mode = player.mode
			player.mode = 0
			player.sprite.stop()
			Audio.play('move')
		else:
			ui.visible = false
			player.mode = prev_player_mode
	
	if menu_is_open:
		if accept and buffer <= 0:
			buffer = 2
			match menu_no:
				0:
					prev_menu_posy = menu_posy
					engine_can_open_menu = false
					match prev_menu_posy:
						0:
							items_node.visible = true
							for i in Global.items.size():
								var item = Global.items[i]
								create_menuitem(item['full_name'], items_panel.position + Vector2(42,28 + i * 32))
				1:
					menu_posx = 0
			menu_no += 1
			Audio.play('select')
		
		if cancel and buffer <= 0 and menu_no != 0:
			buffer = 2
			Audio.play('move')
			match menu_no:
				1:
					match prev_menu_posy:
						0:
							items_node.visible = false
							for i in menuitems.get_children(): i.queue_free()
					menu_posy = prev_menu_posy
					engine_can_open_menu = true
			menu_no -= 1
		
		match menu_no:
			0:
				menu_posy = posmod(menu_posy + menu_y, selections.size())
				
				# sets the soul pos to the selection pos, you can set the offset here
				soul.position = selections[menu_posy].position + Vector2(-19,17)
			1:
				match prev_menu_posy:
					0:
						menu_posy = posmod(menu_posy + menu_y, Global.items.size())
						soul.position = items_panel.position + Vector2(29,45 + menu_posy * 32)
			2:
				match prev_menu_posy:
					0:
						menu_posx = posmod(menu_posx + menu_x, stat_selections.size())
						soul.position = stat_selections[menu_posx].position + Vector2(-12,17)
						if menu_x != 0: Audio.play('move')
		if menu_y != 0: Audio.play('move')
	
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
