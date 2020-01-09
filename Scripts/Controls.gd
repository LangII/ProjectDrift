
extends Node



var gameplay = {
    'arena': 'TestArena01',
    'vehicle': {
        'body': 'TestBody01',
        'engines': 'TestEngines01',
        'blaster': 'TestBlaster01'
    }
}

var vehicle = {
    'friction': 0.0,
    'thrust': 0.5,
    'spin': 6.0,
    'thrust_damp': 0.05, # (perc)
    'spin_damp': 0.99, # (perc)
    'max_speed': 20.0,
    'mouse_sensitivity': 0.002,
    'mouse_vert_damp': 0.80 # (perc)
}

####################################################################################################

var engines = {
    'TestEngines01': {
        'thrust': 0.45, 'max_speed': 36.0
    },
    'TestEngines02': {
        'thrust': 0.90, 'max_speed': 18.0
    }
}

var blasters = {
    'TestBlaster01': {
        'bolt_scene': 'TestBoltScene01', 'bolt_model': 'TestBoltModel01', 'damage': 10, 'speed': 40,
        'delay': 3.0
    }
}
