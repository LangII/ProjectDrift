
"""

TestVehicle01.gd

"""

extends VehicleBody



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

onready var controls = get_node('/root/Controls')

# Get tags.
onready var body_tag =      controls.gameplay['vehicle']['body']
onready var generator_tag = controls.gameplay['vehicle']['generator']
onready var engines_tag =   controls.gameplay['vehicle']['engines']
onready var shields_tag =   controls.gameplay['vehicle']['shields']
onready var blaster_tag =   controls.gameplay['vehicle']['blaster']
onready var bolt_tag =      controls.blasters[blaster_tag]['bolt_scene']

# Get global control variables.
onready var FRICTION =              controls.global['vehicle']['friction']
onready var SPIN =                  controls.global['vehicle']['spin']
onready var THRUST_LINEAR_DAMP =    controls.global['vehicle']['thrust_linear_damp']
onready var REST_LINEAR_DAMP =      controls.global['vehicle']['rest_linear_damp']
onready var SPIN_DAMP =             controls.global['vehicle']['spin_damp']
onready var MOUSE_SENSITIVITY =     controls.global['vehicle']['mouse_sensitivity']
onready var MOUSE_VERT_DAMP =       controls.global['vehicle']['mouse_vert_damp']

# Get parts' control variables.
onready var HEALTH =                    controls.body[body_tag]['health']
onready var ARMOR =                     controls.body[body_tag]['armor']
onready var SHIELDS_BATTERY_CAPACITY =  controls.shields[shields_tag]['battery_capacity']
onready var SHIELDS_DENSITY =           controls.shields[shields_tag]['density']
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

# Generator / Replenishment.
onready var generator_rate = $GeneratorRate
onready var replenish_sets = [
    {'engines': 0.34, 'shields': 0.33, 'blasters': 0.33},
    {'engines': 0.80, 'shields': 0.10, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.80, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.10, 'blasters': 0.80},
]
onready var repl_set_pointer = 0

# Blaster / Bolt.
onready var Bolt = load('res://Scenes/Functional/Projectiles/' + bolt_tag + '.tscn')
onready var blaster_cool_down = $BlasterCoolDown
onready var spawn_bolt = $SpawnBolt
onready var scope = $Pivot/Camera/Scope
onready var look_default = $Pivot/Camera/Scope/LookDefault
onready var pointing_at = Vector3()

# BLOCK ... Preset values.
onready var blaster_cooled_down = true
# Initialize battery values as full.
onready var blaster_battery = BLASTER_BATTERY_CAPACITY
onready var shields_battery = SHIELDS_BATTERY_CAPACITY
# Initialize replenishment values as first set from 'replenish_sets'.
onready var replenish_engines = replenish_sets[repl_set_pointer]['engines']
onready var replenish_shields = replenish_sets[repl_set_pointer]['shields']
onready var replenish_blasters = replenish_sets[repl_set_pointer]['blasters']

# General function variables.
onready var hud = $Hud
onready var pivot = $Pivot
var vel = Vector3()
var rot = Vector3()

var rot_force = 0.0

# var gravity_force = 0.50
var gravity_force = 2.00
var gravity_dir = Vector3.DOWN



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():

    # Capture mouse.
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    # Update physics settings.
    physics_material_override.set_friction(FRICTION)
    set_linear_damp(THRUST_LINEAR_DAMP)
    set_angular_damp(SPIN_DAMP)

    # Set vehicle parts' timers wait times.
    generator_rate.wait_time = GENERATOR_RATE
    blaster_cool_down.wait_time = COOL_DOWN

    # Initiate Hud from Vehicle for replenish values.
    hud.updateReplenishValues(replenish_engines, replenish_shields, replenish_blasters)



####################################################################################################
                                                                              ###   PROCESSING   ###
                                                                              ######################

func _unhandled_input(event):

    # BLOCK ... Vehicle mouse controls (while mouse is captured).
    # Only perform vehicle mouse controls if 'mouse_motion' and 'mouse_captured' are True.
    var mouse_motion = event is InputEventMouseMotion
    var mouse_captured = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
    if mouse_motion and mouse_captured:

        rot_force = -event.relative.x * MOUSE_SENSITIVITY * SPIN

        # Mouse motion on the y-axis translates to camera ('pivot') motion on the z-axis.
        pivot.rotate_z(-event.relative.y * MOUSE_SENSITIVITY * MOUSE_VERT_DAMP)
        # Have to apply 'clamp' to prevent extreme camera positions.
        pivot.rotation.z = clamp(pivot.rotation.z, -1.2, 0.6)



