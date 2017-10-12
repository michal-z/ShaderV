#define PI 3.1415926

float Plot(vec2 st, float pct)
{
    return smoothstep(pct - 0.02, pct, st.y) - smoothstep(pct, pct + 0.02, st.y);
}

void main()
{
    float time = gl_TexCoord[0].s * 0.001;

    vec2 st = -1.0 + 2.0 * (gl_FragCoord.xy / vec2(1280, 720));

    float y = 1.0 - pow(max(0.0, abs(st.x) * 2.0 - 1.0), 3.5);

    vec3 color = vec3(y);

    float pct = Plot(st, y);
    color = pct * vec3(0.0, 1.0, 0.0);

    gl_FragColor = vec4(color, 1.0);
}
