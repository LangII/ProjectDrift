
"""

"""

extends VehicleBody

####################################################################################################
                                                                            ###   CONTROL VARS   ###
                                                                            ########################

onready var controls = get_node('/root/Controls')

# Get parts tags.
onready var body_tag =      controls.gameplay['vehicle']['body']
onready var generator_tag = controls.gameplay['vehicle']['generator']
onready var engines_tag =   controls.gameplay['vehicle']['engines']
onready var blaster_tag =   controls.gameplay['vehicle']['blaster']
onready var bolt_tag =      controls.blasters[blaster_tag]['bolt_scene']

# Get default control stats.
onready var FRICTION =          controls.default['vehicle']['friction']
onready var SPIN =              controls.default['vehicle']['spin']
onready var THRUST_DAMP =       controls.default['vehicle']['thrust_damp']
onready var SPIN_DAMP =         controls.default['vehicle']['spin_damp']
onready var MOUSE_SENSITIVITY = controls.default['vehicle']['mouse_sensitivity']
onready var MOUSE_VERT_DAMP =   controls.default['vehicle']['mouse_vert_damp']

# Get parts control stats.
onready var HEALTH =                    controls.body[body_tag]['health']
onready var THRUST =                    controls.engines[engines_tag]['thrust']
onready var MAX_SPEED =                 controls.engines[engines_tag]['max_speed']
onready var GENERATOR_RATE =            controls.generators[generator_tag]['rate']
onready var REPLENISH =                 controls.generators[generator_tag]['replenish']
onready var BLASTER_BATTERY_CAPACITY =  controls.blasters[blaster_tag]['battery_capacity']
onready var COOL_DOWN =                 controls.blasters[blaster_tag]['cool_down']
onready var BOLT_ENERGY =               controls.blasters[blaster_tag]['energy']



####################################################################################################
                                                                               ###   FUNC VARS   ###
                                                                               #####################

# For calling Hud methods for Hud updates.
onready var hud = $Hud

# Camera node.
onready var pivot = $Pivot

# _process()
var vel = Vector3()
var rot = Vector3()

# _unhandled_input()
var mouse_motion = false
var mouse_captured = false

# Generator variables.
onready var generator_rate = $GeneratorRate
# Energy replenishment settings variables.
onready var replenish_sets = [
    {'engines': 0.5, 'blasters': 0.5},
    {'engines': 0.0, 'blasters': 1.0},
    {'engines': 1.0, 'blasters': 0.0}
]
onready var replenish_set = 0
onready var replenish_engines = 0.0
onready var replenish_blasters = 0.0

# Blaster and Bolt variables.
onready var Bolt = load('res://Scenes/Functional/Projectiles/' + bolt_tag + '.tscn')
onready var blaster_cool_down = $BlasterCoolDown
onready var spawn_bolt = $SpawnBolt
onready var scope = $Pivot/Camera/Scope
onready var look_default = $Pivot/Camera/Scope/LookDefault
var pointing_at = Vector3()
var blaster_cooled_down = true
var has_enough_energy = true
var blaster_battery = 0.0
var bolt

# getWasdInput()
var vel_ = Vector3()

var focus
var focus_name = ''



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():

    # Capture mouse.
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    # Update physics settings.
    physics_material_override.set_friction(FRICTION)
    set_linear_damp(THRUST_DAMP)
    set_angular_damp(SPIN_DAMP)

    """ Set parts' variables. """
    blaster_cooled_down = true
    # Set 'blaster_battery' to full charge at start of gameplay.
    blaster_battery = BLASTER_BATTERY_CAPACITY
    # Set vehicle parts' timers wait times.
    generator_rate.wait_time = GENERATOR_RATE
    blaster_cool_down.wait_time = COOL_DOWN

    """ Set initial replenishment values. """
    replenish_engines = replenish_sets[replenish_set]['engines']
    replenish_blasters = replenish_sets[replenish_set]['blasters']
    hud.updateHealthValue(HEALTH)
    hud.updateBlasterBatteryValue(blaster_battery)
    hud.updateReplenishingValues(replenish_engines, replenish_blasters)



####################################################################################################
                                                                              ###   PROCESSING   ###
                                                                              ######################



func _unhandled_input(event):

    """ Vehicle mouse controls (while mouse is captured). """
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

    """ Bolt spawn controls. """
    has_enough_energy = blaster_battery >= BOLT_ENERGY
    if Input.is_action_pressed('ui_accept') and blaster_cooled_down and has_enough_energy:
        bolt = Bolt.instance()
        get_parent().add_child(bolt)
        bolt.spawn(spawn_bolt.global_transform)
        blaster_battery -= BOLT_ENERGY
        hud.updateBlasterBatteryValue(blaster_battery)
        blaster_cool_down.start()
        blaster_cooled_down = false

    """ Toggling of energy replenishment settings. """
    if Input.is_action_just_pressed('ui_focus_next'):
        if replenish_set <= len(replenish_sets) - 2:    replenish_set += 1
        else:                                           replenish_set = 0
        replenish_engines = replenish_sets[replenish_set]['engines']
        replenish_blasters = replenish_sets[replenish_set]['blasters']
        hud.updateReplenishingValues(replenish_engines, replenish_blasters)

    if Input.is_action_just_pressed('ui_focus_prev'):
        focus = scope.get_collider()
        if focus != null and focus.name == 'Target':
            focus_name = focus.get_parent().name
            hud.updateFocusNameValue(focus_name)
            hud.updateFocusHealthValue(focus.health)



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################


func _physics_process(delta):

    apply_torque_impulse(rot)
    apply_central_impulse(vel)



func _on_BlasterCoolDown_timeout():

    blaster_cooled_down = true



func _on_GeneratorRate_timeout():

    """
    Here is where the different batteries will be replenished.  Currently, the only battery being
    replenished is for blasters.
    """

    # Regulate blaster battery replenishment.  Only replenish of blaster battery is not full.  If
    # replenishment overfills blaster battery, clamp it.  Then update Hud.
    if blaster_battery < BLASTER_BATTERY_CAPACITY:
        blaster_battery += REPLENISH * replenish_blasters
        blaster_battery = clamp(blaster_battery, 0, BLASTER_BATTERY_CAPACITY)
        hud.updateBlasterBatteryValue(blaster_battery)



####################################################################################################
                                                                                ###   MY FUNCS   ###
                                                                                ####################

func getWasdInput():
    """ WASD controls. """
    vel_ = Vector3()

    # With 'THRUST', apply WASD up/down input to 'vel' x-axis (forward/backward).
    if Input.is_action_pressed('ui_up'):	vel_ += Vector3(+THRUST * replenish_engines, 0, 0)
    if Input.is_action_pressed('ui_down'):	vel_ += Vector3(-THRUST * replenish_engines, 0, 0)
    # With 'THRUST', apply WASD left/right input to 'vel' z-axis (left/right).
    if Input.is_action_pressed('ui_left'):	vel_ += Vector3(0, 0, -THRUST * replenish_engines)
    if Input.is_action_pressed('ui_right'):	vel_ += Vector3(0, 0, +THRUST * replenish_engines)

    return vel_
