
"""

Gameplay.gd

'Master' controller of functionality of gameplay.  Individual components hold their own private
individual functions.  But any functionality that expands outside of an individual object, must be
routed through here.



TURNOVER NOTES:

    - Need to move control/location of objective and objective count from Hud to Gameplay.
    - As well as winConditionMet() and loseConditionMet()...  To be moved to Gameplay.

"""

extends Node

onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

### Constants.
onready var NUMBER_OF_TARGETS = controls.gameplay['number_of_targets']

### Arena and entity tags.
onready var arena_tag =     controls.gameplay['arena']
#onready var target_tag =    controls.gameplay['targets']

### Vehicle body and parts tags.
onready var body_tag =      controls.gameplay['vehicle']['body']['part_tag']



####################################################################################################
                                                                             ###   SCENE LOADS   ###
                                                                             #######################

#onready var Arena =     load('res://Scenes/Arenas/%s.tscn' % arena_tag)
#onready var Target =    load('res://Scenes/Functional/Entities/%s.tscn' % target_tag)
#onready var Body =      load('res://Scenes/Functional/VehicleBodies/%s.tscn' % body_tag)
#onready var Generator = load('res://Scenes/Models/VehicleParts/Generators/%s.tscn' % generator_tag)
#onready var Engines =   load('res://Scenes/Models/VehicleParts/Engines/%s.tscn' % engines_tag)



####################################################################################################
                                                                                    ###   VARS   ###
                                                                                    ################

onready var _vehicles_ = get_node('Vehicles')
onready var _targets_ = get_node('Targets')
onready var _vehicle_bolts_ = get_node('VehicleBolts')
onready var _target_bolts_ = get_node('TargetBolts')

var arena
var vehicle
var hud
var targets
var targets_array



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
    print("\n>>> [%s] scripted scene entering tree" % name)
    
    # Open temp mods.
    var boost_mod = main.loadModule(main, 'res://Scenes/Functional/BoostMod.tscn')
    
    randomize()
    
    boost_mod.updateControlsPartsStats()

    arena = generateArena()
    
    vehicle = generateVehicle()
    
    # Reference hud after vehicle is generated.
    hud = vehicle.find_node('NonSpatial*').find_node('Hud')
    
    generateTargets()
    
    # Close temp mods.
    boost_mod.queue_free()
    
    print("\n>>> [%s] ready...  [%s] starting..." % [name, name])



####################################################################################################
                                                                             ###   READY FUNCS   ###
                                                                             #######################


func generateArena():
    """
    Load arena scene from arena_tag, instance scene and add to tree as child, then return arena_
    as reference to arena node.
    """

    add_child(load('res://Scenes/Arenas/%s.tscn' % arena_tag).instance())
    var arena_ = get_node(arena_tag)
    
    return arena_



func generateVehicle():
    """
    Generate vehicle from body_tag under vehicles.
    """
    
    var body = load('res://Scenes/Functional/VehicleBodies/%s.tscn' % body_tag).instance()
    
    # Assign vehicle to tree under vehicles.
    _vehicles_.add_child(body)
    
    # If testing, spawn vehicle at random.  Else, spawn at first spawn point.
    var vehicle_spawners = arena.get_node('VehicleSpawners').get_children()
    if not controls.TESTING_no_menu:
        body.global_transform = vehicle_spawners[randi() % len(vehicle_spawners)].global_transform
    else:
        body.global_transform = vehicle_spawners[0].global_transform
    
    # Adjust vehicle's gravity direction if needed.
    if body.transform.basis.y.z == 1:  body.gravity_dir = Vector3.FORWARD
    
    # Return vehicle reference.
    var vehicle_ = _vehicles_.get_node(body_tag)
    return vehicle_



func generateTargets():
    """
    Randomly generate targets.
    """
    
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
            get_node('/root/Main/Gameplay/Targets').add_child(target)

    # Delete no longer needed container.
    targets.queue_free()



####################################################################################################
                                                                           ###   PROCESS FUNCS   ###
                                                                           #########################

func applyDamageToTarget(_damage, _target):
    
    _target.HEALTH -= _damage
    
    # Handle '_target' with 0 HEALTH.
    if _target.HEALTH <= 0:
        hud.updateObjectiveValue(hud.objective_input - 1)
        if _target == hud.focus_obj:  hud.clearFocusObject()
        _target.queue_free()
    
    # Hud update for '_target' that is in "focus".
    elif hud.focus_name_input == _target.name:
        hud.updateFocusHealthValue(_target.HEALTH)



