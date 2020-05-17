
"""

TestVehicle01.gd

Currently the only vehicle body.  With the development of additional vehicle bodies, there will
need to be the development of a vehicle body module.  Much of the functionality of each body will
be mostly universal.  The functionality that is known to be non-universal will be the part slots.
Though there will be some room for modularization there.  As for now, interchangeable part
functionality will not be modularized.

"""

extends VehicleBody



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

onready var controls = get_node('/root/Controls')

### Get tags.
onready var body_tag =      controls.gameplay['vehicle']['body']
onready var generator_tag = controls.gameplay['vehicle']['generator']
onready var engines_tag =   controls.gameplay['vehicle']['engines']
onready var shields_tag =   controls.gameplay['vehicle']['shields']

onready var blaster1_tag =  controls.gameplay['vehicle']['blaster1']
onready var blaster2_tag =  controls.gameplay['vehicle']['blaster2']
onready var bolt1_tag =     controls.blasters[blaster1_tag]['bolt_scene']
onready var bolt2_tag =     controls.blasters[blaster2_tag]['bolt_scene']

### Get global control variables.
onready var GRAVITY_FORCE =         controls.global['vehicle']['gravity_force']
onready var FRICTION =              controls.global['vehicle']['friction']
onready var SPIN =                  controls.global['vehicle']['spin']
onready var LINEAR_DAMP =           controls.global['vehicle']['linear_damp']
# onready var REST_LINEAR_DAMP =      controls.global['vehicle']['rest_linear_damp']
onready var SPIN_DAMP =             controls.global['vehicle']['spin_damp']
onready var MOUSE_SENSITIVITY =     controls.global['vehicle']['mouse_sensitivity']
onready var MOUSE_VERT_DAMP =       controls.global['vehicle']['mouse_vert_damp']

### Get parts' control variables.
onready var HEALTH =                    controls.body[body_tag]['health']
onready var ARMOR =                     controls.body[body_tag]['armor']
onready var SHIELDS_BATTERY_CAPACITY =  controls.shields[shields_tag]['battery_capacity']
onready var SHIELDS_DENSITY =           controls.shields[shields_tag]['density']
onready var SHIELDS_CONCENTRATION =     controls.shields[shields_tag]['concentration']
onready var THRUST =                    controls.engines[engines_tag]['thrust']
onready var MAX_SPEED =                 controls.engines[engines_tag]['max_speed']
onready var GENERATOR_RATE =            controls.generators[generator_tag]['rate']
onready var REPLENISH =                 controls.generators[generator_tag]['replenish']

onready var BLASTER1_BATTERY_CAPACITY = controls.blasters[blaster1_tag]['battery_capacity']
onready var BLASTER2_BATTERY_CAPACITY = controls.blasters[blaster2_tag]['battery_capacity']
onready var BLASTER1_COOL_DOWN =        controls.blasters[blaster1_tag]['cool_down']
onready var BLASTER2_COOL_DOWN =        controls.blasters[blaster2_tag]['cool_down']
onready var BOLT1_ENERGY =              controls.blasters[blaster1_tag]['energy']
onready var BOLT2_ENERGY =              controls.blasters[blaster2_tag]['energy']



####################################################################################################
                                                                               ###   FUNC VARS   ###
                                                                               #####################

### Generator / Replenishment.
onready var generator_rate = $NonSpatial/GeneratorRate
onready var replenish_sets = [
    {'engines': 0.34, 'shields': 0.33, 'blasters': 0.33},
    {'engines': 0.80, 'shields': 0.10, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.80, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.10, 'blasters': 0.80},
]
onready var no_shields_replenish_sets = [
    {'engines': 0.50, 'shields': 0.00, 'blasters': 0.50},
    {'engines': 0.90, 'shields': 0.00, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.00, 'blasters': 0.90},
]
onready var repl_set_pointer = 0

