


extends Control

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')

onready var tree = find_node('PartsTreeVBox*')

onready var SelectionBoxScene = preload('res://Scenes/Menus/Expandables/PartSelectionBox.tscn')

var inv_mod



####################################################################################################



func _ready():
    
    # Open temp mods.
    inv_mod = main.loadModule(main, 'res://Scenes/Functional/InventoryMod.tscn')

    addSelectionBox(0, 'body', 'body')



####################################################################################################



func bodySelected(_body_node, _selection):
    
    for each in tree.get_children():
        if each.part_layer != 'body':  each.queue_free()
    
    if not _selection:  return
    
    var boost_count = range(getBoostCount('body', _selection))
    boost_count.invert()
    for boost in boost_count:
        addSelectionBox(1, 'boost', 'boost_%s' % str(boost + 1))
    
    var parts = ['generator', 'engines', 'shields']
    
    parts += getExpandableParts(_selection)
    for part in parts:  addSelectionBox(len(tree.get_children()), 'part', part)



func partSelected(_part_node, _selection):
    
    for boost_node in getThisPartsBoosts(_part_node.get_position_in_parent()):
        boost_node.queue_free()
    
    if not _selection:  return
    
    var boost_count = getBoostCount(_part_node.part_type, _selection)
    boost_count = range(boost_count)
    boost_count.invert()
    for boost in boost_count:
        addSelectionBox(
            _part_node.get_position_in_parent() + 1,
            'boost',
            'boost_%s' % str(boost + 1)
        )



func addSelectionBox(_index, _layer, _type):
    
    var selection_box = SelectionBoxScene.instance()
    tree.add_child(selection_box)
    tree.move_child(selection_box, _index)
    selection_box.init(_layer, _type)



func getExpandableParts(_selection):
    
    var expandable_parts_ = []
    var body = controls.bodies[_selection]
    expandable_parts_ += body['blaster_slots'] + body['launcher_slots']
    
    return expandable_parts_



func getPartNodes():
    
    var part_nodes_ = []
    for child in tree.get_children():
        if child.part_layer == 'part':  part_nodes_ += [ child ]
    
    return part_nodes_



func getThisPartsBoosts(_parts_pos):
    
    var branches_below = tree.get_children().slice(_parts_pos + 1, -1)
    
    var boost_nodes_ = []
    for branch in branches_below:
        if branch.part_type.begins_with('boost'):  boost_nodes_ += [ branch ]
        else:  break
    
    return boost_nodes_



func getBoostCount(_type, _selection):
    
    var boost_count_ = 0
    
    var part_ref
        
    if _type.begins_with('body'):                 part_ref = controls.bodies
    elif _type.begins_with('generator'):          part_ref = controls.generators
    elif _type.begins_with('engines'):            part_ref = controls.engines
    elif _type.begins_with('shields'):            part_ref = controls.shields
    elif _type.begins_with('blaster'):            part_ref = controls.blasters
    elif _type.begins_with('missilelauncher'):    part_ref = controls.launchers['Missile']
    
    boost_count_ = part_ref[_selection]['boost_slots']
    
    return boost_count_



func deleteSeparators():
    
#    print("\nDELETING ALL SEPARATORS")
    for branch in tree.get_children():
#        print(branch.get_class())
        if branch.get_class() == 'TextureRect' or branch.part_type == 'separator':
#            print("    deleting")
            tree.remove_child(branch)
            branch.queue_free()
            branch.free()



func resetAllBranchImages():
    
    for branch in tree.get_children():  branch.setBranchImages()



func insertSeparators():
    
#    print("\nlen(tree.get_children()) = ", len(tree.get_children()))
#    for each in tree.get_children():  print(each)
    if len(tree.get_children()) == 1:  return
    
    for _i in range(getCountOfParts()):
        print("\n_i = ", _i)
    
        var branches = tree.get_children()
        
        var part_last_boost_pos = 0
        for i in range(len(branches)):
            var branch = branches[i]