func applyDamageToVehicle(_damage, _vehicle):
    
    # For testing, override vehicle take damage.
    if controls.TESTING_take_no_damage:  return
    # Handle vehicle's 'shields_battery' first.
    if _vehicle.shields_battery > 0:
        # Apply bolt's ENERGY to vehicle's 'shields_battery'
        _vehicle.shields_battery -= _damage * (1 - _vehicle.SHIELDS_DENSITY)
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
        _vehicle.HEALTH -= _damage * (1 - _vehicle.ARMOR)
        hud.updateHealthValue(_vehicle.HEALTH)



func vehicleBoltHitsTargetBody(_bolt, _target):
    
    applyDamageToTarget(_bolt.ENERGY, _target)



func targetBoltHitsVehicleBody(_bolt, _vehicle):
    
    applyDamageToVehicle(_bolt.ENERGY, _vehicle)



func objectInExplosion(_obj, _damage, _obj_group):
    
    match _obj_group:
        'Vehicles':  applyDamageToVehicle(_damage, _obj)
        'Targets':  applyDamageToTarget(_damage, _obj)



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



func winConditionMet():

    main.changeScene('res://Scenes/Menus/WinConditionMet.tscn')



func loseConditionMet():

    main.changeScene('res://Scenes/Menus/LoseConditionMet.tscn')



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_HalfSecond_timeout():

    hud.updateSpeedValue(vehicle.linear_velocity.length())

#    print("\nENGINES = ", vehicle.replenish['engines'])
#    print("SHIELDS = ", vehicle.replenish['shields'])
#    print("BLASTERS = ", vehicle.replenish['blasters'])

#    print(vehicle.MAX_SPEED)

#    vehicle.printTransformBasis()



####################################################################################################
                                                                                ###   OBSOLETE   ###
                                                                                ####################

""" READY FUNC (2020-06-05) """
#func adjustForOptionalVehicleParts():
#    """
#    These adjustment calls need to be made after the scenes are instanced.  That's why these are
#    called in a seperate function that is called at the end of Gameplay's _ready().
#    """
#
#    if not shields_tag:
#        vehicle.adjustForNoShields()
#        hud.adjustForNoShields()
#
#    hud.adjustForBlasters()



""" READY FUNC (2020-06-05) """
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



""" READY FUNC (2020-06-05) """
#func generateBlasterTags():
#
##    for blaster in controls.body[body_tag]['blaster_slots']:
#
#    var blaster_slots = controls.body[body_tag]['blaster_slots']
#
#    for i in range(blaster_slots.size()):
#        blaster_tags += [controls.gameplay['vehicle'][blaster_slots[i]]]



""" _ready() (2020-05-21) """
#    # BLOCK...  Build vehicle, start with body.
#    var body = Body.instance()
#
#    # Get vehicle_spawners, randomly select spawner for vehicle spawn point, and rotate vehicle to
#    # align with spawn point.
#    var vehicle_spawners = arena.get_node('VehicleSpawners').get_children()
#    body.global_transform = vehicle_spawners[randi() % len(vehicle_spawners)].global_transform
#    if body.transform.basis.y.z == 1:  body.gravity_dir = Vector3.FORWARD
#    var vehicles = get_node('Vehicles')
#    vehicles.add_child(body)
#
#    # Get true vehicle variable for referencing.
#    vehicle = get_node('/root/Main/Gameplay/Vehicles/%s' % body_tag)
#
#    get_tree().quit()
#
#    generateBlasterTags()   # <--  Do in Vehicle.gd.
#
#    # Child parts.
#    instanceVehicleParts()   # <--  Do in Vehicle.gd.
#
#    # (see function's comments)
#    vehicle.assignPartValues()   # <--  Do in Vehicle.gd.
#
#    # Assign hud after vehicle build is complete.
##    if body_tag == 'TestBody01':  hud = vehicle.get_node('NonSpatial/Hud01')
##    elif body_tag == 'TestBody02':  hud = vehicle.get_node('NonSpatial/Hud02')
#
#    adjustForOptionalVehicleParts()   # <--  Do in Vehicle.gd.






