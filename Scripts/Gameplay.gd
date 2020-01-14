
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

var spawn_vehicle
var b
var vehicle
var hud



func _ready():

    # Instance 'arena' as child of 'Gameplay'.
    add_child(arena.instance())

    # Instance 'vehicle' as child of 'Gameplay' at pos of 'SpawnVehicle'.
    spawn_vehicle = get_node('/root/Gameplay/' + arena_tag + '/SpawnVehicle')
    b = body.instance()
    b.translate(spawn_vehicle.translation)
    add_child(b)

    # Instance parts as children of 'vehicle'.
    vehicle = get_node('/root/Gameplay/Vehicle')
    vehicle.add_child(generator.instance())
    vehicle.add_child(engines.instance())
    vehicle.add_child(blaster.instance())

    """ NEED TO FIX ... SHOULDN'T USE DIRECT PATH """
    hud = $Vehicle/Hud



func _on_HalfSecond_timeout():

    hud.updateSpeedValue(vehicle.linear_velocity.length())
