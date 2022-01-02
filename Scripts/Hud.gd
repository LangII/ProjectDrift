
"""

Hud.gd

Currently universal hud.  Need to make and extend from a hud module because the hud laout will be
dependent on user input of vehicle body and parts selection.

"""

extends Control

# Singletons.
onready var main = get_node('/root/Main')
onready var controls =  get_node('/root/Controls')
onready var gameplay =  get_node('/root/Main/Gameplay')

####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

### Controls tags.
onready var body_tag =      controls.gameplay['vehicle_rig']['body']['part_tag']
onready var engines_tag =   controls.gameplay['vehicle_rig']['engines']['part_tag']
onready var shields_tag =   controls.gameplay['vehicle_rig']['shields']['part_tag']
### (expandables)
onready var blaster_tags = []
onready var launcher_full_tags = []
onready var launcher_types = []
onready var launcher_tags = []

### Set initial values from controls.
onready var objective_input =       controls.gameplay['number_of_targets']
onready var BLASTER_SLOTS =         controls.bodies[body_tag]['blaster_slots']
onready var LAUNCHER_SLOTS =        controls.bodies[body_tag]['launcher_slots']
onready var health_input =          controls.bodies[body_tag]['health']
onready var MAX_SPEED =             controls.engines[engines_tag]['max_speed']
onready var shields_battery_input = controls.shields[shields_tag]['battery_capacity']
### (expandables)
onready var blaster_battery_inputs = []
onready var blaster_bolt_energy_inputs = []
onready var launcher_magazine_inputs = []
onready var launcher_round_dmg_inputs = []



####################################################################################################
                                                                               ###   NODE REFS   ###
                                                                               #####################

### DebugValues node references.
onready var _debug_values_ = find_node('DebugValues*')
onready var health_value =              _debug_values_.find_node('HealthValue*')
onready var shields_battery_value =     _debug_values_.find_node('ShieldsBatteryValue*')
onready var speed_value =               _debug_values_.find_node('SpeedValue*')
onready var blaster1_battery_value =    _debug_values_.find_node('BlasterBatteryValue*')
onready var replenish_engines_value =   _debug_values_.find_node('ReplenishEnginesValue*')
onready var replenish_shields_value =   _debug_values_.find_node('ReplenishShieldsValue*')
onready var replenish_blasters_value =  _debug_values_.find_node('ReplenishBlastersValue*')
onready var focus_name_value =          _debug_values_.find_node('FocusNameValue*')
onready var focus_health_value =        _debug_values_.find_node('FocusHealthValue*')
onready var objective_value =           _debug_values_.find_node('ObjectiveValue*')

### BottomLeft node references.
onready var _bottom_left_ = find_node('BottomLeft*')
onready var speed_prog_bar =            _bottom_left_.find_node('SpeedProgBar*')
onready var speed_text =                _bottom_left_.find_node('SpeedText*')
onready var engines_repl_prog_bar =     _bottom_left_.find_node('EnginesReplProgBar*')
onready var shields_hbox =              _bottom_left_.find_node('ShieldsHBox*')
onready var shields_repl_prog_bar =     _bottom_left_.find_node('ShieldsReplProgBar*')
onready var blasters_repl_prog_bar =    _bottom_left_.find_node('BlastersReplProgBar*')
onready var shields_prog_bar =          _bottom_left_.find_node('ShieldsProgBar*')
onready var shields_text =              _bottom_left_.find_node('ShieldsText*')
onready var health_prog_bar =           _bottom_left_.find_node('HealthProgBar*')
onready var health_text =               _bottom_left_.find_node('HealthText*')

### BottomRight node references.
onready var _bottom_right_ = find_node('BottomRight*')
onready var blasters_container = _bottom_right_.find_node('BlastersContainer*')
onready var launchers_container = _bottom_right_.find_node('LaunchersContainer*')
### (expandables)
onready var blaster_texts = []
onready var blaster_prog_bars = []
onready var blaster_bolt_energy_texts = []
onready var blaster_cur_containers = []
onready var launcher_texts = []
onready var launcher_prog_bars = []
onready var launcher_round_dmg_texts = []
onready var launcher_cur_containers = []

