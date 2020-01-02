
extends Node

onready var controls = get_node('/root/Controls')

onready var vehicle = preload('res://Scenes/Test/Vehicle.tscn')
onready var pause = preload('res://Scenes/Menu/Pause.tscn')

onready var arena_tag = controls.main['arena']

onready var arena = load('res://Scenes/Arenas/' + arena_tag + '.tscn')



func _ready():

    add_child(arena.instance())

    var arena_node = get_node('/root/Gameplay/' + arena_tag)

    # Instance 'vehicle' into scene tree and spawn at pos of 'SpawnVehicle'.
    var spawn_vehicle = get_node('/root/Gameplay/' + arena_tag + '/SpawnVehicle')
    var v = vehicle.instance()
    v.translate(spawn_vehicle.translation)
    add_child(v)

    add_child(pause.instance())

    # print_tree_pretty()
