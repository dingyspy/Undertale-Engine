extends Node2D

@onready var text = $box/text
@onready var box = $box
var fixed_x = false

func _process(delta):
	text.rect_size.x = 231
	
	var lns = len(text.bbcode_text.split('\n'))
	box.size.y = clamp(lns * 23, 65, 10000)
	text.rect_size.y = clamp(lns * 23, 65, 10000)
	
	if !fixed_x:
		var chr_max = 0
		for i in text.text.split('\n'):
			var chrs = 0
			for chr in i:
				chrs += 1
			if chrs > chr_max: 
				chr_max = chrs
		box.size.x = chr_max * 11 #reg size x 212
	else:
		text.rect_size.x = 201
