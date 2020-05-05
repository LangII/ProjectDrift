
"""

Gameplay.gd

'Master' controller of functionality of gameplay.  Individual components hold their own private
individual functions.  But any functionality that expands outside of an individual object, must be
routed through here.

"""

extends Node



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

onready var controls = get_node('/root/Controls')
onready var main = get_node('/root/Main')

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

onready var shields_tag = controls.gameplay['vehicle']['shields']
onready var Shields = load('res://Scenes/Models/VehicleParts/Shields/%s.tscn' % shields_tag)

onready var target_tag = controls.gameplay['targets']
onready var Target = load('res://Scenes/Functional/Entities/%s.tscn' % target_tag)

""" Optional vehicle part scene tags. (not mandatory scenes) """

onready var blaster1_tag = controls.gameplay['vehicle']['blaster1']



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

    # BLOCK...  Build vehicle, start with body.
    var body = Body.instance()
    # Get vehicle_spawners and randomly select spawner for vehicle spawn point.
    var vehicle_spawners = get_node('/root/Gameplay/%s/VehicleSpawners' % arena_tag).get_children()
    body.global_transform = vehicle_spawners[randi() % len(vehicle_spawners)].global_transform
    # Orient vehicle according to spawner, orientation also resets gravity direction.
    if body.transform.basis.y.z == 1:  body.gravity_dir = Vector3.FORWARD
    # Child body to Gameplay/Vehicles container.
    $Vehicles.add_child(body)
    # Get true vehicle variable for referencing.
    vehicle = get_node('/root/Gameplay/Vehicles/%s' % body_tag)
    # Child parts.
    instanceVehicleParts()
    # (see function's comments)
    vehicle.assignPartValues()
    # Assign hud after vehicle build is complete.
    hud = vehicle.get_node('NonSpatial/Hud')

    generateTargets()



func instanceVehicleParts():
    """
    For each designated vehicle body slot assign child of associated vehicle part from Controls.gd. 
    """
    
    var generator_slot = vehicle.find_node('GeneratorPos')
    generator_slot.add_child(Generator.instance())

    var shields_slot = vehicle.find_node('ShieldsPos')
    shields_slot.add_child(Shields.instance())

    var engines_suffixes = ['Fr', 'Br', 'Bl', 'Fl']
    for suffix in engines_suffixes:
        var engine_slot = vehicle.find_node('Engine%sPos' % suffix)
        engine_slot.add_child(Engines.instance())

    # Blaster1 is wrapped in an if conditional because it's the only current part that is optional.
    if blaster1_tag:
        var Blaster1 = load('res://Scenes/Models/VehicleParts/Blasters/%s.tscn' % blaster1_tag)
        var blaster1_slot = vehicle.find_node('Blaster1Pos')
        blaster1_slot.add_child(Blaster1.instance())



func generateTargets():
    """ Randomly generate targets. """
    
    # Handle random target generation.
    targets = get_node(arena_tag + '/Targets')
    if NUMBER_OF_TARGETS:
        # This process potentially could be improved upon...  Which targets to delete are randomly
        # generated, then targets are transfered from arena's 'Targets' node to gameplay's
        # 'Targets' node.
        targets_array = targets.get_children()

        # BLOCK...  Random target instancing.
        # To ensure that target positions are not repeated, a 'randoms' array has to be appended to.
        # This way there is a collection of previous 'random' numbers to compare the most recent
        # 'random' generation to.
        # Modification... 'randoms' is now generated to set which targets will be deleted, not
        # which will be generated.
        var randoms = []
        for __ in range(len(targets_array) - NUMBER_OF_TARGETS):
            # While-loop is used to continue to generate a 'random' number until a new 'random'
            # number is generated.
            while true:
                var random = randi() % len(targets_array)
                if not randoms.has(random):
                    randoms.append(random)
                    break
        # Once all 'random' numbers have been generated use 'randoms' to delete generated ints.
        for r in randoms:  targets_array[r].queue_free()

        for target in targets.get_children():
            target.get_parent().remove_child(target)
            get_node('/root/Gameplay/Targets').add_child(target)

    # Delete no longer needed container.
    targets.queue_free()



