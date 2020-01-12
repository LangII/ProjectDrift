
extends Control

onready var controls = get_node('/root/Controls')

""" NEED TO FIX ... SHOULDN'T USE ABSOLUTE PATH """
onready var speed_value = get_node('/root/Gameplay/Vehicle/Hud/Stats/Speed/Divider/SpeedValue')

onready var speed_value_text = '00.00'

func _ready():

    pass

func _process(delta):

    speed_value.text = speed_value_text
