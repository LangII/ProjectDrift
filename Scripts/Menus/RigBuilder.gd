


extends Control

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')

# Node references.
onready var background_cam = find_node('BackgroundCamera*')
onready var tree = find_node('PartsTreeVBox*')
onready var pedestal = find_node('PedestalPos*')
onready var stats_vbox = find_node('StatsVBox*')
onready var details_label = find_node('DetailsLabel*')
onready var min_req_popup = find_node('MinimumRequirementsPopUp*')
onready var are_you_sure_popup = find_node('AreYouSurePopUp*')
onready var rig_builder_tab_container = find_node('RigBuilderTabContainer*')
onready var details_tab_container = find_node('DetailsTabContainer*')
onready var model_tab_container = find_node('ModelTabContainer*')
onready var timer_1 = find_node('Timer1*')
onready var timer_2 = find_node('Timer2*')

# Resources.
onready var PartSelectionBoxScene = preload('res://Scenes/Menus/Reusables/PartSelectionBox.tscn')
onready var StatDisplayBoxScene = preload('res://Scenes/Menus/Reusables/StatDisplayBox.tscn')

onready var pedestal_rot_spd = 0.008
onready var background_cam_rot_spd_1 = 0.0009
onready var background_cam_rot_spd_2 = -0.0006

var inv_mod
var boost_mod
var stat_refs
var save_mod
var rig_data_pack = {}
var last_rig_data_pack = {}

onready var boosts = controls.boosts



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
    main.scriptedScenePrint(name, 'enter')
    
    # Open temp mods.
    inv_mod = main.loadModule(main, 'res://Scenes/Functional/InventoryMod.tscn')
    boost_mod = main.loadModule(main, 'res://Scenes/Functional/BoostMod.tscn')
    stat_refs = main.loadModule(main, 'res://Scenes/Functional/StatDisplayRefs.tscn')
    save_mod = main.loadModule(main, 'res://Scenes/Functional/SaveMod.tscn')
    
    setTabs()
    
    insertSelectionBox(0, 'body', 'body')
    
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 



func setTabs():
    
    rig_builder_tab_container.set_tab_title(0, 'rig builder menu')
    details_tab_container.set_tab_title(0, 'details display')
    model_tab_container.set_tab_title(0, 'rig model display')
    model_tab_container.set_tab_title(1, 'rig stats display')



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(_delta):
    
    background_cam.rotate_object_local(Vector3.UP, background_cam_rot_spd_1)
    background_cam.rotate_object_local(Vector3.FORWARD, background_cam_rot_spd_2)
    pedestal.rotate_object_local(Vector3.UP, pedestal_rot_spd)



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
        
        var branches = tree.get_children()
        
        # Inner loop through all branches.
        var this_part_last_boost_pos = 0
        for i in range(len(branches)):
            var branch = branches[i]
            
            # End inner loop conditionals.
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
    
    deleteCurrentRigModel()
    
    rig_data_pack = getRigDataPack()
#    print(rig_data_pack)
    
    var has_no_body = not 'body' in rig_data_pack.keys()
    var body_has_no_part_tag = not rig_data_pack['body']['part_tag']
    if has_no_body or body_has_no_part_tag:  return
    
    var body_model = getBodyModel(rig_data_pack)
    
    pedestal.add_child(body_model)
    
    for part_type in rig_data_pack.keys():
        
        if part_type == 'body':  continue
        
        var part_data = rig_data_pack[part_type]
        
        if not part_data['part_tag']:  continue
        
        var part_refs = getPartRefs(part_type)
        
        var part_model_scene = getPartModelScene(part_refs, part_data)
        
        appendPartModelToBodyModel(body_model, part_refs, part_model_scene, part_data)



func getPartModelScene(_refs, _data):
    
    var file_path_str = 'res://Scenes/Models/VehicleParts/%s/%s.tscn'
    var part_model_scene_ = load(file_path_str % [_refs['file'], _data['part_tag']])
    
    return part_model_scene_



