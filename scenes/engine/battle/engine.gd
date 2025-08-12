extends Node

# only change stuff here if you know what youre doing!!
# theres some info below on how to change stuff

@onready var menu = $'../menu'
@onready var enemies = $'../enemies'
@onready var attacks = $'../attacks'
@onready var attack_script = $attacks
@onready var border = $'../attacks/border'
@onready var border_text = $'../attacks/border/text/text'
@onready var bullet_point = $'../attacks/border/text/bullet'
@onready var soul = $'../attacks/border/soul'
@onready var menuitems = $'../attacks/border/items'
@onready var buttons_node = $'../menu/buttons'

@onready var menuitem = preload('res://scenes/engine/battle/menuitem.tscn')

var current_text = 'Menu text! :)'
var can_flee = true

# engine values
var menu_no = 0
var menu_posx = 0
var menu_posy = 0
var prev_menu_posx = 0
var prev_menu_posy = 0
var prv_menu_posx = 0
var prv_menu_posy = 0
var page = 0
var limitx = 0
var limity = 0
var soul_index_toggle = true
var buttons = []
var buffer = 0

func _ready() -> void:
	for button in buttons_node.get_children(): buttons.append(button)
	limitx = buttons.size()
	Audio.store_audio({
		'move' : 'res://audio/engine/snd_squeak.wav',
		'select' : 'res://audio/engine/snd_select.wav'
	})
	
	await get_tree().process_frame
	border_text.font = 'main2'
	set_current_text()
	toggle_soul_index()

func _process(delta: float) -> void:
	var accept = Input.is_action_just_pressed("accept")
	var cancel = Input.is_action_just_pressed('cancel')
	
	var menu_x = -(int(Input.is_action_just_pressed("left")) - int(Input.is_action_just_pressed("right")))
	var menu_y = -(int(Input.is_action_just_pressed("up")) - int(Input.is_action_just_pressed("down")))
	
	if buffer > -1: buffer -= delta * 30
	if bullet_point.get_theme_font("normal_font") != border_text.get_theme_font("normal_font"):
		var blitter_info = Global.blitter_info[border_text.font]
		Utility.load_font(bullet_point, blitter_info[0], blitter_info[2])
	
	# process menu_no
	# this is where extra button functions can be implemented
	# more can be found in the match statements below
	# handles fight, act, item, mercy moving / pages
	# this specific section is for soul movement and page handling
	if menu_no == -1: return
	match menu_no:
		0:
			menu_posx = posmod(menu_posx + menu_x, buttons.size())
			soul.position = buttons[menu_posx].position
			for button in buttons:
				if button == buttons[menu_posx]: button.frame = 1
				else: button.frame = 0
			soul.z_index = -1
		1:
			soul.z_index = 0
			match prev_menu_posx:
				0,1:
					menu_posy = posmod(menu_posy + menu_y, enemies.get_children().size())
					soul.position = Vector2(42,36 + menu_posy * 32)
				2:
					var pages = int(ceil(Global.items.size() / 4.0))
					
					if pages > 1:
						if page >= 1 and page < pages:
							if menu_posx + menu_x >= 2:
								for item in menuitems.get_children(): item.queue_free()
								page += 1
								
								update_page(pages)
								menu_posx = 1
						if page > 1:
							if menu_posx + menu_x <= -1:
								for item in menuitems.get_children(): item.queue_free()
								page -= 1
								
								update_page(pages)
								menu_posx = 2
					var end_items = Global.items.size() - (page - 1) * 4
					
					limit(end_items, menu_x)
					menu_posx = posmod(menu_posx + menu_x, limitx)
					menu_posy = posmod(menu_posy + menu_y, limity)
					
					soul.position = Vector2(42 + menu_posx * 250,36 + menu_posy * 32)
				3:
					var i = 1 + int(can_flee)
					
					menu_posy = posmod(menu_posy + menu_y, i)
					soul.position = Vector2(42,36 + menu_posy * 32)
		2:
			# for selecting individual enemy acts
			if prev_menu_posx == 1:
				var enemy = enemies.get_children()[prev_menu_posy]
				
				limit(enemy.acts.size(), menu_x)
				menu_posx = posmod(menu_posx + menu_x, limitx)
				menu_posy = posmod(menu_posy + menu_y, limity)
				soul.position = Vector2(42 + menu_posx * 250,36 + menu_posy * 32)
	
	if menu_posx != prv_menu_posx and !accept and buffer < 0: Audio.play('move')
	if menu_posy != prv_menu_posy and !accept and buffer < 0: Audio.play('move')
	prv_menu_posx = menu_posx
	prv_menu_posy = menu_posy
	
	# accept
	if accept and buffer < 0:
		buffer = 2
		
		Audio.play('select')
		menu_posy = 0
		
		# extra button functions can be implemented
		# shows the fight, act, item, mercy options
		
		# menu_no is pretty simple, it goes:
		# 0: the bottom buttons (fight, act, ...)
		# 1: the selected button's function (fight: lists enemy names and health, etc)
		# 2: in this case is only used for acts since it
		#    displays the enemy names in menu_no = 1 and
		#    shows acts in menu_no = 2
		match menu_no:
			0:
				for button in buttons: button.frame = 0
				menu_no = 1
				
				set_current_text(false)
				toggle_soul_index()
				prev_menu_posx = menu_posx
				
				match menu_posx:
					0: show_enemies(true)
					1: show_enemies(false)
					2:
						menu_posx = 0
						for i in 4: create_menuitem('* ' + Global.items[i][0], Vector2(70 + (i % 2) * 250,20 + floor(i / 2) * 32)); i += 1
						create_menuitem('  PAGE 1', Vector2(70 + 1 * 250,20 + 2 * 32))
						page = 1
					3:
						var i = 0
						var spare = false
						
						for enemy in enemies.get_children(): if enemy.sparable: spare = true
						
						if spare: create_menuitem('* ' + 'Spare', Vector2(70,20 + i * 32), Color(1,1,0))
						else: create_menuitem('* ' + 'Spare', Vector2(70,20 + i * 32), Color(1,1,1))
						i += 1
						if can_flee:
							create_menuitem('* ' + 'Flee', Vector2(70,20 + i * 32)); i += 1
			1:
				for item in menuitems.get_children(): item.queue_free()
				menu_no = 2
				
				match prev_menu_posx:
					0: $attacks.setup() # fight
					1:
						prev_menu_posy = menu_posy
						menu_posx = 0
						var enemy = enemies.get_children()[prev_menu_posy]
						
						var i = 0
						for act in enemy.acts: create_menuitem('* ' + act[0], Vector2(70 + (i % 2) * 250,20 + floor(i / 2) * 32)); i += 1
					2: pass # heal
					3: pass # spare / flee
			2:
				if prev_menu_posx == 1:
					pass # act
	
	if cancel and buffer < 0:
		buffer = 2
		
		match menu_no:
			1:
				Audio.play('move')
				menu_no = 0
				menu_posx = prev_menu_posx
				
				for item in menuitems.get_children(): item.queue_free()
				set_current_text()
				toggle_soul_index()
			2:
				Audio.play('move')
				menu_no = 1
				
				for item in menuitems.get_children(): item.queue_free()
				show_enemies(false)

