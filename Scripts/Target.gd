
"""

Target.gd

"""

extends StaticBody

# Singletons.
onready var controls = get_node('/root/Controls')



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

# Get tags.
onready var body_tag =      controls.gameplay['vehicle']['body']
onready var target_tag =    controls.gameplay['targets']
onready var bolt_tag =      controls.targets[target_tag]['bolt_scene']

# Get global control variables.
onready var ANGLE_TO_SHOOT =    controls.global['target']['angle_to_shoot']
onready var AT_REST_TOLERANCE = controls.global['target']['at_rest_tolerance']

# Get target's control variables.
onready var MAX_HEALTH =        controls.targets[target_tag]['health']
onready var HEALTH =            controls.targets[target_tag]['health']
onready var VISIBILITY_RANGE =  controls.targets[target_tag]['visibility_range']
onready var ROTATION_SPEED =    controls.targets[target_tag]['rotation_speed']
onready var TURRET_COOL_DOWN =  controls.targets[target_tag]['turret_cool_down']



####################################################################################################
                                                                       ###   LOADS, REFS, VARS   ###
                                                                       #############################

# Scene loads.
onready var Bolt = load('res://Scenes/Functional/Projectiles/%s.tscn' % bolt_tag)

# Node references.
onready var target_bolts =          get_node('/root/Main/Gameplay/TargetBolts')
onready var visibility_col_shape =  get_node('Visibility*/CollisionShape')
onready var turret =                get_node('Turret*')
onready var spawn_bolt =            turret.get_node('SpawnBolt*')
onready var turret_cool_down =      get_node('TurretCoolDown*')

# Working variables.
onready var turret_cooled_down = true
onready var awake = false
onready var obj_visible = null
onready var targeting = Vector3()
onready var angle_to_targeting = 0.0
onready var targeting_dir = Vector3()
onready var below_target = Vector3()
onready var above_target = Vector3()

# Export variables.
export(String, 'left', 'right', 'up', 'down', 'forward', 'back') var at_rest_dir



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():

    setRefDirsFromExport()

    # Set node values.
    visibility_col_shape.shape.radius = VISIBILITY_RANGE
    turret_cool_down.wait_time = TURRET_COOL_DOWN

    # Set turret's at rest position.
    turret.look_at(turret.global_transform.origin + at_rest_dir, above_target)



func setRefDirsFromExport():
    
    match at_rest_dir:
        'left':     pass
        'right':    pass
        'up':       pass
        'down':
            at_rest_dir = Vector3(0, -1, 0.00001)
            below_target = Vector3.DOWN
            above_target = Vector3.UP
        'forward':
            at_rest_dir = Vector3(0, 0.00001, -1)
            below_target = Vector3.FORWARD
            above_target = Vector3.BACK
        'back':     pass










