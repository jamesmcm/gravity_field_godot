extends Line2D
@export_range(0, 1.0) var e = 0.8
@export_range(1, 1000) var a = 500.0
@export_range(10,1000) var steps = 600
@export_range(0,2*PI) var angle_offset = 0.0
@export var regenerate = true : set = regenerate_ellipse
# Called when the node enters the scene tree for the first time.
func _ready():
	self.e = self.get_parent().e
	self.a = self.get_parent().a
	self.steps = self.get_parent().steps
	self.angle_offset = self.get_parent().angle_offset
	self.position = self.get_parent().orbit_source.position
	self.set_ellipse_points()

func r_from_theta(theta: float) -> float:
	return (self.a*(1.0-(self.e*self.e)))/(1.0 + (self.e*cos(theta)))

func cartesian_from_polar(r: float, theta: float, angle_offset_input: float) -> Vector2:
	var mtheta = theta + angle_offset_input
	return Vector2(r*cos(mtheta), r*sin(mtheta))

func set_ellipse_points():
	var points = PackedVector2Array()
	var theta = 0

	while theta <= 2*PI:
		var mtheta = theta + self.angle_offset
		var r = (a*(1.0-(e*e)))/(1.0 + (e*cos(theta)))
		points.append(Vector2(r*cos(mtheta), r*sin(mtheta)) )
		theta += (2.0*PI) / float(steps)
	self.points = points

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position = self.get_parent().orbit_source.position
	# self.set_ellipse_points()
	pass



func regenerate_ellipse(v):
	self.set_ellipse_points()
