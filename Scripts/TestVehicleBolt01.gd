
extends Area

onready var controls = get_node('/root/Controls')

onready var gameplay = get_node('/root/Gameplay')

# Get control variable tag.
onready var body_tag = controls.gameplay['vehicle']['body']
onready var blaster_tag = controls.gameplay['vehicle']['blaster']

# Get bolt model tag and scene.
onready var bolt_model_tag = controls.blasters[blaster_tag]['bolt_model']
onready var scene_str = 'res://Scenes/Models/Projectiles/%s.tscn' % bolt_model_tag
onready var bolt_model = load(scene_str)

# Get bolt's control variables.
onready var ENERGY = controls.blasters[blaster_tag]['energy']
onready var SPEED = controls.blasters[blaster_tag]['bolt_speed']

# Get global controls.
onready var LIFE_TIME = controls.global['bolt']['life_time']

onready var timer = $Timer

var vel = Vector3()

onready var hud = get_node('/root/Gameplay/Vehicles/%s/Hud' % body_tag)

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

	if body.get_parent().name == 'Targets':  gameplay.vehicleBoltHitsTargetBody(self, body)

	queue_free()
