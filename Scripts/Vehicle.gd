


extends VehicleBody

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

### Get tags.
onready var body_tag =      controls.gameplay['vehicle_rig']['body']['part_tag']
onready var generator_tag = controls.gameplay['vehicle_rig']['generator']['part_tag']
onready var engines_tag =   controls.gameplay['vehicle_rig']['engines']['part_tag']
onready var shields_tag =   controls.gameplay['vehicle_rig']['shields']['part_tag']
### (expandables)
onready var blaster_tags = []
onready var launcher_full_tags = []
onready var launcher_types = []
onready var launcher_tags = []

### Get global control variables.
onready var GRAVITY_FORCE =         controls.global['vehicle']['gravity_force']
onready var FRICTION =              controls.global['vehicle']['friction']
onready var SPIN =                  controls.global['vehicle']['spin']
onready var LINEAR_DAMP =           controls.global['vehicle']['linear_damp']
onready var SPIN_DAMP =             controls.global['vehicle']['spin_damp']
onready var MOUSE_SENSITIVITY =     controls.global['vehicle']['mouse_sensitivity']
onready var MOUSE_VERT_DAMP =       controls.global['vehicle']['mouse_vert_damp']

### (still not sure if I might need this at some point)
# onready var REST_LINEAR_DAMP =      controls.global['vehicle']['rest_linear_damp']

### Get parts' control variables.
onready var vehicle_rig = controls.gameplay['vehicle_rig']
onready var HEALTH =                    vehicle_rig['body']['part_stats']['health']
onready var ARMOR =                     vehicle_rig['body']['part_stats']['armor']
onready var BLASTER_SLOTS =             vehicle_rig['body']['part_stats']['blaster_slots']
onready var LAUNCHER_SLOTS =            vehicle_rig['body']['part_stats']['launcher_slots']
onready var SHIELDS_BATTERY_CAPACITY =  vehicle_rig['shields']['part_stats']['battery_capacity']
onready var SHIELDS_DENSITY =           vehicle_rig['shields']['part_stats']['density']
onready var SHIELDS_CONCENTRATION =     vehicle_rig['shields']['part_stats']['concentration']
onready var THRUST =                    vehicle_rig['engines']['part_stats']['thrust']
onready var MAX_SPEED =                 vehicle_rig['engines']['part_stats']['max_speed']
onready var GENERATOR_RATE =            vehicle_rig['generator']['part_stats']['rate']
onready var REPLENISH =                 vehicle_rig['generator']['part_stats']['replenish']
### (expandables)
onready var BLASTER_BATTERY_CAPACITIES = []
onready var BLASTER_COOL_DOWNS = []
onready var BOLT_ENERGIES = []
onready var LAUNCHER_MAGAZINE_CAPACITIES = []
onready var LAUNCHER_COOL_DOWNS = []



####################################################################################################
                                                                               ###   NODE REFS   ###
                                                                               #####################

### Container node references.
onready var _parts_ = find_node('Parts*')
onready var _non_spatial_ = find_node('NonSpatial*')
### Node references.
onready var hud = _non_spatial_.find_node('Hud')
onready var generator_rate = _non_spatial_.find_node('GeneratorRate*')
onready var camera_pivot = find_node('CameraPivot*')
onready var scope = camera_pivot.find_node('Scope*')
onready var look_default = camera_pivot.find_node('LookDefault*')
onready var spawn_ref = find_node('SpawnRef*')
### (expandables)
onready var blaster_cool_downs = []
onready var launcher_cool_downs = []



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

onready var all_launcher_types = ['Missile',]

### Working vars.
onready var cur_repl_set = 0
onready var cur_blaster = 0
onready var cur_launcher = 0
onready var pointing_at = Vector3()
onready var rot_force = 0.0
onready var gravity_force = 2.00
onready var gravity_dir = Vector3.DOWN
onready var has_shields = false
onready var has_blasters = false
onready var has_launchers = false
onready var input_shifting = false
onready var input_repl_shifting = false
onready var replenish = {}
### (expandables)
onready var blaster_barrel_pivots = []
onready var blaster_proj_spawns = []
onready var blaster_cooled_downs = []
onready var blaster_batteries = []
onready var Bolts = []
onready var launcher_barrel_pivots = []
onready var launcher_proj_spawns = []
onready var launcher_cooled_downs = []
onready var launcher_magazines = []
onready var Rounds = []

