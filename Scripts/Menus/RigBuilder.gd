


extends Control

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')

# Node references.
onready var tree = find_node('PartsTreeVBox*')
onready var pedestal = find_node('PedestalPos*')

# Resources.
onready var SelectionBoxScene = preload('res://Scenes/Menus/Expandables/PartSelectionBox.tscn')

var inv_mod



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
    # Open temp mods.
    inv_mod = main.loadModule(main, 'res://Scenes/Functional/InventoryMod.tscn')

    insertSelectionBox(0, 'body', 'body')



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(delta):
    
#    print("pedestal = ", pedestal)
#    print('something')
#    pedestal.rotate_y(.001)
    pedestal.rotate_object_local(Vector3.UP, .005)
#    pedestal.global_rotate(Vector3.UP, 10)
#    pedestal.transform.basis.y

#    var rot_speed = rad2deg(30)  # 30 deg/sec
#    pedestal.set_rot(pedestal.get_rot() + rot_speed * delta)



####################################################################################################
                                                                       ###   EXTERNALLY CALLED   ###
                                                                       #############################

func bodySelected(_body_node, _selection):
    
    clearBranchesForNewBody()
    
    # End call if empty selection.
    if not _selection:  return
    
    insertBoostsIntoTreeAtIndex(_body_node, _selection, 1)
    
    appendPartsToTree(_selection)



func partSelected(_part_node, _selection):
    
    clearBranchesForNewPart(_part_node)
    
    # End call if empty selection.
    if not _selection:  return
    
    insertBoostsIntoTreeAtIndex(_part_node, _selection, _part_node.get_position_in_parent() + 1)



func deleteSeparators():
    
    for branch in tree.get_children():
        if branch.branch_type == 'separator':
            tree.remove_child(branch)
            branch.queue_free()



func resetAllBranchImages():
    
    for branch in tree.get_children():  branch.setBranchImages()



func insertSeparators():
    
    # If only 'body' branch exists end call.
    if len(tree.get_children()) == 1:  return
    
    # Perform outer loop for each part in tree.  Each separator is inserted in consideration of each
    # branch of part type.
    for _i in range(getCountOfPartBranches()):
        
        # Get new branches with each loop.
        var branches = tree.get_children()
        
        # Inner loop through all branches.
        var this_part_last_boost_pos = 0
        for i in range(len(branches)):
            var branch = branches[i]
            
            # End current loop conditionals.
            if branch.branch_type == 'separator':  continue
            if partAlreadySeparated(i):  continue
            
            """ Obsolete...  But staying here for now. I swear I thought this was relevant. """
#            # Sort out boosts.
#            if branch.branch_layer == 'boost':
#                print("part is boost")
#                continue
            
            # Final get of position for separator insert.
            this_part_last_boost_pos = getThisPartLastBoostPos(i)
            break
        
        insertSeparator(this_part_last_boost_pos)



func buildRigModel():
    
    var current_rig_models = pedestal.get_children()
    for model in current_rig_models:
        pedestal.remove_child(model)
        model.queue_free()
    
    var rig_data_pack = getRigDataPack()
    
#    for key in rig_json.keys():
#        var value = rig_json[key]
    
    var body_tag = rig_data_pack['body']['part_tag']
    
    if not body_tag:  return
    
    var body = load('res://Scenes/Functional/VehicleBodies/%s.tscn' % body_tag).instance()
    
    body.script = null
    var body_non_spatial = body.find_node('NonSpatial*')
    body.remove_child(body_non_spatial)
    body_non_spatial.queue_free()
    var body_camera_pivot = body.find_node('CameraPivot*')
    body.remove_child(body_camera_pivot)
    body_camera_pivot.queue_free()
    
    pedestal.add_child(body)
    
    for part_type in rig_data_pack.keys():
        if part_type == 'body':  continue
        var part_data = rig_data_pack[part_type]
        
        if not part_data['part_tag']:  continue
        
        var part_type_ref
        var part_slot_ref
        if part_type == 'generator':
            part_type_ref = 'Generators'
            part_slot_ref = 'GeneratorPos*'
        elif part_type == 'engines':
            part_type_ref = 'Engines'
            
            part_slot_ref = []
            for each in ['Fr', 'Br', 'Bl', 'Fl']:  part_slot_ref += [ 'Engine%sPos*' % each ]
            
        elif part_type == 'shields':
            part_type_ref = 'Shields'
            part_slot_ref = 'ShieldsPos*'
        elif part_type.begins_with('blaster'):
            part_type_ref = 'Blasters'
            
            var i_tag = part_type.substr(part_type.find('_') + 1, len(part_type))
