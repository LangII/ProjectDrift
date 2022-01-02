
extends Control

# global nodes
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')

# node references
onready var input_controls_grid = find_node('InputControlsGridContainer*')
onready var mouse_sensitivity_slider = find_node('MouseSensitivitySlider*')
onready var mouse_sensitivity_value_label = find_node('MouseSensitivityValueLabel*')
onready var mouse_vertical_drag_slider = find_node('MouseVerticalDragSlider*')
onready var mouse_vertical_drag_value_label = find_node('MouseVerticalDragValueLabel*')
onready var vehicle_body_tag = controls.gameplay['vehicle_rig']['body']['part_tag']  # to get vehicle
onready var vehicle = get_node('/root/Main/Gameplay/Vehicles/%s' % vehicle_body_tag)

# preload resources
onready var InputControlsInputBoxScene = preload('res://Scenes/Menus/Reusables/InputControlsInputBox.tscn')
onready var InputControlsDescriptionBoxScene = preload('res://Scenes/Menus/Reusables/InputControlsDescriptionBox.tscn')

# local vars
onready var pause_state = false
onready var mouse_sensitivity_has_been_set = false
onready var mouse_vertical_drag_has_been_set = false
onready var mouse_sensitivity_translator = controls.global['vehicle']['mouse_sensitivity_translator']
onready var mouse_vertical_drag_translator = controls.global['vehicle']['mouse_vertical_drag_translator']
var save_mod
var input_controls_notes
var input_notes


####################################################################################################
                                                                                 # \/   READY   \/ #

func _ready():
    
    main.scriptedScenePrint(name, 'enter')
    
    # Open temp mods.
    save_mod = main.loadModule(main, 'res://Scenes/Functional/SaveMod.tscn')
    input_controls_notes = main.loadModule(main, 'res://Scenes/Menus/InputControlsNotes.tscn')
    
    input_notes = input_controls_notes.input_map
    
    # Close temp mods.
    input_controls_notes.queue_free()
    
    loadMouseSettings()
    
    loadInputControlsGrid()



func loadMouseSettings():
    
    var mouse_sensitivity = save_mod.getSavedData(['_mouse_sensitivity_'])
    mouse_sensitivity_slider.value = mouse_sensitivity / mouse_sensitivity_translator
    mouse_sensitivity_value_label.text = str(mouse_sensitivity)
    mouse_sensitivity_has_been_set = true
    
    var mouse_vertical_drag = save_mod.getSavedData(['_mouse_vertical_drag_'])
    mouse_vertical_drag_slider.value = mouse_vertical_drag / mouse_vertical_drag_translator
    mouse_vertical_drag_value_label.text = str(mouse_vertical_drag)
    mouse_vertical_drag_has_been_set = true



func loadInputControlsGrid():
    
    for input in input_notes.keys():
        var description = input_notes[input]
        
        # Load input boxes.
        var input_box = InputControlsInputBoxScene.instance()
        input_box.find_node('InputKeyLabel*').text = input
        input_controls_grid.add_child(input_box)
        
        # Load description boxes.
        var description_box = InputControlsDescriptionBoxScene.instance()
        description_box.find_node('InputValueLabel*').text = description
        input_controls_grid.add_child(description_box)



func _input(event):
    
    if event.is_action_pressed('ui_cancel'):
        match pause_state:
            false:
                pause_state = true
                visible = true
                get_tree().paused = true
                Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            true:
                pause_state = false
                visible = false
                get_tree().paused = false
                Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


####################################################################################################
                                                                               # \/   SIGNALS   \/ #

func _on_RestartMatchButton_pressed():
    
    get_tree().paused = false
    main.changeScene('res://Scenes/Functional/Gameplay.tscn')



func _on_ReturnToRigBuilderButton_pressed():
    
    get_tree().paused = false
    main.changeScene('res://Scenes/Menus/RigBuilder.tscn')



func _on_MouseSensitivitySlider_value_changed(_value:float) -> void:
    
    if not mouse_sensitivity_has_been_set:  return
    
    _value *= mouse_sensitivity_translator
    
    # update in pause display
    mouse_sensitivity_value_label.text = str(_value)
    # update in save data
    save_mod.saveDataReplace({'_mouse_sensitivity_': _value})
    # update in vehicle
    var vehicle_body_tag = controls.gameplay['vehicle_rig']['body']['part_tag']
    var vehicle = get_node('/root/Main/Gameplay/Vehicles/%s' % vehicle_body_tag)
    vehicle.mouse_sensitivity = _value



func _on_MouseVerticalDragSlider_value_changed(_value:float) -> void:
    
    if not mouse_vertical_drag_has_been_set:  return
    
    _value *= mouse_vertical_drag_translator
    
    # update in pause display
    mouse_vertical_drag_value_label.text = str(_value)
    # update in save data
    save_mod.saveDataReplace({'_mouse_vertical_drag_': _value})
    # update in vehicle
    var vehicle_body_tag = controls.gameplay['vehicle_rig']['body']['part_tag']
    var vehicle = get_node('/root/Main/Gameplay/Vehicles/%s' % vehicle_body_tag)
    vehicle.mouse_vertical_drag = _value


####################################################################################################
                                                                           # \/   ON DELETION   \/ #

func queue_free():

    main.scriptedScenePrint(name, 'exit')

















