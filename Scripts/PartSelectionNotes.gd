
extends Node


"""
TURNOVVER NOTES:
    Need to update parts names from 'TestGenerator01' to 'GeneratorYellow'.
"""


var parts = {

'GeneratorYellow': """

generator yellow:

rate = 0.80 (sec)
replenish = 8.00

"Replenishes more at a slower rate."

""",

'GeneratorGreen': """

generator green:

rate = 0.40 (sec)
replenish = 4.00

"Replenishes less at a faster rate."

""",

'EnginesYellow': """

engines yellow:

thrust = 16.00
max speed = 18.00

"Lower acceleration, higher maximum speed."

""",

'EnginesGreen': """

engines green:

thrust = 22.00
max speed = 12.00

"Faster acceleration, lower maximum speed."

""",

'BlasterYellow': """

blaster yellow:

energy = 6.00
bolt speed = 50.00
cool down = 0.30 (sec)
battery capacity = 100.00

"Bolt does less damage, travels at a faster rate, fires at a faster rate, and stores more energy."

""",

'BlasterGreen': """

blaster green:

energy = 8.00
bolt speed = 40.00
cool down = 0.35 (sec)
battery capacity = 80.00

"Bolt does more damage, travels at a slower rate, fires at a slower rate, and stores less energy."

""",

'ShieldsYellow': """

shields yellow:

density = 0.02 (perc)
concentration = 0.05 (perc)
battery capacity = 40.00

"2% of damage done will be ignored (density).  Concentration is how effective battery replenishment
is.  Battery stores less energy."

""",

'ShieldsGreen': """

shields green:

density = 0.05 (perc)
concentration = 0.02 (perc)
battery capacity = 50.00

"5% of damage done will be ignored (density).  Concentration is how effective battery replenishment
is.  Battery stores more energy."

"""

}
