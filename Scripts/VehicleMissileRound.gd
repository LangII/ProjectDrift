
extends Spatial

# singletons.
onready var controls = get_node('/root/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')

# Controls.
onready var LIFE_TIME = controls.global['missile']['life_time']
onready var ACCEL_TIME = controls.global['missile']['accel_time']

# Node references.
onready var life_timer = find_node('LifeTimer')
onready var accel_timer = find_node('AccelTimer')

# Working variables.
var missile_launcher_tag
var DAMAGE
var SPEED
var ACCEL
var vel = Vector3()



####################################################################################################
                                                                                   ###   READY   ###
                                                                                   #################

func _ready():
    
#            'damage': {5.0: 10.0, 8.0: 5.0,},
#            'missile_speed': 40.0,
#            'missile_acc': 0.5,
#            'cool_down': 1.5,
#            'magazine_capacity': 14,
    
    missile_launcher_tag = getMissileLauncherTag()
    
    DAMAGE = controls.launchers['Missile'][missile_launcher_tag]['damage']
    SPEED = controls.launchers['Missile'][missile_launcher_tag]['missile_speed']
    ACCEL = controls.launchers['Missile'][missile_launcher_tag]['missile_accel']
    
    life_timer.wait_time = LIFE_TIME
    accel_timer.wait_time = ACCEL_TIME
    life_timer.start()
    accel_timer.start()

func getMissileLauncherTag():
    # blaster_tag is based on scene's root node name.  The node names get renamed by the engine.
    # getBlasterTag() returns blaster_tag regardless of the engine's renaming.
    
    var missile_launcher_tag_
    if name[0] == '@':
        missile_launcher_tag_ = 'MissileLauncher' + name.substr(1, name.find('@', 1) - 1).right(19)
    else:
        missile_launcher_tag_ = 'MissileLauncher' + name.right(19)
    
    return missile_launcher_tag_



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(delta):
    
    vel = vel * (1 + ACCEL)
    transform.origin += vel * delta

func spawn(_spawn_transform):
    
    transform = _spawn_transform
    vel = -transform.basis.z * SPEED



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_Area_body_entered(_body):
    
    print("!!!   EXPLOSION   !!!")
    queue_free()
    
    """
    Next to-do:  Explosion animation and damage radius calculations.
    """

func _on_LifeTimer_timeout():
    
    queue_free()

func _on_AccelTimer_timeout():
    
    ACCEL = 0.00
