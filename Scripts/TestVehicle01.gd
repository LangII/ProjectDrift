
"""

"""

extends VehicleBody

####################################################################################################
                                                                            ###   CONTROL VARS   ###
                                                                            ########################

onready var controls = get_node('/root/Controls')

# Get vehicle parts tags..
onready var engines_tag = controls.gameplay['vehicle']['engines']
onready var blaster_tag = controls.gameplay['vehicle']['blaster']
onready var bolt_tag = controls.blasters[blaster_tag]['bolt_scene']

# Get set of default control stats.
onready var FRICTION =          controls.vehicle['friction']
onready var SPIN =              controls.vehicle['spin']
onready var THRUST_DAMP =       controls.vehicle['thrust_damp']
onready var SPIN_DAMP =         controls.vehicle['spin_damp']
onready var MOUSE_SENSITIVITY = controls.vehicle['mouse_sensitivity']
onready var MOUSE_VERT_DAMP =   controls.vehicle['mouse_vert_damp']

# Get vehicle control stats.
onready var THRUST =    controls.engines[engines_tag]['thrust']
onready var MAX_SPEED = controls.engines[engines_tag]['max_speed']



####################################################################################################
                                                                               ###   FUNC VARS   ###
                                                                               #####################

# Camera node.
onready var pivot = $Pivot

var vel = Vector3()
var rot = Vector3()

var mouse_motion = false
var mouse_captured = false

# Blaster and Bolt variables.
onready var Bolt = load('res://Scenes/Functional/Projectiles/' + bolt_tag + '.tscn')
onready var blaster_cool_down = $BlasterCoolDown
onready var spawn_bolt = $SpawnBolt
onready var scope = $Pivot/Camera/Scope
onready var look_default = $Pivot/Camera/Scope/LookDefault
var pointing_at = Vector3()
var blaster_cooled_down = true

# Hud variables.
onready var hud = $Hud



####################################################################################################
                                                                             ###   GODOT FUNCS   ###
                                                                             #######################

func _ready():

    # Capture mouse.
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    # Update physics settings.
    physics_material_override.set_friction(FRICTION)
    set_linear_damp(THRUST_DAMP)
    set_angular_damp(SPIN_DAMP)

    # Get blaster controls.
    blaster_cool_down.wait_time = controls.blasters[blaster_tag]['cool_down']

    print("hud", hud)



func _unhandled_input(event):

    """
    Vehicle mouse controls (while mouse is captured).
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


    # WASD processing.
    vel = getWasdInput()
    # Rotate vehicle's velocity based on vehicle's rotation.
    vel = vel.rotated(Vector3.UP, rotation.y)

    # Clamp vehicle's max speed.
    if linear_velocity.length() > MAX_SPEED:
        linear_velocity = linear_velocity.normalized() * MAX_SPEED

    # Targetting logic...  'spawn_bolt' looks at whatever 'scope' is looking at.  This is to ensure
    # that whatever is in the player's crosshairs is the point that will be shot at.
    if scope.is_colliding():    pointing_at = scope.get_collision_point()
    else:                       pointing_at = look_default.global_transform.origin
    spawn_bolt.look_at(pointing_at, Vector3.UP)

    """
    Bolt spawn controls.
    """
    if Input.is_action_pressed('ui_accept') and blaster_cooled_down:
        var b = Bolt.instance()
        get_parent().add_child(b)
        b.spawn(spawn_bolt.global_transform)
        blaster_cooled_down = false

    # Send speed values to 'Hud'.
    hud.speed_value_text = String(stepify(linear_velocity.length(), 0.01))



func _physics_process(delta):

    apply_torque_impulse(rot)
    apply_central_impulse(vel)



func _on_BlasterCoolDown_timeout():

    blaster_cooled_down = true



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
