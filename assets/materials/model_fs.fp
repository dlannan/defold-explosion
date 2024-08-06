varying highp vec4 var_position;
varying mediump vec3 var_normal;
varying mediump vec2 var_texcoord0;

uniform highp sampler2D iChannel0;
uniform highp vec4 iResolution;

float particle(vec2 uv, vec2 p, float sz) {
    vec2 j = (p - uv) * sz;
    float sparkle = 1.0/dot(j, j);
    return sparkle;
}

void main()
{
    // get aspect corrected normalized pixel coordinate
    vec2 uv = var_texcoord0.xy;

    vec3 col = vec3(0.0f);
    int nparticles = int(iResolution.x) * int(iResolution.y);
    for(int i =0; i< nparticles; i+=2)
    {
        float xpos = mod(float(i), iResolution.x) / iResolution.x;
        float ypos = (float(i) / iResolution.x) / iResolution.y;
        vec2 tuv = vec2(xpos, ypos);
        vec4 pos = texture2D(iChannel0, tuv);
        col += vec3( particle(uv, vec2(pos.x + 0.5f, pos.y + 0.5f), 1000.0f) );
    }
    
    // smoothstep final color to add contrast
    gl_FragColor.xyz = col;
    gl_FragColor.w = 1.0f;
}