### TopLeft node references.
onready var _top_left_ = find_node('TopLeft*')
onready var objective_text =        _top_left_.find_node('ObjectiveText*')
onready var objective_prog_bar =    _top_left_.find_node('ObjectiveProgBar*')
onready var focus_name_text =       _top_left_.find_node('FocusNameText*')
onready var focus_health_text =     _top_left_.find_node('FocusHealthText*')
onready var focus_health_prog_bar = _top_left_.find_node('FocusHealthProgBar*')



####################################################################################################
                                                                                    ###   VARS   ###
                                                                                    ################

### Value holders.
onready var focus_name_input = ''
onready var focus_health_input = 0.0
onready var speed_input = 0.0
onready var replenish_engines_input = 0.0
onready var replenish_shields_input = 0.0
onready var replenish_blasters_input = 0.0
onready var blaster_cur_input = 0
onready var launcher_cur_input = 0
### Standardizing text formatting.
onready var text_format_std = "%.2f"
onready var text_format_be = "(%.2f)"
onready var text_format_lm = "+%sm"

### Working variables.
onready var vehicle = get_node('/root/Main/Gameplay/Vehicles/%s' % body_tag)
onready var focus_cam = find_node('FocusCamera*')
onready var focus_cam_background = focus_cam.find_node('Background*')
onready var focus_obj = null
onready var focus_cam_pos = Vector3()
onready var focus_obj_pos = Vector3()



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
    main.scriptedScenePrint(name, 'enter')
    
    # Set initial BottomLeft values.
    speed_prog_bar.max_value =      MAX_SPEED
    speed_text.text =               text_format_std % MAX_SPEED
    shields_prog_bar.max_value =    shields_battery_input
    shields_prog_bar.value =        shields_battery_input
    shields_text.text =             text_format_std % shields_battery_input
    health_prog_bar.max_value =     health_input
    health_prog_bar.value =         health_input
    health_text.text =              text_format_std % health_input
    
    # Set initial TopLeft values.
    objective_text.text =           str(objective_input)
    objective_prog_bar.max_value =  objective_input
    objective_prog_bar.value =      objective_input
    
#    # Set initiating _debug_values_.
#    if _debug_values_.is_visible():
#        objective_value.text =          "%6d" % objective_input
#        health_value.text =             "%7.2f" % health_input
#        shields_battery_value.text =    "%7.2f" % shields_battery_input
#        speed_value.text =              "%7.2f" % speed_input
#        blaster1_battery_value.text =   "%7.2f" % blaster1_battery_input
    
    generateExpandableTags()
    
    if not shields_tag:  adjustNodesForNoShields()
    
    adjustNodesForBlasters()
    
    if LAUNCHER_SLOTS:  adjustNodesForLaunchers()
    else:  adjustNodesForNoLaunchers()
    
    generateExpandableControlVars()
    
    generateExpandableNodeRefs()
    
    setInitialExpandableValues()
    
    updateBlasterCurrentValue(blaster_cur_input)
    
    if LAUNCHER_SLOTS:  updateLauncherCurrentValue(launcher_cur_input)
    
    # Make visible because these nodes are default set to invisible for easier editing.
    focus_cam.visible = true
    focus_cam_background.visible = true



####################################################################################################
                                                                             ###   READY FUNCS   ###
                                                                             #######################

func generateExpandableTags():
    """ Generate expandable tags. """
    
    for blaster in BLASTER_SLOTS:
        blaster_tags += [ controls.gameplay['vehicle_rig'][blaster]['part_tag'] ]
    
    for launcher in LAUNCHER_SLOTS:
        var full_tag = controls.gameplay['vehicle_rig'][launcher]['part_tag']
        launcher_full_tags += [ full_tag ]
        launcher_tags += [ full_tag.right(full_tag.find('Launcher') + len('Launcher')) ]
        launcher_types += [ full_tag.left(full_tag.find('Launcher')) ]



