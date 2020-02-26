
extends Control

onready var controls = get_node('/root/Controls')
# onready var gameplay = get_node('/root/Gameplay')

# onready var prefix = '/root/CenterContainer/VBoxContainer/%s'

onready var engines_yellow = find_node('EnginesYellow')
onready var engines_green = find_node('EnginesGreen')
onready var engines_group = ButtonGroup.new()

onready var mouse_sensitivity = find_node('MouseSensitivity')
var MOUSE_TRANSLATOR = 0.00002

func _ready():

    engines_yellow.set_button_group(engines_group)
    engines_green.set_button_group(engines_group)

    engines_yellow.set_pressed(true)

    mouse_sensitivity.text = str(controls.global['vehicle']['mouse_sensitivity'])

func _on_Slider_value_changed(value):

    # mouse_sensitivity.text = str(value * MOUSE_TRANSLATOR)
    mouse_sensitivity.text = str(value)

func _on_Play_pressed():

    print(engines_group.get_pressed_button())
    if engines_group.get_pressed_button() == engines_yellow:  print("yes")

    # controls.global['vehicle']['mouse_sensitivity'] = float(mouse_sensitivity.text)

    # get_tree().change_scene('res://Scenes/Functional/Gameplay.tscn')
