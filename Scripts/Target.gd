
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

        """ WORKS (BUT SNAPS TOO SUDDENLY) """
        turret.look_at(targeting.transform.origin - turret.transform.origin, Vector3.UP)


        """ BUGGY """
        # var current_dir = Quat(turret.transform.basis)
        # var targeting_dir = Quat(Basis(targeting.global_transform.origin - turret.global_transform.origin))
        # var slerp_dir = current_dir.slerp(targeting_dir, 0.5)
        # turret.transform.basis = Basis(slerp_dir)
        # print("q cur ", quat_current_dir)
        # print("q tar ", quat_targeting_dir)

        # var look_dir = targeting.get_transform().origin - transform.origin
        # var rot_trans = turret.look_at(look_dir, Vector3.UP)
        # var this_rot = Quat(transform.basis).slerp(rot_trans.basis, 0.5)
        # set_transform(Transform(this_rot, transform.origin))

        # var targeting_dir = (targeting.global_transform.origin - global_transform.origin).normalized()
        # var rot_trans = look_at(targeting_dir, Vector3.UP)
        # print(rot_trans)
        # var this_rot = Quat(transform.basis).slerp(Quat(rot_trans.basis), 0.5)
        # transform.basis = Basis(this_rot)

        # print(Basis(targeting.transform.origin - transform.origin))

        # print(targeting_dir)
        # var current_dir = Vector3(1, 0, 0).rotated(turret.rotation, PI)
        # print(current_dir)
        # turret.rotation = current_dir.linear_interpolate(targeting_dir, turret_speed * delta).normalized()
        # turret.look_at(current_dir.linear_interpolate(targeting_dir, turret_speed * delta).normalized(), Vector3(0, 1, 0))

        # var current_dir = transform.basis
        # print(current_dir)
        # var targeting_dir = Basis(targeting.global_transform.origin - global_transform.origin)
        # print(targeting_dir)



    else:

        turret.look_at(turret.global_transform.origin + Vector3(0, -1, 0.01), Vector3.UP)
        # turret.rotate_object_local(Vector3(0, 1, 0), PI)

func _on_Visibility_body_entered(body):

    # print(body.name)

    if body.name == 'Vehicle':  targeting = body

func _on_Visibility_body_exited(body):

    if body == targeting:  targeting = null
