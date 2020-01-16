
extends Control

# onready var controls = get_node('/root/Controls')

""" NEED TO FIX ... SHOULDN'T USE ABSOLUTE PATH """
onready var speed_value = get_node('/root/Gameplay/Vehicle/Hud/Stats/Speed/Divider/SpeedValue')
onready var speed_value_input = 0.0

onready var bb_str = '/root/Gameplay/Vehicle/Hud/Stats/BlasterBattery/Divider/BlasterBatteryValue'
onready var blaster_battery_value = get_node(bb_str)
onready var blaster_battery_value_input = 0.0

onready var re_str = '/root/Gameplay/Vehicle/Hud/Stats/ReplenishEngines/Divider/ReplenishEnginesValue'
onready var replenish_engines_value = get_node(re_str)
onready var replenish_engines_value_input = 0.0

onready var rb_str = '/root/Gameplay/Vehicle/Hud/Stats/ReplenishBlasters/Divider/ReplenishBlastersValue'
onready var replenish_blasters_value = get_node(rb_str)
onready var replenish_blasters_value_input = 0.0

func _ready():

    pass

# func _process(delta):

func updateSpeedValue(_value):

    speed_value_input = _value
    speed_value.text = String(stepify(speed_value_input, 0.01))

func updateBlasterBatteryValue(_value):

    blaster_battery_value_input = _value
    blaster_battery_value.text = String(blaster_battery_value_input)

func updateReplenishingValues(_engines, _blasters):

    replenish_engines_value_input = _engines
    replenish_blasters_value_input = _blasters
    replenish_engines_value.text = String(replenish_engines_value_input)
    replenish_blasters_value.text = String(replenish_blasters_value_input)