### Initialize shields var.
onready var shields_battery = SHIELDS_BATTERY_CAPACITY



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
    print("\n>>> [%s] scripted scene entering tree" % name)
    
    # Open temp mods.
    var boost_mod = main.loadModule(main, 'res://Scenes/Functional/BoostMod.tscn')
    
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
    generateExpandableSlotsAndTags()
    
    setHasShields()
    
    setHasBlasters()
    
    setHasLaunchers()
    
    instancePartModels()
    
    boost_mod.instanceBoostModels()
    
    generateExpandableControlVars()
    
    generateExpandableWorkingVars()
    
    resetProjSpawnPos()
    
    generateExpandableNodeRefs()
    
    setNodeRefValues()
    
    setExpandableNodeRefValues()
    
    setReplenishSets()
    
    hud.updateReplenishValues(replenish['engines'], replenish['shields'], replenish['blasters'])
    
    setCurrents()
    
    # Close temp mods.
    boost_mod.queue_free()
    
    print("\n>>> [%s] ready..." % name)



####################################################################################################
                                                                             ###   READY FUNCS   ###
                                                                             #######################

func generateExpandableSlotsAndTags():
    """ Generate expandable tags. """
    
    for blaster in BLASTER_SLOTS:
        blaster_tags += [ controls.gameplay['vehicle_rig'][blaster]['part_tag'] ]
    
    for launcher in LAUNCHER_SLOTS:
        var full_tag = controls.gameplay['vehicle_rig'][launcher]['part_tag']
#        print("full_tag = ", full_tag)
        launcher_full_tags += [ full_tag ]
        launcher_tags += [ full_tag.right(full_tag.find('Launcher') + len('Launcher')) ]
        launcher_types += [ full_tag.left(full_tag.find('Launcher')) ]
    
#    print("LAUNCHER_SLOTS = ", LAUNCHER_SLOTS)
#    print("blaster_tags = ", blaster_tags)
#    print("launcher_full_tags = ", launcher_full_tags)
#    print("launcher_tags = ", launcher_tags)
#    print("launcher_types = ", launcher_types)



func setHasShields():
    """ Set value of has_shields. """
    
    if shields_tag:  has_shields = true



func setHasBlasters():
    """ Set value of has_blasters. """
    
    has_blasters = false
    for blaster_tag in blaster_tags:
        if blaster_tag != '':
            has_blasters = true
            break



func setHasLaunchers():
    """ Set value of has_launchers. """
    
    has_launchers = false
    for launcher_tag in launcher_tags:
        if launcher_tag != '':
            has_launchers = true
            break
    
    print("launcher_tags = ", launcher_tags)
    print("has_launchers = ", has_launchers)



func instancePartModels():
    """ Instance part models.  Must succeed generateExpandableTags(). """
    
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
    if has_shields:
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
    
    # If applicable, instance launcher models.
    if has_launchers:
        for i in range(len(launcher_tags)):
            var launcher_tag = launcher_tags[i]
            if launcher_tag:
                for type in all_launcher_types:
                    if launcher_types[i] == type:
                        var launcher_str = 'res://Scenes/Models/VehicleParts/Launchers/%s/%s.tscn'
                        var Launcher = load(launcher_str % [type, launcher_full_tags[i]])
                        var launcher_pos = _parts_.find_node('%sLauncher%sPos*' % [type, str(i + 1)])
                        launcher_pos.add_child(Launcher.instance())



func generateExpandableControlVars():
    """ Generate expandable control variables.  Has to come after generateExpandableTags(). """
    
    for i in range(len(blaster_tags)):
        var blaster_tag = blaster_tags[i]
        
        var blaster_stats = vehicle_rig['blaster_%s' % str(i + 1)]['part_stats']
        
        BLASTER_BATTERY_CAPACITIES +=   [ blaster_stats['battery_capacity'] ]
        BLASTER_COOL_DOWNS +=           [ blaster_stats['cool_down'] ]
        BOLT_ENERGIES +=                [ blaster_stats['energy'] ]
    
    for i in range(len(launcher_full_tags)):
        var launcher_full_tag = launcher_full_tags[i]
        for type in all_launcher_types:
            if launcher_types[i] == type:
                
                var rig_launcher_tag = '%slauncher_%s' % [type.to_lower(), str(i + 1)]
                var launcher_stats = vehicle_rig[rig_launcher_tag]['part_stats']
                
                LAUNCHER_MAGAZINE_CAPACITIES += [ launcher_stats['magazine_capacity'] ]
                LAUNCHER_COOL_DOWNS +=          [ launcher_stats['cool_down'] ]



