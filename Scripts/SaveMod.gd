
extends Node

export(Script) var save_data


####################################################################################################


func saveDataReplace(_property_value:Dictionary) -> void:
    
    var new_save = save_data.new()
    for property in _property_value.keys():
        var value = _property_value[property]
        new_save.set(property, value)
    
    ResourceSaver.save('res://Saves/save_data.tres', new_save)



func saveDataArrayAppend(_property_value: Dictionary):
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
    
    return saved_data_dict_
