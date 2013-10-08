

#version 150 

in vec4 vertexPosition; 
in vec4 vertexTexCoord;

out vec2 v_texCoord;

void main() {  
  v_texCoord = vec2(vertexTexCoord.x, vertexTexCoord.y);
  gl_Position = vertexPosition;
}



