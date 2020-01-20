
extends Node

onready var controls = get_node('/root/Controls')

# Get tags and scenes variables from 'controls'.
onready var arena_tag = controls.gameplay['arena']
onready var arena = load('res://Scenes/Arenas/' + arena_tag + '.tscn')
onready var body_tag = controls.gameplay['vehicle']['body']
onready var body = load('res://Scenes/Functional/VehicleBodies/' + body_tag + '.tscn')

onready var generator_tag = controls.gameplay['vehicle']['generator']
onready var gt_str = 'res://Scenes/Models/VehicleParts/Generators/' + generator_tag + '.tscn'
onready var generator = load(gt_str)

onready var engines_tag = controls.gameplay['vehicle']['engines']
onready var engines = load('res://Scenes/Models/VehicleParts/Engines/' + engines_tag + '.tscn')
onready var blaster_tag = controls.gameplay['vehicle']['blaster']
onready var blaster = load('res://Scenes/Models/VehicleParts/Blasters/' + blaster_tag + '.tscn')

onready var target_tag = controls.gameplay['targets']
onready var t_str = 'res://Scenes/Functional/Entities/' + target_tag + '.tscn'
onready var Target = load(t_str)

onready var NUMBER_OF_TARGETS = controls.gameplay['number_of_targets']

var vehicle
var hud

var targets
var targets_array



func _ready():

    randomize()

    # Instance 'arena' as child of 'Gameplay'.
    add_child(arena.instance())
    targets = get_node(arena_tag + '/Targets')
    targets_array = targets.get_children()

    # Instance 'vehicle' as child of 'Gameplay' at pos of 'SpawnVehicle'.
    var spawn_vehicle = get_node('/root/Gameplay/' + arena_tag + '/SpawnVehicle')
    var b = body.instance()
    b.translate(spawn_vehicle.translation)
    add_child(b)

    # Instance parts as children of 'vehicle'.
    vehicle = get_node('/root/Gameplay/Vehicle')
    vehicle.add_child(generator.instance())
    vehicle.add_child(engines.instance())
    vehicle.add_child(blaster.instance())

    """ NEED TO FIX ... SHOULDN'T USE DIRECT PATH """
    hud = $Vehicle/Hud

    setTargets()



func _on_HalfSecond_timeout():

    hud.updateSpeedValue(vehicle.linear_velocity.length())



func setTargets():

    """ Random target instancing. """
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
        targets_array[r].add_child(t)
