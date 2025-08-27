extends Area2D

@export var reference_node : Node
@export var interactable = false
# if you want it to only play once
@export var oneshot = false
# only set if you want the event / interaction to move on to the next area
@export var next_area_path = ''