func generateExpandableWorkingVars():
    """
    Generate expandable working variables.  Must succeed generateExpandableTags() and
    generateExpandableControlVars().
    """
    
    for i in range(len(blaster_tags)):
        var blaster_tag = blaster_tags[i]
        if blaster_tag:
            var blaster_pos = _parts_.find_node('Blaster%sPos*' % str(i + 1))
            blaster_barrel_pivots +=    [ blaster_pos.find_node('BarrelPivot*', true, false) ]
            blaster_proj_spawns +=      [ blaster_pos.find_node('ProjectileSpawn*', true, false) ]
            blaster_cooled_downs +=     [ true ]
            blaster_batteries +=        [ BLASTER_BATTERY_CAPACITIES[i] ]
            var bolt_tag = 'VehicleBolt' + blaster_tag.right(7)
            Bolts += [ load('res://Scenes/Functional/Projectiles/%s.tscn' % bolt_tag) ]
        else:
            blaster_barrel_pivots +=    [ null ]
            blaster_proj_spawns +=      [ null ]
            blaster_cooled_downs +=     [ null ]
            blaster_batteries +=        [ 0 ]
            Bolts +=                    [ null ]
    
    for i in range(len(launcher_full_tags)):
        var launcher_tag = launcher_tags[i]
        var launcher_type = launcher_types[i]
        if launcher_tag:
            var launcher_pos = _parts_.find_node('%sLauncher%sPos*' % [launcher_type, str(i + 1)])
            launcher_barrel_pivots += [ launcher_pos.find_node('BarrelPivot*', true, false) ]
            launcher_proj_spawns += [ launcher_pos.find_node('ProjectileSpawn*', true, false) ]
            launcher_cooled_downs += [ true ]
            launcher_magazines += [ LAUNCHER_MAGAZINE_CAPACITIES[i] ]
            var round_tag = 'Vehicle%sRound%s' % [launcher_type, launcher_tag]
            Rounds += [ load('res://Scenes/Functional/Projectiles/%s.tscn' % round_tag) ]
        else:
            launcher_barrel_pivots +=   [ null ]
            launcher_proj_spawns +=     [ null ]
            launcher_cooled_downs +=    [ null ]
            launcher_magazines +=       [ 0 ]
            Rounds +=                   [ null ]



func resetProjSpawnPos():
    """
    Projectile spawn positions need to be dynamically reset based on their distance from the spawn
    reference position.  Basically, this is so that blasters and launchers that are set further back
    on the vehicle body will not have their spawn points over lap with the body's collision shape.
    """
    
    var spawn_ref_pos = spawn_ref.global_transform.origin
    
    for i in range(len(blaster_tags)):
        if blaster_tags[i]:
            var pivot_pos = blaster_barrel_pivots[i].global_transform.origin
            var dist_to = pivot_pos.distance_to(spawn_ref_pos)
            blaster_proj_spawns[i].transform.origin.z = -dist_to
    
    for i in range(len(launcher_tags)):
        if launcher_tags[i]:
            var pivot_pos = launcher_barrel_pivots[i].global_transform.origin
            var dist_to = pivot_pos.distance_to(spawn_ref_pos)
            launcher_proj_spawns[i].transform.origin.z = -dist_to



func generateExpandableNodeRefs():
    """ Generate expandable node references.  Must succeed generateExpandableTags(). """
    
    for i in range(len(BLASTER_SLOTS)):
        blaster_cool_downs += [ _non_spatial_.find_node('Blaster%sCoolDown*' % str(i + 1)) ]
    for i in range(len(LAUNCHER_SLOTS)):
        launcher_cool_downs += [ _non_spatial_.find_node('Launcher%sCoolDown*' % str(i + 1)) ]



func setNodeRefValues():
    """ Set dynamic values of nodes. """
    
    generator_rate.wait_time = GENERATOR_RATE



