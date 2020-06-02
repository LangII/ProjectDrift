
extends Spatial

# singletons.
onready var controls = get_node('/root/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')

# Controls.
onready var LIFE_TIME = controls.global['missile']['life_time']
onready var ACCEL_TIME = controls.global['missile']['accel_time']

# Node references.
#onready var _explosion_ = find_node('Explosion*')
#onready var explosion_mesh = _explosion_.find_node('ExplosionMesh*')
#onready var explosion_area = _explosion_.find_node('ExplosionArea*')
onready var life_timer = find_node('LifeTimer')
onready var accel_timer = find_node('AccelTimer')

onready var missile_explosion = preload('res://Scenes/Functional/Projectiles/MissileExplosion.tscn')

# Working variables.
var missile_launcher_tag
var explosions
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
    
    print("len(DAMAGE) = ", len(DAMAGE))
    
    explosions = buildAndGetExplosions()
    
#    print("DAMAGE = ", DAMAGE)
    
    life_timer.wait_time = LIFE_TIME
    accel_timer.wait_time = ACCEL_TIME
    life_timer.start()
    accel_timer.start()
    
#    onCollision()

func getMissileLauncherTag():
    # blaster_tag is based on scene's root node name.  The node names get renamed by the engine.
    # getBlasterTag() returns blaster_tag regardless of the engine's renaming.
    
    var missile_launcher_tag_
    if name[0] == '@':
        missile_launcher_tag_ = 'MissileLauncher' + name.substr(1, name.find('@', 1) - 1).right(19)
    else:
        missile_launcher_tag_ = 'MissileLauncher' + name.right(19)
    
    return missile_launcher_tag_

func buildAndGetExplosions():
    
    var explosions_ = []
    
    var opac_counter = len(DAMAGE)
    for key in DAMAGE:
        var explosion = {'node': '', 'tween': '', 'area': '', 'mesh': '', 'opacity': '', 'radius': '', 'damage': ''}
        var value = DAMAGE[key]
        explosion['node'] = missile_explosion.instance()
        add_child(explosion['node'])
        explosion['tween'] = explosion['node'].find_node('Tween*')
        explosion['area'] = explosion['node'].find_node('ExplosionArea*')
        explosion['mesh'] = explosion['node'].find_node('ExplosionMesh*')
        explosion['opacity'] = ((1.00 / len(DAMAGE)) * opac_counter) - 0.10
        opac_counter -= 1
        explosion['radius'] = key
        explosion['damage'] = value
        explosions_ += [ explosion ]
    
    return explosions_



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(delta):
    
    vel = vel * (1 + ACCEL)
    transform.origin += vel * delta
    
#    print(explosions[0]['mesh'].scale)

func spawn(_spawn_transform):
    
    transform = _spawn_transform
    vel = -transform.basis.z * SPEED

func onCollision():
    
#    var areas = explosion_area.get_overlapping_areas()
#    var bodies = explosion_area.get_overlapping_bodies()
#
#    for area in areas:  print("area = ", area.name)
#    for body in bodies:  print("body = ", body.name)

    for layer in explosions:
#        print(layer)
        for mesh in layer['mesh'].get_children():
#            mesh.get_surface_material().albedo_color = Color(_, _, _, layer['opacity'])
#            print(mesh.get_surface_material(0).albedo_color)
#            print(layer['opacity'])
            mesh.get_surface_material(0).albedo_color.a = layer['opacity']
#            print(mesh.get_surface_material(0).albedo_color)
#        layer['mesh'].scale = Vector3(1, 1, 1) * layer['radius']
        layer['tween'].interpolate_property(
            layer['mesh'], 'scale', layer['mesh'].scale, Vector3(1, 1, 1) * layer['radius'],
            0.1, Tween.TRANS_LINEAR , Tween.EASE_OUT
        )
        layer['tween'].start()



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_Area_body_entered(_body):
    
    onCollision()
    
#    queue_free()
    vel = Vector3()

func _on_LifeTimer_timeout():
    
#    queue_free()
    pass

func _on_AccelTimer_timeout():
    
    ACCEL = 0.00
