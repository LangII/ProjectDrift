
extends Node

onready var globals = get_node('/root/Globals')

func _ready():

    get_tree().change_scene('res://Scenes/Arenas/' + globals.test_arena + '.tscn')
