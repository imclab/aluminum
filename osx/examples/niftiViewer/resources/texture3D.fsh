
#version 150

uniform sampler3D tex0;

in vec3 texCoord;
out vec4 outputFrag; 

void main(){

 vec4 outColor;

if (texCoord.x < 0.0 || texCoord.x > 1.0) {
 outputFrag = vec4(0.0,0.0,0.0,1.0);
} else if (texCoord.y < 0.0 || texCoord.y > 1.0) {
 outputFrag = vec4(0.0,0.0,0.0,1.0);
} else if (texCoord.z < 0.0 || texCoord.z > 1.0) {
 outputFrag = vec4(0.0,0.0,0.0,1.0);
}
else {
 outColor = texture(tex0, texCoord);

 outputFrag = vec4(outColor.rrr, 1.0);

}


// outputFrag = vec4(texCoord.xyz, 1.0);

}


