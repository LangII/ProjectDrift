


extends HBoxContainer

# External node references.
onready var rig_builder = get_node('/root/Main').find_node('RigBuilder', true, false)
onready var inv_mod = get_node('/root/Main/InventoryMod')

# Internal node references.
onready var branch_image_1 = find_node('BranchImage1*')
onready var branch_image_2 = find_node('BranchImage2*')
onready var _content_container_ = find_node('ContentContainer*')
onready var type_label = _content_container_.find_node('PartTypeLabel*')
onready var pop_up = _content_container_.find_node('PartSelectionPopUp*')
onready var timer_1 = find_node('Timer1*')
onready var timer_2 = find_node('Timer2*')
onready var timer_3 = find_node('Timer3*')
onready var timer_4 = find_node('Timer4*')

# Resources.
onready var Branch_A = preload('res://Textures/tree_branch_A.png')
onready var Branch_l = preload('res://Textures/tree_branch_l.png')
onready var Branch_r = preload('res://Textures/tree_branch_r.png')
onready var Branch_T = preload('res://Textures/tree_branch_T.png')
onready var BranchSep = preload('res://Textures/tree_branch_sep.png')

# Attributes.
onready var branch_layer = ''
onready var branch_type = ''
onready var branch_parent = null
onready var branch_image_type = ''
onready var pop_up_selection_id = 0
onready var pop_up_selection_name = ''



####################################################################################################
                                                                                    ###   INIT   ###
                                                                                    ################

func init(_layer, _type):
    
    branch_layer = _layer
    branch_type = _type
    name = _type
    
    if _type == 'separator':
        branch_image_2.visible = false
        _content_container_.visible = false
        branch_image_1.texture = BranchSep
        rect_min_size = Vector2(0, 0)
    
    else:
        type_label.text = _type
        branch_parent = getPartParent()
        setFirstBodyBranchImgVis()
        setPopUpOptions()



####################################################################################################
                                                                              ###   INIT FUNCS   ###
                                                                              ######################

func getPartParent():
    
    var branch_parent_ = null
    
    var branches = get_parent().get_children()
    var pos_in_branches = get_position_in_parent()
    
    match branch_layer:
        'boost':
            var rev_loop_array = range(pos_in_branches)
            rev_loop_array.invert()
            for i in rev_loop_array:
                if not branches[i].branch_layer == 'boost':
                    branch_parent_ = branches[i]
                    break
        'part':
            branch_parent_ = branches[0]
        'body':
            branch_parent_ = self
    
    return branch_parent_



func setFirstBodyBranchImgVis():
    """
    When the rig builder menu is started, that initial body branch does not have it's branch image
    visibility correctly set.
    """
    
    if branch_layer == 'body':
        branch_image_1.visible = false
        branch_image_2.visible = false



func setPopUpOptions():
    
    var options = []
    match branch_layer:
        'body':
            options = inv_mod.bodies
        'part':
            if   branch_type == 'generator':                  options = inv_mod.generators
            elif branch_type == 'engines':                    options = inv_mod.engines
            elif branch_type == 'shields':                    options = inv_mod.shields
            elif branch_type.begins_with('blaster'):          options = inv_mod.blasters
            elif branch_type.begins_with('missilelauncher'):  options = inv_mod.missilelaunchers
        'boost':
            if   branch_parent.branch_type == 'body':                       options = inv_mod.boosts['body']
            elif branch_parent.branch_type == 'generator':                  options = inv_mod.boosts['generator']
            elif branch_parent.branch_type == 'engines':                    options = inv_mod.boosts['engines']
            elif branch_parent.branch_type == 'shields':                    options = inv_mod.boosts['shields']
            elif branch_parent.branch_type.begins_with('blaster'):          options = inv_mod.boosts['blaster']
            elif branch_parent.branch_type.begins_with('missilelauncher'):  options = inv_mod.boosts['missilelauncher']
    
    pop_up.add_item('')
    for option in options:  pop_up.add_item(option)



####################################################################################################
                                                                        ###   AFTER INIT FUNCS   ###
                                                                        ############################

"""
These funcs should not be called in init().  They should be called after all branches have been set.
"""



