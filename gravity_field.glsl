#[compute]
#version 450

// Invocations in the (x, y, z) dimension

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer FieldBuffer {
    vec2 data[];
}
field_buffer;

layout(set = 0, binding = 1, std430) restrict buffer BodyPositionBuffer {
    vec2 data[];
}
body_position_buffer;

layout(set = 0, binding = 2, std430) restrict buffer BodyMassBuffer {
    float data[];
}
body_mass_buffer;

layout(set = 0, binding = 3, std430) restrict buffer StepSize {
    uint data;
}
step_size;
layout(set = 0, binding = 4, std430) restrict buffer GridSize {
    uint data;
}
grid_size; // 30

layout(local_size_x = 30, local_size_y = 30, local_size_z = 1) in;

// The code we want to execute in each invocation
void main() {
    field_buffer.data[(gl_GlobalInvocationID.y * grid_size.data) + gl_GlobalInvocationID.x] = vec2(0.0);
   for(int i=0;i<int(body_position_buffer.data.length());i++)
  {
    vec2 pos = vec2(float(gl_GlobalInvocationID.x * step_size.data), float(gl_GlobalInvocationID.y * step_size.data));
    pos = pos - body_position_buffer.data[i];
    float f = body_mass_buffer.data[i] / dot(pos, pos);
    field_buffer.data[(gl_GlobalInvocationID.y * grid_size.data) + gl_GlobalInvocationID.x] += f * normalize(pos);
  }	
}
            