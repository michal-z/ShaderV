
void main()
{
  float t = gl_TexCoord[0].s * 0.001;

  vec2 p = -1.0 + 2.0 * (gl_FragCoord.xy / vec2(1280, 720));
  p.x *= 1.777;

  float c = 1.0;
  if (length(p) < 0.8)
  {
    c = 0.25f + sin(t * 0.75);
  }

  gl_FragColor = c * vec4(p, 0.15, 1.0);
}
