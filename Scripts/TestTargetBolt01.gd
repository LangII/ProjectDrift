
extends Area

onready var controls = get_node('/root/Controls')

onready var gameplay = get_node('/root/Main/Gameplay')

onready var body_tag = controls.gameplay['vehicle']['body']

# Get control variable tag.
onready var target_tag = controls.gameplay['targets']

# Get bolt model tag and scene.
onready var bolt_model_tag = controls.targets[target_tag]['bolt_model']
onready var scene_str = 'res://Scenes/Models/Projectiles/' + bolt_model_tag + '.tscn'
onready var bolt_model = load(scene_str)

# Get bolt's control variables.
onready var ENERGY = controls.targets[target_tag]['bolt_energy']
onready var SPEED = controls.targets[target_tag]['bolt_speed']

# Get system controls.
onready var LIFE_TIME = controls.global['bolt']['life_time']

onready var timer = $Timer

var vel = Vector3()

#onready var hud = get_node('/root/Gameplay/Vehicles/%s/NonSpatial/Hud' % body_tag)

onready var temp_bug_fix = $TempBugFix

func _ready():

    add_child(bolt_model.instance())

    timer.wait_time = LIFE_TIME
    timer.start()

func _process(delta):

    transform.origin += vel * delta

    if temp_bug_fix.is_colliding():
        if temp_bug_fix.get_collider().get_parent().name == 'Ramps':  queue_free()

func _on_Timer_timeout():

    queue_free()

func spawn(_spawn_transform):

    transform = _spawn_transform
    vel = -transform.basis.z * SPEED

func _on_Bolt_body_entered(body):

    if body.name == body_tag:  gameplay.targetBoltHitsVehicleBody(self, body)

    queue_free()
