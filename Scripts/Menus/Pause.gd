
extends Control

# Singletons.
onready var main = get_node('/root/Main')

# Node references.
onready var input_controls_grid = find_node('InputControlsGridContainer*')

# Node references.
onready var InputControlsInputBoxScene = preload('res://Scenes/Menus/Reusables/InputControlsInputBox.tscn')
onready var InputControlsDescriptionBoxScene = preload('res://Scenes/Menus/Reusables/InputControlsDescriptionBox.tscn')

onready var pause_state = false

var input_controls_notes
var input_notes


####################################################################################################


func _ready():
    
    main.scriptedScenePrint(name)
    
    # Open temp mods.
    input_controls_notes = main.loadModule(main, 'res://Scenes/Menus/InputControlsNotes.tscn')
    
    input_notes = input_controls_notes.input_map
    
    # Close temp mods.
    input_controls_notes.queue_free()
    
    loadInputControlsGrid()



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


func _on_RestartMatchButton_pressed():
    pass # Replace with function body.



func _on_ReturnToRigBuilderButton_pressed():
    
    get_tree().paused = false
    main.changeScene('res://Scenes/Menus/RigBuilder.tscn')



