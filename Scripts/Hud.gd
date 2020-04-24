
"""

Hud.gd

"""

extends Control



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

onready var controls = get_node('/root/Controls')
onready var gameplay = get_node('/root/Gameplay')

onready var body_tag =      controls.gameplay['vehicle']['body']
# onready var generator_tag = controls.gameplay['vehicle']['generator']
# onready var engines_tag =   controls.gameplay['vehicle']['engines']
onready var blaster1_tag =   controls.gameplay['vehicle']['blaster1']
onready var shields_tag =   controls.gameplay['vehicle']['shields']



####################################################################################################
                                                                                    ###   VARS   ###
                                                                                    ################

onready var values_path = '/root/Gameplay/Vehicles/%s/NonSpatial/Hud/Stats/%s/Divider/%sValue'

# Each block is a different Hud variable.

onready var h_insert = [body_tag, 'Health', 'Health']
onready var health_value = get_node(values_path % h_insert)
onready var health_input = controls.body[body_tag]['health']

onready var sb_insert = [body_tag, 'ShieldsBattery', 'ShieldsBattery']
onready var shields_battery_value = get_node(values_path % sb_insert)
onready var shields_battery_input = controls.shields[shields_tag]['battery_capacity']

onready var s_insert = [body_tag, 'Speed', 'Speed']
onready var speed_value = get_node(values_path % s_insert)
onready var speed_input = 0.0

onready var bb_insert = [body_tag, 'BlasterBattery', 'BlasterBattery']
onready var blaster1_battery_value = get_node(values_path % bb_insert)
onready var blaster1_battery_input = controls.blasters[blaster1_tag]['battery_capacity']

onready var re_insert = [body_tag, 'ReplenishEngines', 'ReplenishEngines']
onready var replenish_engines_value = get_node(values_path % re_insert)
onready var replenish_engines_input = 0.0

onready var rs_insert = [body_tag, 'ReplenishShields', 'ReplenishShields']
onready var replenish_shields_value = get_node(values_path % rs_insert)
onready var replenish_shields_input = 0.0

onready var rb_insert = [body_tag, 'ReplenishBlasters', 'ReplenishBlasters']
onready var replenish_blasters_value = get_node(values_path % rb_insert)
onready var replenish_blasters_input = 0.0

onready var fn_insert = [body_tag, 'FocusName', 'FocusName']
onready var focus_name_value = get_node(values_path % fn_insert)
onready var focus_name_input = ''

onready var fh_insert = [body_tag, 'FocusHealth', 'FocusHealth']
onready var focus_health_value = get_node(values_path % fh_insert)
onready var focus_health_input = 0.0

onready var o_insert = [body_tag, 'Objective', 'Objective']
onready var objective_value = get_node(values_path % o_insert)
onready var objective_input = controls.gameplay['number_of_targets']

# Working vars.
onready var focus_cam = find_node('FocusCamera')
onready var vehicle = get_node('/root/Gameplay/Vehicles/%s' % body_tag)
onready var focus_obj = vehicle



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():

    # Set Hud variables that require initiation.

    health_value.text =             "%7.2f" % health_input
    shields_battery_value.text =    "%7.2f" % shields_battery_input
    speed_value.text =              "%7.2f" % speed_input
    blaster1_battery_value.text =    "%7.2f" % blaster1_battery_input
    objective_value.text =          "%6d" % objective_input



####################################################################################################
                                                                                 ###   UPDATES   ###
                                                                                 ###################

# Each function is a Hud variable update.

func updateHealthValue(_value):

    health_input = _value
    health_value.text = "%7.2f" % health_input

    if health_input <= 0:  gameplay.loseConditionMet()

func updateShieldsBatteryValue(_value):

    shields_battery_input = _value
    shields_battery_value.text = "%7.2f" % shields_battery_input

func updateSpeedValue(_value):

    speed_input = _value
    speed_value.text = "%7.2f" % speed_input

func updateBlasterBatteryValue(_value):

    blaster1_battery_input = _value
    blaster1_battery_value.text = "%7.2f" % blaster1_battery_input

func updateReplenishValues(_engines, _shields, _blasters):

    replenish_engines_input =   _engines
    replenish_shields_input =   _shields
    replenish_blasters_input =  _blasters
    replenish_engines_value.text =  "%7.2f" % replenish_engines_input
    replenish_shields_value.text =  "%7.2f" % replenish_shields_input
    replenish_blasters_value.text = "%7.2f" % replenish_blasters_input

func updateFocusNameValue(_value):

    focus_name_input = _value
    focus_name_value.text = "%013s" % str(focus_name_input)

func updateFocusHealthValue(_value):

    focus_health_input = _value
    if focus_health_input:  focus_health_value.text = "%7.2f" % focus_health_input
    else:  focus_health_value.text = focus_health_input



####################################
"""   UNDER CONSTRUCTION   >>>   """
####################################



func updateFocusViewport(_obj):
    
#    print(_obj)    

    focus_obj = _obj
    _obj.find_node('MeshInstance').set_layer_mask_bit(1, true)

#    var testing = focus_cam.find_node('MeshInstance')
#
#    testing.set_layer_mask_bit(1, true)



func _process(delta):

    var cam_pos = (vehicle.global_transform.origin - focus_obj.global_transform.origin).normalized() * 4
    focus_cam.global_transform.origin = focus_obj.global_transform.origin + cam_pos
    focus_cam.look_at(focus_obj.global_transform.origin, vehicle.gravity_dir * -1)
    
    print(cam_pos)



####################################
"""   <<<   UNDER CONSTRUCTION   """
####################################



func updateObjectiveValue(_value):

    objective_input = _value
    objective_value.text = "%6d" % objective_input

    if objective_input <= 0:  gameplay.winConditionMet()
