
"""

"""

extends VehicleBody

####################################################################################################
                                                                            ###   CONTROL VARS   ###
                                                                            ########################

onready var globals = get_node('/root/Globals')

onready var FRICTION =          globals.vehicle['friction']
onready var THRUST =            globals.vehicle['thrust']
onready var SPIN =              globals.vehicle['spin']
onready var THRUST_DAMP =       globals.vehicle['thrust_damp']
onready var SPIN_DAMP =         globals.vehicle['spin_damp']
onready var MOUSE_SENSITIVITY = globals.vehicle['mouse_sensitivity']
onready var MOUSE_VERT_DAMP =   globals.vehicle['mouse_vert_damp']



####################################################################################################
                                                                               ###   FUNC VARS   ###
                                                                               #####################

# Camera nodes.
onready var pivot = $Pivot

var vel = Vector3()
var rot = Vector3()

var mouse_motion = false
var mouse_captured = false



####################################################################################################
                                                                                ###   MY FUNCS   ###
                                                                                ####################

func getWasdInput():
    """
    WASD controls.
    """
    var vel_ = Vector3()

    # With 'THRUST', apply WASD up/down input to 'vel' x-axis (forward/backward).
    if Input.is_action_pressed('ui_up'):	vel_ += Vector3(+THRUST, 0, 0)
    if Input.is_action_pressed('ui_down'):	vel_ += Vector3(-THRUST, 0, 0)
    # With 'THRUST', apply WASD left/right input to 'vel' z-axis (left/right).
    if Input.is_action_pressed('ui_left'):	vel_ += Vector3(0, 0, -THRUST)
    if Input.is_action_pressed('ui_right'):	vel_ += Vector3(0, 0, +THRUST)

    return vel_



####################################################################################################
                                                                             ###   GODOT FUNCS   ###
                                                                             #######################

func _ready():

    """
    Capture mouse.
    """
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    """
    Updates to physics settings.
    """
    physics_material_override.set_friction(FRICTION)
    set_linear_damp(THRUST_DAMP)
    set_angular_damp(SPIN_DAMP)



func _unhandled_input(event):

    """
    Vehicle mouse controls (while captured).
    """
    # Only perform vehicle mouse controls if 'mouse_motion' and 'mouse_captured' are True.
    mouse_motion = event is InputEventMouseMotion
    mouse_captured = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
    if mouse_motion and mouse_captured:
        # Mouse motion on the x-axis translates to vehicle motion on the y-axis.
        rot = Vector3(0, -event.relative.x * MOUSE_SENSITIVITY * SPIN, 0)
        # Mouse motion on the y-axis translates to camera ('pivot') motion on the z-axis.
        pivot.rotate_z(-event.relative.y * MOUSE_SENSITIVITY * MOUSE_VERT_DAMP)
        # Have to apply 'clamp' to prevent extreme camera positions.
        pivot.rotation.z = clamp(pivot.rotation.z, -1.2, 0.6)



func _process(delta):

    """
    WASD processing.
    """
    vel = getWasdInput()
    # Rotate vehicle's velocity based on vehicle's rotation.
    vel = vel.rotated(Vector3.UP, rotation.y)



func _physics_process(delta):

    apply_torque_impulse(rot)
    apply_central_impulse(vel)