func adjustNodesForNoShields():
    """ Adjust nodes when there are no shields. """
    
    shields_hbox.visible = false



func adjustNodesForBlasters():
    """ Adjust nodes to expand to blaster count. """
    
    # BLOCK...  Expand blasters_container in BottomRight per blaster.
    var blaster_counter = 0
    for blaster in blaster_tags:
        blaster_counter += 1
        if blaster_counter == 1:  continue
        # Get container scene and adjust names of node children per counter.
        var blaster_box = preload('res://Scenes/Functional/Reusables/Blaster1Box.tscn').instance()
        var blaster_box_nodes = [
            'Blaster%sCurrentContainer*', 'Blaster%sText*', 'Blaster%sProgBar*',
            'Blaster%sBoltEnergyText*'
        ]
        for node in blaster_box_nodes:
            blaster_box.find_node(node % str(1)).name = node % blaster_counter
        # Change name per counter and add as child.
        blaster_box.name = 'Blaster%sBox*' % blaster_counter
        blasters_container.add_child(blaster_box)



func adjustNodesForLaunchers():
    
    var launcher_counter = 0
    for launcher in launcher_tags:
        launcher_counter += 1
        if launcher_counter == 1:  continue
        var launcher_box = preload('res://Scenes/Functional/Reusables/Launcher1Box.tscn').instance()
        var launcher_box_nodes = [
            'Launcher%sCurrentContainer*', 'Launcher%sText*', 'Launcher%sProgBar*',
            'Launcher%sRoundDmgText*'
        ]
        for node in launcher_box_nodes:
            launcher_box.find_node(node % str(1)).name = node % launcher_counter
        launcher_box.name = 'Launcher%sBox*' % launcher_counter
        launchers_container.add_child(launcher_box)



func adjustNodesForNoLaunchers():
    
    launchers_container.find_node('Launcher1Box*').visible = false
    _bottom_right_.find_node('Divider*').visible = false



func generateExpandableControlVars():
    """ Generate expandable control variables. """
    
    for blaster_tag in blaster_tags:
        blaster_battery_inputs += [ controls.blasters[blaster_tag]['battery_capacity'] ]
        blaster_bolt_energy_inputs += [ controls.blasters[blaster_tag]['energy'] ]
    
    for i in range(len(launcher_full_tags)):
        
        var launcher_full_tag = launcher_full_tags[i]
        launcher_magazine_inputs += [
            controls.launchers[launcher_types[i]][launcher_full_tag]['magazine_capacity']
        ]
        
        var damages = controls.launchers[launcher_types[i]][launcher_full_tag]['damage']
        var round_damage_input = 0
        for dmg in damages.values():
            if dmg > round_damage_input:  round_damage_input = dmg
        launcher_round_dmg_inputs += [ round_damage_input ]



func generateExpandableNodeRefs():
    """ Generate expandable node references. """
    
    for i in range(len(blaster_tags)):
        blaster_texts += [
            _bottom_right_.find_node('Blaster%sText*' % str(i + 1), true, false)
        ]
        blaster_prog_bars += [
            _bottom_right_.find_node('Blaster%sProgBar*' % str(i + 1), true, false)
        ]
        blaster_bolt_energy_texts += [
            _bottom_right_.find_node('Blaster%sBoltEnergyText*' % str(i + 1), true, false)
        ]
        blaster_cur_containers += [
            _bottom_right_.find_node('Blaster%sCurrentContainer*' % str(i + 1), true, false)
        ]
    
    for i in range(len(launcher_full_tags)):
        launcher_texts += [
            _bottom_right_.find_node('Launcher%sText*' % str(i + 1), true, false)
        ]
        launcher_prog_bars += [
            _bottom_right_.find_node('Launcher%sProgBar*' % str(i + 1), true, false)
        ]
        launcher_round_dmg_texts += [
            _bottom_right_.find_node('Launcher%sRoundDmgText*' % str(i + 1), true, false)
        ]
        launcher_cur_containers += [
            _bottom_right_.find_node('Launcher%sCurrentContainer*' % str(i + 1), true, false)
        ]



