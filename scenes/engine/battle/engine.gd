extends Node

# only change stuff here if you know what youre doing!!
# theres some info below on how to change stuff

signal dialog_finished
signal battle_finished

@onready var menu = $'../menu'
@onready var real_enemies = $'../enemies'
@onready var enemies = $'../enemies/alive'
@onready var ignore_enemies = $'../enemies/ignore'
@onready var attacks = $'../attacks'
@onready var attack_script = $attacks
@onready var border = $'../attacks/border'
@onready var border_text = $'../attacks/border/text/text'
@onready var bullet_point = $'../attacks/border/text/bullet'
@onready var soul = $'../attacks/border/soul'
@onready var menuitems = $'../attacks/border/items'
@onready var buttons_node = $'../menu/buttons'
@onready var overlay = $'../overlay'
@onready var camera = $'../camera'
@onready var bg_color = $'../background/color'

@onready var stats = $'../menu/stats'
@onready var stats_hp_spr = $'../menu/stats/hp_spr'
@onready var stats_kr_spr = $'../menu/stats/kr_spr'
@onready var stats_hp = $'../menu/stats/health/hp'
@onready var stats_name = $'../menu/stats/health/name'
@onready var stats_lv = $'../menu/stats/health/lv'
@onready var stats_health_front = $'../menu/stats/health/bar/front'
@onready var stats_health_kr = $'../menu/stats/health/bar/kr'
@onready var stats_health_back = $'../menu/stats/health/bar/back'

@onready var menuitem = preload('res://scenes/engine/battle/menuitem.tscn')
@onready var dialogbox = preload('res://scenes/engine/battle/dialogbox.tscn')

# if false, the stats bar will start from the left
# otherwise itll be centered
var center_stats = true
# if false, the flee option will be removed
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
var xp_won = 0
var gold_won = 0
var current_text = 'Menu text! :)'

var prev_atk = Global.atk
var prev_def = Global.def

func _ready() -> void:
	for button in buttons_node.get_children(): buttons.append(button)
	limitx = buttons.size()
	Audio.store_audio({
		'move' : 'res://audio/engine/snd_squeak.wav',
		'select' : 'res://audio/engine/snd_select.wav',
		'heal' : 'res://audio/engine/snd_heal_c.wav',
		'bell' : 'res://audio/engine/snd_bell.wav',
		'hit' : 'res://audio/engine/snd_damage.wav',
		'vapor' : 'res://audio/engine/snd_vaporized.wav',
		'laz' : 'res://audio/engine/snd_laz.wav',
		'flee' : 'res://audio/engine/snd_escaped.wav',
		'hurt' : 'res://audio/engine/snd_hurt1.wav',
		'impact' : 'res://audio/engine/snd_impact.wav',
		'blaster_summon' : 'res://audio/engine/mus_sfx_segapower.wav',
		'blaster_fire' : 'res://audio/engine/mus_sfx_rainbowbeam_1.wav',
		'gigatalk' : 'res://audio/engine/mus_sfx_a_gigatalk.wav',
		'spear_rise' : 'res://audio/engine/snd_spearrise.wav',
		'warning' : 'res://audio/engine/snd_b.wav',
	})
	
	await get_tree().process_frame
	border_text.font = 'main2'
	set_current_text()
	toggle_soul_index()
	
	soul.engine = self
	
	if bg_color:
		bg_color.size *= 10
		bg_color.position -= bg_color.size / 2

