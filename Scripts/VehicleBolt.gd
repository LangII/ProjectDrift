
extends Spatial

# singletons.
onready var controls = get_node('/root/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')

# Controls.
onready var LIFE_TIME = controls.global['bolt']['life_time']
onready var vehicle_rig = controls.gameplay['vehicle_rig']

# Node references.
onready var timer = find_node('Timer')

# Working variables.
var blaster_tag
var ENERGY
var SPEED
var vel = Vector3()



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
    blaster_tag = getBlasterTag()
    
    setControlVars()
    
    timer.wait_time = LIFE_TIME
    timer.start()

func getBlasterTag():
    # blaster_tag is based on scene's root node name.  The node names get renamed by the engine.
    # getBlasterTag() returns blaster_tag regardless of the engine's renaming.
    
    var blaster_tag_
    if name[0] == '@':  blaster_tag_ = 'Blaster' + name.substr(1, name.find('@', 1) - 1).right(11)
    else:  blaster_tag_ = 'Blaster' + name.right(11)
    
    return blaster_tag_

func setControlVars():
    
    for part_dict in vehicle_rig.values():
        if part_dict['part_tag'] != blaster_tag:  continue
        
        ENERGY = part_dict['part_stats']['energy']
        SPEED = part_dict['part_stats']['bolt_speed']
        return



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(delta):
    
    transform.origin += vel * delta

func spawn(_spawn_transform):
    
    transform = _spawn_transform
    vel = -transform.basis.z * SPEED



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_Timer_timeout():
    
    queue_free()

func _on_Area_body_entered(_body):
    
    if _body.get_parent().name == 'Targets':  gameplay.vehicleBoltHitsTargetBody(self, _body)
    queue_free()