func setExpandableNodeRefValues():
    """ Set dynamic values of nodes from expandable node groups. """
    
    for i in range(len(BLASTER_SLOTS)):
        blaster_cool_downs[i].wait_time = BLASTER_COOL_DOWNS[i]
        blaster_cool_downs[i].wait_time = BLASTER_COOL_DOWNS[i]
    for i in range(len(LAUNCHER_SLOTS)):
        launcher_cool_downs[i].wait_time = LAUNCHER_COOL_DOWNS[i]



func setReplenishSets():
    """ Set replenish_sets based on has_shields and has_blasters. """
    
    if not has_shields:  replenish_sets = no_shields_replenish_sets
    if not has_blasters:  replenish_sets = no_blasters_replenish_sets
    if not has_shields and not has_blasters:  replenish_sets = only_engines_replenish_sets
    
    replenish['engines'] =     replenish_sets[cur_repl_set]['engines']
    replenish['shields'] =     replenish_sets[cur_repl_set]['shields']
    replenish['blasters'] =    replenish_sets[cur_repl_set]['blasters']



func setCurrents():
    """ Set cur_blaster and cur_launcher based on tags. """
    
    if has_blasters:
        for tag in blaster_tags:
            if not tag:  cur_blaster += 1
            else:  break
        hud.updateBlasterCurrentValue(cur_blaster)
    if has_launchers:
        for tag in launcher_tags:
            if not tag:  cur_launcher += 1
            else:  break
        hud.updateLauncherCurrentValue(cur_launcher)



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(_delta):
    
    setPointingAt()
    if has_blasters:  setBlasterTargetting()
    if has_launchers:  setLauncherTargetting()

    handleInputOther()



func _physics_process(_delta):

    # Apply gravity.
    var grav_force_dir = applyGravDirToGravForce()
    apply_central_impulse(grav_force_dir)

    # Apply player input force.
    var vel = getInputWasd()
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
    
    handleInputMouseMotion(event)
    
    handleInputMouseWheel(event)



####################################################################################################
                                                                           ###   PROCESS FUNCS   ###
                                                                           #########################

func setPointingAt():
    
    if scope.is_colliding():  pointing_at = scope.get_collision_point()
    else:  pointing_at = look_default.global_transform.origin



func setBlasterTargetting():
    # Targetting logic...  'spawn_bolt' looks at whatever 'scope' is looking at.  This is to
    # ensure that whatever is in the player's crosshairs is the point that will be shot at.
    
    blaster_proj_spawns[cur_blaster].look_at(pointing_at, Vector3.UP)
    
    ###   NEED TO FIX   ###
    # Barrel rotation needs rework.  Current rotation is based on global rotation. Should be based
    # on local or parent rotation.  Can see the issue in the barrel's rotation while vehicle is on
    # a gravity inversion slope.
    
    # Point barrel_pivot at pointing_at.
    blaster_barrel_pivots[cur_blaster].look_at(pointing_at, gravity_dir * -1)
    blaster_barrel_pivots[cur_blaster].rotation_degrees.y = -90
    blaster_barrel_pivots[cur_blaster].rotation_degrees.x = clamp(
        blaster_barrel_pivots[cur_blaster].rotation_degrees.x, 0, 90
    )



func setLauncherTargetting():
    # Targetting logic...  'spawn_bolt' looks at whatever 'scope' is looking at.  This is to
    # ensure that whatever is in the player's crosshairs is the point that will be shot at.
    
    launcher_proj_spawns[cur_launcher].look_at(pointing_at, Vector3.UP)
    
    ###   NEED TO FIX   ###
    # Barrel rotation needs rework.  Current rotation is based on global rotation. Should be based
    # on local or parent rotation.  Can see the issue in the barrel's rotation while vehicle is on
    # a gravity inversion slope.
    
    launcher_barrel_pivots[cur_launcher].look_at(pointing_at, gravity_dir * -1)
    launcher_barrel_pivots[cur_launcher].rotation_degrees.y = -90
    launcher_barrel_pivots[cur_launcher].rotation_degrees.x = clamp(
        launcher_barrel_pivots[cur_launcher].rotation_degrees.x, 0, 90
    )



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



#######################
"""   INPUT   >>>   """
#######################



