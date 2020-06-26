
extends Control

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')

onready var tree = find_node('PartsTreeVBox*')

onready var part_node_scene = preload('res://Scenes/Menus/Expandables/PartSelectionBox.tscn')

onready var branch_A =      preload('res://Textures/tree_branch_A.png')
onready var branch_l =      preload('res://Textures/tree_branch_l.png')
onready var branch_r =      preload('res://Textures/tree_branch_r.png')
onready var branch_T =      preload('res://Textures/tree_branch_T.png')
onready var branch__ =      preload('res://Textures/tree_branch_-.png')
onready var branch_sep =    preload('res://Textures/tree_branch_sep.png')

####################################################################################################

func _ready():
    
    # Open temp mods.
    var inv_mod = main.loadModule(main, 'res://Scenes/Functional/InventoryMod.tscn')

    addPartNode(0, 'body', 'body')

    # Close temp mods.
    inv_mod.queue_free()

####################################################################################################

func addPartNode(_index, _layer, _type):
    
    var part_node = part_node_scene.instance()
    part_node.name = _type
    setPartNodeLayer(part_node, _layer)
    part_node.find_node('PartTypeLabel*').text = _type
    tree.add_child(part_node)
    tree.move_child(part_node, _index)

func setPartNodeLayer(_part_node, _layer):
    
    var branch_visibilities = []
    match _layer:
        'body':     branch_visibilities = [false, false]
        'part':     branch_visibilities = [true, false]
        'boost':    branch_visibilities = [true, true]
    
    _part_node.find_node('Branch1*').visible = branch_visibilities[0]
    _part_node.find_node('Branch2*').visible = branch_visibilities[1]







