#version 450

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

// specify the input resources
uniform vec4 color;
uniform vec4 params;
layout(rgba32f) uniform image2D texture_in;

// specify the output image
layout(rgba32f) uniform image2D texture_out;

void main()
{
    ivec2 tex_coord = ivec2(gl_GlobalInvocationID.xy);
    vec4 pos_value = imageLoad(texture_in, tex_coord);
    vec4 output_value = vec4(0.0, 0.0, 0.0, 1.0);
   
    // Work out which block we are looking at (pos, or vel)
    if( tex_coord.x % 2 == 0 ) 
    {
        ivec2 tex_coord_vel = ivec2(tex_coord.x + 1, tex_coord.y);
        vec4 vel_value = imageLoad(texture_in, tex_coord_vel);        
        output_value.xyz = pos_value.xyz + vel_value.xyz;
    }
    // Velocity
    else
    {
        output_value = pos_value;
    }
    
    // Write the output value to the storage texture
    imageStore(texture_out, tex_coord, output_value);
}

