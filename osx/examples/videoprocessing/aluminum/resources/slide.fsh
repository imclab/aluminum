
#version 150

uniform sampler2D curTex;
uniform sampler2D prevTex;
uniform float slideFactor;

in vec2 texCoord;
out vec4 outputFrag; 

void main(){

//next = prev + (cur - prev)*slide

  vec3 pRGB = texture(prevTex, texCoord).rgb;
  vec3 cRGB = texture(curTex, texCoord).rgb;
  vec3 nRGB = pRGB + ((cRGB - pRGB)*slideFactor);

  outputFrag = vec4(nRGB.rgb, 1.0);
}


