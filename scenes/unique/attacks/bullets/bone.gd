extends NinePatchRect

var _position
var _size
var _rotation
var pivot
var type = 'sans'
var dmg = 1
var kr = 2

func setup():
	size.y = _size
	position = _position - size / 2
	rotation_degrees = _rotation
	
	match type:
		'sans':
			texture = load('res://sprites/engine/battle/bullets/bone/bone_sans.png')
			patch_margin_left = 0
			patch_margin_top = 6
			patch_margin_right = 0
			patch_margin_bottom = 6
		'papyrus':
			texture = load('res://sprites/engine/battle/bullets/bone/bone_papyrus.png')
			patch_margin_left = 0
			patch_margin_top = 4
			patch_margin_right = 0
			patch_margin_bottom = 4

func _process(delta: float) -> void:
	match pivot:
		'center': pivot_offset = size / 2
