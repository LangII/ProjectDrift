
extends Control

# onready var controls = get_node('/root/Controls')

func _ready():

    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ButtonReplay_pressed():

    get_tree().change_scene('res://Scenes/Functional/Gameplay.tscn')
