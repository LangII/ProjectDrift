


extends VehicleBody

# singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

### Get tags.
onready var body_tag =      controls.gameplay['vehicle']['body']
onready var generator_tag = controls.gameplay['vehicle']['generator']
onready var engines_tag =   controls.gameplay['vehicle']['engines']
onready var shields_tag =   controls.gameplay['vehicle']['shields']
### (expandables)
onready var blaster_tags = []

### Get global control variables.
onready var GRAVITY_FORCE =         controls.global['vehicle']['gravity_force']
onready var FRICTION =              controls.global['vehicle']['friction']
onready var SPIN =                  controls.global['vehicle']['spin']
onready var LINEAR_DAMP =           controls.global['vehicle']['linear_damp']
onready var SPIN_DAMP =             controls.global['vehicle']['spin_damp']
onready var MOUSE_SENSITIVITY =     controls.global['vehicle']['mouse_sensitivity']
onready var MOUSE_VERT_DAMP =       controls.global['vehicle']['mouse_vert_damp']
# onready var REST_LINEAR_DAMP =      controls.global['vehicle']['rest_linear_damp']

### Get parts' control variables.
onready var HEALTH =                    controls.body[body_tag]['health']
onready var ARMOR =                     controls.body[body_tag]['armor']
onready var SHIELDS_BATTERY_CAPACITY =  controls.shields[shields_tag]['battery_capacity']
onready var SHIELDS_DENSITY =           controls.shields[shields_tag]['density']
onready var SHIELDS_CONCENTRATION =     controls.shields[shields_tag]['concentration']
onready var THRUST =                    controls.engines[engines_tag]['thrust']
onready var MAX_SPEED =                 controls.engines[engines_tag]['max_speed']
onready var GENERATOR_RATE =            controls.generators[generator_tag]['rate']
onready var REPLENISH =                 controls.generators[generator_tag]['replenish']
### (expandables)
onready var BLASTER_BATTERY_CAPACITIES = []
onready var BLASTER_COOL_DOWNS = []
onready var BOLT_ENERGIES = []



####################################################################################################
                                                                               ###   NODE REFS   ###
                                                                               #####################

onready var _non_spatial_ = find_node('NonSpatial')
onready var hud = _non_spatial_.find_node('Hud')
onready var generator_rate = _non_spatial_.find_node('GeneratorRate')
onready var camera_pivot = find_node('CameraPivot')
onready var scope = camera_pivot.find_node('Scope')
onready var look_default = camera_pivot.find_node('LookDefault')

### (expandables)
onready var blaster_cool_downs = []



####################################################################################################
                                                                                    ###   VARS   ###
                                                                                    ################

### Generator replenishment sets.
onready var replenish_sets = [
    {'engines': 0.34, 'shields': 0.33, 'blasters': 0.33},
    {'engines': 0.80, 'shields': 0.10, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.80, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.10, 'blasters': 0.80},
]
onready var no_shields_replenish_sets = [
    {'engines': 0.50, 'shields': 0.00, 'blasters': 0.50},
    {'engines': 0.90, 'shields': 0.00, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.00, 'blasters': 0.90},
]
onready var no_blasters_replenish_sets = [
    {'engines': 0.50, 'shields': 0.50, 'blasters': 0.00},
    {'engines': 0.90, 'shields': 0.10, 'blasters': 0.00},
    {'engines': 0.10, 'shields': 0.90, 'blasters': 0.00},
]
onready var only_engines_replenish_sets = [
    {'engines': 1.00, 'shields': 0.00, 'blasters': 0.00},
]

"""
TO-DOS:  Maybe set replenishment values in a ready func.  Initiating them now, then resetting later
based on no-shields or no-blasters is a waste.
"""

### Working vars.
onready var repl_set_pointer = 0
onready var pointing_at = Vector3()
onready var rot_force = 0.0
onready var gravity_force = 2.00
onready var gravity_dir = Vector3.DOWN

### (expandables)
onready var barrel_pivots = []
onready var bolt_spawns = []
onready var blaster_cooled_downs = []
onready var blaster_batteries = []
onready var Bolts = []

