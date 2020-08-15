
extends HBoxContainer

onready var rig_builder = get_node('/root/Main').find_node('RigBuilder', true, false)

onready var part_type = find_node('PartTypeLabel*').text
onready var stat = find_node('StatLabel*').text

func _on_StatLabel_mouse_entered():
    
    if '_' in part_type:  part_type = part_type.left(part_type.find('_'))
    rig_builder.updateDetailsDisplay('stat', part_type, stat.replace(' *', ''))
