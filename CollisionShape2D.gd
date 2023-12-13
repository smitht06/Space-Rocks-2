extends CollisionShape2D
var screensize = Vector2.ZERO
var size
var radius
var scale_factor = .2

func start(_position, _velocity, _size):
	position = _position
	size = _size
	mass = 1.5 * size
	$Sprite2d.scale = Vector2.ONE * scale_factor * size
	radius = int($Sprite2d.texture.get_size().x/2 * $Sprite2d.scale.x)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2d.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI,PI)

func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
