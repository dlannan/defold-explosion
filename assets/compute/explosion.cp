#version 450

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

// specify the input resources
uniform vec4 color;
uniform vec4 params;
uniform sampler2D texture_in;

// specify the output image
layout(rgba32f) uniform image2D texture_out;

void main()
{
    ivec2 tex_coord   = ivec2(gl_GlobalInvocationID.xy);
    vec2 tex_coord_uv = vec2(float(tex_coord.x)/(gl_NumWorkGroups.x), float(tex_coord.y)/(gl_NumWorkGroups.y));
    vec4 pos_value = texture(texture_in, tex_coord_uv);
    vec4 output_value = vec4(0.0, 0.0, 0.0, 1.0);

    // Work out which block we are looking at (pos, or vel)
    if(( tex_coord.x + tex_coord.y * gl_NumWorkGroups.x ) % 1 == 0) 
    {
        vec2 tex_coord_vel = vec2(float(tex_coord.x + 1)/(gl_NumWorkGroups.x), float(tex_coord.y)/(gl_NumWorkGroups.y));
        vec4 vel_value = texture(texture_in, tex_coord_vel);

        pos_value.xyz += vel_value.xyz * params.x;
        pos_value.w -= params.x;
        
        output_value = pos_value;
    }
    // Velocity
    else
    {
    }

    // Write the output value to the storage texture
    imageStore(texture_out, tex_coord, output_value);
}

