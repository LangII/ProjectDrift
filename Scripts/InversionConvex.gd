
extends Spatial

export(String, 'left', 'right', 'up', 'down', 'forward', 'back') var gravity_dir_A
export(String, 'left', 'right', 'up', 'down', 'forward', 'back') var gravity_dir_B

var GRAVITY_DIR_A
var GRAVITY_DIR_B

var set_gravity_dir_to = null

func _ready():

    match gravity_dir_A:
        'left':     GRAVITY_DIR_A = Vector3.LEFT
        'right':    GRAVITY_DIR_A = Vector3.RIGHT
        'up':       GRAVITY_DIR_A = Vector3.UP
        'down':     GRAVITY_DIR_A = Vector3.DOWN
        'forward':  GRAVITY_DIR_A = Vector3.FORWARD
        'back':     GRAVITY_DIR_A = Vector3.BACK
    match gravity_dir_B:
        'left':     GRAVITY_DIR_B = Vector3.LEFT
        'right':    GRAVITY_DIR_B = Vector3.RIGHT
        'up':       GRAVITY_DIR_B = Vector3.UP
        'down':     GRAVITY_DIR_B = Vector3.DOWN
        'forward':  GRAVITY_DIR_B = Vector3.FORWARD
        'back':     GRAVITY_DIR_B = Vector3.BACK


# func _on_InvAreaOuter_body_entered(body):
#
#     pass

func _on_InvAreaOuter_body_exited(body):

    if body.get_parent().name == 'Vehicles':
        body.gravity_dir = set_gravity_dir_to
        set_gravity_dir_to = null

func _on_InvAreaInner_A_body_exited(body):

    set_gravity_dir_to = GRAVITY_DIR_A

func _on_InvAreaInner_B_body_exited(body):

    set_gravity_dir_to = GRAVITY_DIR_B
