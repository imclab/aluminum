#version 150

//uniform mat4 proj;
//uniform mat4 view;
//uniform mat4 model;

in vec4 vertexPosition; 

void main() {  
  //gl_Position = proj * view * model * vertexPosition; 
  gl_Position = vertexPosition; 
} 

