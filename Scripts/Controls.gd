
extends Node

####################################################################################################

var gameplay = {
    'arena': 'TestArena01',
    'targets': 'TestTarget01',
    'number_of_targets': 0, # (currently) 24 or less
    'vehicle': {
        'body': 'TestBody01',
        'generator': 'TestGenerator01',
        'engines': 'TestEngines01',
        'blaster': 'TestBlaster01',
        'shields': 'TestShields01',
    }
}

####################################################################################################

var global = {
    'vehicle': {
        'friction': 0.0,
        'spin': 6.0,
        'thrust_damp': 0.05, # (perc)
        'spin_damp': 0.99, # (perc)
        'mouse_sensitivity': 0.002,
        'mouse_vert_damp': 0.80 # (perc)
    },
    'bolt': {
        'life_time': 3.0
    }
}

####################################################################################################

var body = {
    'TestBody01': {
        'health': 100.0,
        'armor': 0.05, # (perc) ... NEED TO IMPLEMENT
    },
}

var engines = {
    'TestEngines01': {
        'thrust': 0.60,
        'max_speed': 36.0,
    },
    'TestEngines02': {
        'thrust': 0.90,
        'max_speed': 18.0,
    },
}

var generators = {
    'TestGenerator01': {
        'rate': 0.10,
        'replenish': 5.00,
    },
    'TestGenerator02': {
        'rate': 0.50,
        'replenish': 1.00,
    },
}

var blasters = {
    'TestBlaster01': {
        'bolt_scene': 'TestVehicleBoltScene01',
        'bolt_model': 'TestBoltModel01',
        'energy': 8.0,
        'speed': 40.0,
        'cool_down': 0.2,
        'battery_capacity': 300.0,
    },
    'TestBlaster02': {
        'bolt_scene': 'TestVehicleBoltScene01',
        'bolt_model': 'TestBoltModel02',
        'energy': 2.0,
        'speed': 20.0,
        'cool_down': 0.2,
        'battery_capacity': 80.0,
    },
}

var shields = {
    'TestShields01': {
        'density': 0.02,
        'battery_capacity': 50.0,
    },
    'TestShields02': {
        'density': 0.01,
        'battery_capacity': 150.0,
    },
}

var targets = {
    'TestTarget01': {
        'bolt_scene': 'TestTargetBoltScene01',
        'bolt_model': 'TestBoltModel03',
        'health': 20.0,
        'visibility_radius': 40.0,
        'targeting_speed': 0.02,
        'energy': 5.0,
        'cool_down': 0.6,
        'speed': 30.0,
    },
}