func getInputWasd():
    # WASD controls; primary user input of force on vehicle.
    
    var wasd_vel_ = Vector3()
    
    # With 'THRUST', apply WASD up/down input to 'vel' x-axis (forward/backward).
    if Input.is_action_pressed('ui_up'):
        wasd_vel_ += Vector3(+THRUST * replenish['engines'], 0, 0)
    if Input.is_action_pressed('ui_down'):
        wasd_vel_ += Vector3(-THRUST * replenish['engines'], 0, 0)
    # With 'THRUST', apply WASD left/right input to 'vel' z-axis (left/right).
    if Input.is_action_pressed('ui_left'):
        wasd_vel_ += Vector3(0, 0, -THRUST * replenish['engines'])
    if Input.is_action_pressed('ui_right'):
        wasd_vel_ += Vector3(0, 0, +THRUST * replenish['engines'])
    
    return wasd_vel_


func handleInputOther():
    
    # Shift to bool vars controls.
    if Input.is_action_just_pressed('shift'):       input_shifting = true
    if Input.is_action_just_released('shift'):      input_shifting = false
    if Input.is_action_just_pressed('repl_shift'):  input_repl_shifting = true
    if Input.is_action_just_released('repl_shift'): input_repl_shifting = false
    
    # Blaster / Bolt controls.
    if Input.is_action_pressed('blaster_shoot') and has_blasters:
        if blaster_cooled_downs[cur_blaster]:
            if blaster_batteries[cur_blaster] >= BOLT_ENERGIES[cur_blaster]:
                var bolt = Bolts[cur_blaster].instance()
                
                ###
                # I think this should be handled in Gameplay.gd.
                get_node('/root/Main/Gameplay/VehicleBolts').add_child(bolt)
                ###
                
                bolt.spawn(blaster_proj_spawns[cur_blaster].global_transform)
                blaster_batteries[cur_blaster] -= BOLT_ENERGIES[cur_blaster]
                hud.updateBlasterBatteryValue(cur_blaster, blaster_batteries[cur_blaster])
                blaster_cool_downs[cur_blaster].start()
                blaster_cooled_downs[cur_blaster] = false
    
    # Launcher / Round controls.
    if Input.is_action_pressed('launcher_shoot') and has_launchers:
        if launcher_cooled_downs[cur_launcher]:
            if launcher_magazines[cur_launcher] > 0:
                
                var launcher_round = Rounds[cur_launcher].instance()
                
                ###
                # I think this should be handled in Gameplay.gd.
                get_node('/root/Main/Gameplay/VehicleRounds').add_child(launcher_round)
                ###
                
                launcher_round.spawn(launcher_proj_spawns[cur_launcher].global_transform)
                launcher_magazines[cur_launcher] -= 1
                hud.updateLauncherMagazineValue(cur_launcher, launcher_magazines[cur_launcher])
                launcher_cool_downs[cur_launcher].start()
                launcher_cooled_downs[cur_launcher] = false
    
    
    
    # Change replenish set.
    if Input.is_action_just_pressed('change_repl_set'):
        if cur_repl_set <= len(replenish_sets) - 2:  cur_repl_set += 1
        else:  cur_repl_set = 0
        replenish['engines'] =     replenish_sets[cur_repl_set]['engines']
        replenish['shields'] =     replenish_sets[cur_repl_set]['shields']
        replenish['blasters'] =    replenish_sets[cur_repl_set]['blasters']
        hud.updateReplenishValues(replenish['engines'], replenish['shields'], replenish['blasters'])
    
    # Change replenish each (pos).
    if not input_repl_shifting:
        if Input.is_action_just_pressed('repl_engines'):
            changeReplEach('pos', 'engines')
        elif Input.is_action_just_pressed('repl_shields') and has_shields:
            changeReplEach('pos', 'shields')
        elif Input.is_action_just_pressed('repl_blasters') and has_blasters:
            changeReplEach('pos', 'blasters')
    
    # Change replenish each (neg).
    if input_repl_shifting:
        if Input.is_action_just_pressed('repl_engines'):
            changeReplEach('neg', 'engines')
        elif Input.is_action_just_pressed('repl_shields') and has_shields:
            changeReplEach('neg', 'shields')
        elif Input.is_action_just_pressed('repl_blasters') and has_blasters:
            changeReplEach('neg', 'blasters')
        
    # Force replenishments all back to even.
    if input_repl_shifting and Input.is_action_pressed('change_repl_set'):
        cur_repl_set = 0
        replenish['engines'] =     replenish_sets[cur_repl_set]['engines']
        replenish['shields'] =     replenish_sets[cur_repl_set]['shields']
        replenish['blasters'] =    replenish_sets[cur_repl_set]['blasters']
        hud.updateReplenishValues(replenish['engines'], replenish['shields'], replenish['blasters'])
    
    # Focus controls.
    if Input.is_action_just_pressed('trigger_focus'):
        var focus = scope.get_collider()
        # Only perform focus object update if focus is in Targets.
        if focus != null and focus.get_parent().name == 'Targets':  hud.updateFocusObject(focus)



