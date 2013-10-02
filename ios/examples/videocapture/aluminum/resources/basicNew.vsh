uniform mat4 proj;
uniform mat4 mv;
uniform vec2 MouseCords;

attribute vec4 vertexPosition;
attribute vec3 vertexTexCoord;
varying vec2 texCoord;
//attribute vec4 vertexColor;
varying vec4 color;

void main() {
    float sigma = 0.1;
    texCoord = vertexTexCoord.xy;
    vec4 newPos = vertexPosition;
 
    newPos.z = exp(-0.5*(((newPos.x-MouseCords.x)/sigma)*((newPos.x-MouseCords.x)/sigma) +
                         ((newPos.y+MouseCords.y)/sigma)*((newPos.y+MouseCords.y)/sigma)));
    color = vec4(newPos.z , 0.0,0.0,1.0);
    
  gl_Position = proj * mv * newPos; 
} 

