extends NinePatchRect

var move_speed = 15


var new_position : Vector2 = Vector2(320,320)
var new_size : Vector2 = Vector2(575,140)
@onready var collision_polygon = $staticbody/collisions

# moves / sizes the border to vec2 value
# if true, is_return will move / size to origin
func to(pos = null, siz = null, is_return = false):
	if is_return:
		pos = Vector2(320,320)
		siz = Vector2(575,140)
	if pos != null: new_position = pos
	if siz != null: new_size = siz

func _process(delta: float) -> void:
	#if position != new_position or size != new_size:
	var coll_pos = [Vector2(5,5), Vector2(size.x - 5,5), size - Vector2(5,5), Vector2(5,size.y - 5), Vector2(-1000,size.y + 1000), size + Vector2(1000,1000), Vector2(size.x + 1000,-1000), Vector2(-1000,-1000), Vector2(-1000,size.y + 1000), Vector2(5,size.y - 5)]
	
	var pool = PackedVector2Array()
	pool.append_array(coll_pos)
	
	collision_polygon.polygon = pool
	
	position = new_position - size / 2
	size = new_size
	pivot_offset = size / 2
	
	#rotation_degrees += delta * 2