func setBranchImages():
    
    setBranchImageType()
    
    match branch_image_type:
        'body':
            branch_image_1.visible = false
            branch_image_2.visible = false
        'mid_part':
            branch_image_1.texture = Branch_T
            branch_image_2.visible = false
        'last_part':
            branch_image_1.texture = Branch_r
            branch_image_2.visible = false
        'mid_boost':
            branch_image_1.texture = Branch_l
            branch_image_2.texture = Branch_T
        'last_boost':
            branch_image_1.texture = Branch_l
            branch_image_2.texture = Branch_r
        'last_part_mid_boost':
            branch_image_1.texture = Branch_A
            branch_image_2.texture = Branch_T
        'last_part_last_boost':
            branch_image_1.texture = Branch_A
            branch_image_2.texture = Branch_r



func setBranchImageType():
    
    if branch_layer == 'body':
        branch_image_type = 'body'

    elif branch_layer == 'part':
        if isLastPart():  branch_image_type = 'last_part'
        else:  branch_image_type = 'mid_part'

    elif branch_layer == 'boost':
        if branch_parent.isLastPart():
            if isLastBoostInSet():  branch_image_type = 'last_part_last_boost'
            else:  branch_image_type = 'last_part_mid_boost'
        else:
            if isLastBoostInSet():  branch_image_type = 'last_boost'
            else:  branch_image_type = 'mid_boost'



func isLastPart():
    
    if not branch_layer in ['body', 'part']:
        print('trying to call PartSelectionBox.isLastPart()...  this branch is not a body nor part')
        get_tree().quit()
    
    if isLastBranch():  return true
    
    var branches = get_parent().get_children()
    var branches_after_self = branches.slice(get_position_in_parent() + 1, len(branches))
    
    for branch in branches_after_self:
        if branch.branch_layer == 'part':  return false
    return true



func isLastBoostInSet():
    
    if not branch_layer in ['boost']:
        print('trying to call PartSelectionBox.isLastBoostInSet()...  this branch is not a boost')
        get_tree().quit()
    
    if isLastBranch():  return true
    
    var branches = get_parent().get_children()
    var Branch_After_self = branches[get_position_in_parent() + 1]
    
    if Branch_After_self.branch_layer == 'boost':  return false
    else:  return true



func isLastBranch():
    
    return get_position_in_parent() == len(get_parent().get_children()) - 1



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_PartSelectionPopUp_item_selected(id):
    """
    I had to incorporate a delay in the tree menu updates.  This possibly has to do with threading
    but I'm not sure.  for whatever reason the deleteSeparators() and insertSeparators() likely
    overlap their procedures and delete some separators while leaving others.  This problem does
    not occur if there is a delay in their calls.
    """
    
    pop_up_selection_id = id
    pop_up_selection_name = pop_up.get_item_text(id)
    
    # Delays are not needed for 'boost' branch_layers.
    if branch_layer == 'boost':
        rig_builder.deleteSeparators()
        rig_builder.resetAllBranchImages()
        rig_builder.insertSeparators()
        rig_builder.buildRigModel()
    
    else:
        rig_builder.deleteSeparators()
        timer_1.start()
        timer_2.start()
        timer_3.start()
#        timer_4.start()
    



func _on_Timer1_timeout():
    
    match branch_layer:
        'body':  rig_builder.bodySelected(self, pop_up_selection_name)
        'part':  rig_builder.partSelected(self, pop_up_selection_name)

func _on_Timer2_timeout():
    rig_builder.resetAllBranchImages()

func _on_Timer3_timeout():
    rig_builder.insertSeparators()
    rig_builder.buildRigModel()

#func _on_Timer4_timeout():

####################################################################################################
                                                                                ###   OBSOLETE   ###
                                                                                ####################

#    if branch_layer == 'separator':
#        find_node('Branch2*', true, false).visible = false
#        find_node('PanelContainer', true, false).visible = false
##        find_node('Branch1*', true, false).texture = BranchSep
#        return
#
#    setBranchVisibilities()



#func setBranchVisibilities():
#
#    var branch_visibilities = []
#    match branch_layer:
#        'body':     branch_visibilities = [false, false]
##        'part':     branch_visibilities = [true, false]
##        'boost':    branch_visibilities = [true, true]
#
#    find_node('Branch1*', true, false).visible = branch_visibilities[0]
#    find_node('Branch2*', true, false).visible = branch_visibilities[1]







