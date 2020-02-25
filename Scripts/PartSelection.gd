
extends Control

onready var controls = get_node('/root/Controls')
onready var gameplay = get_node('/root/Gameplay')

onready var mouse_sensitivity = $CenterContainer/VBoxContainer/MouseSensitivity/Sensitivity
var MOUSE_TRANSLATOR = 0.00002

func _ready():

    mouse_sensitivity.text = str(controls.global['vehicle']['mouse_sensitivity'])

func _on_Slider_value_changed(value):

    mouse_sensitivity.text = str(value * MOUSE_TRANSLATOR)
