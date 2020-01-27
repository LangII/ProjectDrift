
"""

Hud.gd

"""

extends Control



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

onready var controls = get_node('/root/Controls')

onready var body_tag =      controls.gameplay['vehicle']['body']
# onready var generator_tag = controls.gameplay['vehicle']['generator']
# onready var engines_tag =   controls.gameplay['vehicle']['engines']
onready var blaster_tag =   controls.gameplay['vehicle']['blaster']
onready var shields_tag =   controls.gameplay['vehicle']['shields']



####################################################################################################
                                                                                    ###   VARS   ###
                                                                                    ################

onready var values_path = '/root/Gameplay/Vehicle/Hud/Stats/{s}/Divider/{s}Value'

onready var health_value = get_node(values_path.format({'s': 'Health'}))
onready var health_input = controls.body[body_tag]['health']

onready var shields_battery_value = get_node(values_path.format({'s': 'ShieldsBattery'}))
onready var shields_battery_input = controls.shields[shields_tag]['battery_capacity']

onready var speed_value = get_node(values_path.format({'s': 'Speed'}))
onready var speed_input = 0.0

onready var blaster_battery_value = get_node(values_path.format({'s': 'BlasterBattery'}))
onready var blaster_battery_input = controls.blasters[blaster_tag]['battery_capacity']

onready var replenish_engines_value = get_node(values_path.format({'s': 'ReplenishEngines'}))
onready var replenish_engines_input = 0.0

onready var replenish_shields_value = get_node(values_path.format({'s': 'ReplenishShields'}))
onready var replenish_shields_input = 0.0

onready var replenish_blasters_value = get_node(values_path.format({'s': 'ReplenishBlasters'}))
onready var replenish_blasters_input = 0.0

onready var focus_name_value = get_node(values_path.format({'s': 'FocusName'}))
onready var focus_name_input = ''

onready var focus_health_value = get_node(values_path.format({'s': 'FocusHealth'}))
onready var focus_health_input = 0.0

onready var objective_value = get_node(values_path.format({'s': 'Objective'}))
onready var objective_input = controls.gameplay['number_of_targets']



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():

    health_value.text =             str(health_input)
    shields_battery_value.text =    str(shields_battery_input)
    speed_value.text =              str(speed_input)
    blaster_battery_value.text =    str(blaster_battery_input)
    objective_value.text =          str(objective_input)



####################################################################################################
                                                                                 ###   UPDATES   ###
                                                                                 ###################

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

func updateReplenishValues(_engines, _shields, _blasters):

    replenish_engines_input = _engines
    replenish_shields_input = _shields
    replenish_blasters_input = _blasters
    replenish_engines_value.text = str(replenish_engines_input)
    replenish_shields_value.text = str(replenish_shields_input)
    replenish_blasters_value.text = str(replenish_blasters_input)

func updateFocusNameValue(_value):

    focus_name_input = _value
    focus_name_value.text = focus_name_input

func updateFocusHealthValue(_value):

    focus_health_input = _value
    focus_health_value.text = str(focus_health_input)

func updateObjectiveValue(_value):

    objective_input = _value
    objective_value.text = str(objective_input)
