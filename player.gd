extends RigidBody2D

signal lives_changed
signal dead
signal shield_changed

@export var max_shield = 100.0
@export var sheld_regen = 5.0
@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene : PackedScene
@export var fire_rate = .25


var shield = 0 : set = set_shield
var can_shoot = true 
var state = INIT
var thrust = Vector2.ZERO
var rotation_dir = 0
var screensize = Vector2.ZERO
var reset_pos = false
var lives = 0: set =  set_lives
var playing = true 

enum {INIT, ALIVE, INVULNERABLE, DEAD}


func set_shield(value):
	value = min(value, max_shield)
	shield = value
	shield_changed.emit(shield/max_shield)
	if shield < 0:
		lives -= 1
		explode()


func set_lives(value):
	lives = value
	lives_changed.emit(lives)
	shield = max_shield
	if lives <= 0:
		change_state(DEAD)
	else:
		change_state(INVULNERABLE)


func reset():
	reset_pos = true
	lives = 3
	change_state(ALIVE)


# Called when the node enters the scene tree for the first time.
func _ready():
	screensize = get_viewport_rect().size
	change_state(ALIVE)
	$GunCooldown.wait_time = fire_rate


func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = .5
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
			$Sprite2D.modulate.a = 1.0
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = .5
			$InvulnerabilityTimer.start()
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = 0
			$EngineSound.stop()
			linear_velocity = Vector2.ZERO
			dead.emit()
	state = new_state


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	shield += sheld_regen * delta
	
	
func get_input():
	$Exhaust.emitting = false
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		$Exhaust.emitting = true
		thrust = transform.x * engine_power
		if not $EngineSound.playing:
			$EngineSound.play()
	else:
		$EngineSound.stop()
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
	$LaserSound.play()
	
	
func _physics_process(delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
	
func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform
	if reset_pos:
		physics_state.transform.origin = screensize / 2
		reset_pos = false

func _on_gun_cooldown_timeout():
	can_shoot = true


func _on_invulnerability_timer_timeout():
	change_state(ALIVE) 


func _on_body_entered(body):
	if body.is_in_group("rocks"):
		shield -= body.size * .25
		body.explode()
		lives -= 1


func explode():
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	$Explosion.hide()
