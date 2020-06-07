
extends Node

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')



func updateControlsPartsStats():
    
    var vehicle_build = controls.gameplay['vehicle']
    
    for key in vehicle_build:
        var value = vehicle_build[key]
        
        if value['part_tag'].begins_with('Body'):
            updateBodyPart(value['part_tag'], value['boosts'])
        
        if value['part_tag'].begins_with('Generator'):
            updateGeneratorPart(value['part_tag'], value['boosts'])
        
        if value['part_tag'].begins_with('Engines'):
            updateEnginesPart(value['part_tag'], value['boosts'])
        
        if value['part_tag'].begins_with('Shields'):
            updateShieldsPart(value['part_tag'], value['boosts'])
        
        if value['part_tag'].begins_with('Blaster'):
            updateBlasterPart(value['part_tag'], value['boosts'])
        
        if value['part_tag'].begins_with('MissileLauncher'):
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
        
        print("")
        print(controls.launchers['Missile'][_part_tag])
        
        boost = controls.boosts['missile_launcher'][boost]

        if boost['stat'] == 'dmg_rad' or boost['stat'] == 'dmg_val':
            var old_dmg_dict = controls.launchers['Missile'][_part_tag]['damage']
            var new_dmg_dict = getNewDamageDict(old_dmg_dict, boost)
            controls.launchers['Missile'][_part_tag]['damage'] = new_dmg_dict

        else:
            var old_stat_value = controls.launchers['Missile'][_part_tag][boost['stat']]
            var new_stat_value = getNewStatValue(old_stat_value, boost)
            controls.launchers['Missile'][_part_tag][boost['stat']] = new_stat_value

        print(controls.launchers['Missile'][_part_tag])



func getNewDamageDict(_old_dict, _boost):
    
    var new_dict_ = {}
    
    for key in _old_dict:
        var value = _old_dict[key]
        
        if _boost['stat'] == 'dmg_rad':  key = getNewStatValue(key, _boost)
        elif _boost['stat'] == 'dmg_val':  value = getNewStatValue(value, _boost)
        
        new_dict_[key] = value
    
    return new_dict_
