### Blaster / Bolt.
onready var blaster1_cool_down = $NonSpatial/Blaster1CoolDown
onready var blaster2_cool_down = $NonSpatial/Blaster2CoolDown
onready var scope = $CameraPivot/Camera/Scope
onready var look_default = $CameraPivot/Camera/Scope/LookDefault
onready var pointing_at = Vector3()
### ...  temporary assignment until assignPartValues()
onready var barrel1_pivot = $TempPivot
onready var barrel2_pivot = $TempPivot
onready var bolt1_spawn = $TempSpawn
onready var bolt2_spawn = $TempSpawn

### BLOCK ... Preset values.
onready var blaster1_cooled_down = true
onready var blaster2_cooled_down = true
### Initialize battery values as full.
onready var blaster1_battery = BLASTER1_BATTERY_CAPACITY
onready var blaster2_battery = BLASTER2_BATTERY_CAPACITY
onready var shields_battery = SHIELDS_BATTERY_CAPACITY
### Initialize replenishment values as first set from 'replenish_sets'.
onready var replenish_engines = replenish_sets[repl_set_pointer]['engines']
onready var replenish_shields = replenish_sets[repl_set_pointer]['shields']
onready var replenish_blasters = replenish_sets[repl_set_pointer]['blasters']

### Other node references.
onready var hud = $NonSpatial/Hud
onready var camera_pivot = $CameraPivot

### Assigned variables.
var rot_force = 0.0
var gravity_force = 2.00
var gravity_dir = Vector3.DOWN



var selected_blaster
var Bolt1
var Bolt2



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():

    # Capture mouse.
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    # Update physics settings.
    physics_material_override.set_friction(FRICTION)
    set_linear_damp(LINEAR_DAMP)
    set_angular_damp(SPIN_DAMP)

    # Set vehicle parts' timers wait times.
    generator_rate.wait_time = GENERATOR_RATE
    blaster1_cool_down.wait_time = BLASTER1_COOL_DOWN
    blaster2_cool_down.wait_time = BLASTER2_COOL_DOWN

    # Initiate Hud from Vehicle for replenish values.
    hud.updateReplenishValues(replenish_engines, replenish_shields, replenish_blasters)
    
    loadBoltScenes()



####################################################################################################
                                                                             ###   READY FUNCS   ###
                                                                             #######################

func assignPartValues():
    """
    Needed for reassigning variables...  Variables cannot be designated in _ready() because their
    node reference doesn't exist at scene instance.  So, they must be forced to be reassigned
    after nodes they're pointing to are made children in Gameplay.gd.
    """

    if blaster1_tag:
        barrel1_pivot = get_node('Parts/Blaster1Pos/%s/BarrelPivot*' % blaster1_tag)
        bolt1_spawn = barrel1_pivot.get_node('BoltSpawn*')
    if blaster2_tag:
        barrel2_pivot = get_node('Parts/Blaster2Pos/%s/BarrelPivot*' % blaster2_tag)
        bolt2_spawn = barrel2_pivot.get_node('BoltSpawn*')



func adjustForNoShields():
    """
    Reassignments made to generator replenishment values.  There is no need to make any other
    adjustments to energy or health transfer values.  That is handled in the math.
    """
    
    # Reassign replenish_sets.
    replenish_sets = no_shields_replenish_sets
    # Reassign initial values individual replenish values.
    replenish_engines = replenish_sets[repl_set_pointer]['engines']
    replenish_shields = replenish_sets[repl_set_pointer]['shields']
    replenish_blasters = replenish_sets[repl_set_pointer]['blasters']
    # Reset initial hud replenish values.
    hud.updateReplenishValues(replenish_engines, replenish_shields, replenish_blasters)



func loadBoltScenes():
    
    if blaster1_tag:  Bolt1 = load('res://Scenes/Functional/Projectiles/' + bolt1_tag + '.tscn')
    if blaster2_tag:  Bolt2 = load('res://Scenes/Functional/Projectiles/' + bolt2_tag + '.tscn')



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(_delta):

    ###   OBSOLETE   ###
