extends Node2D

@export_range(1, 100) var step_size = 50;
@export_range(10, 1000) var grid_size = 30;
@export var regenerate = true : set = regenerate_field

var rd: RenderingDevice
var shader: RID
var points = []
var lines = []


# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: Test code
	self.get_child(4).set_process(false)
	# self.get_child(2).set_process(false)
	# self.get_child(2).remove_from_group("bodies")
	# self.get_child(1).set_process(false)
	# self.get_child(1).remove_from_group("bodies")
	rd = RenderingServer.create_local_rendering_device()
	var shader_file := load("res://gravity_field.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	
	
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
			
	# calculate_field_gpu()
	# calculate_field()
	pass # Replace with function body.

func calculate_field_gpu():
	var input_bytes := PackedVector2Array(self.points).to_byte_array()
	var buffer := rd.storage_buffer_create(input_bytes.size(), input_bytes)
	var field_points := RDUniform.new()
	field_points.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	field_points.binding = 0 # this needs to match the "binding" in our shader file
	field_points.add_id(buffer)
	
	
	var bodies = get_tree().get_nodes_in_group("bodies")
	var body_pos_bytes := PackedVector2Array(bodies.map(func(x): return x.position)).to_byte_array()
	var body_pos_bytes_buffer := rd.storage_buffer_create(body_pos_bytes.size(), body_pos_bytes)
	var body_pos := RDUniform.new()
	body_pos.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	body_pos.binding = 1
	body_pos.add_id(body_pos_bytes_buffer)
	var body_mass_bytes := PackedFloat32Array(bodies.map(func(x): return x.mass)).to_byte_array()
	var body_mass_bytes_buffer := rd.storage_buffer_create(body_mass_bytes.size(), body_mass_bytes)
	var body_mass := RDUniform.new()
	body_mass.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	body_mass.binding = 2
	body_mass.add_id(body_mass_bytes_buffer)
	
	var step_size_uniform := RDUniform.new()
	var step_size_bytes = PackedInt32Array([step_size]).to_byte_array()
	step_size_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	step_size_uniform.binding = 3
	step_size_uniform.add_id(rd.storage_buffer_create(step_size_bytes.size(), step_size_bytes ))
	
	var grid_size_uniform := RDUniform.new()
	var grid_size_bytes = PackedInt32Array([grid_size]).to_byte_array()
	grid_size_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	grid_size_uniform.binding = 4
	grid_size_uniform.add_id(rd.storage_buffer_create(grid_size_bytes.size(), grid_size_bytes ))
	
	var uniform_set := rd.uniform_set_create([field_points, body_pos, body_mass, step_size_uniform, grid_size_uniform], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 1, 1, 1)
	rd.compute_list_end()
	rd.submit()
	rd.sync()
	
	# TODO: Can we get Vector2 array directly ?
	# TODO: Precision issues ? 
	var arr =  rd.buffer_get_data(buffer).to_float32_array()
	# var i = 0
	for i in range(self.points.size()):
		self.points[i] = Vector2(arr[2*i], arr[(2*i)+1])

	# for j in range(0, self.grid_size):
	#	for i in range(0 ,self.grid_size):
	#		self.points[(j*grid_size) + i] = Vector2(arr[2*((j*grid_size) +i)], arr[1+(2*((j*grid_size) +i))] )
	# print(arr.slice(0, 8))
	# print(arr.size())


func calculate_field():
	var bodies = get_tree().get_nodes_in_group("bodies")
	
	for j in range(0, self.grid_size):
		for i in range(0 ,self.grid_size):
			self.points[(j*grid_size) + i] = Vector2(0,0)
			var pos = Vector2(i * self.step_size, j* self.step_size)
			for body in bodies:
				var v =pos - body.position
				var f = body.mass / (v.length_squared())
				self.points[(j*grid_size) + i] += f * v.normalized()
	# print(self.points.slice(0, 4))
	# print(self.points.size())


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
	self.calculate_field_gpu()
	# self.calculate_field()
	self.draw_field()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.regenerate_field(true)
	pass