####################################################################################################
                                                                              ###   PROCESSING   ###
                                                                              ######################


func vehicleBoltHitsTargetBody(_bolt, _target):
    # Anonymously handle vehicle bolt to target body collisions.

    _target.HEALTH -= _bolt.ENERGY

    # Handle '_target' with 0 HEALTH.
    if _target.HEALTH <= 0:
        hud.focus_obj = null
        hud.updateObjectiveValue(int(hud.objective_value.text) - 1)
        hud.updateFocusNameValue('', 0)
        hud.updateFocusHealthValue('')
        _target.queue_free()

    # Hud update for '_target' that is in "focus".
    elif hud.focus_name_input == _target.name:
        hud.updateFocusHealthValue(_target.HEALTH)



func targetBoltHitsVehicleBody(_bolt, _vehicle):
    # Anonymously handle target bolt to vehicle body collisions.

    # For testing, override vehicle take damage.
    if controls.TESTING_take_no_damage:  return

    # Handle vehicle's 'shields_battery' first.
    if _vehicle.shields_battery > 0:

        # Apply bolt's ENERGY to vehicle's 'shields_battery'
        _vehicle.shields_battery -= _bolt.ENERGY * (1 - _vehicle.SHIELDS_DENSITY)

        if _vehicle.shields_battery >= 0:
            hud.updateShieldsBatteryValue(_vehicle.shields_battery)

        # Handle spill over of bolt's ENERGY if vehicle's 'shields_battery' over depletes by
        # applying over depletion to vehicle's HEALTH.
        else:

#            ###   NEED TO FIX   ###
#            # Currently, if damage is done to shield, and carried over to health, the carry over
#            # value will have density applied to it, not armor.  If damage is done to health, armor
#            # should be applied, not density.  Right now, this is not the case.
#            _vehicle.HEALTH -= abs(_vehicle.shields_battery)

            # Updated line as temp fix.  Still needs improvement but atleast ARMOR is actually
            # used now.
            _vehicle.HEALTH -= abs(_vehicle.shields_battery) * (1 - _vehicle.ARMOR)

            _vehicle.shields_battery = 0
            hud.updateShieldsBatteryValue(_vehicle.shields_battery)
            hud.updateHealthValue(_vehicle.HEALTH)

    # If vehicle's 'shields_battery' is empty, then apply bolt's ENERGY to vehicle's HEALTH.
    else:
        _vehicle.HEALTH -= _bolt.ENERGY * (1 - _vehicle.ARMOR)
        hud.updateHealthValue(_vehicle.HEALTH)



func winConditionMet():

    main.changeScene('res://Scenes/Menus/WinConditionMet.tscn')



func loseConditionMet():

    main.changeScene('res://Scenes/Menus/LoseConditionMet.tscn')



####################################
"""   UNDER CONSTRUCTION   >>>   """
####################################



func toggleObjectVisualLayer(_obj, _layer):
    # For all children/grandchildren of _obj, if MeshInstance, toggle VisualInstance _layer.

    # Get list of child/grandchild nodes with MeshInstance children.
    var sub_mesh_groups = []
    if _obj.get_parent().name == 'Targets':  sub_mesh_groups = ['Turret']

    # Build list of all nodes with MeshInstance children.
    var mesh_groups = [_obj.get_children()]
    for group in sub_mesh_groups:  mesh_groups += [_obj.get_node(group).get_children()]

    # Loop through all nodes with MeshInstance children.
    for group in mesh_groups:
        for child in group:
            if child is MeshInstance:
                if child.get_layer_mask_bit(_layer):  child.set_layer_mask_bit(_layer, false)
                else:  child.set_layer_mask_bit(_layer, true)



####################################
"""   <<<   UNDER CONSTRUCTION   """
####################################



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_HalfSecond_timeout():

    hud.updateSpeedValue(vehicle.linear_velocity.length())

#    print(vehicle.MAX_SPEED)

#    vehicle.printTransformBasis()
