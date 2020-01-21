
extends Area

onready var controls = get_node('/root/Controls')

onready var target_tag = controls.gameplay['targets']

onready var health = controls.targets[target_tag]['health']
onready var visibility_radius = controls.targets[target_tag]['visibility_radius']
onready var turret_speed = controls.targets[target_tag]['turret_speed']

# # Bug?
# onready var col_radius = $Visibility/CollisionShape.shape.radius

onready var turret = $Turret
onready var targeting = null

onready var rot_tween = $Turret/RotTween

####################################################################################################

func _ready():

    # # Bug?
    # col_radius = visibility_radius
    $Visibility/CollisionShape.shape.radius = visibility_radius

    turret.look_at(turret.global_transform.origin + Vector3(0, -1, 0.01), Vector3.UP)

    # turret.rotation = Vector3.DOWN

func _process(delta):

    # print("origin   ", turret.transform.origin)
    # print("origin - ", turret.global_transform.origin + Vector3.DOWN)
    # print("rotation ", turret.rotation)

    if targeting:

        # turret.look_at(targeting.transform.origin - turret.transform.origin, Vector3.UP)

        var targeting_origin = targeting.global_transform.origin - turret.global_transform.origin
        var targeting_dir = turret.transform.looking_at(targeting_origin, Vector3.UP)
        turret.transform = turret.transform.interpolate_with(targeting_dir, 0.01)

    else:

        turret.look_at(turret.global_transform.origin + Vector3(0, -1, 0.01), Vector3.UP)

func _on_Visibility_body_entered(body):

    # print(body.name)

    if body.name == 'Vehicle':  targeting = body

func _on_Visibility_body_exited(body):

    if body == targeting:  targeting = null
