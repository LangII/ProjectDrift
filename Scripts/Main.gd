
"""

Main.gd

Curently not much to see.  This is because the current primary development focus is on gameplay
vehicle controls (not to be confused with Controls.gd) and functionality.  As menu systems are
developed, so will Main.gd.

"""

extends Node

onready var controls = get_node('/root/Controls')



func _ready():
    
    changeScene('res://Scenes/Menus/RigBuilder.tscn')
    
#    print("\n>>> [%s] scripted scene entering tree" % name)
#
#    if controls.TESTING_no_menu:
#        var gameplay = preload('res://Scenes/Functional/Gameplay.tscn')
#        add_child(gameplay.instance())
#    else:
#        var part_selection = preload('res://Scenes/Menus/PartSelection.tscn')
#        add_child(part_selection.instance())



func loadModule(_parent, _path):
    
    var Module = load(_path)
    var module = Module.instance()
    _parent.add_child(module)
    
    return module



func changeScene(_scene):
    
    print("\n>>> changing scene to %s" % _scene)
    
#    if get_tree().change_scene(_scene) != OK:
#        print("\n>>> !!! ERROR changing scene to %s !!!" % _scene)
#        get_tree().quit()

    var current_scene = get_child(0)
    if current_scene:  current_scene.queue_free()

    var scene = load(_scene)
    add_child(scene.instance())







