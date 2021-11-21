
extends Control

onready var pause_state = false



"""
Pause screen needs:
    - Restart game.
    - Return to Rig Builder.
    - Display input controls.
"""



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
