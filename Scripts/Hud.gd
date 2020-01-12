
extends Control

# onready var controls = get_node('/root/Controls')

""" NEED TO FIX ... SHOULDN'T USE ABSOLUTE PATH """
onready var speed_value = get_node('/root/Gameplay/Vehicle/Hud/Stats/Speed/Divider/SpeedValue')
onready var speed_value_input = 0.0

onready var bb_string = '/root/Gameplay/Vehicle/Hud/Stats/BlasterBattery/Divider/BlasterBatteryValue'
onready var blaster_battery_value = get_node(bb_string)
onready var blaster_battery_value_input = 0.0

func _ready():

    pass

# func _process(delta):

func updateSpeedValue(_value):

    speed_value_input = _value
    speed_value.text = String(stepify(speed_value_input, 0.01))

func updateBlasterBatteryValue(_value):

    # print(blaster_battery_value)

    blaster_battery_value_input = _value
    blaster_battery_value.text = String(blaster_battery_value_input)
