
extends Control

onready var pause_state = false

func _input(event):
    if event.is_action_pressed('ui_cancel'):
        if pause_state == false:
            pause_state = true
            visible = true
            get_tree().paused = true
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        elif pause_state == true:
            pause_state = false
            visible = false
            get_tree().paused = false
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
