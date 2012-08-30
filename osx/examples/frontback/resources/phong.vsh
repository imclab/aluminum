#version 150 
uniform mat4 proj, view, model;
uniform vec3 lightPosition;

in vec4 vertexPosition, vertexNormal; 
out vec3 N, L, P;

void main() {  
  vec4 position = view * model * vertexPosition;
  
  P = position.xyz;
  N = normalize(vec3(mat3(view) * mat3(model) * vertexNormal.xyz)); 
  L = normalize(vec3(view * vec4(lightPosition.xyz, 1.0)) - P); 

  gl_Position = proj * position; 
} 