#    # Clamp vehicle's max speed.
#    if linear_velocity.length() > MAX_SPEED:
#        linear_velocity = linear_velocity.normalized() * MAX_SPEED

    # Targetting logic...  'spawn_bolt' looks at whatever 'scope' is looking at.  This is to
    # ensure that whatever is in the player's crosshairs is the point that will be shot at.
    if scope.is_colliding():  pointing_at = scope.get_collision_point()
    else:  pointing_at = look_default.global_transform.origin
    bolt1_spawn.look_at(pointing_at, Vector3.UP)
    bolt2_spawn.look_at(pointing_at, Vector3.UP)

    ###   NEED TO FIX   ###
    # Barrel rotation needs rework.  Current rotation is based on global rotation. Should be based
    # on local or parent rotation.  Can see the issue in the barrel's rotation while vehicle is on
    # a gravity inversion slope.

    # Point barrel1_pivot at pointing_at.
    if blaster1_tag:
        barrel1_pivot.look_at(pointing_at, gravity_dir * -1)
        barrel1_pivot.rotation_degrees.y = -90
        barrel1_pivot.rotation_degrees.x = clamp(barrel1_pivot.rotation_degrees.x, 0, 90)
    # Point barrel2_pivot at pointing_at.
    if blaster2_tag:
        barrel2_pivot.look_at(pointing_at, gravity_dir * -1)
        barrel2_pivot.rotation_degrees.y = -90
        barrel2_pivot.rotation_degrees.x = clamp(barrel2_pivot.rotation_degrees.x, 0, 90)

    nonPhysicsInputEvents()



func _physics_process(_delta):

    # Apply gravity.
    var grav_force_dir = applyGravDirToGravForce()
    apply_central_impulse(grav_force_dir)

    # Apply player input force.
    var vel = getWasdInput()
    var vel_dir = applyGravToVel(vel)
    apply_central_impulse(vel_dir)



func _integrate_forces(state):

    # Physics processing method of clamping speed.
    if state.linear_velocity.length() > MAX_SPEED:
        state.linear_velocity = state.linear_velocity.normalized() * MAX_SPEED
    
    # Handle rotation with applied gravity.
    var rot_force_dir = applyGravToRotForce()
    apply_torque_impulse(rot_force_dir)



func _unhandled_input(event):

    # BLOCK ... Vehicle mouse controls (while mouse is captured).
    # Only perform vehicle mouse controls if 'mouse_motion' and 'mouse_captured' are True.
    var mouse_motion = event is InputEventMouseMotion
    var mouse_captured = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
    if mouse_motion and mouse_captured:

        rot_force = -event.relative.x * MOUSE_SENSITIVITY * SPIN

        # Mouse motion on the y-axis translates to camera ('pivot') motion on the z-axis.
        camera_pivot.rotate_z(-event.relative.y * MOUSE_SENSITIVITY * MOUSE_VERT_DAMP)
        # Have to apply 'clamp' to prevent extreme camera positions.
        camera_pivot.rotation.z = clamp(camera_pivot.rotation.z, -1.2, 0.6)



####################################################################################################
                                                                           ###   PROCESS FUNCS   ###
                                                                           #########################

func nonPhysicsInputEvents():

    # Blaster / Bolt controls.
    if Input.is_action_pressed('ui_accept'):
        if bolt1_tag and blaster1_cooled_down and (blaster1_battery >= BOLT1_ENERGY):
            var bolt1 = Bolt1.instance()
            get_node('/root/Gameplay/VehicleBolts').add_child(bolt1)
            bolt1.spawn(bolt1_spawn.global_transform)
            blaster1_battery -= BOLT1_ENERGY
            hud.updateBlasterBatteryValue(blaster1_battery)
            blaster1_cool_down.start()
            blaster1_cooled_down = false

    # Replenish controls.
    if Input.is_action_just_pressed('ui_focus_next'):
        if repl_set_pointer <= len(replenish_sets) - 2:  repl_set_pointer += 1
        else:  repl_set_pointer = 0
        replenish_engines =     replenish_sets[repl_set_pointer]['engines']
        replenish_shields =     replenish_sets[repl_set_pointer]['shields']
        replenish_blasters =    replenish_sets[repl_set_pointer]['blasters']
        hud.updateReplenishValues(replenish_engines, replenish_shields, replenish_blasters)

    # Focus controls.
    if Input.is_action_just_pressed('ui_focus_prev'):
        var focus = scope.get_collider()
        # Only perform focus object update if focus is in Targets.
        if focus != null and focus.get_parent().name == 'Targets':  hud.updateFocusObject(focus)



