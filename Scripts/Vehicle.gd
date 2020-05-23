


extends VehicleBody

# singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

### Get tags.
onready var body_tag =      controls.gameplay['vehicle']['body']
onready var generator_tag = controls.gameplay['vehicle']['generator']
onready var engines_tag =   controls.gameplay['vehicle']['engines']
onready var shields_tag =   controls.gameplay['vehicle']['shields']
### (expandables)
onready var blaster_tags = []

### Get global control variables.
onready var GRAVITY_FORCE =         controls.global['vehicle']['gravity_force']
onready var FRICTION =              controls.global['vehicle']['friction']
onready var SPIN =                  controls.global['vehicle']['spin']
onready var LINEAR_DAMP =           controls.global['vehicle']['linear_damp']
onready var SPIN_DAMP =             controls.global['vehicle']['spin_damp']
onready var MOUSE_SENSITIVITY =     controls.global['vehicle']['mouse_sensitivity']
onready var MOUSE_VERT_DAMP =       controls.global['vehicle']['mouse_vert_damp']

# onready var REST_LINEAR_DAMP =      controls.global['vehicle']['rest_linear_damp']

### Get parts' control variables.
onready var HEALTH =                    controls.body[body_tag]['health']
onready var ARMOR =                     controls.body[body_tag]['armor']
onready var BLASTER_SLOTS =             controls.body[body_tag]['blaster_slots']
onready var SHIELDS_BATTERY_CAPACITY =  controls.shields[shields_tag]['battery_capacity']
onready var SHIELDS_DENSITY =           controls.shields[shields_tag]['density']
onready var SHIELDS_CONCENTRATION =     controls.shields[shields_tag]['concentration']
onready var THRUST =                    controls.engines[engines_tag]['thrust']
onready var MAX_SPEED =                 controls.engines[engines_tag]['max_speed']
onready var GENERATOR_RATE =            controls.generators[generator_tag]['rate']
onready var REPLENISH =                 controls.generators[generator_tag]['replenish']
### (expandables)
onready var BLASTER_BATTERY_CAPACITIES = []
onready var BLASTER_COOL_DOWNS = []
onready var BOLT_ENERGIES = []






####################################################################################################
                                                                               ###   NODE REFS   ###
                                                                               #####################

### Container nodes.
onready var _non_spatial_ = find_node('NonSpatial*')
onready var _parts_ = find_node('Parts*')

onready var hud = _non_spatial_.find_node('Hud')
onready var generator_rate = _non_spatial_.find_node('GeneratorRate*')
onready var camera_pivot = find_node('CameraPivot*')
onready var scope = camera_pivot.find_node('Scope*')
onready var look_default = camera_pivot.find_node('LookDefault*')

### (expandables)
onready var blaster_cool_downs = []



####################################################################################################
                                                                                    ###   VARS   ###
                                                                                    ################

### Generator replenishment sets.
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
onready var no_blasters_replenish_sets = [
    {'engines': 0.50, 'shields': 0.50, 'blasters': 0.00},
    {'engines': 0.90, 'shields': 0.10, 'blasters': 0.00},
    {'engines': 0.10, 'shields': 0.90, 'blasters': 0.00},
]
onready var only_engines_replenish_sets = [
    {'engines': 1.00, 'shields': 0.00, 'blasters': 0.00},
]

"""
TO-DOS:  Maybe set replenishment values in a ready func.  Initiating them now, then resetting later
based on no-shields or no-blasters is a waste.
"""

### Working vars.
onready var cur_repl_set = 0
onready var cur_blaster = 0
onready var pointing_at = Vector3()
onready var rot_force = 0.0
onready var gravity_force = 2.00
onready var gravity_dir = Vector3.DOWN
### (expandables)
onready var barrel_pivots = []
onready var bolt_spawns = []
onready var blaster_cooled_downs = []
onready var blaster_batteries = []
onready var Bolts = []

### Initialize replenishment values as first set from 'replenish_sets'.
onready var replenish_engines =     replenish_sets[cur_repl_set]['engines']
onready var replenish_shields =     replenish_sets[cur_repl_set]['shields']
onready var replenish_blasters =    replenish_sets[cur_repl_set]['blasters']
### Initialize shields var.
onready var shields_battery = SHIELDS_BATTERY_CAPACITY



