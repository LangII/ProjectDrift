
"""

Hud.gd

Currently universal hud.  Need to make and extend from a hud module because the hud laout will be
dependent on user input of vehicle body and parts selection.

TURNOVER NOTES:
    - Have implemented suffix of '*' on node names to note that node as a node referenced in script.
    Should implement this for all scripts.

"""

extends Control

# Singletons.
onready var controls =  get_node('/root/Controls')
onready var gameplay =  get_node('/root/Gameplay')

####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

### Controls tags.
onready var body_tag =      controls.gameplay['vehicle']['body']
onready var engines_tag =   controls.gameplay['vehicle']['engines']
onready var blaster1_tag =  controls.gameplay['vehicle']['blaster1']
onready var shields_tag =   controls.gameplay['vehicle']['shields']

### Set initial values from controls.
onready var objective_input =               controls.gameplay['number_of_targets']
onready var max_speed =                     controls.engines[engines_tag]['max_speed']
onready var health_input =                  controls.body[body_tag]['health']
onready var shields_battery_input =         controls.shields[shields_tag]['battery_capacity']
onready var blaster1_battery_input =        controls.blasters[blaster1_tag]['battery_capacity']
onready var blaster1_bolt_energy_input =    controls.blasters[blaster1_tag]['energy']



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
onready var blaster1_text =             _bottom_right_.find_node('Blaster1Text*')
onready var blaster1_prog_bar =         _bottom_right_.find_node('Blaster1ProgBar*')
onready var blaster1_bolt_energy_text = _bottom_right_.find_node('Blaster1BoltEnergyText*')

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

### _process()
onready var vehicle = get_node('/root/Gameplay/Vehicles/%s' % body_tag)
onready var focus_cam = find_node('FocusCamera*')
onready var focus_cam_background = focus_cam.find_node('Background*')
onready var focus_obj = null
onready var focus_cam_pos = Vector3()
onready var focus_obj_pos = Vector3()

### Value holders.
onready var focus_name_input = ''
onready var focus_health_input = 0.0
onready var speed_input = 0.0
onready var replenish_engines_input = 0.0
onready var replenish_shields_input = 0.0
onready var replenish_blasters_input = 0.0

### Standardizing text formatting.
onready var text_format_std = " %.2f "
onready var text_format_be = " (%.2f) "



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
    # Set initial BottomLeft values.
    speed_prog_bar.max_value =      max_speed
    speed_text.text =               text_format_std % max_speed
    shields_prog_bar.max_value =    shields_battery_input
    shields_prog_bar.value =        shields_battery_input
    shields_text.text =             text_format_std % shields_battery_input
    health_prog_bar.max_value =     health_input
    health_prog_bar.value =         health_input
    health_text.text =              text_format_std % health_input
    
    # Set initial BottomRight values.
    blaster1_text.text =                text_format_std % blaster1_battery_input
    blaster1_prog_bar.max_value =       blaster1_battery_input
    blaster1_prog_bar.value =           blaster1_battery_input
    blaster1_bolt_energy_text.text =    text_format_be % blaster1_bolt_energy_input
    
    # Set initial TopLeft values.
    objective_text.text =           str(objective_input)
    objective_prog_bar.max_value =  objective_input
    objective_prog_bar.value =      objective_input
    
    # Set initiating _debug_values_.
    if _debug_values_.is_visible():
        objective_value.text =          "%6d" % objective_input
        health_value.text =             "%7.2f" % health_input
        shields_battery_value.text =    "%7.2f" % shields_battery_input
        speed_value.text =              "%7.2f" % speed_input
        blaster1_battery_value.text =   "%7.2f" % blaster1_battery_input
    
    # Make visible because these nodes are default set to invisible for easier editing.
    focus_cam.visible = true
    focus_cam_background.visible = true



####################################################################################################
                                                                             ###   READY FUNCS   ###
                                                                             #######################

func adjustForNoShields():
    
    shields_hbox.visible = false



func adjustForBlasters():
    
    # Get blaster_tags, a dict of keys as blaster ref names and values as blaster tags.
    var blaster_tags = {}
    for blaster in controls.body[body_tag]['blaster_slots']:
        var blaster_tag = controls.gameplay['vehicle'][blaster]
        blaster_tags[blaster] = blaster_tag
    
    # Handle no blasters.
    var empty_counter = 0
    for value in blaster_tags.values():
        if value == '':  empty_counter += 1
    if empty_counter == len(blaster_tags):
        noBlasters()
        return
    
    var blasters_container = _bottom_right_.find_node('BlastersContainer*')
    var blaster_counter = 0
    for key in blaster_tags.keys():
        var value = blaster_tags[key]
        
        if value == '':  continue
        blaster_counter += 1
        if blaster_counter == 1:  continue
        
        var blaster_box = preload('res://Scenes/Functional/Blaster1Box.tscn').instance()
        blaster_box.find_node('Blaster1Text*').name = 'Blaster%sText*' % blaster_counter
        blaster_box.find_node('Blaster1ProgBar*').name = 'Blaster%sProgBar*' % blaster_counter
        blaster_box.find_node('Blaster1BoltEnergyText*').name = 'Blaster%sBoltEnergyText*' % blaster_counter

        blasters_container.add_child(blaster_box)

        get_tree().quit()



func noBlasters():
    
    pass



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
    
    replenish_engines_input = _engines
    replenish_shields_input = _shields
    replenish_blasters_input = _blasters
    engines_repl_prog_bar.value = replenish_engines_input
    shields_repl_prog_bar.value = replenish_shields_input
    blasters_repl_prog_bar.value = replenish_blasters_input
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
    shields_text.text = " %.2f " % shields_battery_input
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():  shields_battery_value.text = "%7.2f" % shields_battery_input



func updateBlasterBatteryValue(_value):
    
    blaster1_battery_input = _value
    blaster1_text.text = text_format_std % blaster1_battery_input
    blaster1_prog_bar.value = blaster1_battery_input
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():  blaster1_battery_value.text = "%7.2f" % blaster1_battery_input



func updateObjectiveValue(_value):
    # Update objective display values.

    objective_input = _value
    objective_text.text = str(objective_input)
    objective_prog_bar.value = objective_input
    # Update _debug_values_ if needed.
    if _debug_values_.is_visible():  objective_value.text = "%6d" % objective_input
    
    # Trigger winConditionMet().
    if objective_input <= 0:  gameplay.winConditionMet()


