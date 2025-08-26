extends Node

# blurs the background when menu is opened
var background_blur_on_menuopen = false
var can_open_menu = true
# -1: camera can be set manually, is not moved when player moves
# 0: camera locks to player
# 1: camera lerps to player
# modes 0 and 1 use camera_clamp_x and camera_clamp_y from the scene
var camera_mode = 0
# adjusts positions of menu items depending on the player's position
var menu_adapt = true

@onready var overworld = $'../'
@onready var player = $'../container/player'
@onready var container = $'../container'
@onready var tilemaps = $'../container/tilemaps'
@onready var overlay = $'../overlay'
@onready var camera = $'../camera'

@export var start_scene_path = 'res://scenes/unique/overworld/scenes/test.tscn'
var current_scene

# dialog function and dialog finished signal is in this
@onready var menu = $'menu'
@onready var events = $'events'

# is set to true by evets when player is currently in an event
var is_in_event = false

func _ready() -> void:
	if start_scene_path != '' or start_scene_path != null: load_scene(start_scene_path)
	player.engine = self

# destroys prev scene & assets and loads a new one
# scenes must have a node named "tilemaps"
# tilemap layers should be children of this node
# note: this is just for y-sort, tilemaps dont HAVE
# to be under the tilemaps node
func load_scene(scene):
	# destroys assets
	for _scene in container.get_children(): if _scene != player and _scene != tilemaps: _scene.queue_free()
	for tilemap in tilemaps.get_children(): if tilemap != player: tilemap.queue_free()
	
	# checks if scene is str or packed, else returns
	var loaded_scene
	if scene is String: loaded_scene = load(start_scene_path)
	elif scene is PackedScene: loaded_scene = scene
	else: return
	
	# adds scene
	loaded_scene = loaded_scene.instantiate()
	
	# reparents all tilemaps to main tilemaps node (enables y sorting basically)
	for tilemap in loaded_scene.get_node('tilemaps').get_children():
		var tilemap_dupe = tilemap.duplicate()
		tilemaps.add_child(tilemap_dupe)
	loaded_scene.get_node('tilemaps').queue_free()
	
	# adds player to tilemaps (same y sort issue)
	var player_dupe = player.duplicate()
	tilemaps.add_child(player_dupe)
	player.queue_free()
	player = player_dupe
	
	# finally, adds child and sets current_scene
	container.add_child(loaded_scene)
	current_scene = loaded_scene

func start_fight():
	pass

# called from the player script if "engine" is defined
func update_camera(delta) -> void:
	if current_scene:
		var clampped_x = clamp(player.position.x, current_scene.camera_clamp_x.x, current_scene.camera_clamp_x.y,)
		var clampped_y = clamp(player.position.y, current_scene.camera_clamp_y.x, current_scene.camera_clamp_y.y)
		match camera_mode:
			-1: pass
			0: camera.position = Vector2(clampped_x, clampped_y)
			1: camera.position = lerp(camera.position, Vector2(clampped_x, clampped_y), delta * 10)
		
		# automatically sets the menu stuff position similar to og undertale
		if menu_adapt:
			if clampped_y - player.position.y <= 0:
				menu.default_dialogbox_position = Vector2(0,0)
				menu.menu_mini.position.y = 0
			else:
				menu.default_dialogbox_position = Vector2(0,-310)
				menu.menu_mini.position.y = 270
