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
# every frame a random int is generated
# if random int % random_val is equal to 0
# then the enemy will be encountered
# the higher the value, the less likely you are to encounter an enemy / enemies
# enemy encounter array is in the scene
@export var random_val = 200

@onready var battle = preload("res://scenes/engine/battle/engine.tscn")

@onready var overworld = $'../'
@onready var player = $'../container/player'
@onready var container = $'../container'
@onready var tilemaps = $'../container/tilemaps'
@onready var overlay = $'../overlay'
@onready var fade = $'../overlay/fade'
@onready var flash = $'../overlay/flash'
@onready var camera = $'../camera'
@onready var battle_container = $'../battle'
@onready var black = $'../black'
@onready var soul = $'../overlay/soul'
@onready var bubble = $'../overlay/bubble'

@export var start_scene_path = ''
var current_scene
var current_battle

# dialog function and dialog finished signal is in this
@onready var menu = $'menu'
@onready var events = $'events'

# is set to true by evets when player is currently in an event
var is_in_event = false
# remembers previous collisions when theyre disabled on battle start
var collision_settings = []
var visibility_settings = []

func _ready() -> void:
	if start_scene_path != '' and start_scene_path != null: load_scene(start_scene_path)
	if (start_scene_path == '' or start_scene_path == null) and (Global.saved_overworld_scene != '' and Global.saved_overworld_scene != null): load_scene(Global.saved_overworld_scene, true)
	player.engine = self
	black.visible = false
	soul.visible = false
	bubble.visible = false

# destroys prev scene & assets and loads a new one
# scenes must have a node named "tilemaps"
# tilemap layers should be children of this node
# note: this is just for y-sort, tilemaps dont HAVE
# to be under the tilemaps node
# if go_to_save is true, the players position will be set to the save area's position
func load_scene(scene, go_to_save : bool = false):
	# destroys assets
	for tilemap in tilemaps.get_children(): if tilemap != player: tilemap.queue_free()
	
	# checks if scene is str or packed, else returns
	var loaded_scene
	if scene is String: loaded_scene = load(scene)
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
	player.engine = self
	
	# finally, adds child and sets current_scene
	container.add_child(loaded_scene)
	current_scene = loaded_scene
	
	# sets player position to spawn if scene has it
	# created for scene transition and to avoid softlock
	if loaded_scene.get_node('spawn'): player.position = loaded_scene.get_node('spawn').position
	
	# positions player to save
	if go_to_save: for i in Utility.get_all_children(loaded_scene): if i.name == '_save' and i is Area2D: for col in Utility.get_all_children(i): if col is CollisionShape2D or col is CollisionPolygon2D: player.position = col.position
	
	# tweens fade
	var t = get_tree().create_tween()
	t.tween_property(fade, 'modulate:a', 0, 0.5)

func start_fight(enemies):
	# so overworld logic doesnt interfere
	player.mode = 0
	is_in_event = true
	await get_tree().process_frame
	
	# remembers previous collisions
	collision_settings = []
	visibility_settings = []
	for col in Utility.get_all_children(overworld):
		if col is CollisionPolygon2D or col is CollisionShape2D:
			collision_settings.append([col, col.disabled])
			col.disabled = true
		if col is TileMap or col is TileMapLayer:
			collision_settings.append([col, col.collision_enabled])
			col.collision_enabled = false
	
	for tilemap in tilemaps.get_children():
		if tilemap != player:
			visibility_settings.append([tilemap, tilemap.visible])
			tilemap.visible = false
	
	bubble.global_position = player.get_node('center').global_position + player.get_node('center').position
	bubble.visible = true
	
	Audio.play('encounter')
	await get_tree().create_timer(0.5).timeout
	
	soul.global_position = player.get_node('center').global_position
	black.visible = true
	soul.visible = true
	
	for i in 6:
		soul.visible = !soul.visible
		if soul.visible == true: Audio.play('chk')
		await get_tree().create_timer(0.05).timeout
	
	soul.visible = true
	bubble.visible = false
	player.visible = false
	Audio.play('battlefall')
	
	var t = get_tree().create_tween()
	t.tween_property(soul, 'position', camera.position - Vector2(320,240) + Vector2(48,453), 0.8)
	await get_tree().create_timer(0.8).timeout
	
	# instance it, set enemys, and add child
	var inst = battle.instantiate()
	inst.get_node('enemies').enemy_paths = enemies
	inst.get_node('engine').overworld = self
	inst.get_node('engine/attacks')._randomize = true
	
	battle_container.add_child(inst)
	
	# make the battle's camera current
	while !inst.get_node('engine').camera: await get_tree().process_frame
	inst.get_node('engine').camera.make_current()
	
	current_battle = inst
	soul.visible = false

func end_fight():
	# sets collision disabled bool to original before fight started
	fade.modulate.a = 1
	var t = get_tree().create_tween()
	t.tween_property(fade, 'modulate:a', 0, 0.5)
	
	await get_tree().process_frame
	camera.make_current()
	
	for col in collision_settings:
		if col[0] is CollisionPolygon2D or col[0] is CollisionShape2D: col[0].disabled = col[1]
		else: col[0].collision_enabled = col[1]
	
	for i in visibility_settings: i[0].visible = i[1]
	
	current_battle.queue_free()
	
	player.mode = 1
	is_in_event = false
	player.visible = true

func _process(delta: float) -> void:
	# check if player is moving
	if current_scene:
		if current_scene.encounter_enemies.is_empty() == false and player.velocity != Vector2.ZERO and !is_in_event:
			# if true, encounter enemy
			if randi() % random_val == 0:
				var selected = randi() % current_scene.encounter_enemies.size()
				start_fight(current_scene.encounter_enemies[selected])
				current_scene.encounter_enemies.remove_at(selected)

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
			if clampped_y - player.position.y >= 0:
				menu.default_dialogbox_position = Vector2(0,0)
				menu.menu_mini.position.y = 0
			else:
				menu.default_dialogbox_position = Vector2(0,-310)
				menu.menu_mini.position.y = 270
