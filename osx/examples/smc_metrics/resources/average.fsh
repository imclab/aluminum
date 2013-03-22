
#version 150

uniform sampler2D curTex;
uniform sampler2D prevTex;
uniform int frameNum;

in vec2 texCoord;
out vec4 outputFrag; 

void main(){

// Average in place
// if (frameNum == 0) {
//    avg = curr;
// } else {
//   avg = (prev * (frame-1) + curr) / frame;
// }

  vec3 cRGB = texture(curTex, texCoord).rgb;

  if (frameNum == 0) {
    outputFrag = vec4(cRGB.rgb, 1.0);
  } else { 
    vec3 pRGB = texture(prevTex, texCoord).rgb;
    vec3 nRGB = ((pRGB * (frameNum-1)) + cRGB) / frameNum;
    outputFrag = vec4(nRGB.rgb, 1.0);
  }
}


