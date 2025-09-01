extends NinePatchRect

# emits when border is done moving / sizing
signal finished

var speed = 800
# if true, position, size, and rotation can be manually controlled through code
var manual_override = false

var new_position : Vector2 = Vector2(320,320)
var new_size : Vector2 = Vector2(575,140)
var target_rotation = 0
var border_attack_render = true
var _finished = true
@onready var collision_polygon = $staticbody/collisions
@onready var backbuffer = $backbuffer
@onready var corner0 = $backbuffer/mask/corner0
@onready var corner1 = $backbuffer/mask/corner1
@onready var bullets = $backbuffer/bullets
@onready var attacks = $'../'
@onready var c0 = $c0
@onready var c1 = $c1
var LEFT = 0
var RIGHT = 0
# border.UP and border.DOWN for consistency with VECTOR.UP and VECTOR.DOWN
var UP = 0
var DOWN = 0
var CENTER = 0
var DISTANCE = 0

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
		new_buffer.position = Vector2.ZERO
		
		backbuffer.queue_free()
		backbuffer = new_buffer
		corner0 = backbuffer.get_node('mask/corner0')
		corner1 = backbuffer.get_node('mask/corner1')
		bullets = backbuffer.get_node('bullets')
	else:
		var new_buffer = backbuffer.duplicate()
		new_buffer.position = Vector2.ZERO
		attacks.add_child(new_buffer)
		
		backbuffer.queue_free()
		backbuffer = new_buffer
		corner0 = backbuffer.get_node('mask/corner0')
		corner1 = backbuffer.get_node('mask/corner1')
		bullets = backbuffer.get_node('bullets')
	border_attack_render = !border_attack_render

func _physics_process(delta: float) -> void:
	if !manual_override:
		var vec2speed = Vector2(speed * delta,speed * delta)
		
		#rotation_degrees = 2
		var calculated_size = Vector2(Utility.calculate_diff(size.x, new_size.x, vec2speed.x), Utility.calculate_diff(size.y, new_size.y, vec2speed.y))
		var calculated_pos = Vector2(Utility.calculate_diff(position.x, new_position.x - calculated_size.x / 2, vec2speed.x), Utility.calculate_diff(position.y, new_position.y - calculated_size.y / 2, vec2speed.y))
		position = calculated_pos
		size = calculated_size
		pivot_offset = calculated_size / 2
		
		if border_attack_render:
			LEFT = 5
			RIGHT = calculated_size.x - 5
			UP = 5
			DOWN = calculated_size.y - 5
			CENTER = calculated_size / 2
		else:
			LEFT = global_position.x + 5
			RIGHT = global_position.x + size.x - 5
			UP = global_position.y + 5
			DOWN = global_position.y + size.y - 5
			CENTER = Vector2(LEFT + (size.x - 10) / 2, UP + (size.y - 10) / 2)
		DISTANCE = Vector2(RIGHT - LEFT, DOWN - UP)
		
		c0.position = Vector2(5,5)
		c1.position = size - Vector2(5,5)
		
		if position == new_position - size / 2 and size == new_size and !_finished:
			_finished = true
			finished.emit()
	
	var coll_pos = [Vector2(5,5), Vector2(size.x - 5,5), size - Vector2(5,5), Vector2(5,size.y - 5), Vector2(-1000,size.y + 1000), size + Vector2(1000,1000), Vector2(size.x + 1000,-1000), Vector2(-1000,-1000), Vector2(-1000,size.y + 1000), Vector2(5,size.y - 5)]
	var pool = PackedVector2Array()
	pool.append_array(coll_pos)
	
	collision_polygon.polygon = pool
	
	rotation_degrees = target_rotation
	if border_attack_render:
		corner0.position = Vector2(5,5)
		corner1.position = size - Vector2(5,5)
		corner0.rotation_degrees = 0
		corner1.rotation_degrees = 0
	else:
		corner0.global_position = c0.global_position
		corner1.global_position = c1.global_position
		corner0.rotation_degrees = target_rotation
		corner1.rotation_degrees = target_rotation