func _process(delta: float) -> void:
	var accept = Input.is_action_just_pressed("accept")
	var cancel = Input.is_action_just_pressed('cancel')
	
	var menu_x = -(int(Input.is_action_just_pressed("left")) - int(Input.is_action_just_pressed("right")))
	var menu_y = -(int(Input.is_action_just_pressed("up")) - int(Input.is_action_just_pressed("down")))
	
	if buffer > -1: buffer -= delta * 30
	if bullet_point.get_theme_font("normal_font") != border_text.get_theme_font("normal_font"):
		var blitter_info = Global.blitter_info[border_text.font]
		Utility.load_font(bullet_point, blitter_info[0], blitter_info[2])
	
	update_health()
	
	# accept
	if accept and buffer < 0:
		var items = clean_items()
		if menu_posx == 2 and items.is_empty() == true: return
		
		buffer = 2
		if menu_no != -1: Audio.play('select')
		
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
						for i in 4:
							if i > items.size() - 1: continue
							create_menuitem('* ' + items[i].abv_name, Vector2(70 + (i % 2) * 250,20 + floor(i / 2) * 32)); i += 1
						create_menuitem('  PAGE 1', Vector2(70 + 1 * 250,20 + 2 * 32))
						page = 1
					3:
						var i = 0
						var spare = false
						
						for enemy in enemies.get_children(): if enemy.spareable: spare = true
						
						if spare: create_menuitem('* ' + 'Spare', Vector2(70,20 + i * 32), Color(1,1,0))
						else: create_menuitem('* ' + 'Spare', Vector2(70,20 + i * 32), Color(1,1,1))
						i += 1
						if can_flee:
							create_menuitem('* ' + 'Flee', Vector2(70,20 + i * 32)); i += 1
			1:
				for item in menuitems.get_children(): item.queue_free()
				menu_no = 2
				
				match prev_menu_posx:
					0:
						menu_no = -1
						soul.visible = false
						
						var enemy = enemies.get_children()[menu_posy]
						var loaded = load(Global.weapon_equipped.item_params.script_path)
						var inst = loaded.instantiate()
						
						inst.enemy = enemy
						inst.border = border
						inst.position = border.size / 2
						border.add_child(inst)
						inst.start()
						
						await inst.finished
						if enemy.health <= 0:
							var new_enemy = enemy.duplicate()
							ignore_enemies.add_child(new_enemy)
							inst.enemy = new_enemy
							enemy.queue_free()
							new_enemy.dust()
							gold_won += new_enemy.gold
							xp_won += new_enemy.xp
						
						await get_tree().process_frame
						if enemies.get_children().is_empty():
							win()
							return
						
						if inst.dmg == -1:
							attack_script.turn_skip(3)
							if !attack_script._randomize: return
						else: attack_script.current_attack += 1
						attack_script.setup()
						
						var dialog
						if real_enemies.dialog.is_empty() == false:
							if attack_script._randomize: dialog = real_enemies.dialog[randi_range(0,real_enemies.dialog.size() - 1)]
							else:
								if attack_script.current_attack <= real_enemies.dialog.size() - 1: dialog = real_enemies.dialog[attack_script.current_attack]
							if dialog: create_dialog_box(dialog)
						
						if dialog: await dialog_finished
						attack_script.start()
					1:
						prev_menu_posy = menu_posy
						menu_posx = 0
						var enemy = enemies.get_children()[prev_menu_posy]
						
						var i = 0
						for act in enemy.acts: create_menuitem('* ' + act.name, Vector2(70 + (i % 2) * 250,20 + floor(i / 2) * 32)); i += 1
					2:
						for item in menuitems.get_children(): item.queue_free()
						menu_no = -1
						soul.visible = false
						border_text.position.x -= 28
						
						Audio.play('heal')
						
						var item = items[(page - 1) * 4 + menu_posx + menu_posy * 2]
						Global.hp = clamp(Global.hp + item.item_params.health, 0, Global.maxhp)
						Global.atk += item.item_params.atk
						Global.def += item.item_params.def
						
						var text = '* You eat the ' + item.full_name + '.'
						if item.item_params.atk > 0: text += '\n* ATTACK increased by ' + str(item.item_params.atk) + '!'
						if item.item_params.def > 0: text += '\n* DEFENSE increased by ' + str(item.item_params.def) + '!'
						if Global.hp == Global.maxhp: text += '\n* Your HP was maxed out.'
						else: text += '\n* You recovered ' + str(item.item_params.health) + 'HP!'
						Global.items.erase(item)
						border_text.reset()
						border_text.text = text
						
						await border_text.completed
						while true:
							var _accept = Input.is_action_just_pressed("accept")
							if _accept and buffer <= 0:
								buffer = 2
								break
							await get_tree().process_frame
						set_current_text(false)
						border_text.position.x += 20
						attack_script.turn_skip(1)
					3:
						match menu_posy:
							0:
								for enemy in enemies.get_children(): if enemy.spareable:
									var new_enemy = enemy.duplicate()
									ignore_enemies.add_child(new_enemy)
									enemy.queue_free()
									new_enemy.spare()
									gold_won += new_enemy.gold
								
								await get_tree().process_frame
								if enemies.get_children().is_empty(): win(true)
								else:
									set_current_text(false)
									attack_script.turn_skip(2)
							1:
								menu_no = -1
								for item in menuitems.get_children(): item.queue_free()
								soul.get_node('sprite').play('flee')
								soul.z_index = 1
								soul.mode = 0
								
								var t = get_tree().create_tween()
								t.tween_property(soul, 'global_position:x', -40, 1.3)
								
								create_menuitem('* Escaped...', Vector2(70,20))
								Audio.play('flee')
								
								await t.finished
								t = get_tree().create_tween()
								t.tween_property(overlay.get_node('fade'), 'modulate:a', 1, 0.5)
								await t.finished
								
								battle_finished.emit()
			2:
				if prev_menu_posx == 1:
					for item in menuitems.get_children(): item.queue_free()
					menu_no = -1
					
					var enemy = enemies.get_children()[prev_menu_posy]
					var act = enemy.acts[menu_posx + menu_posy * 2]
					
					bullet_point.visible = true
					soul.visible = false
					for msg in act.msg:
						border_text.reset()
						border_text.text = msg.text
						border_text.override_pause = msg.override_pause
						border_text.override_speed = msg.override_speed
						
						await border_text.completed
						while true:
							var _accept = Input.is_action_just_pressed("accept")
							if _accept and buffer <= 0:
								buffer = 2
								break
							await get_tree().process_frame
					if act.callback != null: act.callback.call()
					set_current_text(false)
					attack_script.turn_skip(0)
		menu_posy = 0
	
	if cancel and buffer < 0:
		buffer = 2
		
		match menu_no:
			1:
				Audio.play('move')
				menu_no = 0
				menu_posx = prev_menu_posx
				prev_menu_posx = 0
				
				for item in menuitems.get_children(): item.queue_free()
				set_current_text()
				toggle_soul_index()
			2:
				Audio.play('move')
				menu_no = 1
				
				for item in menuitems.get_children(): item.queue_free()
				show_enemies(false)
	
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
			soul.z_index = 1
		1:
			soul.z_index = 0
			match prev_menu_posx:
				0,1:
					menu_posy = posmod(menu_posy + menu_y, enemies.get_children().size())
					soul.position = Vector2(42,36 + menu_posy * 32)
				2:
					var items = clean_items()
					var pages = int(ceil(items.size() / 4.0))
					
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
					var end_items = items.size() - (page - 1) * 4
					
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

