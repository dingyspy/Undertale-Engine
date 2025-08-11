extends Node

@onready var menu = $'../menu'
@onready var enemies = $'../enemies'

@onready var border = $'../attacks/border'
@onready var border_text = $'../attacks/border/text/text'
@onready var bullet_point = $'../attacks/border/text/bullet'
@onready var soul = $'../attacks/soul'
@onready var menuitems = $'../attacks/border/items'

@onready var buttons_node = $'../menu/buttons'

@onready var menuitem = preload('res://scenes/engine/battle/menuitem.tscn')

var current_text = 'Menu text! :)'
var can_flee = true

var menu_no = 0
var menu_posx = 0
var menu_posy = 0
var prev_menu_posx = 0

var buttons = []

var buffer = 0

func _ready() -> void:
	for button in buttons_node.get_children(): buttons.append(button)
	Audio.store_audio({
		'move' : 'res://audio/engine/snd_squeak.wav',
		'select' : 'res://audio/engine/snd_select.wav'
	})
	
	await get_tree().process_frame
	border_text.font = 'main2'
	set_current_text()

func _process(delta: float) -> void:
	var accept = Input.is_action_just_pressed("accept")
	var cancel = Input.is_action_just_pressed('cancel')
	
	var menu_x = -(int(Input.is_action_just_pressed("left")) - int(Input.is_action_just_pressed("right")))
	var menu_y = -(int(Input.is_action_just_pressed("up")) - int(Input.is_action_just_pressed("down")))
	
	if buffer > -1: buffer -= delta * 30
	if bullet_point.get_theme_font("normal_font") != border_text.get_theme_font("normal_font"):
		var blitter_info = Global.blitter_info[border_text.font]
		var _font = FontFile.new()
		_font.load_dynamic_font(blitter_info[0])
		bullet_point.add_theme_font_override("normal_font", _font)
		bullet_point.add_theme_font_size_override("normal_font_size", blitter_info[2])
	
	# process menu_no
	match menu_no:
		0:
			menu_posx = posmod(menu_posx + menu_x, buttons.size())
			soul.position = buttons[menu_posx].position
			for button in buttons:
				if button == buttons[menu_posx]: button.frame = 1
				else: button.frame = 0
			if menu_x != 0: Audio.play('move')
		1:
			# this is where extra button functions can be implemented
			# another one is below in the "accept" section
			match menu_posx:
				0,1:
					menu_posy = posmod(menu_posy + menu_y, enemies.get_children().size())
					soul.position = border.position + Vector2(42,36 + menu_posy * 32)
					
					if menu_y != 0 and enemies.get_children().size() != 1: Audio.play('move')
				3:
					var i = 1 + int(can_flee)
					
					menu_posy = posmod(menu_posy + menu_y, i)
					soul.position = border.position + Vector2(42,36 + menu_posy * 32)
					
					if menu_y != 0 and i != 1: Audio.play('move')
	
	# accept
	if accept and buffer < 0:
		buffer = 2
		
		Audio.play('select')
		menu_posy = 0
		match menu_no:
			0:
				for button in buttons: button.frame = 0
				menu_no = 1
				
				set_current_text(false)
				
				# extra button functions can be implemented
				match menu_posx:
					0:
						var i = 0
						for enemy in enemies.get_children():
							create_menuitem(enemy.name, Vector2(70,20 + i * 32))
							
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
					1:
						var i = 0
						for enemy in enemies.get_children():
							create_menuitem(enemy.name, Vector2(70,20 + i * 32))
							i += 1
					2:
						var column = 0
						for i in 4:
							create_menuitem(Global.items[i][0], Vector2(70 + (i % 2) * 200,20 + column * 32)); i += 1
							if i - 1 % 2 == 1: column += 1
					3:
						var i = 0
						var spare = false
						
						for enemy in enemies.get_children(): if enemy.sparable: spare = true
						
						if spare: create_menuitem('Spare', Vector2(70,20 + i * 32), Color(1,1,0))
						else: create_menuitem('Spare', Vector2(70,20 + i * 32), Color(1,1,1))
						i += 1
						if can_flee:
							create_menuitem('Flee', Vector2(70,20 + i * 32)); i += 1
	
	if cancel and buffer < 0:
		buffer = 2
		
		match menu_no:
			1:
				Audio.play('move')
				menu_no = 0
				
				for item in menuitems.get_children(): item.queue_free()
				set_current_text()
				
				# extra button functions can be implemented
				match menu_posx:
					0:
						pass

func create_menuitem(text, position, color=Color(1,1,1)):
	var inst = menuitem.instantiate()
	inst.position = position
	inst.font = border_text.font
	inst.text = '* ' + text
	inst.rdy = true
	inst.modulate = color
	menuitems.add_child(inst)
	return inst

func set_current_text(enabled=true):
	if enabled:
		border_text.reset()
		border_text.text = current_text
		bullet_point.visible = true
	else:
		border_text.stop()
		border_text.text = ''
		bullet_point.visible = false
