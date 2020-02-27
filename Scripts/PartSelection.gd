


extends Control



####################################################################################################
                                                                                ###   CONTROLS   ###
                                                                                ####################

onready var controls = get_node('/root/Controls')
# onready var gameplay = get_node('/root/Gameplay')

onready var Notes = preload('res://Scenes/Menus/PartSelectionNotes.tscn')
onready var part_notes = $PartNotes
var notes



####################################################################################################
                                                                                    ###   VARS   ###
                                                                                    ################

onready var generator_yellow = find_node('GeneratorYellow')
onready var generator_green = find_node('GeneratorGreen')
onready var generator_group = ButtonGroup.new()

onready var engines_yellow = find_node('EnginesYellow')
onready var engines_green = find_node('EnginesGreen')
onready var engines_group = ButtonGroup.new()

onready var blaster_yellow = find_node('BlasterYellow')
onready var blaster_green = find_node('BlasterGreen')
onready var blaster_group = ButtonGroup.new()

onready var shields_yellow = find_node('ShieldsYellow')
onready var shields_green = find_node('ShieldsGreen')
onready var shields_group = ButtonGroup.new()

onready var mouse_sensitivity = find_node('MouseSensitivity')
var MOUSE_TRANSLATOR = 0.00016



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():

    add_child(Notes.instance())
    notes = $PartSelectionNotes

    generator_yellow.set_button_group(generator_group)
    generator_green.set_button_group(generator_group)
    generator_yellow.set_pressed(true)

    engines_yellow.set_button_group(engines_group)
    engines_green.set_button_group(engines_group)
    engines_yellow.set_pressed(true)

    blaster_yellow.set_button_group(blaster_group)
    blaster_green.set_button_group(blaster_group)
    blaster_yellow.set_pressed(true)

    shields_yellow.set_button_group(shields_group)
    shields_green.set_button_group(shields_group)
    shields_yellow.set_pressed(true)

    mouse_sensitivity.text = str(controls.global['vehicle']['mouse_sensitivity'])



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_Slider_value_changed(value):

    mouse_sensitivity.text = str(value * MOUSE_TRANSLATOR)



func _on_Play_pressed():

    match generator_group.get_pressed_button():
        generator_yellow:     controls.gameplay['vehicle']['generator'] = 'TestGenerator01'
        generator_green:      controls.gameplay['vehicle']['generator'] = 'TestGenerator02'

    match engines_group.get_pressed_button():
        engines_yellow:     controls.gameplay['vehicle']['engines'] = 'TestEngines01'
        engines_green:      controls.gameplay['vehicle']['engines'] = 'TestEngines02'

    match blaster_group.get_pressed_button():
        blaster_yellow:     controls.gameplay['vehicle']['blaster'] = 'TestBlaster01'
        blaster_green:      controls.gameplay['vehicle']['blaster'] = 'TestBlaster02'

    match shields_group.get_pressed_button():
        shields_yellow:     controls.gameplay['vehicle']['shields'] = 'TestShields01'
        shields_green:      controls.gameplay['vehicle']['shields'] = 'TestShields02'

    controls.global['vehicle']['mouse_sensitivity'] = float(mouse_sensitivity.text)

    get_tree().change_scene('res://Scenes/Functional/Gameplay.tscn')


func _on_GeneratorYellow_pressed():

    part_notes.text = notes.parts['TestGenerator01']