var has_blasters



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
    print("\n>>> [%s] scripted scene entering tree" % name)
    
    """
    TO-DOS:  Mouse capture should be handled in Gameplay.gd.
    """
    # Capture mouse.
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    # Update physics settings.
    physics_material_override.set_friction(FRICTION)
    set_linear_damp(LINEAR_DAMP)
    set_angular_damp(SPIN_DAMP)
    
    # Among variable generations and model instancing, tags have to come first.
    generateExpandableTags()
    
    instancePartModels()
    
    generateExpandableControlVars()
    
    generateExpandableWorkingVars()
    
    generateExpandableNodeRefs()
    
    setNodeRefValues()
    
    setExpandableNodeRefValues()
    
    setReplenishSets()
    hud.updateReplenishValues(replenish_engines, replenish_shields, replenish_blasters)
    
    print("\n>>> [%s] ready..." % name)



####################################################################################################
                                                                             ###   READY FUNCS   ###
                                                                             #######################

func generateExpandableTags():
    """
    Generate expandable tags.
    """
    
    has_blasters = false
    
    for blaster in BLASTER_SLOTS:
        
        var blaster_tag = controls.gameplay['vehicle'][blaster]
        
        blaster_tags += [ blaster_tag ]
        
        if blaster_tag != '':  has_blasters = true



func instancePartModels():
    """
    Instance part models.  Must succeed generateExpandableTags().
    """
    
    # Instance generator model.
    var Generator = load('res://Scenes/Models/VehicleParts/Generators/%s.tscn' % generator_tag)
    var generator_pos = _parts_.find_node('GeneratorPos*')
    generator_pos.add_child(Generator.instance())
    
    # Instance engines models.
    var Engines = load('res://Scenes/Models/VehicleParts/Engines/%s.tscn' % engines_tag)
    var engines_suffixes = ['Fr', 'Br', 'Bl', 'Fl']
    for suffix in engines_suffixes:
        var engine_pos = _parts_.find_node('Engine%sPos*' % suffix)
        engine_pos.add_child(Engines.instance())
    
    # If applicable, instance shields model.
    if shields_tag:
        var Shields = load('res://Scenes/Models/VehicleParts/Shields/%s.tscn' % shields_tag)
        var shields_pos = _parts_.find_node('ShieldsPos*')
        shields_pos.add_child(Shields.instance())
    
    # If applicable, instance blasters models.
    for i in range(len(blaster_tags)):
        var blaster_tag = blaster_tags[i]
        if blaster_tag:
            var Blaster = load('res://Scenes/Models/VehicleParts/Blasters/%s.tscn' % blaster_tag)
            var blaster_pos = _parts_.find_node('Blaster%sPos*' % str(i + 1))
            blaster_pos.add_child(Blaster.instance())



func generateExpandableControlVars():
    """
    Generate expandable control variables.  Must succeed generateExpandableTags().
    """
    
    for blaster_tag in blaster_tags:
        BLASTER_BATTERY_CAPACITIES +=   [ controls.blasters[blaster_tag]['battery_capacity'] ]
        BLASTER_COOL_DOWNS +=           [ controls.blasters[blaster_tag]['cool_down'] ]
        BOLT_ENERGIES +=                [ controls.blasters[blaster_tag]['energy'] ]



func generateExpandableWorkingVars():
    """
    Generate expandable working variables.  Must succeed generateExpandableTags() and
    generateExpandableControlVars().
    """

    for i in range(len(blaster_tags)):
        var blaster_tag = blaster_tags[i]
        
        if blaster_tag:
            var blaster_pos = _parts_.find_node('Blaster%sPos*' % str(i + 1))
            barrel_pivots +=        [ blaster_pos.find_node('BarrelPivot*', true, false) ]
            bolt_spawns +=          [ blaster_pos.find_node('BoltSpawn*', true, false) ]
            blaster_cooled_downs += [ true ]
            blaster_batteries +=    [ BLASTER_BATTERY_CAPACITIES[i] ]
            
            """
            Need to use load().new() for passing arguments when instancing.
            """
            
            # Load Bolt scenes into Bolts expandable.
            var bolt_tag = 'VehicleBolt' + blaster_tag.right(7)
            Bolts += [ load('res://Scenes/Functional/Projectiles/%s.tscn' % bolt_tag) ]
        
        else:
            barrel_pivots +=        [ null ]
            bolt_spawns +=          [ null ]
            blaster_cooled_downs += [ null ]
            blaster_batteries +=    [ 0 ]
            Bolts +=                [ null ]



