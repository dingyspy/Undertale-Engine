extends NinePatchRect

# emits when border is done moving / sizing
signal finished

var speed = 500
# if true, position, size, and rotation can be manually controlled through code
var manual_override = false

var new_position : Vector2 = Vector2(320,320)
var new_size : Vector2 = Vector2(575,140)
var border_attack_render = true
var _finished = true
@onready var collision_polygon = $staticbody/collisions
@onready var backbuffer = $backbuffer
@onready var corner0 = $backbuffer/mask/corner0
@onready var corner1 = $backbuffer/mask/corner1
@onready var bullets = $backbuffer/bullets
@onready var attacks = $'../'

# moves / sizes the border to array value
# formatted [pos.x, pos.y], [size.x,size.y]
# or [null, null], [null, null] / null, null
# using null sets the position to the original value
func to(pos = null, siz = null):
	_finished = false
	var pos_vec2 = Vector2(320,320)
	var size_vec2 = Vector2(575,140)
	
	if pos is Array: for i in pos.size(): if pos[i] != null: pos_vec2[i] = pos[i]
	if siz is Array: for i in siz.size(): if siz[i] != null: size_vec2[i] = siz[i]
	
	new_position = pos_vec2
	new_size = size_vec2

# if true, attacks will be rendered inside of the border
# meaning, when the border moves, so will the attacks
# if false, the position of attacks will not correspond with the border position
func toggle_attack_render():
	if !border_attack_render:
		var new_buffer = backbuffer.duplicate()
		add_child(new_buffer)
		new_buffer.position = Vector2(0,0)
		
		attacks.remove_child(backbuffer)
		backbuffer = new_buffer
		corner0 = backbuffer.get_node('mask/corner0')
		corner1 = backbuffer.get_node('mask/corner1')
		bullets = backbuffer.get_node('bullets')
	else:
		var new_buffer = backbuffer.duplicate()
		new_buffer.position = Vector2(0,0)
		attacks.add_child(new_buffer)
		
		remove_child(backbuffer)
		backbuffer = new_buffer
		corner0 = backbuffer.get_node('mask/corner0')
		corner1 = backbuffer.get_node('mask/corner1')
		bullets = backbuffer.get_node('bullets')
	border_attack_render = !border_attack_render

func _process(delta: float) -> void:
	if !manual_override:
		var vec2speed = Vector2(speed * delta,speed * delta)
		
		pivot_offset = size / 2
		position.x = calculate_diff(position.x, new_position.x - size.x / 2, vec2speed.x)
		position.y = calculate_diff(position.y, new_position.y - size.y / 2, vec2speed.y)
		size.x = calculate_diff(size.x, new_size.x, vec2speed.x)
		size.y = calculate_diff(size.y, new_size.y, vec2speed.y)
		
		if position == new_position - size / 2 and size == new_size and !_finished:
			_finished = true
			emit_signal('finished')
	
	var coll_pos = [Vector2(5,5), Vector2(size.x - 5,5), size - Vector2(5,5), Vector2(5,size.y - 5), Vector2(-1000,size.y + 1000), size + Vector2(1000,1000), Vector2(size.x + 1000,-1000), Vector2(-1000,-1000), Vector2(-1000,size.y + 1000), Vector2(5,size.y - 5)]
	var pool = PackedVector2Array()
	pool.append_array(coll_pos)
	
	collision_polygon.polygon = pool
	
	if border_attack_render:
		corner0.position = Vector2(5,5)
		corner1.position = size - Vector2(5,5)
	else:
		corner0.position = position + Vector2(5,5)
		corner1.position = position + size - Vector2(5,5)

func calculate_diff(val, newval, add):
	if abs(val - newval) <= add: val = newval
	elif val > newval: val -= add
	else: val += add
	return val
