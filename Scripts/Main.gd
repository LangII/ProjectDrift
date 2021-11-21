
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

    """ comment in to do direct unisolated test of scene (comment out the rest of _ready()) """

#    changeScene('res://Scenes/Menus/RigBuilder.tscn')
#    changeScene('res://Scenes/Menus/ArenaSelection.tscn')
    changeScene('res://Scenes/Functional/Gameplay.tscn')
    
    
    
#    print("\n>>> [%s] scripted scene entering tree" % name)
#    if controls.TESTING_no_menu:
#        var gameplay = preload('res://Scenes/Functional/Gameplay.tscn')
#        add_child(gameplay.instance())
#    else:
#        var part_selection = preload('res://Scenes/Menus/PartSelection.tscn')
#        add_child(part_selection.instance())

    ################################################################################################

func _process(_delta):
    if Input.is_action_just_released('ui_test'):
        print("\nTESTING...")
        
        ############################################################################################
        """ TESTING """
        
#        print()
        
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


####################################################################################################


    # OBSOLETE (DL 2021-02-21) ... update main.changeScene()
#    if get_tree().change_scene(_scene) != OK:
#        print("\n>>> !!! ERROR changing scene to %s !!!" % _scene)
#        get_tree().quit()

