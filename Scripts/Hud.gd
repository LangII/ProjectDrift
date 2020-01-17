
extends Control

onready var controls = get_node('/root/Controls')

onready var blaster_tag = controls.gameplay['vehicle']['blaster']
onready var blaster_battery_capacity = controls.blasters[blaster_tag]['battery_capacity']


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

onready var fn_str = '/root/Gameplay/Vehicle/Hud/Stats/FocusName/Divider/FocusNameValue'
onready var focus_name_value = get_node(fn_str)
onready var focus_name_value_input = ''

onready var fh_str = '/root/Gameplay/Vehicle/Hud/Stats/FocusHealth/Divider/FocusHealthValue'
onready var focus_health_value = get_node(fh_str)
onready var focus_health_value_input = 0.0

####################################################################################################

func _ready():

    blaster_battery_value.text = String(blaster_battery_capacity)

####################################################################################################

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

func updateFocusNameValue(_value):

    focus_name_value_input = _value
    focus_name_value.text = focus_name_value_input

func updateFocusHealthValue(_value):

    focus_health_value_input = _value
    focus_health_value.text = String(focus_health_value_input)
