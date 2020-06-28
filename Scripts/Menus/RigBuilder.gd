


extends Control

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')

onready var tree = find_node('PartsTreeVBox*')

onready var selection_node_scene = preload('res://Scenes/Menus/Expandables/PartSelectionBox.tscn')

onready var branch_A =      preload('res://Textures/tree_branch_A.png')
onready var branch_l =      preload('res://Textures/tree_branch_l.png')
onready var branch_r =      preload('res://Textures/tree_branch_r.png')
onready var branch_T =      preload('res://Textures/tree_branch_T.png')
onready var branch__ =      preload('res://Textures/tree_branch_-.png')
onready var branch_sep =    preload('res://Textures/tree_branch_sep.png')

var inv_mod



####################################################################################################



func _ready():
    
    # Open temp mods.
    inv_mod = main.loadModule(main, 'res://Scenes/Functional/InventoryMod.tscn')

    addSelectionNode(0, 'body', 'body')



####################################################################################################



func bodySelected(_body_node, _selection):
    
    for part_node in getPartNodes():
        var this_parts_boosts = getThisPartsBoosts(part_node.get_position_in_parent())
        for this_parts_boost in this_parts_boosts:  this_parts_boost.queue_free()
        part_node.queue_free()
    for boost_node in getThisPartsBoosts(_body_node.get_position_in_parent()):  boost_node.queue_free()
    
    if not _selection:  return
    
    var boost_count = getBoostCount('body', _selection)
    for boost in range(boost_count):  addSelectionNode(-1, 'boost', 'boost_%s' % str(boost + 1))
    
    var parts = ['generator', 'engines', 'shields']
    
    parts += getExpandableParts(_selection)
    for part in parts:  addSelectionNode(-1, 'part', part)



func partSelected(_part_node, _selection):
    
    for boost_node in getThisPartsBoosts(_part_node.get_position_in_parent()):  boost_node.queue_free()
    
    if not _selection:  return
    
    var boost_count = getBoostCount(_part_node.part_type, _selection)
    for boost in range(boost_count):  addSelectionNode(_part_node.get_position_in_parent() + 1, 'boost', 'boost_%s' % str(boost + 1))
    



func addSelectionNode(_index, _layer, _type):
    
    var node_ = selection_node_scene.instance()
    tree.add_child(node_)
    tree.move_child(node_, _index)
    node_.init(_layer, _type)



func getExpandableParts(_selection):
    
    var expandable_parts_ = []
    var body = controls.bodies[_selection]
    expandable_parts_ += body['blaster_slots'] + body['launcher_slots']
    
    return expandable_parts_



func getPartNodes():
    
    var part_nodes_ = []
    for child in tree.get_children():
        if child.node_layer == 'part':  part_nodes_ += [ child ]
    
    return part_nodes_



func getThisPartsBoosts(_parts_pos):
    
    var branches_below = tree.get_children().slice(_parts_pos + 1, -1)
    
    var boost_nodes_ = []
    for branch in branches_below:
        print("branch.part_type = ", branch.part_type)
        if branch.part_type.begins_with('boost'):  boost_nodes_ += [ branch ]
        else:  break
    
    print("boost_nodes_ = ", boost_nodes_)
    return boost_nodes_



func getBoostCount(_type, _selection):
    
    var boost_count_ = 0
    
    var part_ref
#    match _type:
#        'body':             part_ref = controls.bodies
#        'generator':        part_ref = controls.generators
#        'engines':          part_ref = controls.engines
#        'shields':          part_ref = controls.shields
#        'blaster':          part_ref = controls.blasters
#        'missilelauncher':  part_ref = controls.launchers['Missile']
        
    if _type.begins_with('body'):                 part_ref = controls.bodies
    elif _type.begins_with('generator'):          part_ref = controls.generators
    elif _type.begins_with('engines'):            part_ref = controls.engines
    elif _type.begins_with('shields'):            part_ref = controls.shields
    elif _type.begins_with('blaster'):            part_ref = controls.blasters
    elif _type.begins_with('missilelauncher'):    part_ref = controls.launchers['Missile']
    
    boost_count_ = part_ref[_selection]['boost_slots']
    
    return boost_count_



####################################################################################################



func queue_free():
    
    # Close temp mods.
    inv_mod.queue_free()



####################################################################################################



#    part_node_.name = _type
#    setPartNodeLayer(part_node_, _layer)
#    part_node_.find_node('PartTypeLabel*', true, false).text = _type
#    fillPartNodeOptions(part_node_)



#func fillPartNodeOptions(_part_node):
#
#    var type = _part_node.find_node('PartTypeLabel*', true, false).text
#    var pop_up = _part_node.find_node('PartSelectionPopUp*', true, false)
#
#    for option in getPopUpOptions(type):  pop_up.add_item(option)
#
#func getPopUpOptions(_type):
#
#    match _type:
#        'body':  return inv_mod.bodies
#
#func selectPart(_type, _selection):
#
#    pass