func _process(delta):

    # # Clamp vehicle's max speed.
    # if linear_velocity.length() > MAX_SPEED:
    #     linear_velocity = linear_velocity.normalized() * MAX_SPEED

    # Targetting logic...  'spawn_bolt' looks at whatever 'scope' is looking at.  This is to ensure
    # that whatever is in the player's crosshairs is the point that will be shot at.
    if scope.is_colliding():    pointing_at = scope.get_collision_point()
    else:                       pointing_at = look_default.global_transform.origin
    spawn_bolt.look_at(pointing_at, Vector3.UP)

    ###   INPUT EVENTS   ###

    # BLOCK ... Blaster / Bolt controls.
    if Input.is_action_pressed('ui_accept'):
        if blaster_cooled_down and (blaster_battery >= BOLT_ENERGY):
            var bolt = Bolt.instance()
            get_node('/root/Gameplay/VehicleBolts').add_child(bolt)
            bolt.spawn(spawn_bolt.global_transform)
            blaster_battery -= BOLT_ENERGY
            hud.updateBlasterBatteryValue(blaster_battery)
            blaster_cool_down.start()
            blaster_cooled_down = false

    # BLOCK ... Replenish controls.
    if Input.is_action_just_pressed('ui_focus_next'):
        if repl_set_pointer <= len(replenish_sets) - 2:    repl_set_pointer += 1
        else:                                              repl_set_pointer = 0
        replenish_engines =     replenish_sets[repl_set_pointer]['engines']
        replenish_shields =     replenish_sets[repl_set_pointer]['shields']
        replenish_blasters =    replenish_sets[repl_set_pointer]['blasters']
        hud.updateReplenishValues(replenish_engines, replenish_shields, replenish_blasters)

    # BLOCK ... Focus controls.
    if Input.is_action_just_pressed('ui_focus_prev'):
        var focus = scope.get_collider()
        if focus != null and focus.get_parent().name == 'Targets':
            hud.updateFocusNameValue(focus.name)
            hud.updateFocusHealthValue(focus.HEALTH)



func _integrate_forces(state):

    if state.linear_velocity.length() > MAX_SPEED:
        state.linear_velocity = state.linear_velocity.normalized() * MAX_SPEED

    var rot_force_dir = applyGravToRotForce()
    apply_torque_impulse(rot_force_dir)



func _physics_process(delta):


    var grav_force_dir = applyGravDirToGravForce()
    apply_central_impulse(grav_force_dir)

    vel = getWasdInput()

    var vel_dir = applyGravToVel(vel)
    apply_central_impulse(vel_dir)



func applyGravDirToGravForce():

    var applied_grav = Vector3()
    for axis in range(3):  applied_grav[axis] = gravity_dir[axis] * gravity_force

    return applied_grav

func applyGravToRotForce():

    var applied_rot_force = Vector3()
    for axis in range(3):  applied_rot_force[axis] = -gravity_dir[axis] * rot_force

    return applied_rot_force

func applyGravToVel(_vel):

    var applied_vel = Vector3()

    match gravity_dir:

        Vector3.DOWN:
            applied_vel = _vel.rotated(Vector3.UP, rotation.y)

        Vector3.FORWARD:
            _vel = _vel.rotated(Vector3(1, 0, 0), deg2rad(90))
            var vel_rotation = rotation.x - deg2rad(90)
            if rotation.y >= 0:  vel_rotation = -vel_rotation
            applied_vel = _vel.rotated(transform.basis.y, vel_rotation)

        Vector3.RIGHT:
            _vel = _vel.rotated(Vector3(0, 0, 1), deg2rad(90))
            var vel_rotation = -rotation.x
            if rotation.z <= 0:  vel_rotation = -vel_rotation + deg2rad(180)
            applied_vel = _vel.rotated(transform.basis.y, vel_rotation)

    return applied_vel



func getWasdInput():
    """ WASD controls. """
    var wasd_vel = Vector3()

    # With 'THRUST', apply WASD up/down input to 'vel' x-axis (forward/backward).
    if Input.is_action_pressed('ui_up'):	wasd_vel += Vector3(+THRUST * replenish_engines, 0, 0)
    if Input.is_action_pressed('ui_down'):	wasd_vel += Vector3(-THRUST * replenish_engines, 0, 0)
    # With 'THRUST', apply WASD left/right input to 'vel' z-axis (left/right).
    if Input.is_action_pressed('ui_left'):	wasd_vel += Vector3(0, 0, -THRUST * replenish_engines)
    if Input.is_action_pressed('ui_right'):	wasd_vel += Vector3(0, 0, +THRUST * replenish_engines)

    return wasd_vel



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_BlasterCoolDown_timeout():

    blaster_cooled_down = true



func _on_GeneratorRate_timeout():

    # Regulate blaster battery and shields battery replenishment.  Only replenish if battery is not
    # full.  If replenishment overfills battery, clamp it.  Then update Hud.
    if blaster_battery < BLASTER_BATTERY_CAPACITY:
        blaster_battery += REPLENISH * replenish_blasters
        blaster_battery = clamp(blaster_battery, 0, BLASTER_BATTERY_CAPACITY)
        hud.updateBlasterBatteryValue(blaster_battery)
    if shields_battery < SHIELDS_BATTERY_CAPACITY:
        shields_battery += REPLENISH * replenish_shields
        shields_battery = clamp(shields_battery, 0, SHIELDS_BATTERY_CAPACITY)
        hud.updateShieldsBatteryValue(shields_battery)



# func printTransformBasis():
#     print("rot ", rotation_degrees)
#     print("X   ", transform.basis.x)
#     print("Y   ", transform.basis.y)
#     print("Z   ", transform.basis.z)
#     print("\n")
#
#