func generateExpandableNodeRefs():
    """
    Generate expandable node references.  Must succeed generateExpandableTags().
    """
    
    for i in range(len(BLASTER_SLOTS)):
        blaster_cool_downs += [ _non_spatial_.find_node('Blaster%sCoolDown*' % str(i + 1)) ]



func setNodeRefValues():
    """
    Set dynamic values of nodes. 
    """
    
    generator_rate.wait_time = GENERATOR_RATE



func setExpandableNodeRefValues():
    """
    Set dynamic values of nodes from expandable node groups. 
    """
    
    for i in range(len(BLASTER_SLOTS)):
        blaster_cool_downs[i].wait_time = BLASTER_COOL_DOWNS[i]



func setReplenishSets():
    
    if not shields_tag:  replenish_sets = no_shields_replenish_sets
    if not has_blasters:  replenish_sets = no_blasters_replenish_sets
    if not shields_tag and not has_blasters:  replenish_sets = only_engines_replenish_sets
    
    replenish_engines =     replenish_sets[cur_repl_set]['engines']
    replenish_shields =     replenish_sets[cur_repl_set]['shields']
    replenish_blasters =    replenish_sets[cur_repl_set]['blasters']



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(_delta):

    ###   OBSOLETE   ###
#    # Clamp vehicle's max speed. 
#    if linear_velocity.length() > MAX_SPEED:
#        linear_velocity = linear_velocity.normalized() * MAX_SPEED

#    print("has_blasters = ", has_blasters)
    if has_blasters:
        # Targetting logic...  'spawn_bolt' looks at whatever 'scope' is looking at.  This is to
        # ensure that whatever is in the player's crosshairs is the point that will be shot at.
        if scope.is_colliding():  pointing_at = scope.get_collision_point()
        else:  pointing_at = look_default.global_transform.origin
        bolt_spawns[cur_blaster].look_at(pointing_at, Vector3.UP)

        ###   NEED TO FIX   ###
        # Barrel rotation needs rework.  Current rotation is based on global rotation. Should be based
        # on local or parent rotation.  Can see the issue in the barrel's rotation while vehicle is on
        # a gravity inversion slope.

        # Point barrel_pivot at pointing_at.
        barrel_pivots[cur_blaster].look_at(pointing_at, gravity_dir * -1)
        barrel_pivots[cur_blaster].rotation_degrees.y = -90
        barrel_pivots[cur_blaster].rotation_degrees.x = clamp(
            barrel_pivots[cur_blaster].rotation_degrees.x, 0, 90
        )

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
    # Handling of mouse input.

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
    
    
    
    """
    TURNOVER:
    
    - So far it appears as if the builds and connections of the blaster expansions are working
    correctly.  But I can't say 100%.  It appears as if all that's left is the functionality of the
    hud's blaster expansion as well as the vehicle's generator replenishment.
    
    - Will still need like blaster linking and blaster replenishment options.
    """
    
    """
    TO-DO:  document...
    """
    
    if event is InputEventMouseButton and event.is_pressed():
        if event.button_index == BUTTON_WHEEL_UP:
            if cur_blaster <= len(BLASTER_SLOTS) - 2:  cur_blaster += 1
            else:  cur_blaster = 0
            if blaster_tags[cur_blaster] == '':
                if cur_blaster <= len(BLASTER_SLOTS) - 2:  cur_blaster += 1
                else:  cur_blaster = 0

        if event.button_index == BUTTON_WHEEL_DOWN:
            if cur_blaster != 0:  cur_blaster -= 1
            else:  cur_blaster = len(BLASTER_SLOTS) - 1
            if blaster_tags[cur_blaster] == '':
                if cur_blaster != 0:  cur_blaster -= 1
                else:  cur_blaster = len(BLASTER_SLOTS) - 1
            
        hud.updateBlasterCurrentValue(cur_blaster)