func deleteCurrentRigModel():
    
    var current_rig_models = pedestal.get_children()
    for model in current_rig_models:
        pedestal.remove_child(model)
        model.queue_free()



func getRigDataPack():
    
    var rig_data_pack_ = {}
    
    # Build parts of data pack.
    for branch in tree.get_children():
        if not branch.branch_layer in ['part', 'body']:  continue
        
        """ Need to review further, but looks like to avoid the 'shields' missing from Dictionary
        error I need to build a complete rig_data_pack including empty parts.  Also just noticed
        that boosts has this line uncommented.  So, I don't collect boosts empty tags but I do
        collect parts empty tags.  Need to review further. """
#        if not branch.pop_up_cur_selection_name_trim:  continue
        
        rig_data_pack_[branch.branch_type] = {
            'part_tag': branch.pop_up_cur_selection_name_trim, 'boosts': []
        }
        
    # Build boosts of data pack.
    for branch in tree.get_children():
        if branch.branch_layer != 'boost':  continue
        if not branch.pop_up_cur_selection_name_trim:  continue
        var parent = branch.branch_parent
        rig_data_pack_[parent.branch_type]['boosts'] += [ branch.pop_up_cur_selection_name_trim ]
    
#    print(rig_data_pack_)
    
    return rig_data_pack_



func getBodyModel(_rig_data_pack):
    """
    TO DO:
        Currently getting error messages because Vehicle.gd is still some how connected to 'body'.
        I think this is engine related.  I'll fix on my end by creating the vehicle bodies
        seperately and calling their models and part references into the fuctional scene.
    """
    
    var body_tag = _rig_data_pack['body']['part_tag']
    var body_model_ = load('res://Scenes/Functional/VehicleBodies/%s.tscn' % body_tag).instance()

    body_model_.script = null
    
    var nodes_to_delete = ['NonSpatial*', 'CameraPivot*']
    for node_name in nodes_to_delete:
        var node_to_delete = body_model_.find_node(node_name, true, false)
        body_model_.remove_child(node_to_delete)
        node_to_delete.queue_free()
    
    body_model_ = appendBoostModelsToPartModel(body_model_, 'body', _rig_data_pack['body'])
    
    return body_model_



func getPartRefs(_part_type):
    
    var part_refs_ = {}
    
    if _part_type == 'generator':
        part_refs_ = {'type': 'generator', 'file': 'Generators', 'slot': 'GeneratorPos*'}
    
    elif _part_type == 'shields':
        part_refs_ = {'type': 'shields', 'file': 'Shields', 'slot': 'ShieldsPos*'}
    
    elif _part_type == 'engines':
        var part_slot_refs = []
        for each in ['Fr', 'Br', 'Bl', 'Fl']:  part_slot_refs += [ 'Engine%sPos*' % each ]
        part_refs_ = {'type': 'engines', 'file': 'Engines', 'slot': part_slot_refs}
    
    elif _part_type.begins_with('blaster'):
        var i_tag = _part_type.substr(_part_type.find('_') + 1, len(_part_type))
        var part_slot_ref = 'Blaster%sPos*' % i_tag
        part_refs_ = {'type': 'blaster', 'file': 'Blasters', 'slot': part_slot_ref}
    
    elif _part_type.begins_with('missilelauncher'):
        var i_tag = _part_type.substr(_part_type.find('_') + 1, len(_part_type))
        var part_slot_ref = 'MissileLauncher%sPos*' % i_tag
        part_refs_ = {'type': 'missilelauncher', 'file': 'Launchers/Missile', 'slot': part_slot_ref}
    
    return part_refs_



