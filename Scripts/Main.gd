
"""

TURNOVER NOTES:
    2019-12-29
    - Working on modularizing arena...  Need to make all arenas based on 'Gameplay.gd' script.  Then
    from 'Gameplay.gd' instance child scene nodes of 'Vehicle' and 'Pause'.

"""

extends Node

onready var globals = get_node('/root/Globals')

func _ready():

    get_tree().change_scene('res://Scenes/Arenas/' + globals.main['arena'] + '.tscn')
