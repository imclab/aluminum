precision mediump float;
uniform sampler2D tex0;
varying vec2 texCoord;
varying lowp vec4 color;

void main() {
    vec4 outColor; // = color;
      outColor = vec4(texture2D(tex0, texCoord.st).xyz, 1.0);
    //outColor.xyz = outColor.xyz*color.x*2.0;
  gl_FragColor = outColor;
    
}