func appendPartModelToBodyModel(_body, _refs, _scene, _data):

    if _refs['type'] == 'engines':
        for ref in _refs['slot']:
            var part_slot = _body.find_node(ref, true, false)
            var part_node = _scene.instance()
            part_node = appendBoostModelsToPartModel(part_node, _refs['type'], _data)
            part_slot.add_child(part_node)
        return

    var part_slot = _body.find_node(_refs['slot'], true, false)
    var part_node = _scene.instance()
    part_node = appendBoostModelsToPartModel(part_node, _refs['type'], _data)
    part_slot.add_child(part_node)



func appendBoostModelsToPartModel(_part_model, _part_type, _part_data_pack):
    
    for i in range(len(_part_data_pack['boosts'])):
        
        var _boosts_node_ = _part_model.get_node('Boosts*')
        var boost_slot = _boosts_node_.find_node('Boost%dPos*' % (i + 1), true, false)
        
        var boost_tag = _part_data_pack['boosts'][i]
        var boost_stat = boosts[_part_type][boost_tag]['stat']
        var boost_scene = boost_mod.getBoostModelScene(_part_type, boost_stat)
        
        boost_slot.add_child(boost_scene.instance())
    
    return _part_model



func updateAllPopUpOptionsDisabled() -> void:
    
    for branch in tree.get_children():
        if branch.branch_layer == 'separator':  continue
        branch.setPopUpOptionsDisabled()



####################################################################################################
                                                                                   ###   FUNCS   ###
                                                                                   #################

func clearBranchesForNewBody():

    for each in tree.get_children():
        if each.branch_layer != 'body':
            each.pre_queue_free()
            each.queue_free()



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
    
    var selection_box = PartSelectionBoxScene.instance()
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
    
    var node_ = PartSelectionBoxScene.instance()
    tree.add_child(node_)
    tree.move_child(node_, _part_last_boost_pos)
    node_.init('separator', 'separator')



func prepRigDataPackForPlay():

    for part_type in rig_data_pack.keys():
        var is_missile_launcher = part_type.begins_with('missilelauncher')
        var no_missile_launcher_assigned = rig_data_pack[part_type]['part_tag'] == ''
        if is_missile_launcher and no_missile_launcher_assigned:
            rig_data_pack[part_type]['part_tag'] = 'MissileLauncher'



func minimumRequirementsMet():
    
    for min_req_part in ['body', 'generator', 'engines']:
        if not min_req_part in rig_data_pack:  return false
        if not rig_data_pack[min_req_part]['part_tag']:  return false
    return true



####################################################################################################
                                                                           ###   STATS DISPLAY   ###
                                                                           #########################

func updateStatsDisplay():
    
    deleteAllInStatsDisplay()
    
    for part_type in rig_data_pack.keys():
        var part_tag = rig_data_pack[part_type]['part_tag']
        var boosts = rig_data_pack[part_type]['boosts']
        
        # Ignore unselected parts.
        if not part_tag:  continue
        
        var label_display_box = generateLabelDisplayBox(part_type, part_tag)
        stats_vbox.add_child(label_display_box)
        
        var part_stats = getPartStats(part_type, part_tag)
        for stat in part_stats.keys():
            var value = part_stats[stat]
            
            # Ignore slots stats.
            if stat.ends_with('_slots'):  continue
            
            var stat_display_box = generateStatDisplayBox(part_type, part_tag, stat, value)
            
            if boosts:  stat_display_box = updateStatDisplayBoxWithBoosts(stat_display_box, boosts)
            
            stat_display_box = updateBoostAdjustNodes(stat_display_box)
            
            stats_vbox.add_child(stat_display_box)



func deleteAllInStatsDisplay():
    
    for child in stats_vbox.get_children():
        stats_vbox.remove_child(child)
        child.queue_free()



