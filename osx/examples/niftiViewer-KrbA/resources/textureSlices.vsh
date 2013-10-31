#version 150

uniform mat4 proj;
uniform mat4 view;
uniform mat4 textureRotation;

in vec4 vertexPosition;
in vec4 vertexTexCoord;

out vec3 texCoord;

void main() {
    texCoord = (textureRotation * vertexTexCoord).xyz;
    gl_Position = proj * view * vertexPosition;

}

