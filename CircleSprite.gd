extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	var parent = self.get_parent()
	# Position relative to parent
	draw_circle(Vector2(0,0), parent.radius, parent.colour)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
