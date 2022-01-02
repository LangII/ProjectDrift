
extends Node

# Singletons.
onready var main = get_node('/root/Main')

export(Script) var save_data


####################################################################################################


func _ready():
    
    main.scriptedScenePrint(name, 'enter')



func saveDataReplace(_saving_data:Dictionary) -> void:
    """ When saving to a Text Resource (tres), every value in the resource gets saved.  So, to save
    a single value, you first have to get all previously saved values, and save them again, along
    with all the new data you're saving. """
    
    var new_save = save_data.new()
    var prev_saved_data = getSavedData()
    
    # load new save data into previously saved data
    for key in _saving_data.keys():
        var value = _saving_data[key]
        prev_saved_data[key] = value
    
    # now load all saved data into resource
    for key in prev_saved_data.keys():
        var value = prev_saved_data[key]
        new_save.set(key, value)
    
    ResourceSaver.save('res://Saves/save_data.tres', new_save)



func saveDataArrayAppend(_saving_data: Dictionary):
    pass



func getSavedData(_properties:Array=[]) -> Dictionary:
    
    var saved_data_dict_ = {}
    
    var saved_data_res = load('res://Saves/save_data.tres')
    var saved_properties = saved_data_res.get_property_list()
    
    # Get saved data for properties provided in params.
    if _properties:
        for property in _properties:
            saved_data_dict_[property] = saved_data_res.get(property)
    
    # If properties not provided in params, collect all saved data.
    else:
        for property in saved_properties:
            # Sort out built-in properties. 
            if not (property['name'].begins_with('_') and property['name'].ends_with('_')):  continue
            saved_data_dict_[property['name']] = saved_data_res.get(property['name'])
    
    if len(_properties) == 1:
        saved_data_dict_ = saved_data_dict_[_properties[0]]
    
    return saved_data_dict_


####################################################################################################


func queue_free():
    
    main.scriptedScenePrint(name, 'exit')
