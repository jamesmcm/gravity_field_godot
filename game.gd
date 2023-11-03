extends Node2D

@export_range(1, 100) var step_size = 50;
@export_range(10, 1000) var grid_size = 30;
@export var regenerate = true : set = regenerate_field


var points = []
var lines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for j in range(0, self.grid_size):
		for i in range(0 ,self.grid_size):
			var pos = Vector2(i * self.step_size, j* self.step_size)
			points.append(Vector2(0.0, 0.0))
			var l = Line2D.new()
			l.z_index = -1
			l.default_color = Color.MAGENTA
			l.width = 2.0
			l.add_point(pos)
			self.lines.append(l)
			self.add_child(l)
	pass # Replace with function body.


func calculate_field():
	var bodies = get_tree().get_nodes_in_group("bodies")
	
	for j in range(0, self.grid_size):
		for i in range(0 ,self.grid_size):
			self.points[(j*grid_size) + i] = Vector2(0,0)
			var pos = Vector2(i * self.step_size, j* self.step_size)
			for body in bodies:
				var v =pos - body.position
				var f = body.mass / (v.length_squared())
				self.points[(j*grid_size) + i] += -1.0 * f * v.normalized()


func draw_field():
	for j in range(0, self.grid_size):
		for i in range(0 ,self.grid_size):
			# print(self.points)
			var pos = Vector2(i * self.step_size, j* self.step_size)
			# print(pos, pos + 100.0* self.points[(j*grid_size) + i])
			self.lines[(j*grid_size) + i].clear_points()
			self.lines[(j*grid_size) + i].add_point(pos)
			self.lines[(j*grid_size) + i].add_point(pos +  self.points[(j*grid_size) + i])
			# draw_line(pos, pos + 100.0* self.points[(j*grid_size) + i], Color.WHEAT, 6.0)

func regenerate_field(v):
	if get_tree() == null:
		return
	self.calculate_field()
	self.draw_field()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.regenerate_field(true)
	pass
