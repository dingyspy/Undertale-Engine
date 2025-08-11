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

var menu_no = 0
var menu_posx = 0
var menu_posy = 0

var buttons = []

var buffer = 0

func _ready() -> void:
	for button in buttons_node.get_children(): buttons.append(button)
	Audio.store_audio({
		'move' : 'res://audio/engine/snd_squeak.wav',
		'select' : 'res://audio/engine/snd_select.wav'
	})

func _process(delta: float) -> void:
	var accept = Input.is_action_just_pressed("accept")
	var cancel = Input.is_action_just_pressed('cancel')
	
	var menu_x = (int(Input.is_action_just_pressed("left")) - int(Input.is_action_just_pressed("right")))
	var menu_y = -(int(Input.is_action_just_pressed("up")) - int(Input.is_action_just_pressed("down")))
	
	if buffer > -1: buffer -= delta * 30
	
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
				0:
					menu_posy = posmod(menu_posy + menu_y, enemies.get_children().size())
					soul.position = border.position + Vector2(42,36 + menu_posy * 30)
					
					if menu_y != 0: Audio.play('move')
	
	# accept
	if accept and buffer < 0:
		buffer = 2
		
		match menu_no:
			0:
				Audio.play('select')
				for button in buttons: button.frame = 0
				menu_no = 1
				
				# extra button functions can be implemented
				match menu_posx:
					0:
						set_current_text(false)
						
						var i = 0
						for enemy in enemies.get_children():
							var inst = create_menuitem(enemy.name, Vector2(70,20 + i * 30))
							
							var rect_back = ColorRect.new()
							rect_back.size = Vector2(95,16)
							rect_back.color = Color(1,0,0)
							rect_back.position = Vector2(250,30 + i * 30)
							menuitems.add_child(rect_back)
							
							var rect_front = ColorRect.new()
							rect_front.size = Vector2((enemy.health / enemy.max_health) * 95,16)
							rect_front.color = Color(0,1,0)
							rect_front.position = Vector2(250,30 + i * 30)
							menuitems.add_child(rect_front)
							
							i += 1
	
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

func create_menuitem(text, position):
	var inst = menuitem.instantiate()
	inst.position = position
	inst.font = border_text.font
	inst.text = '* ' + text
	inst.rdy = true
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
