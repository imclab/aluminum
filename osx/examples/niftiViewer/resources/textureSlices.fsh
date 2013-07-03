
#version 150

uniform sampler3D brain;
uniform sampler3D time1;
uniform sampler3D time2;
uniform sampler3D time3;
uniform float opacity;

in vec3 texCoord;
out vec4 outputFrag;

void main(){

vec4 outColor;
vec4 c1_t1;
vec4 c1_t2;
vec4 c1_t3;

float c1 = 0.0;
float c2 = 0.0;
float c3 = 0.0;


if (texCoord.x <= 0.0 || texCoord.x >= 1.0) {
    outputFrag = vec4(0.0,0.0,0.0,0.0);
} else if (texCoord.y <= 0.0 || texCoord.y >= 1.0) {
    outputFrag = vec4(0.0,0.0,0.0,0.0);
} else if (texCoord.z <= 0.0 || texCoord.z >= 1.0) {
    outputFrag = vec4(0.0,0.0,0.0,0.0);
}

else {

    outColor = texture(brain, texCoord);
 
    c1_t1 = texture(time1, texCoord);
    c1_t2 = texture(time2, texCoord);
    c1_t3 = texture(time3, texCoord);

    if (c1_t1.r > 0.1) {
        c2 = c1_t1.r;
    } 

    if (c1_t2.r > 0.1) {
        c1 = c1_t2.r;
    }

    if (c1_t3.r > 0.1) {
        c3 = c1_t3.r;
    }

    if (c1 > 0.0 || c2 > 0.0 || c3 > 0.0) {
            outputFrag = vec4(c1, c2, c3, 0.4);


    } else {
          if (outColor.r < 0.09) {
            outputFrag = vec4(outColor.rrr, 0.0);

        } else {
            outputFrag = vec4(outColor.rrr, opacity);
        }
    }

}



}


