
"""

Controls.gd

"""

extends Node



####################################################################################################
                                                                                ###   GAMEPLAY   ###
                                                                                ####################

### If 'true' bypass menus and generate game from 'gameplay' values.
#var TESTING_no_menu = false
var TESTING_no_menu = true

### If 'true', vehicle takes no damage from target bolts.
#var TESTING_take_no_damage = false
var TESTING_take_no_damage = true

var gameplay = {
    # 'arena': 'TestArena01',
    'arena': 'Bunny',
    'targets': 'TestTarget01',
    'number_of_targets': 0, # (currently) 64 or less
    'vehicle': {

#        'body': 'TestBody01',
#        'body': 'TestBody02',
        'body': 'BodyWhiteWithYellow',

#        'generator': 'GeneratorYellow',
        'generator': 'GeneratorGreen',

        'engines': 'EnginesYellow',
#        'engines': 'EnginesGreen',

#        'shields': 'ShieldsYellow',
        'shields': 'ShieldsGreen',
#        'shields': '_',

        'blaster1': 'BlasterYellow',
#        'blaster1': 'BlasterGreen',
#        'blaster1': '_',

#        'blaster2': 'BlasterYellow',
        'blaster2': 'BlasterGreen',
#        'blaster2': '_',
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
        'blaster_slots': [
            'blaster1',
        ]
    },
    'TestBody02': {
        'health': 15.00,
        'armor': 0.04,
        'blaster_slots': [
            'blaster1',
            'blaster2',
        ]
    },
    'BodyWhiteWithYellow': {
        'health': 15.00,
        'armor': 0.04,
        'blaster_slots': [
            'blaster1',
            'blaster2',
        ]
    },
}

var generators = {
    'GeneratorYellow': {
        'rate': 0.80,
        'replenish': 8.00,
    },
    'GeneratorGreen': {
        'rate': 0.40,
        'replenish': 4.00,
    },
}

var engines = {
    'EnginesYellow': {
        'thrust': 16.00,
        'max_speed': 18.00,
    },
    'EnginesGreen': {
        'thrust': 22.00,
        'max_speed': 12.00,
    },
}

var blasters = {
    'BlasterYellow': {
        'bolt_scene': 'VehicleBoltScene01',
        'bolt_model': 'BoltModelYellow',
        'energy': 6.00,
        'bolt_speed': 50.00,
        'cool_down': 0.30,
        'battery_capacity': 100.00,
    },
    'BlasterGreen': {
        'bolt_scene': 'VehicleBoltScene01',
        'bolt_model': 'BoltModelGreen',
        'energy': 8.00,
        'bolt_speed': 40.00,
        'cool_down': 0.35,
        'battery_capacity': 80.00,
    },
    '_': {
        'bolt_scene': '',
        'bolt_model': '',
        'energy': 0.00,
        'bolt_speed': 0.00,
        'cool_down': 0.00,
        'battery_capacity': 0.00,
    },
}

var shields = {
    'ShieldsYellow': {
        'density': 0.02,
        'concentration': 0.05, # (perc)
        'battery_capacity': 40.00,
    },
    'ShieldsGreen': {
        'density': 0.05,
        'concentration': 0.02, # (perc)
        'battery_capacity': 50.00,
    },
    '_': {
        'density': 0.0,
        'concentration': 0.00, # (perc)
        'battery_capacity': 0.0,
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