### Initialize replenishment values as first set from 'replenish_sets'.
onready var replenish_engines = replenish_sets[repl_set_pointer]['engines']
onready var replenish_shields = replenish_sets[repl_set_pointer]['shields']
onready var replenish_blasters = replenish_sets[repl_set_pointer]['blasters']
### Initialize shields var.
onready var shields_battery = SHIELDS_BATTERY_CAPACITY



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
    print("\n>>> [%s] (scripted) scene entering tree" % name)
    
    """
    TO-DOS:  Mouse capture should be handled in Gameplay.gd.
    """
    # Capture mouse.
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    generateExpandableVars()
    
    # Update physics settings.
    physics_material_override.set_friction(FRICTION)
    set_linear_damp(LINEAR_DAMP)
    set_angular_damp(SPIN_DAMP)
    
#    # Set vehicle parts' timers wait times.
#    generator_rate.wait_time = GENERATOR_RATE
#    blaster1_cool_down.wait_time = BLASTER1_COOL_DOWN
#    blaster2_cool_down.wait_time = BLASTER2_COOL_DOWN



func generateExpandableVars():
    
    # blaster_tags
    for blaster in controls.body[body_tag]['blaster_slots']:
        blaster_tags += [ controls.gameplay['vehicle'][blaster] ]
    
    
    print(blaster_tags)
    print(blaster_tags[0])
    print(blaster_tags[1])
    get_tree().quit()


""" Need to generate tags first. """
#func instanceVehicleParts():
#    """
#    For each designated vehicle body slot assign child of associated vehicle part from Controls.gd. 
#    """
#
#    var generator_slot = vehicle.find_node('GeneratorPos')
#    generator_slot.add_child(Generator.instance())
#
#    var engines_suffixes = ['Fr', 'Br', 'Bl', 'Fl']
#    for suffix in engines_suffixes:
#        var engine_slot = vehicle.find_node('Engine%sPos' % suffix)
#        engine_slot.add_child(Engines.instance())
#
#    if shields_tag:
#        var Shields = load('res://Scenes/Models/VehicleParts/Shields/%s.tscn' % shields_tag)
#        var shields_slot = vehicle.find_node('ShieldsPos')
#        shields_slot.add_child(Shields.instance())
#
##    # Blaster1 is wrapped in an if conditional because it's the only current part that is optional.
##    if blaster1_tag:
##        var Blaster1 = load('res://Scenes/Models/VehicleParts/Blasters/%s.tscn' % blaster1_tag)
##        var blaster1_slot = vehicle.find_node('Blaster1Pos')
##        blaster1_slot.add_child(Blaster1.instance())
#
#    if blaster_tags:
#        for i in range(blaster_tags.size()):
#            var blaster_tag = blaster_tags[i]
#            if not blaster_tag:  continue
#            var Blaster = load('res://Scenes/Models/VehicleParts/Blasters/%s.tscn' % blaster_tag)
#            var blaster_slot = vehicle.find_node('Blaster%sPos' % str(i + 1))
#            blaster_slot.add_child(Blaster.instance())



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_GeneratorRate_timeout():
    # Regulate blaster battery and shields battery replenishment.  Only replenish if battery is not
    # full.  If replenishment overfills battery, clamp it.  Then update Hud.

    """
    TO-DOS:  Need to update for multiple blasters.
    """
    pass
#    if blaster1_battery < BLASTER1_BATTERY_CAPACITY:
#        blaster1_battery += REPLENISH * replenish_blasters
#        blaster1_battery = clamp(blaster1_battery, 0, BLASTER1_BATTERY_CAPACITY)
#        hud.updateBlasterBatteryValue(blaster1_battery)
#    if shields_battery < SHIELDS_BATTERY_CAPACITY:
#        shields_battery += REPLENISH * replenish_shields * SHIELDS_CONCENTRATION
#        shields_battery = clamp(shields_battery, 0, SHIELDS_BATTERY_CAPACITY)
#        hud.updateShieldsBatteryValue(shields_battery)



func _on_Blaster1CoolDown_timeout():
    
    blaster_cooled_downs[0] = true



func _on_Blaster2CoolDown_timeout():
    
    blaster_cooled_downs[1] = true