#            print("i_tag = |%s|" % i_tag)
            part_slot_ref = 'Blaster%sPos*' % i_tag
#            continue
            
        elif part_type.begins_with('missilelauncher'):
            part_type_ref = 'Launchers/Missile'
            
            var i_tag = part_type.substr(part_type.find('_') + 1, len(part_type))
#            print("i_tag = |%s|" % i_tag)
            part_slot_ref = 'MissileLauncher%sPos*' % i_tag
            
        var part_node = load('res://Scenes/Models/VehicleParts/%s/%s.tscn' % [part_type_ref, part_data['part_tag']])
        
        if part_type == 'engines':
            print("part_slot_ref = ", part_slot_ref)
            print("part_node = ", part_node)
            for ref in part_slot_ref:
                var part_slot = body.find_node(ref, true, false)
                part_slot.add_child(part_node.instance())
            continue
        
        var part_slot = body.find_node(part_slot_ref, true, false)
        part_slot.add_child(part_node.instance())



####################################################################################################
                                                                                   ###   FUNCS   ###
                                                                                   #################

func clearBranchesForNewBody():

    for each in tree.get_children():
        if each.branch_layer != 'body':  each.queue_free()



func clearBranchesForNewPart(_part_node):
    
    for boost_node in getThisPartsBoosts(_part_node.get_position_in_parent()):
        boost_node.queue_free()



func getThisPartsBoosts(_parts_pos):
    
    var branches_below_pos = tree.get_children().slice(_parts_pos + 1, -1)
    var boost_nodes_ = []
    for branch in branches_below_pos:
        if branch.branch_type.begins_with('boost'):  boost_nodes_ += [ branch ]
        else:  break
    
    return boost_nodes_



func insertBoostsIntoTreeAtIndex(_branch_node, _selection, _index):
    
    var boost_list = range(getBoostCount(_branch_node.branch_type, _selection))
    boost_list.invert()
    for boost in boost_list:  insertSelectionBox(_index, 'boost', 'boost_%s' % str(boost + 1))



func appendPartsToTree(_selection):
    
    var parts = ['generator', 'engines', 'shields']
    parts += getExpandableParts(_selection)
    for part in parts:  insertSelectionBox(len(tree.get_children()), 'part', part)



func getExpandableParts(_selection):
    
    var body = controls.bodies[_selection]
    var expandable_parts_ = body['blaster_slots'] + body['launcher_slots']
    
    return expandable_parts_



func getBoostCount(_branch_type, _selection):
    
    var part_ref
    if _branch_type == 'body':                          part_ref = controls.bodies
    elif _branch_type == 'generator':                   part_ref = controls.generators
    elif _branch_type == 'engines':                     part_ref = controls.engines
    elif _branch_type == 'shields':                     part_ref = controls.shields
    elif _branch_type.begins_with('blaster'):           part_ref = controls.blasters
    elif _branch_type.begins_with('missilelauncher'):   part_ref = controls.launchers['Missile']
    
    var boost_count_ = part_ref[_selection]['boost_slots']
    
    return boost_count_



func insertSelectionBox(_index, _layer, _type):
    
    var selection_box = SelectionBoxScene.instance()
    tree.add_child(selection_box)
    tree.move_child(selection_box, _index)
    selection_box.init(_layer, _type)



func getCountOfPartBranches():
    
    var count_of_part_branches_ = 0
    for branch in tree.get_children():
        if branch.branch_layer == 'part':  count_of_part_branches_ += 1
    
    return count_of_part_branches_



func partAlreadySeparated(_i):
    
    var part_already_separated_ = false
    for branch in tree.get_children().slice(_i + 1, -1):
        if branch.branch_type == 'separator':
            part_already_separated_ = true
            break
        if branch.branch_layer == 'boost':  continue
        break
    
    return part_already_separated_



func isLastPart(_i):
    
    var is_last_part_ = true
    for branch in tree.get_children().slice(_i, -1):
        if branch.branch_type == 'separator':  is_last_part_ = false
        elif branch.branch_layer == 'part':  is_last_part_ = false
    
    return is_last_part_



