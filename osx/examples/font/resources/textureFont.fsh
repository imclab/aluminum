
#version 150

uniform vec4 textColor;
uniform sampler2D tex0;

in vec2 texCoord;
out vec4 outputFrag; 

void main(){
  //for one channel
  float a = ( texture(tex0, texCoord).r);
  vec4 outColor = vec4(a,a,a,a);
  
  //for four channel
  //vec4 outColor = texture(tex0, texCoord).rgbr;
  //float a = ( texture(tex0, texCoord).a);
  //vec4 outColor = vec4(a,a,a,a);
   

  outColor *= textColor;
  outputFrag = vec4(outColor); 

}
