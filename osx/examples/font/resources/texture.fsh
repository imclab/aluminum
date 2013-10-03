
#version 150

uniform sampler2D tex0;
in vec2 texCoord;
out vec4 outputFrag; 

void main(){
  outputFrag = texture(tex0, texCoord);
}