func setInitialExpandableValues():
    """ Set initial values of expandable nodes. """
    
    # Set initial BottomRight values.
    for i in range(len(BLASTER_SLOTS)):
        blaster_texts[i].text = text_format_std % blaster_battery_inputs[i]
        blaster_prog_bars[i].max_value = blaster_battery_inputs[i]
        blaster_prog_bars[i].value = blaster_battery_inputs[i]
        blaster_bolt_energy_texts[i].text = text_format_be % blaster_bolt_energy_inputs[i]
    
    for i in range(len(LAUNCHER_SLOTS)):
        launcher_texts[i].text = text_format_lm % str(launcher_magazine_inputs[i] / 8)
        launcher_prog_bars[i].max_value = 8
        launcher_prog_bars[i].value = launcher_magazine_inputs[i] % 8
        launcher_round_dmg_texts[i].text = text_format_be % launcher_round_dmg_inputs[i]



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(_delta):
    
    # Perform per-frame updates.
    updateSpeedProgBar(vehicle.linear_velocity.length())
    if focus_obj:  updateFocusCamera()



####################################################################################################
                                                                           ###   PROCESS FUNCS   ###
                                                                           #########################

func updateSpeedProgBar(_value):
    # Called from _process().
    
    speed_prog_bar.value = _value



func updateFocusCamera():
    # Update position and rotation of FocusCamera.
    
    # Get pos of focus_obj.
    focus_obj_pos = focus_obj.global_transform.origin
    
    # Set pos of focus_cam.
    focus_cam_pos = (vehicle.global_transform.origin - focus_obj_pos).normalized() * 4
    focus_cam_pos = focus_cam_pos + focus_obj_pos
    focus_cam.global_transform.origin = focus_cam_pos
    
    # Set rot of focus_cam with look_at.
    focus_cam.look_at(focus_obj_pos, vehicle.gravity_dir * -1)



func updateFocusObject(_obj):
    # Update which object is set to current focus_obj.  This also requires adjusting the old and new
    # focus_obj's 'focus' visual layers.
    
    # NOTE...  HAVE TO adjust visual layers first due to nature of toggleObjectVisualLayer().
    
    # Turn off 'focus' visual layer of current focus_obj.
    if focus_obj:  gameplay.toggleObjectVisualLayer(focus_obj, 1)
    # Turn on 'focus' visual layer of to-be focus_obj (_obj).
    gameplay.toggleObjectVisualLayer(_obj, 1)
    # Make to-be focus_obj (_obj) the new current focus_obj.
    focus_obj = _obj
    

    focus_name_input = focus_obj.name
    focus_name_text.text = "%s " % focus_name_input
    focus_health_prog_bar.max_value = focus_obj.MAX_HEALTH
    updateFocusHealthValue(focus_obj.HEALTH)
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():  focus_name_value.text = "%013s" % focus_name_input



func updateFocusHealthValue(_value):
    
    focus_health_input = _value
    focus_health_prog_bar.value = focus_health_input
    # Update focus_health_text, if 0, update to '' not 0.0.
    if _value == 0:  focus_health_text.text = ''
    else:  focus_health_text.text = text_format_std.replace(' ', '') % focus_health_input
    # Update _debug_values_ if needed.    
    if _debug_values_.is_visible():  focus_health_value.text = "%7.2f" % focus_health_input



