
"""

Controls.gd

"""

extends Node



####################################################################################################
                                                                            ###   TESTING VARS   ###
                                                                            ########################

### If 'true' bypass menus and generate game from 'gameplay' values.
#var TESTING_no_menu = false
var TESTING_no_menu = true

### If 'true', vehicle takes no damage from target bolts.
#var TESTING_take_no_damage = false
var TESTING_take_no_damage = true



####################################################################################################
                                                                                ###   GAMEPLAY   ###
                                                                                ####################

var gameplay = {
    # 'arena': 'TestArena01',
    'arena': 'Bunny',
    'targets': 'TestTarget01',
    'number_of_targets': 0, # (currently) 64 or less
    'vehicle': {

#        'body': {'part_tag': 'BodyWhite', 'boosts': []}, # 0
#        'body': {'part_tag': 'BodyWhiteWithYellow', 'boosts': []}, # 1
#        'body': {'part_tag': 'BodyWhiteWithOrange', 'boosts': []}, # 2
        'body': {'part_tag': 'BodyWhiteWithGreen', 'boosts': []}, # 0

#        'generator': {'part_tag': 'GeneratorWhite', 'boosts': []}, # 1
        'generator': {'part_tag': 'GeneratorWhiteWithYellow', 'boosts': []}, # 2

        'engines': {'part_tag': 'EnginesWhite', 'boosts': []}, # 1
#        'engines': {'part_tag': 'EnginesWhiteWithYellow', 'boosts': []}, # 0

#        'shields': {'part_tag': 'ShieldsWhite', 'boosts': []}, # 2
        'shields': {'part_tag': 'ShieldsWhiteWithYellow', 'boosts': []}, # 0
#        'shields': {'part_tag': '', 'boosts': []}, # 0

#        'blaster1': {'part_tag': 'BlasterWhite', 'boosts': []}, # 1
#        'blaster1': {'part_tag': 'BlasterWhiteWithYellow', 'boosts': []}, # 2
        'blaster1': {'part_tag': 'BlasterWhiteWithOrange', 'boosts': []}, # 0
#        'blaster1': {'part_tag': '', 'boosts': []}, # 0

#        'blaster2': {'part_tag': 'BlasterWhite', 'boosts': []}, # 1
#        'blaster2': {'part_tag': 'BlasterWhiteWithYellow', 'boosts': []}, # 2
        'blaster2': {'part_tag': 'BlasterWhiteWithOrange', 'boosts': []}, # 0
#        'blaster2': {'part_tag': '', 'boosts': []}, # 0

#        'blaster3': {'part_tag': 'BlasterWhite', 'boosts': []}, # 1
#        'blaster3': {'part_tag': 'BlasterWhiteWithYellow', 'boosts': []}, # 2
        'blaster3': {'part_tag': 'BlasterWhiteWithOrange', 'boosts': []}, # 0
#        'blaster3': {'part_tag': '', 'boosts': []}, # 0

        'missilelauncher1': {'part_tag': 'MissileLauncherWhite', 'boosts': []}, # 1
#        'missilelauncher1': {'part_tag': 'MissileLauncherWhiteWithYellow', 'boosts': []}, # 2
#        'missilelauncher1': {'part_tag': 'MissileLauncher', 'boosts': []}, # 0

        'missilelauncher2': {'part_tag': 'MissileLauncherWhite', 'boosts': []}, # 1
#        'missilelauncher2': {'part_tag': 'MissileLauncherWhiteWithYellow', 'boosts': []}, # 2
#        'missilelauncher2': {'part_tag': 'MissileLauncher', 'boosts': []}, # 0
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
    'missile': {
        'life_time': 5.00,
        'accel_time': 1.00,
        'explosion_expand_time': 0.15,
        'explosion_fade_out_time': 2.00,
    },
}



####################################################################################################
                                                                           ###   VEHICLE PARTS   ###
                                                                           #########################

var bodies = {
    'BodyWhite': {
        'health': 20.00,
        'armor': 0.05,
        'blaster_slots': ['blaster1',],
        'launcher_slots': [],
        'boost_slots': 0,
    },
    'BodyWhiteWithYellow': {
        'health': 15.00,
        'armor': 0.04,
        'blaster_slots': ['blaster1', 'blaster2',],
        'launcher_slots': [],
        'boost_slots': 1,
    },
    'BodyWhiteWithOrange': {
        'health': 18.00,
        'armor': 0.02,
        'blaster_slots': ['blaster1', 'blaster2'],
        'launcher_slots': ['missilelauncher1',],
        'boost_slots': 2,
    },
    'BodyWhiteWithGreen': {
        'health': 5.00,
        'armor': 0.01,
        'blaster_slots': ['blaster1', 'blaster2', 'blaster3',],
        'launcher_slots': ['missilelauncher1', 'missilelauncher2'],
        'boost_slots': 0,
    },
}

var generators = {
    'GeneratorWhite': {
        'rate': 0.80,
        'replenish': 8.00,
        'boost_slots': 1,
    },
    'GeneratorWhiteWithYellow': {
        'rate': 0.40,
        'replenish': 4.00,
        'boost_slots': 2,
    },
}

var engines = {
    'EnginesWhite': {
        'thrust': 22.00,
        'max_speed': 12.00,
        'boost_slots': 1,
    },
    'EnginesWhiteWithYellow': {
        'thrust': 16.00,
        'max_speed': 18.00,
        'boost_slots': 0,
    },
}

var shields = {
    'ShieldsWhite': {
        'density': 0.02,
        'concentration': 0.05, # (perc)
        'battery_capacity': 40.00,
        'boost_slots': 2,
    },
    'ShieldsWhiteWithYellow': {
        'density': 0.05,
        'concentration': 0.02, # (perc)
        'battery_capacity': 50.00,
        'boost_slots': 0,
    },
    '': {
        'density': 0.0,
        'concentration': 0.00, # (perc)
        'battery_capacity': 0.0,
        'boost_slots': 0,
    },
}

var blasters = {
    'BlasterWhite': {
        'energy': 6.00,
        'bolt_speed': 50.00,
        'cool_down': 0.30,
        'battery_capacity': 100.00,
        'boost_slots': 1,
    },
    'BlasterWhiteWithYellow': {
        'energy': 8.00,
        'bolt_speed': 40.00,
        'cool_down': 0.35,
        'battery_capacity': 80.00,
        'boost_slots': 2,
    },
    'BlasterWhiteWithOrange': {
        'energy': 5.00,
        'bolt_speed': 55.00,
        'cool_down': 0.25,
        'battery_capacity': 70.00,
        'boost_slots': 0,
    },
    '': {
        'energy': 0.00,
        'bolt_speed': 0.00,
        'cool_down': 0.00,
        'battery_capacity': 0.00,
        'boost_slots': 0,
    },
}

var launchers = {
    'Missile': {
        'MissileLauncherWhite': {
            'damage': {20.0: 10.0, 50.0: 5.0, 100.0: 5.0,},
            'missile_speed': 8.0,
            'missile_accel': 0.015,
            'cool_down': 1.0,
            'magazine_capacity': 3,
            'boost_slots': 1,
        },
        'MissileLauncherWhiteWithYellow': {
            'damage': {20.0: 5.0, 60.0: 5.0,},
            'missile_speed': 9.0,
            'missile_accel': 0.020,
            'cool_down': 0.8,
            'magazine_capacity': 5,
            'boost_slots': 2,
        },
        'MissileLauncher': {
            'damage': {0.0: 0.0,},
            'missile_speed': 0.0,
            'missile_accel': 0.0,
            'cool_down': 0.0,
            'magazine_capacity': 0,
            'boost_slots': 0,
        },
    },
}



####################################################################################################
                                                                                  ###   BOOSTS   ###
                                                                                  ##################

var boosts = {
        # 'type': 'perc +', 'perc -', 'incr +', or 'incr -'
        # 'value': value of increase with consideration of 'type'
    'body': {
        # 'stat': 'health' or 'armor'
        'body_boost_01': {'stat': 'health', 'type': 'incr +', 'value': 2},
        'body_boost_02': {'stat': 'armor', 'type': 'perc +', 'value': 0.10},
    },
    'generator': {
        # 'stat': 'rate' or 'replenish'
        #       !!!  If 'stat': 'rate', then 'type' can only be 'perc -'.  !!!
        'generator_boost_01': {'stat': 'rate', 'type': 'incr +', 'value': 0.20},
        'generator_boost_02': {'stat': 'replenish', 'type': 'perc -', 'value': 0.02},
    },
    'engines': {
        # 'stat': 'thrust' or 'max_speed'
        'engines_boost_01': {'stat': 'thrust', 'type': 'perc +', 'value': 0.20},
        'engines_boost_02': {'stat': 'max_speed', 'type': 'incr +', 'value': 5},
    },
    'shields': {
        # 'stat': 'density', 'concentration', or 'battery_capacity'
        'shields_boost_01': {'stat': 'density', 'type': 'perc +', 'value': 0.02},
        'shields_boost_02': {'stat': 'concentration', 'type': 'perc +', 'value': 0.10},
    },
    'blasters': {
        # 'stat': 'energy', 'bolt_speed', 'cool_down', or 'battery_capacity'
        #       !!!  If 'stat': 'cool_down', then 'type' can only be 'perc -'.  !!!
        'blaster_boost_01': {'stat': 'energy', 'type': 'incr +', 'value': 0.50},
        'blaster_boost_02': {'stat': 'battery_capacity', 'type': 'perc +', 'value': 0.10},
    },
    'missile_launchers': {
        # 'stat': 'dmg_rad', 'dmg_val', 'missile_speed', 'missile_accel', 'cool_down', or
        # 'magazine_capacity'
        #       !!!  If 'stat': 'cool_down', then 'type' can only be 'perc -'.  !!!
        'missile_launcher_boost_01': {'stat': 'dmg_val', 'type': 'perc +', 'value': 0.10},
        'missile_launcher_boost_02': {'stat': 'magazine_capacity', 'type': 'perc +', 'value': 0.10},
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



####################################################################################################
                                                                                ###   OBSOLETE   ###
                                                                                ####################

""" from var body (2020-05-24) """
#    'TestBody01': {
#        'health': 20.00,
#        'armor': 0.05,
#        'blaster_slots': [
#            'blaster1',
#        ]
#    },
#    'TestBody02': {
#        'health': 15.00,
#        'armor': 0.04,
#        'blaster_slots': [
#            'blaster1',
#            'blaster2',
#        ]
#    },

""" from var blasters (2020-05-21) """
#    'BlasterYellow': {
#        'bolt_scene': 'VehicleBoltScene01',
#        'bolt_model': 'BoltModelYellow',
#        'energy': 6.00,
#        'bolt_speed': 50.00,
#        'cool_down': 0.30,
#        'battery_capacity': 100.00,
#    },
#    'BlasterGreen': {
#        'bolt_scene': 'VehicleBoltScene01',
#        'bolt_model': 'BoltModelGreen',
#        'energy': 8.00,
#        'bolt_speed': 40.00,
#        'cool_down': 0.35,
#        'battery_capacity': 80.00,
#    },








