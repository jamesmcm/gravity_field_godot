extends Area2D

@export_range(4,400) var radius = 10
@export var colour: Color = Color.BLUE
@export_range(1,2000000) var mass = 1000
@export var orbit_source: Node2D
@export_range(0, 1.0) var e = 0.9
@export_range(1, 1000) var a = 400.0
@export_range(10,1000) var steps = 600
@export_range(1,1000) var velocity = 600
@export_range(0,2*PI) var angle_offset = 0.0

var theta = 0
var i = 0
var orbit_ellipse = null

# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# TODO: smooth animation
	# print(self.position)
	var dtheta = (2.0 * velocity) / self.position.distance_squared_to(self.orbit_source.position)
	self.theta += dtheta
	
	if self.theta > (2.0*PI):
		self.theta = self.theta - (2.0 * PI)
	
	var r = self.get_child(0).r_from_theta(theta)
	var p = self.get_child(0).cartesian_from_polar(r, theta, self.angle_offset)
	self.position = p + self.orbit_source.position
	# i += 1
	# if i >= steps:
	#	i = 0
	pass
