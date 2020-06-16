
extends Spatial

# singletons.
onready var controls = get_node('/root/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')

# Controls.
onready var LIFE_TIME = controls.global['missile']['life_time']
onready var ACCEL_TIME = controls.global['missile']['accel_time']
onready var EXPL_EXPAND_TIME = controls.global['missile']['explosion_expand_time']
onready var EXPL_FADE_OUT_TIME = controls.global['missile']['explosion_fade_out_time']
onready var vehicle_rig = controls.gameplay['vehicle_rig']

# Node references.
onready var missile_mesh = find_node('Mesh*')
onready var life_timer = find_node('LifeTimer*')
onready var accel_timer = find_node('AccelTimer*')
onready var expl_expand_timer = find_node('ExplosionExpandTimer*')
onready var expl_complete_timer = find_node('ExplosionCompleteTimer*')

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
    
    missile_launcher_tag = getMissileLauncherTag()
    
    setControlVars()
    
    explosions = buildAndGetExplosionLayers()
    
    life_timer.wait_time = LIFE_TIME
    accel_timer.wait_time = ACCEL_TIME
    expl_expand_timer.wait_time = EXPL_EXPAND_TIME
    expl_complete_timer.wait_time = EXPL_EXPAND_TIME + EXPL_FADE_OUT_TIME

    life_timer.start()
    accel_timer.start()



func getMissileLauncherTag():
    # missile_launcher_tag is based on scene's root node name.  The node names get renamed by the
    # engine.  getMissileLauncherTag() returns missile_launcher_tag regardless of the engine's
    # renaming.
    
    var missile_launcher_tag_
    if name[0] == '@':
        missile_launcher_tag_ = 'MissileLauncher' + name.substr(1, name.find('@', 1) - 1).right(19)
    else:
        missile_launcher_tag_ = 'MissileLauncher' + name.right(19)
    
    return missile_launcher_tag_



func setControlVars():
    
    for part_dict in vehicle_rig.values():
        if part_dict['part_tag'] != missile_launcher_tag:  continue
        
        DAMAGE = part_dict['part_stats']['damage']
        SPEED = part_dict['part_stats']['missile_speed']
        ACCEL = part_dict['part_stats']['missile_accel']
        return



func buildAndGetExplosionLayers():
    # Return array explosions_, each element is a dictionary needed for visual animation and damage
    # distribution of each layer.
    
    var explosions_ = []
    
    # BLOCK...  Loop through key, value of DAMAGE to build each explosion layer.
    var opac_counter = len(DAMAGE)
    for key in DAMAGE:
        var value = DAMAGE[key]
        var explosion = {}
        # Get instanced scene and reference node.
        var explosion_node = missile_explosion.instance()
        var explosion_area = explosion_node.find_node('ExplosionArea*')
        # Build explosion layer dictionary.
        explosion['node'] =     explosion_node
        explosion['tween'] =    explosion_node.find_node('Tween*')
        explosion['area'] =     explosion_area
        explosion['mesh'] =     explosion_node.find_node('ExplosionMesh*')
        explosion['opacity'] =  ((1.00 / len(DAMAGE)) * opac_counter) - 0.10
        explosion['radius'] =   key
        explosion['damage'] =   value
        # Other necessary maintenance per loop.
        add_child(explosion['node'])
        explosion_area.get_node('CollisionShape').shape.radius = key / 10.0
        opac_counter -= 1
        # Append for return.
        explosions_ += [ explosion ]
    
    return explosions_



####################################################################################################
                                                                                 ###   PROCESS   ###
                                                                                 ###################

func _process(delta):
    
    vel = vel * (1 + ACCEL)
    transform.origin += vel * delta



func spawn(_spawn_transform):
    
    transform = _spawn_transform
    vel = -transform.basis.z * SPEED



func distributeDamage():
    # Find objects that are with explosion area of each explosion layer and trigger
    # objectInExplosion() gameplay method.
    
    for layer in explosions:
        # Get objects in area.
        var areas = layer['area'].get_overlapping_areas()
        var bodies = layer['area'].get_overlapping_bodies()
        # Based on object's parent, send object and damage data to gameplay method.
        for object in areas + bodies:
            if object.get_parent().name == 'Vehicles':
                gameplay.objectInExplosion(object, layer['damage'], 'Vehicles')
            elif object.get_parent().name == 'Targets':
                gameplay.objectInExplosion(object, layer['damage'], 'Targets')



func onCollision():
    # Events that occur when the missile collides.
    
    # Trigger collision timers.
    expl_expand_timer.start()
    expl_complete_timer.start()
    
    distributeDamage()
    
    # Because as of now there are multiple mesh nodes making up the model, the mesh container needs
    # to be looped through inside of each layer loop.  All of this to update each mesh's alpha then
    # trigger a tween on the mesh container.
    for layer in explosions:
        for mesh in layer['mesh'].get_children():
            mesh.get_surface_material(0).albedo_color.a = layer['opacity']
        layer['tween'].interpolate_property(
            layer['mesh'],                      # node
            'scale',                            # property
            layer['mesh'].scale,                # starting value
            Vector3.ONE * layer['radius'],      # ending value
            EXPL_EXPAND_TIME,                   # duration of tween
            Tween.TRANS_LINEAR,                 # detail 1
            Tween.EASE_OUT                      # detail 2
        )
        layer['tween'].start()



func explosionFadeOut():
    # Trigger alpha fade out tween of each mesh in mesh container of each explosion layer.
    
    for layer in explosions:
        for mesh in layer['mesh'].get_children():
            var mesh_mat = mesh.get_surface_material(0)
            var mesh_color = mesh_mat.albedo_color
            layer['tween'].interpolate_property(
                mesh_mat,                                               # node
                'albedo_color',                                         # property
                mesh_color,                                             # starting value
                Color(mesh_color.r, mesh_color.g, mesh_color.b, 0),     # ending value
                EXPL_FADE_OUT_TIME,                                     # duration of tween
                Tween.TRANS_LINEAR,                                     # detail 1
                Tween.EASE_IN                                           # detail 2
            )
            layer['tween'].start()



####################################################################################################
                                                                                 ###   SIGNALS   ###
                                                                                 ###################

func _on_Area_body_entered(_body):
    
    onCollision()
    vel = Vector3()
    missile_mesh.visible = false

func _on_LifeTimer_timeout():
    
    queue_free()

func _on_AccelTimer_timeout():
    
    ACCEL = 0.00

func _on_ExplosionExpandTimer_timeout():
    
    explosionFadeOut()

func _on_ExplosionCompleteTimer_timeout():

    queue_free()
