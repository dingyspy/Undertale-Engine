extends Node

# undertale values
var lv = 1
var maxhp = 16 + (4 * lv)
var hp = maxhp
var kr = 0
var atk = -2 + (2 * lv)
var def = floor((lv - 1) / 4)
var gold = 0
var xp = 0

# items for both in-game and overworld
# formatted: [abbreviated name, full name, [text, text1, ...], heal, atk gain, def gain, buy price, sell price, type (0:item,1:weapon,2:armor)]
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
# used for font changing & audio with text blitter
# formatted {name : [font path, audio path, font size]}
var blitter_info = {
	'main1' : ['res://fonts/main.ttf', 'res://audio/blitter/SND_TXT1.wav', 32],
	'main2' : ['res://fonts/main.ttf', 'res://audio/blitter/SND_TXT2.wav', 32],
	'alphys' : ['res://fonts/main.ttf', 'res://audio/blitter/snd_txtal.wav', 32],
	'asgore' : ['res://fonts/main.ttf', 'res://audio/blitter/snd_txtasg.wav', 32],
	'asriel' : ['res://fonts/main.ttf', 'res://audio/blitter/snd_txtasr.wav', 32],
	'papyrus' : ['res://fonts/papyrus-font-undertale.ttf', 'res://audio/blitter/snd_txtpap.wav', 32],
	'sans' : ['res://fonts/sans.ttf', 'res://audio/blitter/snd_txtsans.wav', 28],
	'toriel' : ['res://fonts/main.ttf', 'res://audio/blitter/snd_txttor.wav', 32],
	'undyne' : ['res://fonts/main.ttf', 'res://audio/blitter/snd_txtund.wav', 32],
}

func _ready() -> void:
	Engine.max_fps = 30