func clearFocusObject():
    # Reset all focus values.
    
    # NOTE...  As of right now this is unnecessary.  But, if later down the road it's needed to
    # clearFocusObject() that is not queue_free()'ed as well.'
    if focus_obj:  gameplay.toggleObjectVisualLayer(focus_obj, 1)
    
    focus_obj = null
    focus_name_text.text = ''
    focus_health_prog_bar.max_value = 0.0
    updateFocusHealthValue(0.0)
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():  focus_name_value.text = ''



func updateReplenishValues(_engines, _shields, _blasters):
    
    replenish_engines_input =       _engines
    replenish_shields_input =       _shields
    replenish_blasters_input =      _blasters
    engines_repl_prog_bar.value =   replenish_engines_input
    shields_repl_prog_bar.value =   replenish_shields_input
    blasters_repl_prog_bar.value =  replenish_blasters_input
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():
        replenish_engines_value.text =  "%7.2f" % replenish_engines_input
        replenish_shields_value.text =  "%7.2f" % replenish_shields_input
        replenish_blasters_value.text = "%7.2f" % replenish_blasters_input



func updateSpeedValue(_value):
    
    speed_input = _value
    speed_text.text = text_format_std % speed_input
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():  speed_value.text = "%7.2f" % speed_input



func updateHealthValue(_value):
    
    health_input = _value
    health_prog_bar.value = health_input
    health_text.text = text_format_std % health_input
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():  health_value.text = "%7.2f" % health_input
    
    # Trigger loseConditionMet().
    if health_input <= 0:  gameplay.loseConditionMet()



func updateShieldsBatteryValue(_value):
    
    shields_battery_input = _value
    shields_prog_bar.value = shields_battery_input
    shields_text.text = text_format_std % shields_battery_input
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():  shields_battery_value.text = "%7.2f" % shields_battery_input



func updateBlasterBatteryValue(_cur_blaster, _value):
    
    blaster_battery_inputs[_cur_blaster] = _value
    blaster_texts[_cur_blaster].text = text_format_std % blaster_battery_inputs[_cur_blaster]
    blaster_prog_bars[_cur_blaster].value = blaster_battery_inputs[_cur_blaster]
    
    # Update _debug_values_ if needed.
#    if _debug_values_.is_visible():  blaster1_battery_value.text = "%7.2f" % blaster1_battery_input



func updateBlasterCurrentValue(_value):
    
    blaster_cur_input = _value
    for each in blaster_cur_containers:  each.visible = false
    blaster_cur_containers[blaster_cur_input].visible = true



func updateLauncherMagazineValue(_cur_launcher, _value):
    
    """ DIRTY DIRTY CODE!!! """
    
    launcher_magazine_inputs[_cur_launcher] = _value
    launcher_texts[_cur_launcher].text = text_format_lm % str(launcher_magazine_inputs[_cur_launcher] / 8)
    launcher_prog_bars[_cur_launcher].value = launcher_magazine_inputs[_cur_launcher] % 8
    
    if (launcher_magazine_inputs[_cur_launcher] % 8) == 0:
        launcher_texts[_cur_launcher].text = text_format_lm % str((launcher_magazine_inputs[_cur_launcher] / 8) - 1)
        launcher_prog_bars[_cur_launcher].value = 8
    
    if launcher_magazine_inputs[_cur_launcher] == 0:
        launcher_texts[_cur_launcher].text = text_format_lm % str(0)
        launcher_prog_bars[_cur_launcher].value = 0



func updateLauncherCurrentValue(_value):
    
    launcher_cur_input = _value
    for each in launcher_cur_containers:  each.visible = false
    launcher_cur_containers[launcher_cur_input].visible = true



func updateObjectiveValue(_value):
    # Update objective display values.

    objective_input = _value
    objective_text.text = str(objective_input)
    objective_prog_bar.value = objective_input
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():  objective_value.text = "%6d" % objective_input
    
    # Trigger winConditionMet().
    if objective_input <= 0:  gameplay.winConditionMet()


####################################################################################################


func queue_free() -> void:
    
    main.scriptedScenePrint(name, 'exit')


