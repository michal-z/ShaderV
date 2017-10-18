float Plot(vec2 st, float pct)
{
    return smoothstep(pct - 0.02, pct, st.y) - smoothstep(pct, pct + 0.02, st.y);
}

void main()
{
    float time = gl_TexCoord[0].s * 0.001;

    vec2 st = -1.0 + 2.0 * (gl_FragCoord.xy / vec2(1280, 720));

    float y = cos(sin(4.0 * st.x + time)) - 0.5;

    float pct = Plot(st, y);

    vec3 colorA = vec3(0.149, 0.141, 0.912);
    vec3 colorB = vec3(1.000, 0.833, 0.224);

    vec3 color = pct * mix(colorA, colorB, y);

    gl_FragColor = vec4(color, 1.0);
}
