
#version 150

uniform sampler2D tex0;

in vec2 texCoord;
out vec4 outputFrag; 

void main(){

  vec4 outColor;

  // //debugs...
  //outColor = vec4(texCoord.st, 0.0, 1.0);
  //outColor = vec4(texture(tex0, texCoord.st).xyz, 1.0);
  // //end debugs

  
  outColor = texture(tex0, texCoord);

  //outputFrag = outColor;
  outputFrag = vec4(outColor.rrrr);
  
}


