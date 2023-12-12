extends CollisionShape2D
var screensize = Vector2.ZERO
var size
var radius
var scale_factor = .2

func start(_position, _velocity, _size):
	position = _position
	size = _size
	var mass = 1.5 * size
	$Sprite2D.scale = Vector2.ONE * scale_factor * size
	radius = int($Sprite2D.texture.get_size().x/2 * $Sprite2D.scale.x)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2d.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI,PI)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