# function that gets called when all enemies are dead / spared
func win(spared = false):
	for item in menuitems.get_children(): item.queue_free()
	
	menu_no = -1
	border_text.reset()
	border_text.position.x -= 28
	border_text.text = '* YOU WON!'
	
	Global.gold += gold_won
	Global.xp += xp_won
	
	var text = '\n* You earned ' + str(xp_won) +  ' EXP and ' + str(gold_won) + ' gold.'
	if text.length() >= 33: text = '\n* You earned ' + str(xp_won) +  ' EXP and ' + str(gold_won) + '\n  gold.'
	border_text.text += text
	soul.visible = false
	
	await border_text.finished
	while true:
		var _accept = Input.is_action_just_pressed("accept")
		if _accept:
			battle_finished.emit()
			break
		await get_tree().process_frame

# returns only healing / stat items
func clean_items():
	var items = Global.items
	var nitems = []
	for i in items: if i.item_type == 0: nitems.append(i)
	return nitems

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
		soul.queue_free()
		soul = new_soul
		new_soul.visible = true
		new_soul.engine = self
	else:
		var new_soul = soul.duplicate()
		border.add_child(new_soul)
		soul.queue_free()
		soul = new_soul
		new_soul.visible = true
		new_soul.engine = self
	soul_index_toggle = !soul_index_toggle

