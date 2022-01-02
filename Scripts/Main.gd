
"""

Main.gd

Curently not much to see.  This is because the current primary development focus is on gameplay
vehicle controls (not to be confused with Controls.gd) and functionality.  As menu systems are
developed, so will Main.gd.

"""

extends Node

onready var controls = get_node('/root/Controls')

var save_mod

####################################################################################################


func _ready():
    
    
    ################################################################################################
    """ TESTING """

    save_mod = loadModule(self, 'res://Scenes/Functional/SaveMod.tscn')

    """ Comment in/out to select game starting scene. """

    changeScene('res://Scenes/Menus/RigBuilder.tscn')
#    changeScene('res://Scenes/Menus/ArenaSelection.tscn')
#    changeScene('res://Scenes/Functional/Gameplay.tscn')

    ################################################################################################

func _process(_delta):
    if Input.is_action_just_released('ui_test'):
        print("\nTESTING...")
        
        ############################################################################################
        """ TESTING """
        
        var pause = get_node('/root/Main/Gameplay/Pause')
        
        print("pause mouse_sensitivity slider value = ", pause.mouse_sensitivity_slider.value)
        print("pause mouse_vertical_drag slider value = ", pause.mouse_vertical_drag_slider.value)
        print("")
        print("saved_mouse_sensitivity = ", save_mod.getSavedData(['_mouse_sensitivity_']))
        print("saved_mouse_vertical_drag = ", save_mod.getSavedData(['_mouse_vertical_drag_']))
        
        
        ############################################################################################

func loadModule(_parent, _path):
    
    var Module = load(_path)
    var module = Module.instance()
    _parent.add_child(module)
    
    return module



func changeScene(_scene):
    
    var print_str = "\n>>> changing scene to %s" % _scene
    
    var current_scene = get_child(0)
    if current_scene:
        print_str += " ... from scene %s" % current_scene.name
        remove_child(current_scene)
        current_scene.queue_free()
    
    print(print_str)

    add_child(load(_scene).instance())



func scriptedScenePrint(_scene_name:String, _type:String) -> void:
    
    if _type == 'enter':  _type = 'entering'
    elif _type == 'exit':  _type = 'exiting'
    
    print("\n>>> [%s] scripted scene [%s] tree" % [_scene_name, _type])


####################################################################################################


    # OBSOLETE (DL 2021-02-21) ... update main.changeScene()
#    if get_tree().change_scene(_scene) != OK:
#        print("\n>>> !!! ERROR changing scene to %s !!!" % _scene)
#        get_tree().quit()

