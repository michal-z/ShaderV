
void main()
{
    float t = gl_TexCoord[0].s*.001;

    //vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / vec2(1920, 1080);
    vec2 p = gl_FragCoord.xy / vec2(1280, 720);
    //p.x *= 1.77;

    gl_FragColor = vec4(p, 0.25, 1.0);
}
