
#version 150

uniform sampler3D brain;
uniform sampler3D time1;
uniform sampler3D time2;
uniform sampler3D time3;

uniform float percent; //val between 0.0 and 1.0, used to interpolate between times...

uniform float opacity;

in vec3 texCoord;
out vec4 outputFrag;

void main() {
    
    vec4 brainColor;
    vec4 clusterColor;
    
    vec4 c1_t1;
    vec4 c1_t2;
    vec4 c1_t3;
    
    float c1 = 0.0;
    float c2 = 0.0;
    float c3 = 0.0;
    
    if (texCoord.x <= 0.0 || texCoord.x >= 1.0) {
        brainColor = vec4(0.0, 0.0, 0.0, 0.0);
    } else if (texCoord.y <= 0.0 || texCoord.y >= 1.0) {
        brainColor = vec4(0.0, 0.0, 0.0, 0.0);
    } else if (texCoord.z <= 0.0 || texCoord.z >= 1.0) {
        brainColor = vec4(0.0, 0.0, 0.0, 0.0);
    } else if (texCoord.z > 0.5 && texCoord.y > 0.5) { //testing cutting out a portion of the brain...
        brainColor = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        brainColor = texture(brain, texCoord);
    }
    
    c1_t1 = texture(time1, texCoord);
    c1_t2 = texture(time2, texCoord);
    c1_t3 = texture(time3, texCoord);
    
    
    float c1_o = 0.0;
    float c2_o = 0.0;
    float c3_o = 0.0;
    
    if (c1_t1.r > 0.1) {
        c1 = 1.0; //c1_t1.r;
    }
    
    if (c1_t2.r > 0.1) {
        c2 = 1.0; //c1_t2.r;
    }
    
    if (c1_t3.r > 0.1) {
        c3 = 1.0; //c1_t3.r;
    }
    
    float minVal = 0.15;
    
    bool useCluster = true;
    
        if (percent < 0.5) {
            
            c1_o = 1.0 - (percent*2.0);
            c2_o = percent*2.0;
            vec4 cA = vec4(c1,0.0,0.0, 1.0);
            vec4 cB = vec4(c2,0.0,0.0, 1.0);
            
            vec4 ccc = mix(cA, cB, c2_o);
            clusterColor = ccc;
            
            
        } else if (percent >= 0.5) {
            
            c2_o = 1.0 - ((percent-0.5)*2.0);
            c3_o = (percent-0.5)*2.0;
           
            vec4 cB = vec4(c2,0.0,0.0, 1.0);
            vec4 cC = vec4(c3,0.0,0.0, 1.0);
      
            vec4 ccc = mix(cB, cC, c3_o);
            clusterColor = ccc;
        } else {
            useCluster = true;
        }
        
    
    
    
    
        if (brainColor.r < 0.09) {
            outputFrag = vec4(brainColor.rrr, 0.0);
            
        } else {
            if (useCluster) {
                outputFrag = mix(vec4(brainColor.rrr, opacity), clusterColor, opacity);
            } else {
                outputFrag = vec4(brainColor.rrr, opacity);
            }
        }
    
    
}


