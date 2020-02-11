
extends Spatial

export(String, 'left', 'right', 'up', 'down', 'forward', 'back') var gravity_dir_A
export(String, 'left', 'right', 'up', 'down', 'forward', 'back') var gravity_dir_B

var GRAVITY_DIR_A
var GRAVITY_DIR_B

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

func _on_InversionArea_body_entered(body):

	if body.gravity_dir == GRAVITY_DIR_A:      body.gravity_dir = GRAVITY_DIR_B
	elif body.gravity_dir == GRAVITY_DIR_B:    body.gravity_dir = GRAVITY_DIR_A
