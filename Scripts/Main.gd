
"""

Main.gd

Curently not much to see.  This is because the current primary development focus is on gameplay
vehicle controls (not to be confused with Controls.gd) and functionality.  As menu systems are
developed, so will Main.gd.

"""

extends Node

onready var controls = get_node('/root/Controls')



func _ready():

    if controls.TESTING_no_menu:  changeScene('res://Scenes/Functional/Gameplay.tscn')
    else:  changeScene('res://Scenes/Menus/PartSelection.tscn')



func changeScene(_scene):
    if get_tree().change_scene(_scene) != OK:
        print("error changing scene to %s" % _scene)
        get_tree().quit()
