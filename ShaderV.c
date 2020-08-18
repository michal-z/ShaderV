void main() {
    //float time = gl_TexCoord[0].s * 0.001;
    vec2 st = gl_FragCoord.xy / vec2(1280, 720);
    gl_FragColor = vec4(st, 0.0, 1.0);
}
