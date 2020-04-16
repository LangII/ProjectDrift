
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
onready var blaster1_tag =  controls.gameplay['vehicle']['blaster1']
onready var bolt1_tag =     controls.blasters[blaster1_tag]['bolt_scene']

# Get global control variables.
onready var GRAVITY_FORCE =         controls.global['vehicle']['gravity_force']
onready var FRICTION =              controls.global['vehicle']['friction']
onready var SPIN =                  controls.global['vehicle']['spin']
onready var LINEAR_DAMP =           controls.global['vehicle']['linear_damp']
# onready var REST_LINEAR_DAMP =      controls.global['vehicle']['rest_linear_damp']
onready var SPIN_DAMP =             controls.global['vehicle']['spin_damp']
onready var MOUSE_SENSITIVITY =     controls.global['vehicle']['mouse_sensitivity']
onready var MOUSE_VERT_DAMP =       controls.global['vehicle']['mouse_vert_damp']

# Get parts' control variables.
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
onready var BLASTER1_COOL_DOWN =        controls.blasters[blaster1_tag]['cool_down']
onready var BOLT1_ENERGY =              controls.blasters[blaster1_tag]['energy']



####################################################################################################
                                                                               ###   FUNC VARS   ###
                                                                               #####################

# Generator / Replenishment.
onready var generator_rate = $NonSpatial/GeneratorRate
onready var replenish_sets = [
    {'engines': 0.34, 'shields': 0.33, 'blasters': 0.33},
    {'engines': 0.80, 'shields': 0.10, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.80, 'blasters': 0.10},
    {'engines': 0.10, 'shields': 0.10, 'blasters': 0.80},
]
onready var repl_set_pointer = 0

# Blaster / Bolt.
onready var Bolt1 = load('res://Scenes/Functional/Projectiles/' + bolt1_tag + '.tscn')
onready var blaster1_cool_down = $NonSpatial/BlasterCoolDown



#onready var barrel1_pivot = get_node('Parts/Blaster1Pos/%s/BarrelPivot' % blaster1_tag)
#onready var bolt1_spawn = $SpawnBolt
onready var barrel1_pivot = $TempPivot
onready var bolt1_spawn = $TempSpawn



onready var scope = $CameraPivot/Camera/Scope
onready var look_default = $CameraPivot/Camera/Scope/LookDefault
onready var pointing_at = Vector3()

# BLOCK ... Preset values.
onready var blaster1_cooled_down = true
# Initialize battery values as full.
onready var blaster1_battery = BLASTER1_BATTERY_CAPACITY
onready var shields_battery = SHIELDS_BATTERY_CAPACITY
# Initialize replenishment values as first set from 'replenish_sets'.
onready var replenish_engines = replenish_sets[repl_set_pointer]['engines']
onready var replenish_shields = replenish_sets[repl_set_pointer]['shields']
onready var replenish_blasters = replenish_sets[repl_set_pointer]['blasters']

# General function variables.
onready var hud = $NonSpatial/Hud
onready var camera_pivot = $CameraPivot
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
    set_linear_damp(LINEAR_DAMP)
    set_angular_damp(SPIN_DAMP)

    # Set vehicle parts' timers wait times.
    generator_rate.wait_time = GENERATOR_RATE
    blaster1_cool_down.wait_time = BLASTER1_COOL_DOWN

    # Initiate Hud from Vehicle for replenish values.
    hud.updateReplenishValues(replenish_engines, replenish_shields, replenish_blasters)



func assignPartValues():

    barrel1_pivot = get_node('Parts/Blaster1Pos/%s/BarrelPivot' % blaster1_tag)
    bolt1_spawn = barrel1_pivot.get_node('BoltSpawn')
    
    print("WORKED")



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
        camera_pivot.rotate_z(-event.relative.y * MOUSE_SENSITIVITY * MOUSE_VERT_DAMP)
        # Have to apply 'clamp' to prevent extreme camera positions.
        camera_pivot.rotation.z = clamp(camera_pivot.rotation.z, -1.2, 0.6)



func _process(delta):

    ###   OBSOLETE   ###
    # # Clamp vehicle's max speed.
    # if linear_velocity.length() > MAX_SPEED:
    #     linear_velocity = linear_velocity.normalized() * MAX_SPEED

    # Targetting logic...  'spawn_bolt' looks at whatever 'scope' is looking at.  This is to ensure
    # that whatever is in the player's crosshairs is the point that will be shot at.
    if scope.is_colliding():  pointing_at = scope.get_collision_point()
    else:  pointing_at = look_default.global_transform.origin
    bolt1_spawn.look_at(pointing_at, Vector3.UP)



    ####################################
    """   UNDER CONSTRUCTION   >>>   """
    ####################################



    """
    TURNOVER NOTES:  Need to optimize variable designations.  'barrel1_pivot' and 'bolt1_spawn'
        should be assigned onready.  But they can't be because they're dependent on child scenes
        that are generated after scene instancing.  ...  Not sure how to fix it.
    """

    # Visuals of rotating blaster barrel to look at 'pointing_at'.
#    var barrel1_pivot = get_node('Parts/Blaster1Pos/%s/BarrelPivot' % blaster1_tag)
#    bolt1_spawn = barrel1_pivot.get_node('BoltSpawn')
    barrel1_pivot.look_at(pointing_at, Vector3.UP)
    barrel1_pivot.rotation_degrees.y = -90
    barrel1_pivot.rotation_degrees.x = clamp(barrel1_pivot.rotation_degrees.x, 0, 90)



    ####################################
    """   <<<   UNDER CONSTRUCTION   """
    ####################################



    ###   INPUT EVENTS   ###

    # BLOCK ... Blaster / Bolt controls.
    if Input.is_action_pressed('ui_accept'):
        
        ###
        
        if bolt1_tag and blaster1_cooled_down and (blaster1_battery >= BOLT1_ENERGY):
            
        ###
            
            var bolt1 = Bolt1.instance()
            get_node('/root/Gameplay/VehicleBolts').add_child(bolt1)
            bolt1.spawn(bolt1_spawn.global_transform)
            blaster1_battery -= BOLT1_ENERGY
            hud.updateBlasterBatteryValue(blaster1_battery)
            blaster1_cool_down.start()
            blaster1_cooled_down = false

    # BLOCK ... Replenish controls.
    if Input.is_action_just_pressed('ui_focus_next'):
        if repl_set_pointer <= len(replenish_sets) - 2:  repl_set_pointer += 1
        else:  repl_set_pointer = 0
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
    for axis in range(3):  applied_grav[axis] = gravity_dir[axis] * GRAVITY_FORCE

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

    blaster1_cooled_down = true



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