func changeReplEach(_dir, _each):
    """
    _dir = Dictates positive or negative value change of replenish[_each].
    _each = Which replenish value is directly adjusted.
    Functionality allowing player to manually change the replenishment values.
    """
    
    """
    There HAS to be a better way to do this.
    """
    
    # Ignore if replenish[_each] is capped.
    if _dir == 'pos' and replenish[_each] == 1.00:  return
    if _dir == 'neg' and replenish[_each] == 0.00:  return
    
    var replenishes = ['engines', 'shields', 'blasters']
    var others = []
    for each in replenishes:
        if each != _each:  others += [ each ]
    
    match _dir:
        'pos':
            if replenish[_each] >= 0.90:
                replenish[_each] = 1.00
                for other in others:  replenish[other] = 0.00
            else:
                replenish[_each] += 0.10
                for other in others:
                    replenish[other] -= (0.10 / len(others))
                    if replenish[other] < 0.00:
                        replenish[_each] += replenish[other]
                        replenish[other] = 0.00
        'neg':
            if replenish[_each] <= 0.10:
                for other in others:  replenish[other] += (replenish[_each] / len(others))
                replenish[_each] = 0.00
            else:
                replenish[_each] -= 0.10
                for other in others:
                    replenish[other] += (0.10 / len(others))
                    if replenish[other] > 1.00:
                        replenish[_each] += (replenish[other] - 1.00)
                        replenish[other] = 0.00

    hud.updateReplenishValues(replenish['engines'], replenish['shields'], replenish['blasters'])



func handleInputMouseMotion(_event):
    # Vehicle mouse controls (while mouse is captured).  Only perform vehicle mouse controls if
    # 'mouse_motion' and 'mouse_captured' are True.
    
    var mouse_motion = _event is InputEventMouseMotion
    var mouse_captured = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
    if mouse_motion and mouse_captured:
        rot_force = -_event.relative.x * MOUSE_SENSITIVITY * SPIN
        # Mouse motion on the y-axis translates to camera ('pivot') motion on the z-axis.
        camera_pivot.rotate_z(-_event.relative.y * MOUSE_SENSITIVITY * MOUSE_VERT_DAMP)
        # Have to apply 'clamp' to prevent extreme camera positions.
        camera_pivot.rotation.z = clamp(camera_pivot.rotation.z, -1.2, 0.6)



