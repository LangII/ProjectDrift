
"""

Controls.gd

"""

extends Node



####################################################################################################
                                                                                ###   GAMEPLAY   ###
                                                                                ####################

var gameplay = {
    # 'arena': 'TestArena01',
    'arena': 'Bunny',
    'targets': 'TestTarget01',
    'number_of_targets': 8, # (currently) 64 or less
    'vehicle': {
        'body': 'TestBody01',
        'generator': 'TestGenerator02',
        'engines': 'TestEngines02',
        'blaster': 'TestBlaster02',
        'shields': 'TestShields02',
    },
}



####################################################################################################
                                                                                 ###   GLOBALS   ###
                                                                                 ###################

var global = {
    'vehicle': {
        'gravity_force': 3.00,
        'friction': 0.00,
        'spin': 24.00,
        'linear_damp': 0.70, # (perc)
        'spin_damp': 0.98, # (perc)
        'mouse_sensitivity': 0.004,
        'mouse_vert_damp': 0.50, # (perc)
    },
    'target': {
        'angle_to_shoot': 0.04,
        'at_rest_tolerance': 1.60,
    },
    'bolt': {
        'life_time': 3.00,
    },
}



####################################################################################################
                                                                           ###   VEHICLE PARTS   ###
                                                                           #########################

var body = {
    'TestBody01': {
        'health': 20.00,
        'armor': 0.05,
    },
}

var engines = {
    'TestEngines01': {
        'thrust': 16.00,
        'max_speed': 18.00,
    },
    'TestEngines02': {
        'thrust': 22.00,
        'max_speed': 12.00,
    },
}

var generators = {
    'TestGenerator01': {
        'rate': 0.80,
        'replenish': 8.00,
    },
    'TestGenerator02': {
        'rate': 0.40,
        'replenish': 4.00,
    },
}

var blasters = {
    'TestBlaster01': {
        'bolt_scene': 'TestVehicleBoltScene01',
        'bolt_model': 'TestBoltModel01',
        'energy': 6.00,
        'bolt_speed': 50.00,
        'cool_down': 0.30,
        'battery_capacity': 100.00,
    },
    'TestBlaster02': {
        'bolt_scene': 'TestVehicleBoltScene01',
        'bolt_model': 'TestBoltModel02',
        'energy': 8.00,
        'bolt_speed': 40.00,
        'cool_down': 0.35,
        'battery_capacity': 80.00,
    },
}

var shields = {
    'TestShields01': {
        'density': 0.02,
        'concentration': 0.05, # (perc)
        'battery_capacity': 40.00,
    },
    'TestShields02': {
        'density': 0.05,
        'concentration': 0.02, # (perc)
        'battery_capacity': 50.00,
    },
}



####################################################################################################
                                                                                ###   ENTITIES   ###
                                                                                ####################

var targets = {
    'TestTarget01': {
        'bolt_scene': 'TestTargetBoltScene01',
        'bolt_model': 'TestBoltModel03',
        'health': 20.00,
        'visibility_range': 80.00,
        'rotation_speed': 0.02,
        'bolt_energy': 3.00,
        'turret_cool_down': 0.40,
        'bolt_speed': 40.00,
    },
}
