
extends Node

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')

# Controls.
onready var vehicle_rig = controls.gameplay['vehicle']
onready var boosts = controls.boosts
onready var boost_model_refs = controls.boost_model_refs

# Scene loads.
onready var Red = preload('res://Scenes/Models/VehicleParts/Boosts/BoostRed.tscn')
onready var Purple = preload('res://Scenes/Models/VehicleParts/Boosts/BoostPurple.tscn')
onready var Orange = preload('res://Scenes/Models/VehicleParts/Boosts/BoostOrange.tscn')
onready var White = preload('res://Scenes/Models/VehicleParts/Boosts/BoostWhite.tscn')

var UNIT_TESTING = false
#var UNIT_TESTING = true



####################################################################################################
                                                                       ###   APPLY BOOST STATS   ###
                                                                       #############################

func updateControlsPartsStats():
    
    var vehicle_rig = controls.gameplay['vehicle']
    
    for value in vehicle_rig.values():
        
        """
        While looping through vehicle_rig, use part_tag to establish vehicle part, then call
        referenced part func with part_tag and boosts to apply boosts to vehicle.
        """
        
        if value['part_tag'].begins_with('Body'):
            updateStats('body', value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('Generator'):
            updateStats('generator', value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('Engines'):
            updateStats('engines', value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('Shields'):
            updateStats('shields', value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('Blaster'):
            updateStats('blaster', value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('MissileLauncher'):
            updateMissileLauncherPart(value['part_tag'], value['boosts'])



func updateStats(_part_type, _part_tag, _boosts):
    """ Update stat values from boost dictionary. """
    
    var part_type_ref
    match _part_type:
        'body':         part_type_ref = controls.bodies
        'generator':    part_type_ref = controls.generators
        'engines':      part_type_ref = controls.engines
        'shields':      part_type_ref = controls.shields
        'blaster':      part_type_ref = controls.blasters
    
    for boost in _boosts:
        if not boost:  continue
        var boost_dict = controls.boosts[_part_type][boost]
        var old_stat_value = part_type_ref[_part_tag][boost_dict['stat']]
        var new_stat_value = getNewStatValue(old_stat_value, boost_dict)
        part_type_ref[_part_tag][boost_dict['stat']] = new_stat_value
    
        if UNIT_TESTING:
            printStatUpdate(_part_tag, boost, boost_dict, old_stat_value, new_stat_value)



func getNewStatValue(_old_value, _boost):
    """
    Get type from _boost, extract 'incr' or 'perc' and '+' or '-' to determine stat change.  With
    logic of stat change change _old_value into _new_value with 'value'.
    """
    
    var new_value_
    
    if _boost['type'].begins_with('incr') and _boost['type'].ends_with('+'):
        new_value_ = _old_value + _boost['value']
    elif _boost['type'].begins_with('incr') and _boost['type'].ends_with('-'):
        new_value_ = _old_value - _boost['value']
    elif _boost['type'].begins_with('perc') and _boost['type'].ends_with('+'):
        new_value_ = _old_value + (_old_value * _boost['value'])
    elif _boost['type'].begins_with('perc') and _boost['type'].ends_with('-'):
        new_value_ = _old_value - (_old_value * _boost['value'])
    
    # Because magazines are measured as integers, this rounds all magazine calculations up.
    if _boost['stat'] == 'magazine_capacity':  new_value_ = int(new_value_) + 1
    
    return new_value_



func updateMissileLauncherPart(_part_tag, _boosts):
    """
    Because of the dictionary value in MissileLaunchers, their boosts have to be processed
    differently.  
    """
    
    for boost in _boosts:
        
        if not boost:  continue
        
        var boost_dict = controls.boosts['missilelauncher'][boost]

        # Handle odd boost stats of 'dmg_rad' and 'dmg_val'.
        if boost_dict['stat'] == 'dmg_rad' or boost_dict['stat'] == 'dmg_val':
            var old_dmg_dict = controls.launchers['Missile'][_part_tag]['damage']
            var new_dmg_dict = getNewDamageDict(old_dmg_dict, boost_dict)
            controls.launchers['Missile'][_part_tag]['damage'] = new_dmg_dict
            
            if UNIT_TESTING:
                printStatUpdate(_part_tag, boost, boost_dict, old_dmg_dict, new_dmg_dict)
        
        # Process other stats as normal.
        else:
            var old_stat_value = controls.launchers['Missile'][_part_tag][boost_dict['stat']]
            var new_stat_value = getNewStatValue(old_stat_value, boost_dict)
            controls.launchers['Missile'][_part_tag][boost_dict['stat']] = new_stat_value
        
            if UNIT_TESTING:
                printStatUpdate(_part_tag, boost, boost_dict, old_stat_value, new_stat_value)



func getNewDamageDict(_old_dict, _boost):
    """ Call getNewStatValue() on each item in missile's 'damage' value. """
    
    var new_dict_ = {}
    
    for key in _old_dict:
        var value = _old_dict[key]
        match _boost['stat']:
            'dmg_rad':  key = getNewStatValue(key, _boost)
            'dmg_val':  value = getNewStatValue(value, _boost)
        new_dict_[key] = value
    
    return new_dict_



####################################################################################################
                                                                      ###   APPLY BOOST MODELS   ###
                                                                      ##############################

func instanceBoostModels():
    """
    Loop through vehicle_rig applying boosts from boost_tags to parts from part_tags designated with
    part_type.
    """
    
    var body = main.find_node(vehicle_rig['body']['part_tag'], true, false)
    
    for part_type in vehicle_rig:
        
        var part_tag = vehicle_rig[part_type]['part_tag']
        var boost_tags = vehicle_rig[part_type]['boosts']
        var boost_slots
        
        # Check for empty parts.
        if absentPart(part_tag):  continue
        
        # Apply boosts to body parts.
        if part_type == 'body':
            boost_slots = body.get_node('Boosts*')
        
        # Apply boosts to engines parts.
        elif part_type == 'engines':
            # Loop through engines_suffixes to apply boosts to each engine model.
            var engines_suffixes = ['Fr', 'Br', 'Bl', 'Fl']
            for suffix in engines_suffixes:
                var engine_pos = body.find_node('Engine%sPos*' % suffix, true, false)
                boost_slots = engine_pos.find_node(part_tag, true, false).get_node('Boosts*')
                addChildModelToSlot(boost_slots, part_type, part_tag, boost_tags)
            # Because addChildModelToSlot() is called for each engine model, must continue to not
            # call addChildModelToSlot() again.
            continue
        
        # Apply boosts to blaster parts and launcher parts.
        elif '_' in part_type:
            # Get part_counter from part_type and update part_type.
            var part_counter = part_type.right(part_type.find('_') + 1)
            part_type = part_type.left(part_type.find('_'))
            var part_node
            # Get part_node for blaster or launcher and set boost_slots.
            if part_type.begins_with('blaster'):
                part_node = body.find_node('Blaster%sPos*' % part_counter, true, false)
            elif part_type.begins_with('missilelauncher'):
                part_node = body.find_node('MissileLauncher%sPos*' % part_counter, true, false)
            boost_slots = part_node.find_node(part_tag, true, false).find_node('Boosts*', true, false)
        
        # Apply boosts for shields parts and generator parts. 
        else:
            boost_slots = body.find_node(part_tag, true, false).get_node('Boosts*')
        
        addChildModelToSlot(boost_slots, part_type, part_tag, boost_tags)



func absentPart(_part_tag):
    """ Return true if no part is equipped, else false.  Needed for instanceBoostModels(). """
    
    if not _part_tag:
        return true
    elif 'Launcher' in _part_tag:
        if not _part_tag.right(_part_tag.find('Launcher') + len('Launcher')):  return true
    else:
        return false



func getBoostModelScene(_part_type, _stat):
    """
    Combine _part_type and _stat into reference for boost_model_refs to get pointer to corect
    boost_model_.
    """
    
    var boost_model_
    
    # Reset _part_type to account for _ in blaster and launcher types.
    if '_' in _part_type:
        _part_type = _part_type.left(_part_type.find('_'))
    
    # Get boost_model_ as string ref.
    for model in boost_model_refs:
        var pointers = boost_model_refs[model]
        if _part_type + ' ' + _stat in pointers:
            boost_model_ = model
            break
    
    # Convert boost_model_ string ref into boost_model_ as preloaded scene.
    match boost_model_:
        'red':      boost_model_ = Red
        'purple':   boost_model_ = Purple
        'orange':   boost_model_ = Orange
        'white':    boost_model_ = White
    
    return boost_model_



func addChildModelToSlot(_boost_slots, _part_type, _part_tag, _boost_tags):
    """ Repeatable application of boosts.  Needed for instanceBoostModels(). """
    
    for i in range(len(_boost_tags)):
        if not _boost_tags[i]:  continue
        var stat = boosts[_part_type][_boost_tags[i]]['stat']
        var boost_scene = getBoostModelScene(_part_type, stat)
        var boost_slot = _boost_slots.get_node('Boost%sPos*' % str(i + 1))
        boost_slot.add_child(boost_scene.instance())
        
        if UNIT_TESTING:
            printModelUpdate(
                boost_slot.get_parent().get_parent().name, _boost_tags[i], stat, boost_scene
            )



####################################################################################################
                                                                            ###   UNIT TESTING   ###
                                                                            ########################

var print_stat_counter = 0
func printStatUpdate(_part_tag, _boost_tag, _boost, _old_value, _new_value):
    
    print_stat_counter += 1
    
    var part_tag_pad = 32
    var boost_tag_pad = 26
    var boost_pad = 64
    var old_value_pad = 38
    var new_value_pad = 38
    
    var div_str_form = [
        '-'.repeat(part_tag_pad), '-'.repeat(boost_tag_pad), '-'.repeat(boost_pad),
        '-'.repeat(old_value_pad), '-'.repeat(new_value_pad)
    ]
    var div_line = "+-%s-+-%s-+-%s-+-%s-+-%s-+" % div_str_form
    
    if print_stat_counter == 1:  print("\n", div_line)
    
    if typeof(_old_value) == TYPE_DICTIONARY:
        var str_form = [
            part_tag_pad, _part_tag, boost_tag_pad, _boost_tag, boost_pad, _boost, old_value_pad,
            String(_old_value), new_value_pad, String(_new_value)
        ]
        print("| %-*s | %-*s | %-*s | %*s | %*s |" % str_form)
        print(div_line)
        return
    
    var str_form = [
        part_tag_pad, _part_tag, boost_tag_pad, _boost_tag, boost_pad, _boost, old_value_pad,
        float(_old_value), new_value_pad, float(_new_value)
    ]
    print("| %-*s | %-*s | %-*s | %*.4f | %*.4f |" % str_form)
    print(div_line)



var print_model_counter = 0
var engines_counter = 0
func printModelUpdate(_part_tag, _boost_tag, _stat, _boost_model):
    
    print_model_counter += 1
    
    if _part_tag.begins_with('Engines'):
        engines_counter += 1
        if engines_counter > 1:  return
    
    var part_tag_pad = 32
    var boost_tag_pad = 26
    var stat_pad = 18
    var boost_model_pad = 16
    
    var model_name = _boost_model.resource_path.right(_boost_model.resource_path.rfind('/') + 1)
    
    var div_str_form = [
        '-'.repeat(part_tag_pad), '-'.repeat(boost_tag_pad), '-'.repeat(stat_pad),
        '-'.repeat(boost_model_pad)
    ]
    var div_line = "+-%s-+-%s-+-%s-+-%s-+" % div_str_form
    
    if print_model_counter == 1:  print("\n", div_line)
    
    var str_form = [
        part_tag_pad, _part_tag, boost_tag_pad, _boost_tag, stat_pad, _stat, boost_model_pad,
        model_name
    ]
    print("| %-*s | %-*s | %-*s | %-*s |" % str_form)
    print(div_line)












