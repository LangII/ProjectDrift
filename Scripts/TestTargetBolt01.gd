
extends Area

onready var controls = get_node('/root/Controls')

# Get control variable tag.
onready var target_tag = controls.gameplay['targets']

# Get bolt model tag and scene.
onready var bolt_model_tag = controls.targets[target_tag]['bolt_model']
onready var scene_str = 'res://Scenes/Models/Projectiles/' + bolt_model_tag + '.tscn'
onready var bolt_model = load(scene_str)

# Get bolt's control variables.
onready var ENERGY = controls.targets[target_tag]['energy']
onready var SPEED = controls.targets[target_tag]['speed']

# Get system controls.
onready var LIFE_TIME = controls.global['bolt']['life_time']

onready var timer = $Timer

var vel = Vector3()

onready var hud = get_node('/root/Gameplay/Vehicle/Hud')

onready var temp_bug_fix = $TempBugFix

func _ready():

    add_child(bolt_model.instance())

    timer.wait_time = LIFE_TIME
    timer.start()

func _process(delta):

    transform.origin += vel * delta

    if temp_bug_fix.is_colliding():
        if temp_bug_fix.get_collider().get_parent().name == 'ObstaclesRamps':  queue_free()

func _on_Timer_timeout():

    queue_free()

func spawn(_spawn_transform):

    transform = _spawn_transform
    vel = -transform.basis.z * SPEED



func _on_Bolt_body_entered(body):

    if body.name == 'Vehicle':

        if body.shields_battery > 0:

            body.shields_battery -= ENERGY * (1 - body.SHIELDS_DENSITY)

            if body.shields_battery < 0:

                # NEED TO FIX ... Currently, if damage is done to shield, and carried over to
                # health, the carry over value will have density applied to it, not armor.  If
                # damage is done to health, armor should be applied, not density.  Right now, this
                # is not the case.

                body.HEALTH -= abs(body.shields_battery)
                body.shields_battery = 0
                hud.updateShieldsBatteryValue(body.shields_battery)
                hud.updateHealthValue(body.HEALTH)

            else:

                hud.updateShieldsBatteryValue(body.shields_battery)

        else:

            body.HEALTH -= ENERGY * (1 - body.ARMOR)
            hud.updateHealthValue(body.HEALTH)

        """
        *** NEED TO FIX ***
        These operations should be handled by the parent Gameplay.gd.
        """
        # if body.HEALTH <= 0:
        #     print("GAME OVER")

    queue_free()








# func _on_Bolt_area_entered(area):
#
#     """
#     *** NEED TO FIX ***
#     Issues with collision layers.  This if replaces layer controls.
#     """
#     if area.name == 'Visibility':  return
#
#     """
#     *** NEED TO FIX ***
#     These operations should be handled by the parent Gameplay.gd.
#     """
#     if area.get_parent().get_parent().name == 'Targets':
#
#         area.health -= ENERGY
#
#         if area.health <= 0:
#             hud.updateObjectiveValue(int(hud.objective_value.text) - 1)
#             area.get_parent().queue_free()
#             hud.updateFocusNameValue('')
#             hud.updateFocusHealthValue('')
#
#         elif hud.focus_name_value.text == area.get_parent().name:
#             hud.updateFocusHealthValue(area.health)
#
#     queue_free()


# func _on_Bolt_area_entered(area):
# 	# print(area.get_parent().name, "-", area.get_parent().get_parent().name)
#     pass
#
#
# func _on_Bolt_body_shape_entered(body_id, body, body_shape, area_shape):
#     # print(body_id)
#     # print(body)
#     # print(body_shape)
#     # print(area_shape)
#     pass
