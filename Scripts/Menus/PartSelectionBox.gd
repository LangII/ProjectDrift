


extends HBoxContainer

onready var rig_builder = get_node('/root/Main').find_node('RigBuilder', true, false)
onready var inv_mod = get_node('/root/Main/InventoryMod')

# Node references.
onready var branch_1 = find_node('Branch1*')
onready var branch_2 = find_node('Branch2*')
onready var _content_container_ = find_node('ContentContainer*')
onready var type_label = _content_container_.find_node('PartTypeLabel*')
onready var pop_up = _content_container_.find_node('PartSelectionPopUp*')
onready var timer_1 = find_node('Timer1*')
onready var timer_2 = find_node('Timer2*')
onready var timer_3 = find_node('Timer3*')

# Class attributes.
onready var part_layer = ''
onready var part_type = ''
onready var part_parent = null

# Working vars.
var pop_up_selection = 0



####################################################################################################



func init(_layer, _type):
    
    part_layer = _layer
    part_type = _type
    name = _type
    type_label.text = _type
    part_parent = getPartParent()
    
    setFirstBodyBranchImgVis()
    
    setPopUpOptions()



####################################################################################################



func getPartParent():
    
    var part_parent_ = null
    
    var branches = get_parent().get_children()
    var pos_in_branches = get_position_in_parent()
    
    match part_layer:
        'boost':
            var rev_loop_array = range(pos_in_branches)
            rev_loop_array.invert()
            for i in rev_loop_array:
                if not branches[i].part_layer == 'boost':
                    part_parent_ = branches[i]
                    break
        'part':
            part_parent_ = branches[0]
        'body':
            part_parent_ = 'is parent'
    
    return part_parent_



func setFirstBodyBranchImgVis():
    """
    When the rig builder menu is started, that initial body box does not have it's branch image
    visibility correctly set.
    """
    
    if part_layer == 'body':
        branch_1.visible = false
        branch_2.visible = false



func setPopUpOptions():
    
    var options = []
    match part_layer:
        'body':
            options = inv_mod.bodies
        'part':
            if   part_type == 'generator':                  options = inv_mod.generators
            elif part_type == 'engines':                    options = inv_mod.engines
            elif part_type == 'shields':                    options = inv_mod.shields
            elif part_type.begins_with('blaster'):          options = inv_mod.blasters
            elif part_type.begins_with('missilelauncher'):  options = inv_mod.missilelaunchers
        'boost':
            if   part_parent.part_type == 'body':                       options = inv_mod.boosts['body']
            elif part_parent.part_type == 'generator':                  options = inv_mod.boosts['generator']
            elif part_parent.part_type == 'engines':                    options = inv_mod.boosts['engines']
            elif part_parent.part_type == 'shields':                    options = inv_mod.boosts['shields']
            elif part_parent.part_type.begins_with('blaster'):          options = inv_mod.boosts['blaster']
            elif part_parent.part_type.begins_with('missilelauncher'):  options = inv_mod.boosts['missilelauncher']
    
    pop_up.add_item('')
    for option in options:  pop_up.add_item(option)



####################################################################################################



func _on_PartSelectionPopUp_item_selected(id):
    """
    I had to incorporate a delay in the tree menu updates.  This possibly has to do with threading
    but I'm not sure.  for whatever reason the deleteSeparators() and insertSeparators() likely
    overlap their procedures and delete some separators while leaving others.  This problem does
    not occur if there is a delay in their calls.
    """
    
    pop_up_selection = pop_up.get_item_text(id)
    
    # Delays are not needed for 'boost' part_layers.
    if part_layer == 'boost':
        rig_builder.deleteSeparators()
        rig_builder.resetAllBranchImages()
        rig_builder.insertSeparators()
    
    else:
        rig_builder.deleteSeparators()
        timer_1.start()
        timer_2.start()
        timer_3.start()



func _on_Timer1_timeout():
    
    match part_layer:
        'body':  rig_builder.bodySelected(self, pop_up_selection)
        'part':  rig_builder.partSelected(self, pop_up_selection)

func _on_Timer2_timeout():
    
    rig_builder.resetAllBranchImages()

func _on_Timer3_timeout():

    rig_builder.insertSeparators()



####################################################################################################



#    if part_layer == 'separator':
#        find_node('Branch2*', true, false).visible = false
#        find_node('PanelContainer', true, false).visible = false
##        find_node('Branch1*', true, false).texture = branch_sep
#        return
    
#    setBranchVisibilities()



#func setBranchVisibilities():
#
#    var branch_visibilities = []
#    match part_layer:
#        'body':     branch_visibilities = [false, false]
##        'part':     branch_visibilities = [true, false]
##        'boost':    branch_visibilities = [true, true]
#
#    find_node('Branch1*', true, false).visible = branch_visibilities[0]
#    find_node('Branch2*', true, false).visible = branch_visibilities[1]





