extends Node

# blurs the background when menu is opened
var background_blur_on_menuopen = false
var can_open_menu = true

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

func _ready() -> void:
	if start_scene_path != '' or start_scene_path != null: load_scene(start_scene_path)

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
