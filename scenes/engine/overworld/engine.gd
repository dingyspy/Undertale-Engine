extends Node

# blurs the background when menu is opened
var background_blur_on_menuopen = false
var can_open_menu = true

@onready var overworld = $'../'
@onready var player = $'../player'

# dialog function and dialog finished signal is in this
@onready var menu = $'menu'
@onready var events = $'events'

func _ready() -> void:
	pass