# 2 modes
# when soul_index_toggle is true, the soul is removed from the
# border and added to the border parent node instead. this is
# so the soul is able to smoothly position itself on the buttons
# without process function lag
# the second mode is pretty much the opposite and adds the soul to the border
func toggle_soul_index():
	soul.visible = false
	soul.position = Vector2(-2000,-2000)
	if soul_index_toggle:
		var new_soul = soul.duplicate()
		attacks.add_child(new_soul)
		border.remove_child(soul)
		soul = new_soul
		new_soul.visible = true
	else:
		var new_soul = soul.duplicate()
		border.add_child(new_soul)
		attacks.remove_child(soul)
		soul = new_soul
		new_soul.visible = true
	soul_index_toggle = !soul_index_toggle

# simple function to help redundancy, shows enemy names in the menu
func show_enemies(health=false):
	var i = 0
	for enemy in enemies.get_children():
		if enemy.sparable: create_menuitem('* ' + enemy.name, Vector2(70,20 + i * 32), Color(1,1,0))
		else: create_menuitem('* ' + enemy.name, Vector2(70,20 + i * 32))
		
		if health:
			var rect_back = ColorRect.new()
			rect_back.size = Vector2(95,16)
			rect_back.color = Color(1,0,0)
			rect_back.position = Vector2(250,30 + i * 32)
			menuitems.add_child(rect_back)
			
			var rect_front = ColorRect.new()
			rect_front.size = Vector2((enemy.health / enemy.max_health) * 95,16)
			rect_front.color = Color(0,1,0)
			rect_front.position = Vector2(250,30 + i * 32)
			menuitems.add_child(rect_front)
		
		i += 1

# also helps redundancy, updates the menu item pages
func update_page(pages):
	var endrange = page * 4
	if page == pages: endrange = Global.items.size()
	
	for i in range((page - 1) * 4, endrange): create_menuitem('* ' + Global.items[i][0], Vector2(70 + (i % 2) * 250,20 + floor((i - (page - 1) * 4) / 2) * 32)); i += 1
	create_menuitem('  PAGE ' + str(page), Vector2(70 + 1 * 250,20 + 2 * 32))

# a function used for the soul positioning in menus
# with 1-3 selectable items
func limit(items, menu_x):
	limitx = 2
	limity = 1
	if items > 2: limity = 2
	elif items > -1 and items <= 2: limitx = items
	else:
		limitx = 2
		limity = 2
	
	if items == 3 and menu_posx == 0:
		limity = 2
		if menu_posx + menu_x == 1: limity = 1
	elif items == 3:
		limity = 1
		menu_posy = 0

# pretty simple, literally creates menu options
func create_menuitem(text, position, color=Color(1,1,1)):
	var inst = menuitem.instantiate()
	inst.position = position
	inst.font = border_text.font
	inst.text = text
	inst.rdy = true
	inst.modulate = color
	menuitems.add_child(inst)
	return inst

# sets the border's blitter text
func set_current_text(enabled=true):
	if enabled:
		border_text.reset()
		border_text.text = current_text
		bullet_point.visible = true
	else:
		border_text.stop()
		border_text.text = ''
		bullet_point.visible = false
