extends CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.shape = CircleShape2D.new()
	self.shape.radius = self.get_parent().radius
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
