
"""

TURNOVER NOTES:

"""

extends Node

onready var controls = get_node('/root/Controls')

func _ready():

	if controls.testing:    get_tree().change_scene('res://Scenes/Functional/Gameplay.tscn')
	else:                   get_tree().change_scene('res://Scenes/Menus/PartSelection.tscn')
