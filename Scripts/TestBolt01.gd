
extends Area

onready var controls = get_node('/root/Controls')

# Get control variable tag.
onready var blaster_tag = controls.gameplay['vehicle']['blaster']

# Get bolt model tag and scene.
onready var bolt_model_tag = controls.blasters[blaster_tag]['bolt_model']
onready var scene_str = 'res://Scenes/Models/VehicleParts/Projectiles/' + bolt_model_tag + '.tscn'
onready var bolt_model = load(scene_str)

# Get bolt's control variables.
onready var DAMAGE = controls.blasters[blaster_tag]['damage']
onready var SPEED = controls.blasters[blaster_tag]['speed']
onready var DELAY = controls.blasters[blaster_tag]['delay']

onready var timer = $Timer

var vel = Vector3()

func _ready():

    add_child(bolt_model.instance())

    timer.wait_time = DELAY
    timer.start()

func _process(delta):

    transform.origin += vel * delta

func _on_Timer_timeout():

    queue_free()

func spawn(_spawn_transform):

    transform = _spawn_transform
    vel = -transform.basis.z * SPEED
