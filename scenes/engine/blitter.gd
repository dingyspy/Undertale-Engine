extends RichTextLabel

# is emitted when blitter is finished
# this can be used with await
signal completed

@onready var timer = $timer
@onready var audio = $audio

# manual override for pausing
# format is {character position : pause time, character position : pause time}
var override_pause = {}
# set speed of blitter
# format is {character position : speed, character position : speed}
var override_speed = {}
# false means you can't skip the text
var can_cancel = true
# the time before timeout, aka how fast the blitter is
var speed = 0.033
# references Global.blitter_info
# must be changed BEFORE using .reset()
var font = 'main1'

# pauses for [character_pause_time] time on the characters listed in array
var character_pause_time = 0.2
var pause_characters = [
	'!',
	'?',
	'.',
	',',
	'-'
]

# does not play sound for characters listed in array
var audio_ignore_characters = [
	'',
	' ',
	'.',
	'!',
	'?',
	',',
	':',
	'/',
	'\\'
]

var buffer = 0

func _ready() -> void:
	if !timer:
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
	if !audio:
		audio = AudioStreamPlayer.new()
		add_child(audio)
	
	timer.connect('timeout', on_timeout)

func on_timeout() -> void:
	if visible_characters == len(text): return
	
	var char = text[visible_characters]
	
	if visible_characters < len(text) - 1:
		if visible_characters in override_pause.keys() and !override_pause.is_empty(): timer.start(override_pause[visible_characters])
		elif char in pause_characters and override_pause.is_empty(): timer.start(character_pause_time)
		else: timer.start(speed)
		if visible_characters in override_speed.keys() and !override_speed.is_empty(): speed = override_speed[visible_characters]
	
	if audio_ignore_characters.find(char) == -1: audio.play()
	
	visible_characters += 1
	if visible_characters == len(text): completed.emit()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cancel") and buffer < 0 and can_cancel: stop()
	if buffer > -1: buffer -= 30 * delta

func stop() -> void:
	timer.stop()
	buffer = 2
	
	visible_characters = len(text)
	completed.emit()

func reset() -> void:
	visible_characters = 1
	
	speed = 0.02
	buffer = 2
	
	override_pause = {}
	override_speed = {}
	
	var blitter_info = Global.blitter_info[font]
	audio.stream = load(blitter_info[1])
	
	Utility.load_font(self, blitter_info[0], blitter_info[2])
	timer.start(speed)
