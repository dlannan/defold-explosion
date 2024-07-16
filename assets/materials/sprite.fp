varying highp vec4 var_position;
varying highp vec4 var_world_position;
varying mediump vec3 var_normal;
varying mediump vec2 var_texcoord0;
varying mediump vec4 var_light;

uniform lowp sampler2D tex0;
uniform lowp vec4 tint;

// assign colour to the media
vec3 computeColour( float density, float radius )
{
    // these are almost identical to the values used by iq

    // colour based on density alone. gives impression of occlusion within
    // the media
    vec3 result = mix( 1.1*vec3(1.0,0.9,0.8), vec3(0.4,0.15,0.1), density );

    // colour added for explosion
    vec3 colBottom = 3.1*vec3(1.0,0.5,0.05);
    vec3 colTop = 2.*vec3(0.48,0.53,0.5);
    result *= mix( colBottom, colTop, min( (radius+.5)/1.7, 1.0 ) );

    return result;
}

void main()
{
    // Pre-multiply alpha since all runtime textures already are
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 color = texture2D(tex0, var_texcoord0.xy);

    // Diffuse light calculations
    vec3 ambient_light = vec3(0.2);
    vec3 diff_light = vec3(normalize(var_light.xyz - var_position.xyz));
    diff_light = max(dot(var_normal,diff_light), 0.0) + ambient_light;
    diff_light = clamp(diff_light, 0.0, 1.0);

    float d = length(var_world_position) * 0.006;
    diff_light = computeColour( clamp(d, 0, 1), clamp(d, 0, 1) );
    
    gl_FragColor = vec4(color.xyz * diff_light, color.a);
}

