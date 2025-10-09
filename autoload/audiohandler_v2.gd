extends Node

@onready var stored = $stored
@onready var temp = $temp

var stored_audios = {}

# dictionaries are formatted:
# {name : stream, name : stream}
# stream can either be an audiostream or a path
func store_audio(dict : Dictionary):
	for _name in dict:
		if stored_audios.has(_name): continue
		
		var audio = AudioStreamPlayer.new()
		audio.name = _name
		
		var stream = dict[_name]
		if stream is String: audio.stream = load(stream)
		elif stream is AudioStream: audio.stream = stream
		else:
			print('Invalid audiostream or path in func store_audio()')
			audio.queue_free()
			return
		
		stored.add_child(audio)
		stored_audios[_name] = audio

# provide the same name used for store_audio
func remove_audio_from_stored(_name : String):
	if stored_audios.find(_name):
		var audio = stored_audios[stored_audios.find(_name)]
		stored_audios.remove_at(stored_audios.find(_name))
		
		audio.queue_free()

# provide the same name used for store_audio, plays the audio
# seek is the audio position when played, ref to audio.seek()
# fade is for if you want the audio out, set to an int
func play(_name : String, pitch : float = 1.0, seek : float = 0.0, volume : float = 0.0, fade = null):
	if stored_audios.has(_name):
		var audio = stored_audios[_name]
		if audio.stream_paused == true:
			audio.stream_paused = false
			return
		audio.pitch_scale = pitch
		audio.volume_db = volume
		audio.play(seek)
		
		if fade:
			var t = get_tree().create_tween()
			t.tween_property(audio, 'volume_db', -80, fade).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

# provide the same name used for store_audio, plays the audio
func pause(_name : String):
	if stored_audios.has(_name):
		var audio = stored_audios[_name]
		audio.stream_paused = true

# returns the node
# provide the same name used for store_audio, plays the audio
func return_node(_name : String):
	if stored_audios.has(_name): return stored_audios[_name]

# this function is for if you want audio to overlap
# the audio plays once and gets destroyed
# stream can either be an audiostream or a path
# seek is the audio position when played, ref to audio.seek()
func play_once(stream, pitch : float = 1.0, seek : float = 0.0, volume : float = 0.0):
	var audio = AudioStreamPlayer.new()
	
	if stream is String: audio.stream = load(stream)
	elif stream is AudioStream: audio.stream = stream
	else:
		push_warning('Invalid audiostream or path in func play_once()')
		audio.queue_free()
		return
	
	temp.add_child(audio)
	audio.pitch_scale = pitch
	audio.volume_db = volume
	audio.play(seek)
	
	await audio.finished
	audio.queue_free()