func applyGravDirToGravForce():
    # With the changing of direction of gravity, gravity has to be manually applied via function.

    var applied_grav_ = Vector3()
    for axis in range(3):  applied_grav_[axis] = gravity_dir[axis] * GRAVITY_FORCE

    return applied_grav_



func applyGravToRotForce():
    # With the changing of direction of gravity, gravity has to be manually applied via function.

    var applied_rot_force_ = Vector3()
    for axis in range(3):  applied_rot_force_[axis] = -gravity_dir[axis] * rot_force

    return applied_rot_force_



func applyGravToVel(_vel):
    # With the changing of direction of gravity, gravity has to be manually applied via function.

    var applied_vel_ = Vector3()

    # Gravity is applied specifically to each rotational direction based on gravity's direction in
    # 3D space.
    match gravity_dir:
        Vector3.DOWN:
            applied_vel_ = _vel.rotated(Vector3.UP, rotation.y)
        Vector3.FORWARD:
            _vel = _vel.rotated(Vector3(1, 0, 0), deg2rad(90))
            var vel_rotation = rotation.x - deg2rad(90)
            if rotation.y >= 0:  vel_rotation = -vel_rotation
            applied_vel_ = _vel.rotated(transform.basis.y, vel_rotation)
        Vector3.RIGHT:
            _vel = _vel.rotated(Vector3(0, 0, 1), deg2rad(90))
            var vel_rotation = -rotation.x
            if rotation.z <= 0:  vel_rotation = -vel_rotation + deg2rad(180)
            applied_vel_ = _vel.rotated(transform.basis.y, vel_rotation)

    return applied_vel_



func getWasdInput():
    # WASD controls; primary user input of force on vehicle.

    var wasd_vel_ = Vector3()

    # With 'THRUST', apply WASD up/down input to 'vel' x-axis (forward/backward).
    if Input.is_action_pressed('ui_up'):	wasd_vel_ += Vector3(+THRUST * replenish_engines, 0, 0)
    if Input.is_action_pressed('ui_down'):	wasd_vel_ += Vector3(-THRUST * replenish_engines, 0, 0)
    # With 'THRUST', apply WASD left/right input to 'vel' z-axis (left/right).
    if Input.is_action_pressed('ui_left'):	wasd_vel_ += Vector3(0, 0, -THRUST * replenish_engines)
    if Input.is_action_pressed('ui_right'):	wasd_vel_ += Vector3(0, 0, +THRUST * replenish_engines)

    return wasd_vel_



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_Blaster1CoolDown_timeout():

    blaster1_cooled_down = true



func _on_Blaster2CoolDown_timeout():

    blaster2_cooled_down = true



func _on_GeneratorRate_timeout():
    # Regulate blaster battery and shields battery replenishment.  Only replenish if battery is not
    # full.  If replenishment overfills battery, clamp it.  Then update Hud.

    if blaster1_battery < BLASTER1_BATTERY_CAPACITY:
        blaster1_battery += REPLENISH * replenish_blasters
        blaster1_battery = clamp(blaster1_battery, 0, BLASTER1_BATTERY_CAPACITY)
        hud.updateBlasterBatteryValue(blaster1_battery)
    if shields_battery < SHIELDS_BATTERY_CAPACITY:
        shields_battery += REPLENISH * replenish_shields * SHIELDS_CONCENTRATION
        shields_battery = clamp(shields_battery, 0, SHIELDS_BATTERY_CAPACITY)
        hud.updateShieldsBatteryValue(shields_battery)



# func printTransformBasis():
#     print("rot ", rotation_degrees)
#     print("X   ", transform.basis.x)
#     print("Y   ", transform.basis.y)
#     print("Z   ", transform.basis.z)
#     print("\n")



####################################
"""   UNDER CONSTRUCTION   >>>   """
####################################

####################################
"""   <<<   UNDER CONSTRUCTION   """
####################################






