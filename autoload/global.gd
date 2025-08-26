extends Node

const SAVE_PATH = 'user://config.cfg'
var save_data = {}
var saving = false
# all variables that should be saved / loaded when calling _save or _load functions
# should be in here for proper functionality
const included = [
	'player_name',
	'lv',
	'maxhp',
	'hp',
	'kr',
	'atk',
	'def',
	'gold',
	'xp',
	'time',
	'items',
	'weapon_equipped',
	'armor_equipped',
	'cell',
]

# undertale values
var player_name = 'NAME'
var lv = 19
var maxhp = 16 + (4 * lv)
var hp = maxhp
# -1 kr makes the kr system inactive
var kr = -1
var atk = -2 + (2 * lv)
var def = floor((lv - 1) / 4)
var gold = 0
var xp = 0
# amount of time spent in-game (in seconds)
# can be formatted with time_format(seconds) in utility
var time = 0
# size of inventory, doesnt clamp itself, this is only used for box
# there is an example of clamping in test overworld scene
var inventory_size = 8
var box_size = 10

# items for both in-game and overworld
# formatted: {abbreviated name, full name, [text, text1, ...], heal, atk gain, def gain, buy price, sell price, type (0:item,1:weapon,2:armor)}
var items = [
	{
		'abv_name' : 'L. Hero',
		'full_name' : 'Legendary Hero',
		'info_dialog' : ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'],
		'item_type' : 0, # 0: item, 1: weapon, 2: armor
		'item_params' : {
			'health' : 40,
			'atk' : 4, # gets added to main atk for the battle
			'def' : 0, # gets added to main def for the battle
		},
		'buy_price' : 300,
		'sell_price' : 40,
	},
	{
		'abv_name' : 'L. Hero',
		'full_name' : 'Legendary Hero',
		'info_dialog' : ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'],
		'item_type' : 0, # 0: item, 1: weapon, 2: armor
		'item_params' : {
			'health' : 40,
			'atk' : 4, # gets added to main atk for the battle
			'def' : 0, # gets added to main def for the battle
		},
		'buy_price' : 300,
		'sell_price' : 40,
	},
	{
		'abv_name' : 'L. Hero',
		'full_name' : 'Legendary Hero',
		'info_dialog' : ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'],
		'item_type' : 0, # 0: item, 1: weapon, 2: armor
		'item_params' : {
			'health' : 40,
			'atk' : 4, # gets added to main atk for the battle
			'def' : 0, # gets added to main def for the battle
		},
		'buy_price' : 300,
		'sell_price' : 40,
	},
	{
		'abv_name' : 'L. Hero',
		'full_name' : 'Legendary Hero',
		'info_dialog' : ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'],
		'item_type' : 0, # 0: item, 1: weapon, 2: armor
		'item_params' : {
			'health' : 40,
			'atk' : 4, # gets added to main atk for the battle
			'def' : 0, # gets added to main def for the battle
		},
		'buy_price' : 300,
		'sell_price' : 40,
	},
	{
		'abv_name' : 'L. Hero',
		'full_name' : 'Legendary Hero',
		'info_dialog' : ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'],
		'item_type' : 0, # 0: item, 1: weapon, 2: armor
		'item_params' : {
			'health' : 40,
			'atk' : 4, # gets added to main atk for the battle
			'def' : 0, # gets added to main def for the battle
		},
		'buy_price' : 300,
		'sell_price' : 40,
	},
	{
		'abv_name' : 'L. Hero',
		'full_name' : 'Legendary gg',
		'info_dialog' : ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'],
		'item_type' : 2, # 0: item, 1: weapon, 2: armor
		'item_params' : {
			'health' : 40,
			'def' : 4, # gets added to main def for the battle
		},
		'buy_price' : 300,
		'sell_price' : 40,
	},
]
# current weapon equipped
# this determines which attack the player does in a fight
# same format as item format
var weapon_equipped = {
	'abv_name' : 'Stick',
	'full_name' : 'Stick',
	'info_dialog' : ['* Its bark is worse than its bite.'],
	'item_type' : 1,
	'item_params' : {
		'atk' : 4,
		'script_path' : 'res://scenes/unique/battle/attacks/player/single.tscn'
	},
	'buy_price' : 0,
	'sell_price' : 150,
}
# same format as item format
var armor_equipped = {
	'abv_name' : 'Bandage',
	'full_name' : 'Bandage',
	'info_dialog' : ['* It has already been used many\n  times.'],
	'item_type' : 2,
	'item_params' : {
		'def' : 0,
	},
	'buy_price' : 0,
	'sell_price' : 150,
}
# same format as items format
var box = [
	{
		'abv_name' : 'L. Hero',
		'full_name' : 'Legendary Hero',
		'info_dialog' : ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'],
		'item_type' : 0, # 0: item, 1: weapon, 2: armor
		'item_params' : {
			'health' : 40,
			'atk' : 4, # gets added to main atk for the battle
			'def' : 0, # gets added to main def for the battle
		},
		'buy_price' : 300,
		'sell_price' : 40,
	},
	{
		'abv_name' : 'L. Hero',
		'full_name' : 'Legendary Hero',
		'info_dialog' : ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'],
		'item_type' : 0, # 0: item, 1: weapon, 2: armor
		'item_params' : {
			'health' : 40,
			'atk' : 4, # gets added to main atk for the battle
			'def' : 0, # gets added to main def for the battle
		},
		'buy_price' : 300,
		'sell_price' : 40,
	},
	{
		'abv_name' : 'L. Hero',
		'full_name' : 'Legendary Hero',
		'info_dialog' : ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'],
		'item_type' : 0, # 0: item, 1: weapon, 2: armor
		'item_params' : {
			'health' : 40,
			'atk' : 4, # gets added to main atk for the battle
			'def' : 0, # gets added to main def for the battle
		},
		'buy_price' : 300,
		'sell_price' : 40,
	},
]
# all the ppl you can call in the overworld
# formatted: {name, if the phone picks up, dialog [{text, font, override_pause, override_speed, face_animation (if null, none), question}], ...}
# if the question "options" is not null, dialogbox will prompt a yes/no selection (or option0, option1)
# the options will be named depending on the values in the array chronologically
# option0+ dialog is selected according to what is selected by the player
# theoretically you can make nested options, which is kinda cool lol
# "yes" and "no" option text can be changed in the overworld dialog box manually
# options can also be added, just make sure to add it in the overworld and format the next option as
# option prev number + 1
# the engine should automatically handle the rest
var cell = [
	{
		'name' : 'Toriel',
		'pick_up' : true,
		'dialog' : [
			{
				'text' : 'This is a test text.',
				'font' : 'toriel',
				'override_pause' : {},
				'override_speed' : {},
				'face_animation' : 'papyrus',
				'question' : {
					'options' : ['Yes', 'No'],
					'Yes' : [
						{
							'text' : 'Selected yes.',
							'font' : 'main1',
							'override_pause' : {},
							'override_speed' : {},
							'face_animation' : null,
							'question' : {
								'options' : null,
							}
						},
					],
					'No' : [
						{
							'text' : 'Selected no.',
							'font' : 'main1',
							'override_pause' : {},
							'override_speed' : {},
							'face_animation' : null,
							'question' : {
								'options' : null,
							}
						},
					],
				}
			},
			{
				'text' : 'This is a test text 2.',
				'font' : 'papyrus',
				'override_pause' : {},
				'override_speed' : {},
				'face_animation' : null,
				'question' : {
					'options' : null,
				}
			},
		]
	},
]
# used for font changing & audio with text blitter
# formatted {name : [font path, audio path, font size]}
var blitter_info = {
	'main1' : ['res://fonts/DeterminationMonoWebRegular-Z5oq.ttf', 'res://audio/blitter/SND_TXT1.wav', 32],
	'main2' : ['res://fonts/DeterminationMonoWebRegular-Z5oq.ttf', 'res://audio/blitter/SND_TXT2.wav', 32],
	'alphys' : ['res://fonts/DeterminationMonoWebRegular-Z5oq.ttf', 'res://audio/blitter/snd_txtal.wav', 32],
	'asgore' : ['res://fonts/DeterminationMonoWebRegular-Z5oq.ttf', 'res://audio/blitter/snd_txtasg.wav', 32],
	'asriel' : ['res://fonts/DeterminationMonoWebRegular-Z5oq.ttf', 'res://audio/blitter/snd_txtasr.wav', 32],
	'papyrus' : ['res://fonts/papyrus-font-undertale.ttf', 'res://audio/blitter/snd_txtpap.wav', 32],
	'sans' : ['res://fonts/sans.ttf', 'res://audio/blitter/snd_txtsans.wav', 28],
	'toriel' : ['res://fonts/DeterminationMonoWebRegular-Z5oq.ttf', 'res://audio/blitter/snd_txttor.wav', 32],
	'undyne' : ['res://fonts/DeterminationMonoWebRegular-Z5oq.ttf', 'res://audio/blitter/snd_txtund.wav', 32],
}

func _ready() -> void:
	Engine.max_fps = 30

# for if you want to tweak anything after variables are loaded
# in this case, i use it to increment time
func on_loaded():
	while true:
		await get_tree().create_timer(1).timeout
		time += 1

func _save():
	# awaits process frame in case value is changed at the same
	# time as this is called
	await get_tree().process_frame
	saving = true
	var config = ConfigFile.new()
	
	# gets all variable names found in included
	# sets values in cfg
	for info in get_script().get_script_property_list(): if info.name in included: config.set_value("global", info.name, get(info.name))
	
	config.save(SAVE_PATH)
	saving = false

func _load():
	var config = ConfigFile.new()
	
	# if theres no save file, create one with default settings
	if !FileAccess.file_exists(SAVE_PATH):
		_save()
		while !saving: await get_tree().process_frame
	config.load(SAVE_PATH)
	
	# gets all variable names found in included
	# sets values from cfg in here
	for info in get_script().get_script_property_list(): if config.get_value("global", info.name): self[info.name] = config.get_value("global", info.name)
	on_loaded()
