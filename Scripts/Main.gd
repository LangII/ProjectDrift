
"""

TURNOVER NOTES:

'Controls.gd' now controls selection of vehicle engines as well.  Settings from 'controls.engines'
also control the statistics of that designated part.  The key for each engine will be the name of
the model associated with that part.

Next step is to make a 2nd test engine with alternative model and statistics.

Then, after that, I need to introduce other parts (generator, blaster, shield, launcher, etc).

"""

extends Node

# onready var controls = get_node('/root/Controls')

func _ready():

    get_tree().change_scene('res://Scenes/Gameplay.tscn')
