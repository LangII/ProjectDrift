
extends Control

onready var controls = get_node('/root/Controls')

onready var number_of_targets = controls.gameplay['number_of_targets']

onready var blaster_tag = controls.gameplay['vehicle']['blaster']
onready var blaster_battery_capacity = controls.blasters[blaster_tag]['battery_capacity']

"""
*** NEED TO FIX ***
'get_node' shouldn't use absolute path.
"""

onready var h_str = '/root/Gameplay/Vehicle/Hud/Stats/Health/Divider/HealthValue'
onready var health_value = get_node(h_str)
onready var health_input = 0.0

onready var sb_str = '/root/Gameplay/Vehicle/Hud/Stats/ShieldsBattery/Divider/ShieldsBatteryValue'
onready var shields_battery_value = get_node(sb_str)
onready var shields_battery_input = 0.0

onready var s_str = '/root/Gameplay/Vehicle/Hud/Stats/Speed/Divider/SpeedValue'
onready var speed_value = get_node(s_str)
onready var speed_input = 0.0

onready var bb_str = '/root/Gameplay/Vehicle/Hud/Stats/BlasterBattery/Divider/BlasterBatteryValue'
onready var blaster_battery_value = get_node(bb_str)
onready var blaster_battery_input = 0.0

onready var re_str = '/root/Gameplay/Vehicle/Hud/Stats/ReplenishEngines/Divider/ReplenishEnginesValue'
onready var replenish_engines_value = get_node(re_str)
onready var replenish_engines_input = 0.0

onready var rs_str = '/root/Gameplay/Vehicle/Hud/Stats/ReplenishShields/Divider/ReplenishShieldsValue'
onready var replenish_shields_value = get_node(rs_str)
onready var replenish_shields_input = 0.0

onready var rb_str = '/root/Gameplay/Vehicle/Hud/Stats/ReplenishBlasters/Divider/ReplenishBlastersValue'
onready var replenish_blasters_value = get_node(rb_str)
onready var replenish_blasters_input = 0.0

onready var fn_str = '/root/Gameplay/Vehicle/Hud/Stats/FocusName/Divider/FocusNameValue'
onready var focus_name_value = get_node(fn_str)
onready var focus_name_input = ''

onready var fh_str = '/root/Gameplay/Vehicle/Hud/Stats/FocusHealth/Divider/FocusHealthValue'
onready var focus_health_value = get_node(fh_str)
onready var focus_health_input = 0.0

onready var o_str = '/root/Gameplay/Vehicle/Hud/Stats/Objective/Divider/ObjectiveValue'
onready var objective_value = get_node(o_str)
onready var objective_input = 0.0

####################################################################################################

func _ready():

    objective_value.text = str(number_of_targets)
    blaster_battery_value.text = str(blaster_battery_capacity)

####################################################################################################

func updateReplenishingValues(_engines, _shields, _blasters):

    replenish_engines_input = _engines
    replenish_shields_input = _shields
    replenish_blasters_input = _blasters
    replenish_engines_value.text = str(replenish_engines_input)
    replenish_shields_value.text = str(replenish_shields_input)
    replenish_blasters_value.text = str(replenish_blasters_input)

func updateHealthValue(_value):

    health_input = _value
    health_value.text = str(stepify(health_input, 0.01))

func updateShieldsBatteryValue(_value):

    shields_battery_input = _value
    shields_battery_value.text = str(stepify(shields_battery_input, 0.01))

func updateSpeedValue(_value):

    speed_input = _value
    speed_value.text = str(stepify(speed_input, 0.01))

func updateBlasterBatteryValue(_value):

    blaster_battery_input = _value
    blaster_battery_value.text = str(stepify(blaster_battery_input, 0.01))

func updateFocusNameValue(_value):

    focus_name_input = _value
    focus_name_value.text = focus_name_input

func updateFocusHealthValue(_value):

    focus_health_input = _value
    focus_health_value.text = str(focus_health_input)

func updateObjectiveValue(_value):

    objective_input = _value
    objective_value.text = str(objective_input)
