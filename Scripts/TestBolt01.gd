
extends Area

onready var controls = get_node('/root/Controls')

# Get control variable tag.
onready var blaster_tag = controls.gameplay['vehicle']['blaster']

# Get bolt model tag and scene.
onready var bolt_model_tag = controls.blasters[blaster_tag]['bolt_model']
onready var scene_str = 'res://Scenes/Models/VehicleParts/Projectiles/' + bolt_model_tag + '.tscn'
onready var bolt_model = load(scene_str)

# Get bolt's control variables.
onready var ENERGY = controls.blasters[blaster_tag]['energy']
onready var SPEED = controls.blasters[blaster_tag]['speed']

# Get system controls.
onready var LIFE_TIME = controls.default['bolt']['life_time']

onready var timer = $Timer

var vel = Vector3()

onready var hud = get_node('/root/Gameplay/Vehicle/Hud')

func _ready():

    add_child(bolt_model.instance())

    timer.wait_time = LIFE_TIME
    timer.start()

func _process(delta):

    transform.origin += vel * delta

func _on_Timer_timeout():

    queue_free()

func spawn(_spawn_transform):

    transform = _spawn_transform
    vel = -transform.basis.z * SPEED

func _on_Bolt_body_entered(body):

    queue_free()

func _on_Bolt_area_entered(area):

    if area.get_parent().get_parent().name == 'Targets':
        area.health -= ENERGY

        if area.health <= 0:
            area.get_parent().queue_free()
            hud.updateFocusNameValue('')
            hud.updateFocusHealthValue('')

        elif hud.focus_name_value.text == area.get_parent().name:
            hud.updateFocusHealthValue(area.health)

    queue_free()