# simple function to help redundancy, shows enemy names in the menu
func show_enemies(health=false):
	var i = 0
	for enemy in enemies.get_children():
		if enemy.spareable: create_menuitem('* ' + enemy._name, Vector2(70,20 + i * 32), Color(1,1,0))
		else: create_menuitem('* ' + enemy._name, Vector2(70,20 + i * 32))
		
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
	
	var items = clean_items()
	if page == pages: endrange = items.size()
	
	for i in range((page - 1) * 4, endrange): create_menuitem('* ' + items[i].abv_name, Vector2(70 + (i % 2) * 250,20 + floor((i - (page - 1) * 4) / 2) * 32)); i += 1
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
		if menu_posx + menu_x == -1: limity = 1
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
	randomize()
	if !attack_script._randomize:
		if attack_script.current_attack > attack_script.menu_blitter_texts.size() - 1: current_text = 'blitter not found'
		else: current_text = attack_script.menu_blitter_texts[attack_script.current_attack + 1]
	else: current_text = attack_script.menu_blitter_texts[randi_range(0,attack_script.menu_blitter_texts.size() - 1)]
	
	if enabled:
		border_text.reset()
		border_text.text = current_text
		bullet_point.visible = true
	else:
		border_text.stop()
		border_text.text = ''
		bullet_point.visible = false

# used for enemy dialog, called in attacks script
# text should be formatted: [{'text' : 'text', 'override_pause' : {}, 'override_speed' : {0:0.02}}, ...]
# automatic goes through the text automatically with a delay inbetween
# oneshot only creates the dialog box and plays the first like of the array. note: you must queue free manually after using
func create_dialog_box(text_array : Array, automatic : bool = false, oneshot : bool = false):
	var prev_enemy
	var text
	var inst
	
	for dict in text_array:
		var enemy = enemies.get_node(dict.enemy)
		if enemy == null: continue
		var enemy_pos = enemy.position
		var enemy_dialogbox_pos = enemy.get_node('positions/dialogbox').position
		
		if enemy != prev_enemy:
			enemy = prev_enemy
			
			if inst: inst.queue_free()
			inst = dialogbox.instantiate()
			inst.position = enemy_pos + enemy_dialogbox_pos
			enemies.add_child(inst)
	
			text = inst.get_node('box/text')
		
		text.override_font_size = 16
		if dict.has('size'): text.override_font_size = dict.size
		if dict.has('font'): text.font = dict.font
		text.reset()
		text.text = dict.text
		text.override_pause = dict.override_pause
		text.override_speed = dict.override_speed
			
		if oneshot: return
		await text.completed
		if automatic:
			await get_tree().create_timer(text.text.length() / 0.35).timeout
			continue
		while true:
			var accept = Input.is_action_just_pressed("accept")
			if accept and buffer <= 0:
				buffer = 2
				break
			await get_tree().process_frame
	if inst: inst.queue_free()
	dialog_finished.emit()

# updates the player stats
func update_health():
	var back_size = floor(Global.maxhp * 1.2) + 1
	stats_health_back.size.x = back_size
	stats_health_front.size.x = floor(back_size * Global.hp / Global.maxhp)
	stats_health_kr.size.x = ceil(back_size * Global.kr / Global.maxhp)
	stats_health_back.position.x = stats_hp_spr.position.x + 20
	stats_health_front.position.x = stats_health_back.position.x
	stats_health_kr.position.x = stats_health_back.position.x + back_size * (Global.hp - Global.kr) / Global.maxhp
	
	stats_lv.position.x = stats_name.position.x + stats_name.size.x
	stats_hp_spr.position.x = stats_lv.position.x + stats_lv.size.x + 20
	if Global.kr > -1:
		stats_kr_spr.visible = true
		stats_kr_spr.position.x = stats_health_back.position.x + stats_health_back.size.x + 20
	else:
		stats_kr_spr.visible = false
		stats_kr_spr.position.x = stats_health_back.position.x + stats_health_back.size.x
	stats_hp.position.x = stats_kr_spr.position.x + 30
	stats_name.text = Global.player_name
	stats_name.size.x = Global.player_name.length() * 20
	if center_stats: stats_name.position.x = 32 + back_size / 2
	
	stats_lv.text = 'LV ' + str(Global.lv)
	stats_hp.text = str(Global.hp) + ' / ' + str(Global.maxhp)
	stats_hp.modulate = stats_health_kr.color if Global.kr > 0 else Color(1,1,1)
