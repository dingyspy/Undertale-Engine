extends Node

var atk = 0
var def = 0

# items for both in-game and overworld
# formatted: [abbreviated name, full name, [text, text1, ...], heal, atk gain, def gain, buy price, sell price]
var items = [
	['L. Hero', 'Legendary Hero', ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'], 40, 4, 0, 300, 40],
	['L. Hero', 'Legendary Hero', ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'], 40, 4, 0, 300, 40],
	['L. Hero', 'Legendary Hero', ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'], 40, 4, 0, 300, 40],
	['L. Hero', 'Legendary Hero', ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'], 40, 4, 0, 300, 40],
	['L. Hero', 'Legendary Hero', ['Sandwich shaped like a sword.', 'Increases ATTACK when eaten.'], 40, 4, 0, 300, 40],
]

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
