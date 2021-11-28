
"""

Main.gd

Curently not much to see.  This is because the current primary development focus is on gameplay
vehicle controls (not to be confused with Controls.gd) and functionality.  As menu systems are
developed, so will Main.gd.

"""

extends Node

onready var controls = get_node('/root/Controls')

####################################################################################################


func _ready():
    
    
    ################################################################################################
    """ TESTING """
#    print("TESTING")
#    var word = 'something'
#    for i in range(2):
#        var word = String(i)
#        print("word", word)
#    print("word", word)

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
        
        var rig_builder = get_node('/root/Main/RigBuilder')
        for branch in rig_builder.tree.get_children():
            print("")
            print("branch.branch_layer = ", branch.branch_layer)
            print("branch.branch_type = ", branch.branch_type)
            
#        print("\ncontrols.parts_inv:")
#        print(controls.parts_inv)
#        print("\ncontrols.boosts_inv:")
#        print(controls.boosts_inv)
        
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



func scriptedScenePrint(_scene_name):
    
    print("\n>>> [%s] scripted scene entering tree" % _scene_name)


####################################################################################################


    # OBSOLETE (DL 2021-02-21) ... update main.changeScene()
#    if get_tree().change_scene(_scene) != OK:
#        print("\n>>> !!! ERROR changing scene to %s !!!" % _scene)
#        get_tree().quit()