func generateLabelDisplayBox(_part_type, _part_tag):
    
    var label_display_box_ = StatDisplayBoxScene.instance()
    
    label_display_box_.find_node('TabLabel*', true, false).visible = false
    label_display_box_.find_node('PartTypeLabel*', true, false).text = _part_type
    label_display_box_.find_node('PartTagLabel*', true, false).text = _part_tag
    
    var hide_nodes = [
        'StatContainer*', 'StatOriginalValueContainer*', 'BoostAdjustContainer1*',
        'BoostAdjustContainer2*', 'BoostAdjustContainer3*', 'BoostAdjustContainer4*',
        'StatFinalValueContainer*'
    ]
    for hide_node in hide_nodes:
        label_display_box_.find_node(hide_node, true, false).visible = false
    
    return label_display_box_



func getPartStats(_part_type, _part_tag):
    
    var part_ref
    if _part_type == 'body':                        part_ref = controls.bodies
    elif _part_type == 'generator':                 part_ref = controls.generators
    elif _part_type == 'engines':                   part_ref = controls.engines
    elif _part_type == 'shields':                   part_ref = controls.shields
    elif _part_type.begins_with('blaster'):         part_ref = controls.blasters
    elif _part_type.begins_with('missilelauncher'): part_ref = controls.launchers['Missile']
    
    var part_stats_ = part_ref[_part_tag]
    
    return part_stats_



func generateStatDisplayBox(_part_type, _part_tag, _stat, _value):
    
    var stat_display_box_ = StatDisplayBoxScene.instance()
    
    stat_display_box_.find_node('PartTypeLabel*', true, false).text = _part_type
    stat_display_box_.find_node('PartTagLabel*', true, false).text = _part_tag
    stat_display_box_.find_node('PartTypeContainer*', true, false).visible = false
    stat_display_box_.find_node('PartTagContainer*', true, false).visible = false
    
    stat_display_box_.find_node('StatLabel*', true, false).text = '%s *' % _stat
    stat_display_box_.find_node('StatOriginalValueLabel*', true, false).text = str(_value)
    stat_display_box_.find_node('StatFinalValueLabel*', true, false).text = '= %s' % str(_value)
    
    return stat_display_box_



func updateStatDisplayBoxWithBoosts(_stat_display, _boosts):
    
    var part_type = _stat_display.find_node('PartTypeLabel*', true, false).text
    if '_' in part_type:  part_type = part_type.left(part_type.find('_'))
    
    var stat_label = _stat_display.find_node('StatLabel*', true, false)
    var stat_final_value_label = _stat_display.find_node('StatFinalValueLabel*', true, false)
    
    for i in range(len(_boosts)):
        var boost_tag = _boosts[i]
        var boost_data_pack = controls.boosts[part_type][boost_tag]
        
        # Conditional used to ensure that updates are only applied to correct stat.
        if boost_data_pack['stat'] != stat_label.text.replace(' *', ''):  continue
        
        """ Gonna leave this for now.  Might come in handy later on. """
#        if i != 0 and _stat_display.find_node('BoostAdjustLabel%s*' % str(i), true, false).text == '':
#            i -= 1
        
        var boost_adjust_label = _stat_display.find_node('BoostAdjustLabel%s*' % str(i + 1), true, false)
        
        var new_value = boost_mod.getNewStatValue(
            float(stat_final_value_label.text.right(2)), boost_data_pack
        )
        var dif_value = abs(new_value - float(stat_final_value_label.text.right(2)))
        var symbol = boost_data_pack['type'].right(boost_data_pack['type'].find(' '))
        
        boost_adjust_label.text = '%s %s' % [symbol, str(dif_value)]
        stat_final_value_label.text = '= %s' % str(new_value)
    
    return _stat_display



func updateBoostAdjustNodes(_stat_display_box):
    
    var empty_boost_counter = 0
    for i in range(4):
        # If boost label node is empty (not used), hide boost container and ++ counter.
        if _stat_display_box.find_node('BoostAdjustLabel%s*' % str(i + 1)).text == '':
            _stat_display_box.find_node('BoostAdjustContainer%s*' % str(i + 1)).visible = false
            empty_boost_counter += 1
    # If all boosts are empty hide original value container.
    if empty_boost_counter == 4:
        _stat_display_box.find_node('StatOriginalValueContainer*').visible = false
    
    return _stat_display_box



