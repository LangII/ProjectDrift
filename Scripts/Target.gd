
extends Area

onready var controls = get_node('/root/Controls')

onready var target_tag = controls.gameplay['targets']

onready var health = controls.targets[target_tag]['health']
onready var visibility_radius = controls.targets[target_tag]['visibility_radius']
onready var turret_speed = controls.targets[target_tag]['turret_speed']

# # Bug?
# onready var col_radius = $Visibility/CollisionShape.shape.radius

onready var turret = $Turret
onready var obj_visible = null
onready var targeting
onready var how_far

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

    """ WORKING """
    # var targeting_origin = obj_visible.global_transform.origin - turret.global_transform.origin
    # var targeting_dir = turret.transform.looking_at(targeting_origin, Vector3.UP)
    # turret.transform = turret.transform.interpolate_with(targeting_dir, 0.01)

    """ WORKING BETTER """
    if obj_visible:  targeting = obj_visible.global_transform.origin - turret.global_transform.origin
    else:  targeting = Vector3(0, -1, 0.001)
    var targeting_dir = turret.transform.looking_at(targeting, Vector3.UP)
    if not turret.transform.basis.is_equal_approx(targeting_dir.basis, 0.01):
        turret.transform = turret.transform.interpolate_with(targeting_dir, 0.01)

    # how_far = turret.transform.basis.get_euler().angle_to(targeting_dir.basis.get_euler())
    # if how_far > 0.1:

    # turret.look_at(targeting.transform.origin - turret.transform.origin, Vector3.UP)

    # else:

        # turret.look_at(turret.global_transform.origin + Vector3(0, -1, 0.01), Vector3.UP)

func _on_Visibility_body_entered(body):

    if body.name == 'Vehicle':  obj_visible = body

func _on_Visibility_body_exited(body):

    if body == obj_visible:  obj_visible = null
