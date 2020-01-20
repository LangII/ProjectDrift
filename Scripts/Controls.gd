
extends Node

var gameplay = {
    'arena': 'TestArena01',
    'targets': 'TestTarget01',
    'number_of_targets': 24, # (currently) 24 or less
    'vehicle': {
        'body': 'TestBody01',
        'generator': 'TestGenerator01',
        'engines': 'TestEngines01',
        'blaster': 'TestBlaster01'
    }
}

####################################################################################################

var default = {
    'vehicle': {
        'friction': 0.0,
        'thrust': 0.5,
        'spin': 6.0,
        'thrust_damp': 0.05, # (perc)
        'spin_damp': 0.99, # (perc)
        'max_speed': 20.0,
        'mouse_sensitivity': 0.002,
        'mouse_vert_damp': 0.80 # (perc)
    },
    'bolt': {
        'life_time': 3.0
    }
}

####################################################################################################

var body = {
    'TestBody01': {'health': 100}
}

var engines = {
    'TestEngines01': {'thrust': 0.45, 'max_speed': 36.0},
    'TestEngines02': {'thrust': 0.90, 'max_speed': 18.0}
}

var generators = {
    'TestGenerator01': {'rate': 0.10, 'replenish': 5.00},
    'TestGenerator02': {'rate': 0.50, 'replenish': 1.00}
}

var blasters = {
    'TestBlaster01': {
        'bolt_scene': 'TestBoltScene01', 'bolt_model': 'TestBoltModel01', 'energy': 8,
        'speed': 40, 'cool_down': 0.2, 'battery_capacity': 300.0
    },
    'TestBlaster02': {
        'bolt_scene': 'TestBoltScene01', 'bolt_model': 'TestBoltModel02', 'energy': 2,
        'speed': 20, 'cool_down': 0.2, 'battery_capacity': 80.0
    }
}

var targets = {
    'TestTarget01': {'health': 20, 'visibility_radius': 10, 'turret_speed': 0}
}
