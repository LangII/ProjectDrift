
extends Control

# onready var controls = get_node('/root/Controls')
onready var main = get_node('/root/Main')

func _ready():

    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ButtonReplay_pressed():

    main.changeScene('res://Scenes/Menus/PartSelection.tscn')
