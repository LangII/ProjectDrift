
extends Area

onready var controls = get_node('/root/Controls')

onready var target_tag = controls.gameplay['targets']
onready var bolt_tag = controls.targets[target_tag]['bolt_scene']

onready var health = controls.targets[target_tag]['health']
onready var visibility_radius = controls.targets[target_tag]['visibility_radius']
onready var targeting_speed = controls.targets[target_tag]['targeting_speed']
onready var cool_down = controls.targets[target_tag]['cool_down']

onready var Bolt = load('res://Scenes/Functional/Projectiles/' + bolt_tag + '.tscn')
onready var spawn_bolt = $Turret/SpawnBolt
onready var turret_cool_down = $TurretCoolDown
onready var turret_cooled_down = true
var bolt

# # Bug?
# onready var col_radius = $Visibility/CollisionShape.shape.radius

onready var turret = $Turret
onready var obj_visible = null
onready var awake = false
onready var targeting = Vector3()
onready var how_close_to_shoot = 0.04

####################################################################################################

func _ready():

    """ Bug? """
    # col_radius = visibility_radius
    $Visibility/CollisionShape.shape.radius = visibility_radius

    turret_cool_down.wait_time = cool_down
    turret_cooled_down = true

    turret.look_at(turret.global_transform.origin + Vector3(0, -1, 0.00001), Vector3.UP)

####################################################################################################

func _process(delta):

    """ from Discord (Fabian) """
    # _tween.interpolate_property(self, "transform:basis",
    #         initial_basis, final_basis, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
    #     _tween.start()

    if awake:
        if obj_visible:
            targeting = obj_visible.global_transform.origin - turret.global_transform.origin

            var aim = turret.transform.basis.y.angle_to(targeting)
            # print(aim)
            if (aim < 1.57 + how_close_to_shoot) and (aim > 1.57 - how_close_to_shoot):
                if turret_cooled_down:
                    bolt = Bolt.instance()
                    get_parent().get_parent().add_child(bolt)
                    bolt.spawn(spawn_bolt.global_transform)
                    turret_cool_down.start()
                    turret_cooled_down = false

        else:
            targeting = Vector3(0, -1, 0.00001)
            if turret.transform.basis.y.angle_to(Vector3.DOWN) < 1.6:  awake = false
        var targeting_dir = turret.transform.looking_at(targeting, Vector3.UP)
        turret.transform = turret.transform.interpolate_with(targeting_dir, targeting_speed).orthonormalized()

####################################################################################################

func _on_Visibility_body_entered(body):

    if body.name == 'Vehicle':
        awake = true
        obj_visible = body

func _on_Visibility_body_exited(body):

    if body == obj_visible:  obj_visible = null

func _on_TurretCoolDown_timeout():

    turret_cooled_down = true
