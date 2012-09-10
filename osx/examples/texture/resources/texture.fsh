
#version 150

uniform sampler2D tex0;
in vec2 texCoord;
out vec4 outputFrag; 

void main(){

  vec3 outColor;
  
  // //debugs...
  //outColor = vec3(texCoord.st, 0.0);
  //outColor = vec3(1.0, 0.0, 0.0);
  // //end debugs

  outColor = vec3(texture(tex0, texCoord.st).xyz);

  outputFrag = vec4(outColor, 1.0); 

}