####################################################################################################
                                                                           ###   PROCESS FUNCS   ###
                                                                           #########################

func nonPhysicsInputEvents():

    # Blaster / Bolt controls.
    if Input.is_action_pressed('ui_accept') and has_blasters:
#        if bolt1_tag and blaster1_cooled_down and (blaster1_battery >= BOLT1_ENERGY):
        if blaster_cooled_downs[cur_blaster] and (blaster_batteries[cur_blaster] >= BOLT_ENERGIES[cur_blaster]):
#            var bolt = Bolts[cur_blaster].instance().init(blaster_tags[cur_blaster])
            var bolt = Bolts[cur_blaster].instance()
            
#            print(bolt.name)
            
            # I think this should be handled in Gameplay.gd.
            get_node('/root/Main/Gameplay/VehicleBolts').add_child(bolt)
            
            bolt.spawn(bolt_spawns[cur_blaster].global_transform)
            blaster_batteries[cur_blaster] -= BOLT_ENERGIES[cur_blaster]
            
            ###
            hud.updateBlasterBatteryValue(cur_blaster, blaster_batteries[cur_blaster])
            ###
            
            blaster_cool_downs[cur_blaster].start()
            blaster_cooled_downs[cur_blaster] = false

#    if Input.is_action_pressed('ui_page_up'):
#        print("wheel working")

    # Replenish controls.
    if Input.is_action_just_pressed('ui_focus_next'):
        if cur_repl_set <= len(replenish_sets) - 2:  cur_repl_set += 1
        else:  cur_repl_set = 0
        replenish_engines =     replenish_sets[cur_repl_set]['engines']
        replenish_shields =     replenish_sets[cur_repl_set]['shields']
        replenish_blasters =    replenish_sets[cur_repl_set]['blasters']
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

func _on_GeneratorRate_timeout():
    # Regulate blaster battery and shields battery replenishment.  Only replenish if battery is not
    # full.  If replenishment overfills battery, clamp it.  Then update Hud.

    """
    TO-DOS:  Need to update for multiple blasters.
    """
#    pass
#    if blaster1_battery < BLASTER1_BATTERY_CAPACITY:
#        blaster1_battery += REPLENISH * replenish_blasters
#        blaster1_battery = clamp(blaster1_battery, 0, BLASTER1_BATTERY_CAPACITY)
#        hud.updateBlasterBatteryValue(blaster1_battery)

    var replenish_each_blaster = getReplEachBlaster()

    for i in range(len(blaster_tags)):
        if blaster_batteries[i] < BLASTER_BATTERY_CAPACITIES[i]:
            blaster_batteries[i] += REPLENISH * replenish_blasters * replenish_each_blaster[i]
            blaster_batteries[i] = clamp(blaster_batteries[i], 0, BLASTER_BATTERY_CAPACITIES[i])
            hud.updateBlasterBatteryValue(i, blaster_batteries[i])

    if shields_battery < SHIELDS_BATTERY_CAPACITY:
        shields_battery += REPLENISH * replenish_shields * SHIELDS_CONCENTRATION
        shields_battery = clamp(shields_battery, 0, SHIELDS_BATTERY_CAPACITY)
        hud.updateShieldsBatteryValue(shields_battery)

func getReplEachBlaster():
    
    var repl_each = []
    
    for i in range(len(blaster_tags)):  repl_each += [ 1 / float(len(blaster_tags)) ]
    
    for i in range(len(blaster_tags)):
        if blaster_batteries[i] == BLASTER_BATTERY_CAPACITIES[i]:
            
            ###
            for each_i in range(len(repl_each)):
                if i == each_i:  continue
                repl_each[each_i] += float(repl_each[i]) / (len(blaster_tags) - 1)
            ###
            
            repl_each[i] = 0
            
    
#    print("len(blaster_tags) = ", len(blaster_tags))
#    print("1 / len(blaster_tags) = ", 1 % len(blaster_tags))
#    print("\n", repl_each)
    
    return repl_each



func _on_Blaster1CoolDown_timeout():
    
    blaster_cooled_downs[0] = true



func _on_Blaster2CoolDown_timeout():
    
    blaster_cooled_downs[1] = true
