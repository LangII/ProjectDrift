


extends Control

# Singletons.
onready var main = get_node('/root/Main')
onready var controls = get_node('/root/Controls')

# Node references.
onready var background_cam = find_node('BackgroundCamera*')
#onready var tree = find_node('PartsTreeVBox*')
#onready var pedestal = find_node('PedestalPos*')
#onready var stats_vbox = find_node('StatsVBox*')
#onready var details_label = find_node('DetailsLabel*')
#onready var min_req_popup = find_node('MinimumRequirementsPopUp*')
#onready var are_you_sure_popup = find_node('AreYouSurePopUp*')
#onready var rig_builder_tab_container = find_node('RigBuilderTabContainer*')
#onready var details_tab_container = find_node('DetailsTabContainer*')
#onready var model_tab_container = find_node('ModelTabContainer*')

## Resources.
#onready var PartSelectionBoxScene = preload('res://Scenes/Menus/Expandables/PartSelectionBox.tscn')
#onready var StatDisplayBoxScene = preload('res://Scenes/Menus/Expandables/StatDisplayBox.tscn')

#onready var pedestal_rot_spd = 0.008
onready var background_cam_rot_spd_1 = 0.0009
onready var background_cam_rot_spd_2 = -0.0006

#var inv_mod
#var boost_mod
#var stat_refs
#var rig_data_pack = {}

#onready var boosts = controls.boosts



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

#func _ready():
#
#    # Open temp mods.
#    inv_mod = main.loadModule(main, 'res://Scenes/Functional/InventoryMod.tscn')
#    boost_mod = main.loadModule(main, 'res://Scenes/Functional/BoostMod.tscn')
#    stat_refs = main.loadModule(main, 'res://Scenes/Functional/StatDisplayRefs.tscn')
#
#    setTabs()



#func setTabs():
#
#    rig_builder_tab_container.set_tab_title(0, 'rig builder menu')
#    details_tab_container.set_tab_title(0, 'details display')
#    model_tab_container.set_tab_title(0, 'rig model display')
#    model_tab_container.set_tab_title(1, 'rig stats display')



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(delta):
    
    background_cam.rotate_object_local(Vector3.UP, background_cam_rot_spd_1)
    background_cam.rotate_object_local(Vector3.FORWARD, background_cam_rot_spd_2)
#    pedestal.rotate_object_local(Vector3.UP, pedestal_rot_spd)



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_RigBuilderRulesButton_pressed():
    
    main.changeScene('res://Scenes/Menus/RigBuilder.tscn')
