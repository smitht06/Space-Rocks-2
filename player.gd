extends RigidBody2D
var screensize = Vector2.ZERO
@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene : PackedScene
@export var fire_rate = .25

var can_shoot = true 
enum {INIT, ALIVE, INVULNERABLE, DEAD}

var state = INIT
var thrust = Vector2.ZERO
var rotation_dir = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	screensize = get_viewport_rect().size
	change_state(ALIVE)
	$GunCooldown.wait_time = fire_rate

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
	state = new_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	
func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	
func shoot():
	if state == INVULNERABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)
	
func _physics_process(delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform

func _on_gun_cooldown_timeout():
	can_shoot = true
	# Replace with function body.
