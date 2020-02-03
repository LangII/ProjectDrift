
"""

Gameplay.gd

"""

extends Node



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

onready var controls = get_node('/root/Controls')

onready var NUMBER_OF_TARGETS = controls.gameplay['number_of_targets']



####################################################################################################
                                                                             ###   SCENE LOADS   ###
                                                                             #######################

onready var arena_tag = controls.gameplay['arena']
onready var Arena = load('res://Scenes/Arenas/%s.tscn' % arena_tag)

onready var body_tag = controls.gameplay['vehicle']['body']
onready var Body = load('res://Scenes/Functional/VehicleBodies/%s.tscn' % body_tag)

onready var generator_tag = controls.gameplay['vehicle']['generator']
onready var Generator = load('res://Scenes/Models/VehicleParts/Generators/%s.tscn' % generator_tag)

onready var engines_tag = controls.gameplay['vehicle']['engines']
onready var Engines = load('res://Scenes/Models/VehicleParts/Engines/%s.tscn' % engines_tag)

onready var blaster_tag = controls.gameplay['vehicle']['blaster']
onready var Blaster = load('res://Scenes/Models/VehicleParts/Blasters/%s.tscn' % blaster_tag)

onready var shields_tag = controls.gameplay['vehicle']['shields']
onready var Shields = load('res://Scenes/Models/VehicleParts/Shields/%s.tscn' % shields_tag)

onready var target_tag = controls.gameplay['targets']
onready var Target = load('res://Scenes/Functional/Entities/%s.tscn' % target_tag)



####################################################################################################
                                                                               ###   FUNC VARS   ###
                                                                               #####################

var vehicle
var hud
var targets
var targets_array



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():

    randomize()

    # Instance 'arena' as child of 'Gameplay'.
    add_child(Arena.instance())
    targets = get_node(arena_tag + '/Targets')
    targets_array = targets.get_children()

    # Instance 'vehicle' as child of 'Gameplay' at pos of 'SpawnVehicle'.
    var spawn_vehicle = get_node('/root/Gameplay/' + arena_tag + '/SpawnVehicle')
    var b = Body.instance()
    b.translate(spawn_vehicle.translation)
    $Vehicles.add_child(b)

    # Instance parts as children of 'vehicle'.
    vehicle = get_node('/root/Gameplay/Vehicles/%s' % body_tag)
    vehicle.add_child(Generator.instance())
    vehicle.add_child(Engines.instance())
    vehicle.add_child(Blaster.instance())

    vehicle.add_child(Shields.instance())

    """ NEED TO FIX ... SHOULDN'T USE DIRECT PATH """
    hud = vehicle.get_node('Hud')

    setTargets()



func setTargets():

    # BLOCK ...  Random target instancing.
    # To ensure that target positions are not repeated, a 'randoms' array has to be appended to.
    # This way there is a collection of previous 'random' numbers to compare the most recent
    # 'random' generation to.
    var randoms = []
    for i in range(NUMBER_OF_TARGETS):
        # While-loop is used to continue to generate a 'random' number until a new 'random' number
        # is generated.
        while true:
            var random = randi() % len(targets_array)
            if not randoms.has(random):
                randoms.append(random)
                break
    # Once all 'random' numbers have been generated use 'randoms' to instance 'Targets' from
    # 'targets_array'.
    for r in randoms:
        var t = Target.instance()
        get_node('/root/Gameplay/Targets').add_child(t)
        t.global_transform.origin = targets_array[r].global_transform.origin

    targets.queue_free()



####################################################################################################
                                                                              ###   PROCESSING   ###
                                                                              ######################


func vehicleBoltHitsTargetBody(_bolt, _target):
    # Anonymously handle vehicle bolt to target body collisions.

    _target.HEALTH -= _bolt.ENERGY

    # Handle '_target' with 0 HEALTH.
    if _target.HEALTH <= 0:
        hud.updateObjectiveValue(int(hud.objective_value.text) - 1)
        _target.queue_free()
        hud.updateFocusNameValue('')
        hud.updateFocusHealthValue('')

    # Hud update for '_target' that is in "focus".
    elif hud.focus_name_value.text == _target.name:
        hud.updateFocusHealthValue(_target.HEALTH)



func targetBoltHitsVehicleBody(_bolt, _vehicle):
    # Anonymously handle target bolt to vehicle body collisions.

    # Handle vehicle's 'shields_battery' first.
    if _vehicle.shields_battery > 0:

        # Apply bolt's ENERGY to vehicle's 'shields_battery'
        _vehicle.shields_battery -= _bolt.ENERGY * (1 - _vehicle.SHIELDS_DENSITY)

        if _vehicle.shields_battery >= 0:
            hud.updateShieldsBatteryValue(_vehicle.shields_battery)

        # Handle spill over of bolt's ENERGY if vehicle's 'shields_battery' over depletes by
        # applying over depletion to vehicle's HEALTH.
        else:
            # NEED TO FIX ... Currently, if damage is done to shield, and carried over to
            # health, the carry over value will have density applied to it, not armor.  If
            # damage is done to health, armor should be applied, not density.  Right now, this
            # is not the case.
            _vehicle.HEALTH -= abs(_vehicle.shields_battery)
            _vehicle.shields_battery = 0
            hud.updateShieldsBatteryValue(_vehicle.shields_battery)
            hud.updateHealthValue(_vehicle.HEALTH)

    # If vehicle's 'shields_battery' is empty, then apply bolt's ENERGY to vehicle's HEALTH.
    else:
        _vehicle.HEALTH -= _bolt.ENERGY * (1 - _vehicle.ARMOR)
        hud.updateHealthValue(_vehicle.HEALTH)



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_HalfSecond_timeout():

    hud.updateSpeedValue(vehicle.linear_velocity.length())

    # vehicle.printTransformBasis()
