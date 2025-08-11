extends RichTextLabel

var font = 'main1'
var rdy = false

func _ready() -> void:
	while rdy == false: await get_tree().process_frame
	
	var blitter_info = Global.blitter_info[font]
	Utility.load_font(self, blitter_info[0], blitter_info[2])
