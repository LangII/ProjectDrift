
extends Node

onready var controls = get_node('/root/Controls')

# Get tags and scenes variables from 'controls'.
onready var arena_tag = controls.gameplay['arena']
onready var arena = load('res://Scenes/Arenas/' + arena_tag + '.tscn')
onready var body_tag = controls.gameplay['vehicle']['body']
onready var body = load('res://Scenes/Functional/VehicleBodies/' + body_tag + '.tscn')
onready var engines_tag = controls.gameplay['vehicle']['engines']
onready var engines = load('res://Scenes/Models/VehicleParts/Engines/' + engines_tag + '.tscn')
onready var blaster_tag = controls.gameplay['vehicle']['blaster']
onready var blaster = load('res://Scenes/Models/VehicleParts/Blasters/' + blaster_tag + '.tscn')

# onready var hud = preload('res://Scenes/Functional/Hud.tscn')
onready var pause = preload('res://Scenes/Menus/Pause.tscn')



func _ready():

    # Instance 'arena' as child of 'Gameplay'.
    add_child(arena.instance())

    # Instance 'vehicle' as child of 'Gameplay' at pos of 'SpawnVehicle'.
    var spawn_vehicle = get_node('/root/Gameplay/' + arena_tag + '/SpawnVehicle')
    var b = body.instance()
    b.translate(spawn_vehicle.translation)
    add_child(b)

    # Instance parts as children of 'vehicle'.
    var vehicle_body_node = get_node('/root/Gameplay/Vehicle')
    # vehicle_body_node.add_child(hud.instance())
    vehicle_body_node.add_child(engines.instance())
    vehicle_body_node.add_child(blaster.instance())

    # add_child(hud.instance())
    add_child(pause.instance())
