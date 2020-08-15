
extends Node

var bodies = {
    'health': "[num] Vehicle's starting health value.  Most matches result in a loss when this value reaches 0.",
    'armor': "[perc] When (damage) is applied to a vehicle's (health), it is first reduced by (damage * armor).",
}

var generators = {
    'rate': "[sec] How often a vehicle's total energy is increased.",
    'replenish': "[num] Value that the vehicle's total energy is increased by.",
}

var engines = {
    'thrust': "[num] Value of how much force is applied to the vehicle during move input.",
    'max_speed': "[num] The capped speed rate of the vehicle.",
}

var shields = {
    'density': "[perc] When (damage) is applied to a vehicle's (shields), it is first reduced by (damage * density).",
    'concentration': "[perc] When a (shields' battery energy) is replenished by a (generator), the (replenish) value is first converted to (replenish * concentration).",
    'battery_capacity': "[num] Vehicle's maximum and starting (shields battery) value.",
}

var blasters = {
    'energy': "[num] Value of (damage) applied to an entity upon (bolt) collision and value that (blaster battery) is decreased by.",
    'bolt_speed': "[dist] Value of distance a bolt travels per gameplay frame.",
    'cool_down': "[sec] Minimum wait time between consecutive bolt blasts.",
    'battery_capacity': "[num] Blaster's maximum and starting (blaster battery) value.",
}

var launchers = {
    'Missile': {
        'damage': "[map] Each item within the map is a key:value pairing.  The (key) represents the distance from point of the round's collision and the (value) represents the (damage) applied.  If an entity is within the designated distance of multiple key:value pairings, then the combined (damage) will be applied.",
        'missile_speed': "[dist] Value of distance a round travels after the acceleration time period per gameplay frame.",
        'missile_accel': "[dist] Value of exponential distance a round travels during the accleeration time period per gameplay frame.",
        'cool_down': "[sec] Minimum wait time between consecutive round launches.",
        'magazine_capacity': "[num] Missile Launcher's maximum and starting (magazine) value.",
    },
}
