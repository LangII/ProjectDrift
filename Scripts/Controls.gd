
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
        'generator': 'TestGenerator01',
        'engines': 'TestEngines01',
        'blaster': 'TestBlaster01',
        'shields': 'TestShields01',
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
        'thrust_linear_damp': 0.70, # (perc)
        # 'rest_linear_damp': 0.90, # (perc)
        'spin_damp': 0.99, # (perc)
        'mouse_sensitivity': 0.002,
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
        'max_speed': 20.00,
    },
    'TestEngines02': {
        'thrust': 0.90,
        'max_speed': 18.00,
    },
}

var generators = {
    'TestGenerator01': {
        'rate': 0.80,
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
        'energy': 6.00,
        'bolt_speed': 50.00,
        'cool_down': 0.30,
        'battery_capacity': 100.00,
    },
    'TestBlaster02': {
        'bolt_scene': 'TestVehicleBoltScene01',
        'bolt_model': 'TestBoltModel02',
        'energy': 2.00,
        'bolt_speed': 20.00,
        'cool_down': 0.20,
        'battery_capacity': 80.00,
    },
}

var shields = {
    'TestShields01': {
        'density': 0.02,
        'concentration': 0.20, # (perc)
        'battery_capacity': 40.00,
    },
    'TestShields02': {
        'density': 0.01,
        'concentration': 0.30, # (perc)
        'battery_capacity': 80.00,
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
        'energy': 3.00,
        'turret_cool_down': 0.40,
        'bolt_speed': 40.00,
    },
}