func deleteStartingSeparators() -> void:
    
    for branch in tree.get_children():
        if branch.branch_type == 'separator':
            tree.remove_child(branch)
            branch.queue_free()
        else:
            break



####################################################################################################



func updateDetailsDisplay(_type, _branch, _selection):
    
    """ DIRTY """
    
#    print(PoolStringArray([_type, _branch, _selection]).join(' '))
    
    var details_text = ''
    match _type:
        'body', 'part':
            details_text += '[  PART DETAILS  ]\n  - - - - -  \n'
            var part_ref
            match _branch:
                'body':             part_ref = controls.bodies
                'generator':        part_ref = controls.generators
                'engines':          part_ref = controls.engines
                'shields':          part_ref = controls.shields
                'blaster':          part_ref = controls.blasters
                'missilelauncher':  part_ref = controls.launchers['Missile']
            details_text += "part type = %s\npart name = %s\n  - - - - -\n" % [_branch, _selection]
            for key in part_ref[_selection]:
                var value = part_ref[_selection][key]
                if typeof(value) == TYPE_ARRAY:  value = len(value)
                
                if typeof(value) == TYPE_DICTIONARY:
                    var value_list = []
                    for dkey in value:
                        var dvalue = value[dkey]
                        value_list += [ '%s:%s' % [dkey, dvalue] ]
                    value = '{' + PoolStringArray(value_list).join(', ') + '}'
                key = key.replace('_', ' ')
                details_text += "%s:  %s\n" % [key, value]
        'boost':
            details_text += '[  BOOST DETAILS  ]\n  - - - - -  \n'
#            details_text = PoolStringArray([_type, _branch, _selection]).join(' ')
            details_text += "part type = %s\nboost name = %s\n  - - - - -\n" % [_branch, _selection]
            for key in controls.boosts[_branch][_selection]:
                var value = controls.boosts[_branch][_selection][key]
                details_text += "%s:  %s\n" % [key, value]
        'stat':
#            details_text += "%s - %s - %s" % [_type, _branch, _selection]
            details_text += '[  STAT DETAILS  ]\n  - - - - -  \n'
            var stat_ref
            match _branch:
                'body':             stat_ref = stat_refs.bodies
                'generator':        stat_ref = stat_refs.generators
                'engines':          stat_ref = stat_refs.engines
                'shields':          stat_ref = stat_refs.shields
                'blaster':          stat_ref = stat_refs.blasters
                'missilelauncher':  stat_ref = stat_refs.launchers['Missile']
            details_text += stat_ref[_selection]
    
    details_label.text = details_text



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_StartMatchButton_pressed():
    
    if not minimumRequirementsMet():
        min_req_popup.popup_centered()
        return
    prepRigDataPackForPlay()
    controls.gameplay['vehicle_rig'] = rig_data_pack
    
    save_mod.saveDataReplace({'_last_used_vehicle_rig_': rig_data_pack})
    
    main.changeScene('res://Scenes/Functional/Gameplay.tscn')



####################################################################################################
                                                                         ###   RELOAD LAST RIG   ###
                                                                         ###########################

func _on_ReloadLastRigButton_pressed() -> void:
    
    last_rig_data_pack = save_mod.getSavedData(['_last_used_vehicle_rig_']).values()[0]

    loadRigBuilderFromLastRigDataPack()



func loadRigBuilderFromLastRigDataPack() -> void:
    
    # Load body selection box.
    findAndLoadPartSelectionBox(last_rig_data_pack['body']['part_tag'], 'body')
    
    # Load parts selection boxes.
    timer_1.start()
    
    # Load boosts selection boxes.
    timer_2.start()



func _on_Timer1_timeout() -> void:
    """ Load parts selection boxes from last_rig_data_pack. """
    
    for part_type in last_rig_data_pack.keys():
        if part_type == 'body':  continue
        findAndLoadPartSelectionBox(last_rig_data_pack[part_type]['part_tag'], part_type)
    


