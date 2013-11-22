#version 150

in vec3 texCoord;  // 3D texture coordinates from the vertex shader
out vec4 outputFrag;  // This is the fragment shader output


void main() {
  outputFrag = vec4(texCoord.r,0.0,0.0,1.0);
}
