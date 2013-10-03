#version 150

out vec4 outputFrag; 
in vec4 color;

void main() {
  //  vec4 ccc = color.rgba;
  outputFrag = color;
}
