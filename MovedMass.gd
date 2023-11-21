extends RigidBody2D

@export_range(4,400) var radius = 10
@export var colour: Color = Color.ORANGE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var grid_step_size = self.get_parent().step_size
	var grid_size = self.get_parent().grid_size
	
	var index = ((self.position.y / grid_step_size) * grid_size) + (self.position.x / grid_step_size)
	# print(index)
	# print(self.get_parent().points[int(index)] * self.mass)
	var force = -1.0*self.get_parent().points[int(index)] * self.mass
	# print(force)
	self.apply_impulse(force)
	pass