func _on_Timer2_timeout() -> void:
    """ Load boosts selection boxes from last_rig_data_pack. """
    
    for parent_part_type in last_rig_data_pack.keys():
        for i in range(len(last_rig_data_pack[parent_part_type]['boosts'])):
            var part_tag = last_rig_data_pack[parent_part_type]['boosts'][i]
            var boost_part_type = 'boost_%s' % (i + 1)
            findAndLoadPartSelectionBox(part_tag, boost_part_type, parent_part_type)



func findAndLoadPartSelectionBox(_part_tag:String, _branch_type:String, _parent_type:String='') -> void:
    
    var part_box_node = getSelectionBox(_branch_type, _parent_type)
    var part_selected_id = part_box_node.getPopUpIdFromText(_part_tag)
    part_box_node.pop_up.select(part_selected_id)
    part_box_node._on_PartSelectionPopUp_item_selected(part_selected_id)



func getSelectionBox(_branch_type:String, _parent_type:String='') -> Object:
    
    var selection_box_
    
    for branch in tree.get_children():
        
        # Get bool conditional vars.
        var same_branch_type = branch.branch_type == _branch_type
        var same_parent_type
        if _parent_type and branch.branch_parent:
            same_parent_type = branch.branch_parent.branch_type == _parent_type
        else:
            same_parent_type = true
        
        # Do condition check.
        if same_branch_type and same_parent_type:
            selection_box_ = branch
            break
    
    return selection_box_



####################################################################################################
                                                                             ###   ON DELETION   ###
                                                                             #######################

func queue_free():
    
    # Close temp mods.
    inv_mod.queue_free()
    boost_mod.queue_free()
    stat_refs.queue_free()
    save_mod.queue_free()
    
    resetAllInvUsed()
    
    main.scriptedScenePrint(name, 'exit')



func resetAllInvUsed():
    
    for part_type in controls.parts_inv.values() + controls.boosts_inv.values():
        for part in part_type.values():
            part['used'] = false



####################################################################################################
                                                                                ###   OBSOLETE   ###
                                                                                ####################

#    if _type == 'engines':
#
#
#    if _type == 'engines':
#        for ref in _refs['slot']:
#            var part_node = load('res://Scenes/Models/VehicleParts/%s/%s.tscn' % [part_refs['type'], part_data['part_tag']]).instance()
#
#            part_node = appendBoostModelsToPartModel(part_node, part_type, part_data)
#
#    var part_node = load('res://Scenes/Models/VehicleParts/%s/%s.tscn' % [part_refs['type'], part_data['part_tag']]).instance()
#
#    if part_type.begins_with('blaster'):
#        part_node = appendBoostModelsToPartModel(part_node, 'blaster', part_data)
#    elif part_type.begins_with('missilelauncher'):
#        part_node = appendBoostModelsToPartModel(part_node, 'missilelauncher', part_data)
#    else:
#        part_node = appendBoostModelsToPartModel(part_node, part_type, part_data)
#
#    var part_slot = body_model.find_node(part_refs['slot'], true, false)
#    part_slot.add_child(part_node)
#
#    return part_model_



#        if branch.branch_type == 'body':
#            rig_json_['body'] = {}
#            rig_json_['body']['part_tag'] = branch.pop_up_cur_selection_name
#        elif branch.branch_type == 'generator':
#            rig_json_['generator'] = {}
#            rig_json_['generator']['part_tag'] = branch.pop_up_cur_selection_name
#        elif branch.branch_type == 'engines':
#            rig_json_['engines'] = {}
#            rig_json_['engines']['part_tag'] = branch.pop_up_cur_selection_name
#        elif branch.branch_type == 'shields':
#            rig_json_['shields'] = {}
#            rig_json_['shields']['part_tag'] = branch.pop_up_cur_selection_name



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




























