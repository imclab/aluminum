
#version 150

uniform sampler3D tex0;
uniform float opacity;

in vec3 texCoord;
out vec4 outputFrag; 

void main(){

 vec4 outColor;


if (texCoord.x <= 0.0 || texCoord.x >= 1.0) {
 outputFrag = vec4(0.0,0.0,0.0,0.0);
} else if (texCoord.y <= 0.0 || texCoord.y >= 1.0) {
 outputFrag = vec4(0.0,0.0,0.0,0.0);
} else if (texCoord.z <= 0.0 || texCoord.z >= 1.0) {
 outputFrag = vec4(0.0,0.0,0.0,0.0);
}

else {


 outColor = texture(tex0, texCoord);


 if (outColor.r < 0.1) {
 outputFrag = vec4(outColor.rrr, 0.0);

} else {
 outputFrag = vec4(outColor.rrr, opacity);
}
}



}


