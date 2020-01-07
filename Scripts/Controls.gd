
extends Node



var gameplay = {
    'arena': 'TestArena01',
    'vehicle': {
        'body': 'TestBody01',
        'engines': 'TestEngines02'
    }
}

var vehicle = {
    'friction': 0.0,
    'thrust': 0.5,
    'spin': 6.0,
    'thrust_damp': 0.05, # (perc)
    'spin_damp': 0.99, # (perc)
    'mouse_sensitivity': 0.002,
    'mouse_vert_damp': 0.80 # (perc)
}

var engines = {
    'TestEngines01': {'thrust': 0.5, 'max_speed': 0.0},
    'TestEngines02': {'thrust': 0.6, 'max_speed': 0.0}
}
