
#version 150

uniform sampler2D tex0;
uniform float xNumPixels;
uniform float yNumPixels;

in vec2 texCoord;
out vec4 outputFrag; 


void main() {

  vec2 uv = texCoord.xy;

  float dx = 1.0/xNumPixels;
  float dy = 1.0/yNumPixels;

  outputFrag = texture(tex0, uv - mod(uv, vec2(dx,dy)));

}

