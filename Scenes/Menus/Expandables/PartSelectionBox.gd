


extends HBoxContainer

onready var rig_builder = get_node('/root/Main').find_node('RigBuilder', true, false)
onready var inv_mod = get_node('/root/Main/InventoryMod')

onready var type_label = find_node('PartTypeLabel*', true, false)
onready var pop_up = find_node('PartSelectionPopUp*', true, false)

onready var node_layer = ''
onready var part_type = ''



####################################################################################################



func init(_layer, _type):
    
    node_layer = _layer
    part_type = _type
    name = _type
    type_label.text = _type
    
    setBranchVisibilities()
    setPopUpOptions()



####################################################################################################



func setBranchVisibilities():
    
    var branch_visibilities = []
    match node_layer:
        'body':     branch_visibilities = [false, false]
        'part':     branch_visibilities = [true, false]
        'boost':    branch_visibilities = [true, true]
    
    find_node('Branch1*', true, false).visible = branch_visibilities[0]
    find_node('Branch2*', true, false).visible = branch_visibilities[1]



func setPopUpOptions():
    
    var options
    match node_layer:
        
        'body', 'part':
            if part_type.begins_with('body'):               options = inv_mod.bodies
            elif part_type.begins_with('generator'):        options = inv_mod.generators
            elif part_type.begins_with('engines'):          options = inv_mod.engines
            elif part_type.begins_with('shields'):          options = inv_mod.shields
            elif part_type.begins_with('blaster'):          options = inv_mod.blasters
            elif part_type.begins_with('missilelauncher'):  options = inv_mod.missilelaunchers
        
        'boost':
            
            var part_parent = getPartParent()
#            print("part_parent = ", part_parent)
            
            if part_parent.begins_with('body'):                 options = inv_mod.boosts['body']
            elif part_parent.begins_with('generator'):          options = inv_mod.boosts['generator']
            elif part_parent.begins_with('engines'):            options = inv_mod.boosts['engines']
            elif part_parent.begins_with('shields'):            options = inv_mod.boosts['shields']
            elif part_parent.begins_with('blaster'):            options = inv_mod.boosts['blaster']
            elif part_parent.begins_with('missilelauncher'):    options = inv_mod.boosts['missilelauncher']
    
    pop_up.add_item('')
    for option in options:  pop_up.add_item(option)



func getPartParent():
    
    var tree = get_parent()
    var branches = tree.get_children()
    var pos_in_branches = get_position_in_parent()
    var looping_array = range(pos_in_branches)
    looping_array.invert()
    
    for i in looping_array:
        if not branches[i].part_type.begins_with('boost'):  return branches[i].part_type
    
    return "not good"



####################################################################################################



func _on_PartSelectionPopUp_item_selected(id):
    
    var selection = pop_up.get_item_text(id)

    match node_layer:
        'body':  rig_builder.bodySelected(self, selection)
        'part':  rig_builder.partSelected(self, selection)

#    print("\n")
#    print("part_type = ", part_type)
#    print("selection = ", selection)