func getThisPartLastBoostPos(_i):
    
    var this_part_last_boost_pos_ = 0
    var branches = tree.get_children()

    for i in range(len(branches)):
        var branch = branches[i]

        # Ignore branches before 'this' branch.
        if i <= _i:  continue

        if branch.branch_layer != 'boost':
            this_part_last_boost_pos_ = i
            break
    
    return this_part_last_boost_pos_



func insertSeparator(_part_last_boost_pos):
    
    var node_ = SelectionBoxScene.instance()
    tree.add_child(node_)
    tree.move_child(node_, _part_last_boost_pos)
    node_.init('separator', 'separator')



func getRigDataPack():
    
    var rig_data_pack_ = {}
    # Build parts of data pack.
    for branch in tree.get_children():
        if branch.branch_layer in ['separator', 'boost']:  continue

        rig_data_pack_[branch.branch_type] = {'part_tag': '', 'boosts': []}
        rig_data_pack_[branch.branch_type]['part_tag'] = branch.pop_up_selection_name
    
    # Build boosts of data pack.
    for branch in tree.get_children():
        if branch.branch_layer != 'boost':  continue
        if not branch.pop_up_selection_name:  continue

        var parent = branch.branch_parent
        rig_data_pack_[parent.branch_type]['boosts'] += [ branch.pop_up_selection_name ]

#    print(rig_data_pack_)

    return rig_data_pack_



####################################################################################################
                                                                             ###   ON DELETION   ###
                                                                             #######################

func queue_free():
    
    # Close temp mods.
    inv_mod.queue_free()
    inv_mod.queue_free()



####################################################################################################
                                                                                ###   OBSOLETE   ###
                                                                                ####################

#        if branch.branch_type == 'body':
#            rig_json_['body'] = {}
#            rig_json_['body']['part_tag'] = branch.pop_up_selection_name
#        elif branch.branch_type == 'generator':
#            rig_json_['generator'] = {}
#            rig_json_['generator']['part_tag'] = branch.pop_up_selection_name
#        elif branch.branch_type == 'engines':
#            rig_json_['engines'] = {}
#            rig_json_['engines']['part_tag'] = branch.pop_up_selection_name
#        elif branch.branch_type == 'shields':
#            rig_json_['shields'] = {}
#            rig_json_['shields']['part_tag'] = branch.pop_up_selection_name



#func getPartNodes():
#
#    var part_nodes_ = []
#    for child in tree.get_children():
#        if child.branch_layer == 'part':  part_nodes_ += [ child ]
#
#    return part_nodes_



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
#        if branch.branch_layer == 'body':  branch_types_ += [ [branch.branch_type, 'body'] ]
#
#        # Handle last_part_last_boost and last_part_mid_boosts.
#        if last_part_boosts and branch.branch_layer == 'part':
#            last_part_boosts = false
#        if last_part_boosts and branch.branch_layer == 'boost':
##            if _branches[i - 1].branch_layer != 'boost':
##            print("i = ", i)
##            print("len(_branches) = ", len(_branches))
#            if i == 0:
#                branch_types_ += [ [branch.branch_type, 'last_part_last_boost'] ]
#                continue
#            else:
#                branch_types_ += [ [branch.branch_type, 'last_part_mid_boost'] ]
#                continue
#
#        # Handle last_part.
#        if last_part and branch.branch_layer == 'part':
#            last_part = false
#            branch_types_ += [ [branch.branch_type, 'last_part'] ]
#            continue
#
#        # Handle mid_parts.
#        if branch.branch_layer == 'part':
#            branch_types_ += [ [branch.branch_type, 'mid_part'] ]
#            continue
#
#        # Handle last_boosts and mid_boosts.
#        if branch.branch_layer == 'boost':
#            if _branches[i - 1].branch_layer != 'boost':
#                branch_types_ += [ [branch.branch_type, 'last_boost'] ]
#                continue
#            else:
#                branch_types_ += [ [branch.branch_type, 'mid_boost'] ]
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
#            if branch.branch_layer != 'part':  continue
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
#        if branch.branch_layer == 'part':
#
##            print(i)
#
##            insertSelectionBox(i + sep_counter, 'separator', 'separator')
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










