
#version 150

out vec4 outputFrag; 
in vec4 color;

uniform vec3 hi;
 
void main(){ 

  outputFrag = vec4(color.xyz,1.0); 

}
