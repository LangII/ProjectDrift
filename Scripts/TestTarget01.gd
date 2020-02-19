
"""

TestTarget01.gd

"""

extends StaticBody



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

onready var controls = get_node('/root/Controls')

# Get tags.
onready var body_tag =      controls.gameplay['vehicle']['body']
onready var target_tag =    controls.gameplay['targets']
onready var bolt_tag =      controls.targets[target_tag]['bolt_scene']

# Get global control variables.
onready var ANGLE_TO_SHOOT =    controls.global['target']['angle_to_shoot']
onready var AT_REST_TOLERANCE = controls.global['target']['at_rest_tolerance']

# Get target's control variables.
onready var HEALTH =            controls.targets[target_tag]['health']
onready var VISIBILITY_RANGE =  controls.targets[target_tag]['visibility_range']
onready var ROTATION_SPEED =    controls.targets[target_tag]['rotation_speed']
onready var TURRET_COOL_DOWN =  controls.targets[target_tag]['turret_cool_down']



####################################################################################################
                                                                               ###   FUNC VARS   ###
                                                                               #####################

onready var visibility_col = $Visibility/CollisionShape

onready var turret = $Turret
onready var turret_cool_down = $TurretCoolDown
onready var turret_cooled_down = true

onready var spawn_bolt = $Turret/SpawnBolt
onready var Bolt = load('res://Scenes/Functional/Projectiles/%s.tscn' % bolt_tag)
var bolt

onready var awake = false
onready var obj_visible = null
onready var targeting = Vector3()
onready var angle_to_targeting = 0.0
onready var target_bolts = get_node('/root/Gameplay/TargetBolts')
onready var targeting_dir = Vector3()



export(String, 'left', 'right', 'up', 'down', 'forward', 'back') var at_rest

var below_target
var above_target



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():

    match at_rest:

        'left':     pass
        'right':    pass
        'up':       pass

        'down':
            at_rest = Vector3(0, -1, 0.00001)
            below_target = Vector3.DOWN
            above_target = Vector3.UP

        'forward':
            at_rest = Vector3(0, 0.00001, -1)
            below_target = Vector3.FORWARD
            above_target = Vector3.BACK

        'back':     pass

    # BLOCK ...  Set initiating variables.
    visibility_col.shape.radius = VISIBILITY_RANGE
    turret_cool_down.wait_time = TURRET_COOL_DOWN
    turret_cooled_down = true

    # Set turret's at rest position.
    turret.look_at(turret.global_transform.origin + at_rest, above_target)



####################################################################################################
                                                                              ###   PROCESSING   ###
                                                                              ######################

func _process(delta):

    ### from Discord (Fabian) ...  To try in the future as a better interpolation method.
    # _tween.interpolate_property(self, "transform:basis",
    #         initial_basis, final_basis, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
    #     _tween.start()

    # 'awake' is used to reduce unnecessary 'target' processing.
    if awake:
        if obj_visible:
            targeting = obj_visible.global_transform.origin - turret.global_transform.origin

            ###   OBSOLETE   ###
            # # NEED TO FIX ...  Targets 1 unit above origin, need to give vehicle to-be-targeted
            # # coord.  Will fix with next vehicle update of part positional instancing.
            # targeting.y += 1

            angle_to_targeting = turret.transform.basis.y.angle_to(targeting)
            # NEED TO FIX ...  Not sure why, but 'angle_to_targeting' has a constant offset of 90d
            # (1.57r).  Should not be hard coded this way.
            if angle_to_targeting < 1.57 + ANGLE_TO_SHOOT:
                if angle_to_targeting > 1.57 - ANGLE_TO_SHOOT:
                    if turret_cooled_down:
                        # If all conditions are met, proceed to processing of instancing 'bolt',
                        # spawning 'bolt', and reseting 'turret_cool_down'.
                        bolt = Bolt.instance()
                        target_bolts.add_child(bolt)
                        bolt.spawn(spawn_bolt.global_transform)
                        turret_cool_down.start()
                        turret_cooled_down = false

        # Handle processing of turret from object-no-longer-visible to at-rest.
        else:
            targeting = at_rest
            if turret.transform.basis.y.angle_to(below_target) < AT_REST_TOLERANCE:  awake = false

        # Need additional step of 'targeting_dir' for interpolation.
        targeting_dir = turret.transform.looking_at(targeting, above_target)
        targeting_dir = turret.transform.interpolate_with(targeting_dir, ROTATION_SPEED)
        turret.transform = targeting_dir.orthonormalized()



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_Visibility_body_entered(body):

    # Only handle body entering if 'body' is vehicle's 'body_tag'.
    if body.name == body_tag:
        awake = true
        obj_visible = body



func _on_Visibility_body_exited(body):

    # Only handle body exiting if 'body' is body recognized ('obj_visible') from body entered
    # signal.
    if body == obj_visible:  obj_visible = null



func _on_TurretCoolDown_timeout():

    turret_cooled_down = true
