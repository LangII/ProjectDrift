
"""

Main.gd

Curently not much to see.  This is because the current primary development focus is on gameplay
vehicle controls (not to be confused with Controls.gd) and functionality.  As menu systems are
developed, so will Main.gd.

"""

extends Node

onready var controls = get_node('/root/Controls')

#var save_mod

####################################################################################################


func _ready():
    
    
    ################################################################################################
    """ TESTING """

##    save_mod = loadModule(self, 'res://Scenes/Functional/SaveMod.tscn')
#    var scene_path = 'test/TEST_NAME.tscn'
##    var len_scene_path = len(scene_path)
##    print("len_scene_path = ", len_scene_path)
#    var slash_i = scene_path.rfind('/')
#    var dot_i = scene_path.rfind('.')
#    print("slash_i = ", slash_i)
#    print("dot_i = ", dot_i)
#
#    print(scene_path.substr(slash_i + 1, dot_i - slash_i - 1))
#
#    get_tree().quit()

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
        
        var save_mod = loadModule(self, 'res://Scenes/Functional/SaveMod.tscn')
        
        print("\ncontrols.gameplay['vehicle_rig'] =")
        print(controls.gameplay['vehicle_rig'])
        
        print("\nsave_mod.getSavedData(['_last_used_vehicle_rig_']) =")
        print(save_mod.getSavedData(['_last_used_vehicle_rig_']))
        
        ############################################################################################

func loadModule(_parent, _path):
    
    # get 'module_name' from '_path'
    var slash_i = _path.rfind('/')
    var dot_i = _path.rfind('.')
    var module_name = _path.substr(slash_i + 1, dot_i - slash_i - 1)
    
    # check all prev loaded modules, if module already loaded, return it
    for child in get_children():
        if module_name == child.name:
            print("\n>>> [%s] scene already loaded" % module_name)
            return child
    
    # load module (if not prev loaded) and return it
    var Module = load(_path)
    var module = Module.instance()
    _parent.add_child(module)
    return module



func changeScene(_scene):
    
    for child in get_children():
        print("\n>>> removing scene [%s]" % child.name)
        remove_child(child)
        child.queue_free()
    
    print("\n>>> changing scene to [%s]" % _scene)
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