func handleInputMouseWheel(_event):
    # Handle mouse buttons input events.
    
    if _event is InputEventMouseButton and _event.is_pressed():
        
        """
        TO-DO:  The current check for an empty cur_blaster will only work if there is only a
        single empty cur_blaster at a time.  If there are 2 empty cur_blasters in a row then this
        will break.  Need to update to a while loop.
        """
        
        # BLOCK...  Handle scroll wheel input events.
        if not input_shifting and has_blasters:
            if _event.button_index == BUTTON_WHEEL_DOWN:
                if cur_blaster <= len(BLASTER_SLOTS) - 2:  cur_blaster += 1
                else:  cur_blaster = 0
                # After each cur_blaster change, the process is repeated if the cur_blaster is changed
                # to an empty cur_blaster.  (same for BUTTON_WHEEL_DOWN)
                if blaster_tags[cur_blaster] == '':
                    if cur_blaster <= len(BLASTER_SLOTS) - 2:  cur_blaster += 1
                    else:  cur_blaster = 0
            if _event.button_index == BUTTON_WHEEL_UP:
                if cur_blaster != 0:  cur_blaster -= 1
                else:  cur_blaster = len(BLASTER_SLOTS) - 1
                if blaster_tags[cur_blaster] == '':
                    if cur_blaster != 0:  cur_blaster -= 1
                    else:  cur_blaster = len(BLASTER_SLOTS) - 1
            hud.updateBlasterCurrentValue(cur_blaster)
    
        if input_shifting and has_launchers:
            if _event.button_index == BUTTON_WHEEL_DOWN:
                if cur_launcher <= len(LAUNCHER_SLOTS) - 2:  cur_launcher += 1
                else:  cur_launcher = 0
                # After each cur_blaster change, the process is repeated if the cur_blaster is changed
                # to an empty cur_blaster.  (same for BUTTON_WHEEL_DOWN)
                if launcher_tags[cur_launcher] == '':
                    if cur_launcher <= len(LAUNCHER_SLOTS) - 2:  cur_launcher += 1
                    else:  cur_launcher = 0
            if _event.button_index == BUTTON_WHEEL_UP:
                if cur_launcher != 0:  cur_launcher -= 1
                else:  cur_launcher = len(LAUNCHER_SLOTS) - 1
                if launcher_tags[cur_launcher] == '':
                    if cur_launcher != 0:  cur_launcher -= 1
                    else:  cur_launcher = len(LAUNCHER_SLOTS) - 1
            hud.updateLauncherCurrentValue(cur_launcher)



#######################
"""   <<<   INPUT   """
#######################



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_GeneratorRate_timeout():
    # Regulate blaster battery and shields battery replenishment.  Only replenish if battery is not
    # full.  If replenishment overfills battery, clamp it.  Then update Hud.

    var replenish_each_blaster = getReplEachBlaster()

    for i in range(len(blaster_tags)):
        if blaster_batteries[i] < BLASTER_BATTERY_CAPACITIES[i]:
            blaster_batteries[i] += REPLENISH * replenish['blasters'] * replenish_each_blaster[i]
            blaster_batteries[i] = clamp(blaster_batteries[i], 0, BLASTER_BATTERY_CAPACITIES[i])
            hud.updateBlasterBatteryValue(i, blaster_batteries[i])

    if shields_battery < SHIELDS_BATTERY_CAPACITY:
        shields_battery += REPLENISH * replenish['shields'] * SHIELDS_CONCENTRATION
        shields_battery = clamp(shields_battery, 0, SHIELDS_BATTERY_CAPACITY)
        hud.updateShieldsBatteryValue(shields_battery)



func getReplEachBlaster():
    # repl_each_ is an array of perc who's sum = 100%.  Each value represents how much of the
    # generator replenishment that blaster receives.
    
    # First set each value of repl_each_ to an even perc value based on count of blaster_tags.
    var repl_each_ = []
    for _i in range(len(blaster_tags)):  repl_each_ += [ 1 / float(len(blaster_tags)) ]
    
    # BLOCK...  Adjust values of repl_each_ so that blaster batteries that are full do not get
    # replenished unnecessarily.
    for i in range(len(blaster_tags)):
        # Check if i blaster battery is full.  If so, distribute repl value from i battery to the
        # rest of the batteries and reset i battery value to 0.
        if blaster_batteries[i] == BLASTER_BATTERY_CAPACITIES[i]:
            for each_i in range(len(repl_each_)):
                if i == each_i:  continue
                repl_each_[each_i] += float(repl_each_[i]) / (len(blaster_tags) - 1)
            repl_each_[i] = 0

    return repl_each_



func _on_Blaster1CoolDown_timeout():
    
    blaster_cooled_downs[0] = true

func _on_Blaster2CoolDown_timeout():
    
    blaster_cooled_downs[1] = true

func _on_Blaster3CoolDown_timeout():
    
    blaster_cooled_downs[2] = true

func _on_Launcher1CoolDown_timeout():
    
    launcher_cooled_downs[0] = true

func _on_Launcher2CoolDown_timeout():
    
    launcher_cooled_downs[1] = true



####################################################################################################
                                                                                ###   OBSOLETE   ###
                                                                                ####################

""" from _process() (2020-05-23) """
#    # Clamp vehicle's max speed. 
#    if linear_velocity.length() > MAX_SPEED:
#        linear_velocity = linear_velocity.normalized() * MAX_SPEED







