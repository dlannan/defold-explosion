varying highp vec4 var_position;
varying highp vec4 var_world_position;
varying mediump vec3 var_normal;
varying mediump vec2 var_texcoord0;
varying mediump vec4 var_light;

uniform lowp sampler2D tex0;
uniform lowp vec4 tint;

vec3 distancefog( vec3 col, float pos )
{
    float len = pos / 700;
    const vec3 endColor = vec3(0.8359, 0.88235, 0.89019);
    return mix( col, endColor, len );
}

void main()
{
    // Pre-multiply alpha since all runtime textures already are
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 color = texture2D(tex0, var_texcoord0.xy) * tint_pm;

    // Diffuse light calculations
    vec3 ambient_light = vec3(0.2);
    vec3 diff_light = vec3(normalize(var_light.xyz - var_position.xyz));
    diff_light = max(dot(var_normal,diff_light), 0.0) + ambient_light;
    diff_light = clamp(diff_light, 0.0, 1.0);

    color.rgb = distancefog( color.rgb, abs(var_position.z));
    gl_FragColor = vec4(color.rgb,1.0);
}

