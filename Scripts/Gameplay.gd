
extends Node

onready var controls = get_node('/root/Controls')

onready var arena_tag = controls.gameplay['arena']
onready var arena = load('res://Scenes/Arenas/' + arena_tag + '.tscn')

onready var body_tag = controls.gameplay['vehicle']['body']
onready var body = load('res://Scenes/VehicleBodies/' + body_tag + '.tscn')

onready var engines_tag = controls.gameplay['vehicle']['engines']
onready var engines = load('res://Scenes/Models/VehicleParts/Engines/' + engines_tag + '.tscn')

onready var pause = preload('res://Scenes/Menus/Pause.tscn')



func _ready():

    # Instance 'arena' as child of 'Gameplay'.
    add_child(arena.instance())
    var arena_node = get_node('/root/Gameplay/' + arena_tag)

    # Instance 'vehicle' as child of 'Gameplay' at pos of 'SpawnVehicle'.
    var spawn_vehicle = get_node('/root/Gameplay/' + arena_tag + '/SpawnVehicle')
    var b = body.instance()
    b.translate(spawn_vehicle.translation)
    add_child(b)

    # Instance 'engines' as child of 'vehicle'.
    var vehicle_body_node = get_node('/root/Gameplay/Vehicle')
    vehicle_body_node.add_child(engines.instance())

    add_child(pause.instance())