#            print("i = ", i)
            
            # Sort out separators.
            print("branch.part_type = ", branch.part_type)
            if branch.get_class() == 'TextureRect' or branch.part_type == 'separator':
                print("part is separator")
                continue
            
            # Sort out parts already separated.
            if partAlreadySeparated(i):  continue
            
            # Sort out boosts.
            if branch.part_layer == 'boost':  continue
            
            part_last_boost_pos = getPartLastBoostPos(i)
            break
        
#        print("part_last_boost_pos = ", part_last_boost_pos)
        insertSeparator(part_last_boost_pos)



func getCountOfParts():
    
    var branches = tree.get_children()
    
    var count_of_parts_ = 0
    for branch in branches:
        if branch.get_class() == 'TextureRect' or branch.part_type == 'separator':  continue
        if branch.part_layer == 'part':  count_of_parts_ += 1
    
    return count_of_parts_



func partAlreadySeparated(_i):
    
    var part_already_separated_ = false
    
    for branch in tree.get_children().slice(_i + 1, -1):
        if branch.get_class() == 'TextureRect' or branch.part_type == 'separator':
            part_already_separated_ = true
            break
        if branch.part_layer == 'boost':  continue
        break
    
#    print("part_already_separated_ = ", part_already_separated_)
    return part_already_separated_



func isLastPart(_i):
    
    var is_last_part_ = true
    
    for branch in tree.get_children().slice(_i, -1):
        if branch.get_class() == 'TextureRect' or branch.part_type == 'separator':  is_last_part_ = false
        elif branch.part_layer == 'part':  is_last_part_ = false
    
#    print("is_last_part_ = ", is_last_part_)
    return is_last_part_



func getPartLastBoostPos(_i):
    
    var part_last_boost_pos_ = 0
    
    var branches = tree.get_children()
    
    for i in range(len(branches)):
        var branch = branches[i]
        if i <= _i:  continue
        if branch.part_layer != 'boost':
            part_last_boost_pos_ = i
            break
    
    return part_last_boost_pos_



func insertSeparator(_part_last_boost_pos):
    
#    print(_part_last_boost_pos)

#    var separator = TextureRect.new()
#    separator.texture = branch_sep
#    tree.add_child(separator)
#    tree.move_child(separator, _part_last_boost_pos)

    var node_ = SelectionBoxScene.instance()
    tree.add_child(node_)
    tree.move_child(node_, _part_last_boost_pos)
    node_.init('separator', 'separator')



####################################################################################################



func queue_free():
    
    # Close temp mods.
    inv_mod.queue_free()



####################################################################################################



#func getBranchTypes(_branches):
#
#    var branch_types_ = []
#
#    _branches.invert()
#
#    var last_part_boosts = true
#    var last_part = true
#
#    for i in range(len(_branches)):
#        var branch = _branches[i]
#
#        # Handle body.
#        if branch.part_layer == 'body':  branch_types_ += [ [branch.part_type, 'body'] ]
#
#        # Handle last_part_last_boost and last_part_mid_boosts.
#        if last_part_boosts and branch.part_layer == 'part':
#            last_part_boosts = false
#        if last_part_boosts and branch.part_layer == 'boost':
##            if _branches[i - 1].part_layer != 'boost':
##            print("i = ", i)
##            print("len(_branches) = ", len(_branches))
#            if i == 0:
#                branch_types_ += [ [branch.part_type, 'last_part_last_boost'] ]
#                continue
#            else:
#                branch_types_ += [ [branch.part_type, 'last_part_mid_boost'] ]
#                continue
#
#        # Handle last_part.
#        if last_part and branch.part_layer == 'part':
#            last_part = false
#            branch_types_ += [ [branch.part_type, 'last_part'] ]
#            continue
#
#        # Handle mid_parts.
#        if branch.part_layer == 'part':
#            branch_types_ += [ [branch.part_type, 'mid_part'] ]
#            continue
#
#        # Handle last_boosts and mid_boosts.
#        if branch.part_layer == 'boost':
#            if _branches[i - 1].part_layer != 'boost':
#                branch_types_ += [ [branch.part_type, 'last_boost'] ]
#                continue
#            else:
#                branch_types_ += [ [branch.part_type, 'mid_boost'] ]
#                continue
#
##    branch_types_.invert()
#
#    return branch_types_



