
extends Node

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')

onready var vehicle_rig = controls.gameplay['vehicle']

onready var boosts = controls.boosts
onready var boost_model_refs = controls.boost_model_refs

onready var red = preload('res://Scenes/Models/VehicleParts/Boosts/BoostRed.tscn')
onready var purple = preload('res://Scenes/Models/VehicleParts/Boosts/BoostPurple.tscn')
onready var orange = preload('res://Scenes/Models/VehicleParts/Boosts/BoostOrange.tscn')
onready var white = preload('res://Scenes/Models/VehicleParts/Boosts/BoostWhite.tscn')



func updateControlsPartsStats():
    
    var vehicle_build = controls.gameplay['vehicle']
    
    for key in vehicle_build:
        var value = vehicle_build[key]
        
        if value['part_tag'].begins_with('Body'):
            updateBodyPart(value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('Generator'):
            updateGeneratorPart(value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('Engines'):
            updateEnginesPart(value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('Shields'):
            updateShieldsPart(value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('Blaster'):
            updateBlasterPart(value['part_tag'], value['boosts'])
        
        elif value['part_tag'].begins_with('MissileLauncher'):
            updateMissileLauncherPart(value['part_tag'], value['boosts'])



func updateBodyPart(_part_tag, _boosts):
    
    for boost in _boosts:
        boost = controls.boosts['body'][boost]
        var old_stat_value = controls.bodies[_part_tag][boost['stat']]
        var new_stat_value = getNewStatValue(old_stat_value, boost)
        controls.bodies[_part_tag][boost['stat']] = new_stat_value

func updateGeneratorPart(_part_tag, _boosts):
    
    for boost in _boosts:
        boost = controls.boosts['generator'][boost]
        var old_stat_value = controls.generators[_part_tag][boost['stat']]
        var new_stat_value = getNewStatValue(old_stat_value, boost)
        controls.generators[_part_tag][boost['stat']] = new_stat_value

func updateEnginesPart(_part_tag, _boosts):
    
    for boost in _boosts:
        boost = controls.boosts['engines'][boost]
        var old_stat_value = controls.engines[_part_tag][boost['stat']]
        var new_stat_value = getNewStatValue(old_stat_value, boost)
        controls.engines[_part_tag][boost['stat']] = new_stat_value

func updateShieldsPart(_part_tag, _boosts):
    
    for boost in _boosts:
        boost = controls.boosts['shields'][boost]
        var old_stat_value = controls.shields[_part_tag][boost['stat']]
        var new_stat_value = getNewStatValue(old_stat_value, boost)
        controls.shields[_part_tag][boost['stat']] = new_stat_value

func updateBlasterPart(_part_tag, _boosts):
    
    for boost in _boosts:
        boost = controls.boosts['blaster'][boost]
        var old_stat_value = controls.blasters[_part_tag][boost['stat']]
        var new_stat_value = getNewStatValue(old_stat_value, boost)
        controls.blasters[_part_tag][boost['stat']] = new_stat_value



func getNewStatValue(_old_value, _boost):
    
    var new_value_
    
    if _boost['type'].begins_with('incr') and _boost['type'].ends_with('+'):
        new_value_ = _old_value + _boost['value']
    elif _boost['type'].begins_with('incr') and _boost['type'].ends_with('-'):
        new_value_ = _old_value - _boost['value']
    elif _boost['type'].begins_with('perc') and _boost['type'].ends_with('+'):
        new_value_ = _old_value + (_old_value * _boost['value'])
    elif _boost['type'].begins_with('perc') and _boost['type'].ends_with('-'):
        new_value_ = _old_value - (_old_value * _boost['value'])
    
    if _boost['stat'] == 'magazine_capacity':  new_value_ = int(new_value_) + 1
    
    return new_value_



func updateMissileLauncherPart(_part_tag, _boosts):
    
    for boost in _boosts:
        
        boost = controls.boosts['missilelauncher'][boost]

        if boost['stat'] == 'dmg_rad' or boost['stat'] == 'dmg_val':
            var old_dmg_dict = controls.launchers['Missile'][_part_tag]['damage']
            var new_dmg_dict = getNewDamageDict(old_dmg_dict, boost)
            controls.launchers['Missile'][_part_tag]['damage'] = new_dmg_dict

        else:
            var old_stat_value = controls.launchers['Missile'][_part_tag][boost['stat']]
            var new_stat_value = getNewStatValue(old_stat_value, boost)
            controls.launchers['Missile'][_part_tag][boost['stat']] = new_stat_value



func getNewDamageDict(_old_dict, _boost):
    
    var new_dict_ = {}
    
    for key in _old_dict:
        var value = _old_dict[key]
        
        if _boost['stat'] == 'dmg_rad':  key = getNewStatValue(key, _boost)
        elif _boost['stat'] == 'dmg_val':  value = getNewStatValue(value, _boost)
        
        new_dict_[key] = value
    
    return new_dict_



func getBoostModel(_part_type, _stat):
    
    var boost_model_
    
    if '_' in _part_type:
        _part_type = _part_type.left(_part_type.find('_'))
    
#    print(_part_type + ' ' + _stat)
    
    for model in boost_model_refs:
        var pointers = boost_model_refs[model]
        if _part_type + ' ' + _stat in pointers:  boost_model_ = model
        
#    print(boost_model_)
    match boost_model_:
        'red':  boost_model_ = red
        'purple':  boost_model_ = purple
        'orange':  boost_model_ = orange
        'white':  boost_model_ = white
    
    
    return boost_model_



func instanceBoostModels():
    
#    print(vehicle_)
    var body = main.find_node(vehicle_rig['body']['part_tag'], true, false)
    
    for part_type in vehicle_rig:
        
        var part_tag = vehicle_rig[part_type]['part_tag']
        var boost_tags = vehicle_rig[part_type]['boosts']
        
        if not part_tag:  continue
        
        if 'Launcher' in part_tag:
            if not part_tag.right(part_tag.find('Launcher') + len('Launcher')):  continue

        if part_type == 'body':
            var boost_slots = body.get_node('Boosts*')
            for i in range(len(boost_tags)):
                
                var stat = boosts[part_type][boost_tags[i]]['stat']
                var boost_model = getBoostModel(part_type, stat)
                
                var boost_slot = boost_slots.get_node('Boost%sPos*' % str(i + 1))
                
                boost_slot.add_child(boost_model.instance())
            
            continue
        
        
        
        elif part_type == 'engines':
#            var boost_slots = body.get_node('Boosts*')
            for i in range(len(boost_tags)):
                
                var stat = boosts[part_type][boost_tags[i]]['stat']
                var boost_model = getBoostModel(part_type, stat)
                
                var engines_suffixes = ['Fr', 'Br', 'Bl', 'Fl']
                for suffix in engines_suffixes:
    #                var engine_pos = _parts_.find_node('Engine%sPos*' % suffix)
    #                engine_pos.add_child(Engines.instance())
                    var engine_pos = body.find_node('Engine%sPos*' % suffix, true, false)
                    var boost_slots = engine_pos.find_node(part_tag, true, false).get_node('Boosts*')
                    var boost_slot = boost_slots.get_node('Boost%sPos*' % str(i + 1))
                    boost_slot.add_child(boost_model.instance())
        
        
        
        elif '_' in part_type:
            var part_counter = part_type.right(part_type.find('_') + 1)
#            print(part_counter)
            part_type = part_type.left(part_type.find('_'))
            
            if part_type.begins_with('blaster'):
                var boost_slots = body.find_node('Blaster%sPos*' % part_counter, true, false).find_node(part_tag, true, false).find_node('Boosts*', true, false)
                for i in range(len(boost_tags)):
                    
                    var stat = boosts[part_type][boost_tags[i]]['stat']
                    var boost_model = getBoostModel(part_type, stat)
                    
                    var boost_slot = boost_slots.get_node('Boost%sPos*' % str(i + 1))
                    
                    boost_slot.add_child(boost_model.instance())
            
            elif part_type.begins_with('missilelauncher'):
                var boost_slots = body.find_node('MissileLauncher%sPos*' % part_counter, true, false).find_node(part_tag, true, false).find_node('Boosts*', true, false)
                for i in range(len(boost_tags)):
                    
                    var stat = boosts[part_type][boost_tags[i]]['stat']
                    var boost_model = getBoostModel(part_type, stat)
                    
                    var boost_slot = boost_slots.get_node('Boost%sPos*' % str(i + 1))
                    
                    boost_slot.add_child(boost_model.instance())
        
        
        
        else:
            var boost_slots = body.find_node(part_tag, true, false).get_node('Boosts*')
            for i in range(len(boost_tags)):
                
                var stat = boosts[part_type][boost_tags[i]]['stat']
                var boost_model = getBoostModel(part_type, stat)
                
                var boost_slot = boost_slots.get_node('Boost%sPos*' % str(i + 1))
                
                boost_slot.add_child(boost_model.instance())














