extends Node

# undertale values
var player_name = 'NAME'
var lv = 19
var maxhp = 16 + (4 * lv)
var hp = maxhp
# -1 kr makes it inactive
var kr = 0
var atk = -2 + (2 * lv)
var def = floor((lv - 1) / 4)
var gold = 0
var xp = 0

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
# current weapon equipped
# this determines which attack the player does in a fight
# same format as item format
var weapon_equipped = {
	'abv_name' : 'Stick',
	'full_name' : 'Stick',
	'info_dialog' : ['Its bark is worse than its bite.'],
	'item_type' : 1,
	'item_params' : {
		'use_text' : ['You threw the stick away. Then picked it back up.'],
		'atk' : 4,
		'script_path' : 'res://scenes/unique/attacks/player/single.tscn'
	},
	'buy_price' : 0,
	'sell_price' : 150,
}
# same format as item format
var armor_equipped = {
	'abv_name' : 'Bandage',
	'full_name' : 'Bandage',
	'info_dialog' : ['It has already been used many times.'],
	'item_type' : 1,
	'item_params' : {
		'use_text' : ['You re-applied the bandage. Still kind of gooey.'],
		'def' : 0,
	},
	'buy_price' : 0,
	'sell_price' : 150,
}
# all the ppl you can call in the overworld
# formatted: {name, if the phone picks up, dialog [{text, font, override_pause, override_speed, face_animation (if null, none)}, ...], question}
# if the question "bool" is true, dialogbox will prompt a yes/no selection
# the yes_dialog and no_dialog is selected according to what is selected by the player
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
				'face_animation' : 'toriel',
				'question' : {
					'bool' : true,
					'yes_dialog' : [
						{
							'text' : 'Selected yes.',
							'font' : 'main1',
							'override_pause' : {},
							'override_speed' : {},
							'face_animation' : null,
							'question' : true,
						},
					],
					'no_dialog' : [
						{
							'text' : 'Selected no.',
							'font' : 'main1',
							'override_pause' : {},
							'override_speed' : {},
							'face_animation' : null,
							'question' : true,
						},
					],
				}
			},
			{
				'text' : 'This is a test text 2.',
				'font' : 'toriel',
				'override_pause' : {},
				'override_speed' : {},
				'face_animation' : 'toriel',
				'question' : {
					'bool' : false,
				}
			},
		]
	}
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