#        branch_types += [ branch.branch_image_type ]
    
#    print("\nDEBUG")
#    for branch_type in branch_types:  print(branch_type)
    
#    print("\n")
#    for each in branch_types:  print(each)
#
#    for i in range(len(branch_types)):
#        var branch_type = branch_types[i]
#        match branch_type:
#            'body':
#                var branch1 = branches[i].find_node('Branch1*', true, false)
#                var branch2 = branches[i].find_node('Branch2*', true, false)
#                branch1.visible = false
#                branch2.visible = false
#            'mid_part':
#                var branch1 = branches[i].find_node('Branch1*', true, false)
#                var branch2 = branches[i].find_node('Branch2*', true, false)
#                branch1.texture = branch_T
#                branch2.visible = false
#            'last_part':
#                var branch1 = branches[i].find_node('Branch1*', true, false)
#                var branch2 = branches[i].find_node('Branch2*', true, false)
#                branch1.texture = branch_r
#                branch2.visible = false
#            'mid_boost':
#                var branch1 = branches[i].find_node('Branch1*', true, false)
#                var branch2 = branches[i].find_node('Branch2*', true, false)
#                branch1.texture = branch_l
#                branch2.texture = branch_T
#            'last_boost':
#                var branch1 = branches[i].find_node('Branch1*', true, false)
#                var branch2 = branches[i].find_node('Branch2*', true, false)
#                branch1.texture = branch_l
#                branch2.texture = branch_r
#            'last_part_mid_boost':
#                var branch1 = branches[i].find_node('Branch1*', true, false)
#                var branch2 = branches[i].find_node('Branch2*', true, false)
#                branch1.texture = branch_A
#                branch2.texture = branch_T
#            'last_part_last_boost':
#                var branch1 = branches[i].find_node('Branch1*', true, false)
#                var branch2 = branches[i].find_node('Branch2*', true, false)
#                branch1.texture = branch_A
#                branch2.texture = branch_r



#    for branch in branches:
#        branch.find_node('Branch1*', true, false).texture = branch_A
#        branch.find_node('Branch2*', true, false).texture = branch_A
    
#    print("branches = ", branches)
    
#    var branch_types = getBranchTypes(branches)



#    var found_all_parts = false
#    var while_loop_counter = 0
#    while not found_all_parts:
#        while_loop_counter += 1
#        print("while_loop_counter = ", while_loop_counter)
#
#        var part_last_boost_pos = 0
#        var branches = tree.get_children()
#        for i in range(len(branches)):
#            var branch = branches[i]
#
#            if isLastPart(i):
#                found_all_parts = true
#                break
#
##            print(branch.get_class())
#            if branch.get_class() == 'TextureRect':  continue
#            if branch.part_layer != 'part':  continue
#
#
#            if partAlreadySeparated(i):  continue
#
#            part_last_boost_pos = getPartLastBoostPos(i)
#
#        insertSeparator(part_last_boost_pos)



#    var branches = tree.get_children()
#
#    var sep_counter = 0
#    for i in range(len(branches)):
#        var branch = branches[i]
#
#        if branch.part_layer == 'part':
#
##            print(i)
#
##            addSelectionBox(i + sep_counter, 'separator', 'separator')
#
#            """
#            Maybe try using add_child_below_node().  Will have to write a function that determines
#            if the separator goes below the part or the last_boost.  It's possible these issues are
#            due to changing an array while looping through it.
#            """
#
#            var separator = TextureRect.new()
#            separator.texture = branch_sep
#            tree.add_child(separator)
#            tree.move_child(separator, i + sep_counter)
##            tree.move_child(separator, i)
#            sep_counter += 1



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










