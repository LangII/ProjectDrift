
"""

Main.gd

Curently not much to see.  This is because the current primary development focus is on gameplay
vehicle controls (not to be confused with Controls.gd) and functionality.  As menu systems are
developed, so will Main.gd.

"""

extends Node

onready var controls = get_node('/root/Controls')

func _ready():

    if controls.testing:  get_tree().change_scene('res://Scenes/Functional/Gameplay.tscn')
    else:  get_tree().change_scene('res://Scenes/Menus/PartSelection.tscn')
