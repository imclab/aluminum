#version 150 

in vec4 vertexPosition; 
in vec4 vertexTexCoord;

out vec2 texCoord;

void main() {  
  texCoord = vertexTexCoord.xy;
  gl_Position = vertexPosition; 
} 

