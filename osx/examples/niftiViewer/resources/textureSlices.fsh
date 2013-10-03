
#version 150

uniform sampler3D brain;

uniform sampler3D cluster1_time1;
uniform sampler3D cluster1_time2;
uniform sampler3D cluster1_time3;

uniform sampler3D cluster2_time1;
uniform sampler3D cluster2_time2;
uniform sampler3D cluster2_time3;

uniform sampler3D cluster3_time1;
uniform sampler3D cluster3_time2;
uniform sampler3D cluster3_time3;

uniform sampler3D cluster4_time1;
uniform sampler3D cluster4_time2;
uniform sampler3D cluster4_time3;

uniform sampler3D cluster5_time1;
uniform sampler3D cluster5_time2;
uniform sampler3D cluster5_time3;

uniform float percent; //val between 0.0 and 1.0, used to interpolate between times...
uniform float opacity;

uniform int useCluster1;
uniform int useCluster2;

in vec3 texCoord;
out vec4 outputFrag;


void lookUpVoxels(in sampler3D s1, in sampler3D s2, in sampler3D s3, in vec3 tc, out vec4 t1, out vec4 t2, out vec4 t3 ) {
  t1 = texture(s1, tc);
  t2 = texture(s2, tc);
  t3 = texture(s3, tc);
}

bool setColor(in float percent, in vec4 c1_t1, in vec4 c1_t2, in vec4 c1_t3, in vec3 cluster1_color, out vec4 clusterColor) {
  
  if (percent < 0.5) {
    float c1_o = 1.0 - (percent*2.0);
    float c2_o = percent*2.0;
    vec4 cA = vec4(cluster1_color, c1_o);
    vec4 cB = vec4(cluster1_color, c2_o);
    
    if (c1_t1.r > 0.0 && c1_t2.r > 0.0) {
      clusterColor = mix(cA, cB, c2_o);
      return true;
      
    } else if (c1_t1.r > 0.0) {
      clusterColor = cA;
      return true;
      
    } else if (c1_t2.r > 0.0) {
      clusterColor = cB;
      return true;
      
    } else {
      clusterColor = vec4(0.0);
      return false;
    }
  } else { //if (percent >= 0.5) {
    
    float c2_o = 1.0 - ((percent-0.5)*2.0);
    float c3_o = (percent-0.5)*2.0;
    
    vec4 cB = vec4(cluster1_color, c2_o);
    vec4 cC = vec4(cluster1_color, c3_o);
    
    if (c1_t2.r > 0.0 && c1_t3.r > 0.0) {
      clusterColor = mix(cB, cC, c3_o);
      return true;
    } else if (c1_t2.r > 0.0) {
      clusterColor = cB;
      return true;
    } else if (c1_t3.r > 0.0) {
      clusterColor = cC;
      return true;
    } else {
      clusterColor = vec4(0.0);
      return false;
    }
    
    
  }
}

void main() {
  
  float ooo = opacity;
  vec4 brainColor;
  vec4 clusterColor;
  vec4 clusterColorA;
  vec4 clusterColorB;
  
  
  vec3 cluster1_color = vec3(1.0,0.0,0.0);
  vec3 cluster2_color = vec3(0.0,1.0,0.0);
  
  
  if (texCoord.x <= 0.0 || texCoord.x >= 1.0) {
    brainColor = vec4(0.0, 0.0, 0.0, 0.0);
  } else if (texCoord.y <= 0.0 || texCoord.y >= 1.0) {
    brainColor = vec4(0.0, 0.0, 0.0, 0.0);
  } else if (texCoord.z <= 0.0 || texCoord.z >= 1.0) {
    brainColor = vec4(0.0, 0.0, 0.0, 0.0);
  //} else if (texCoord.z > 0.5 && texCoord.y > 0.5) { //testing cutting out a portion of the brain...
  //  brainColor = vec4(0.0, 0.0, 0.0, 0.0);
  } else {
    brainColor = texture(brain, texCoord);
  }
  
  vec4 c1_t1, c1_t2, c1_t3;
  lookUpVoxels(cluster1_time1, cluster1_time2, cluster1_time3, texCoord, c1_t1, c1_t2, c1_t3);
 
  vec4 c2_t1, c2_t2, c2_t3;
  lookUpVoxels(cluster2_time1, cluster2_time2, cluster2_time3, texCoord, c2_t1, c2_t2, c2_t3);
  
  vec4 c3_t1, c3_t2, c3_t3;
  lookUpVoxels(cluster3_time1, cluster3_time2, cluster3_time3, texCoord, c3_t1, c3_t2, c3_t3);
  
  vec4 c4_t1, c4_t2, c4_t3;
  lookUpVoxels(cluster4_time1, cluster4_time2, cluster4_time3, texCoord, c4_t1, c4_t2, c4_t3);
  
  vec4 c5_t1, c5_t2, c5_t3;
  lookUpVoxels(cluster5_time1, cluster5_time2, cluster5_time3, texCoord, c5_t1, c5_t2, c5_t3);
 
//  float c1_o = 0.0;
//  float c2_o = 0.0;
//  float c3_o = 0.0;
//  
  
  bool useCluster = false;
 /*
  if (useCluster1 == 1) {
  if (    setColor(percent, c2_t1, c2_t2, c2_t3, cluster2_color, clusterColorB)) {
    clusterColor = clusterColorB;
    useCluster = true;
  }
  } else if (useCluster2 == 1) {
  if (setColor(percent, c1_t1, c1_t2, c1_t3, cluster1_color, clusterColorA)) {
    clusterColor = clusterColorA;
    useCluster = true;
  }
  }
  */
 
  if (useCluster1 == 1 && useCluster2 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, cluster1_color, clusterColorA) ||
        setColor(percent, c2_t1, c2_t2, c2_t3, cluster2_color, clusterColorB) ) {
      
      clusterColor = clusterColorA + clusterColorB;
      
      //clusterColor = mix(clusterColorA, clusterColorB, 0.5);
      useCluster = true;
    }
  } else if (useCluster1 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, cluster1_color, clusterColorA)) {
      clusterColor = clusterColorA;
      useCluster = true;
    }
  } else if (useCluster2 == 1) {
    if (    setColor(percent, c2_t1, c2_t2, c2_t3, cluster2_color, clusterColorB)) {
      clusterColor = clusterColorB;
      useCluster = true;
    }
  }
  
  
  
  if (brainColor.r < 0.09) {
    discard;
    //outputFrag = vec4(brainColor.rrr, 0.0);
    
  } else {
    if (useCluster) {
      outputFrag = clusterColor;
      // outputFrag = mix(vec4(brainColor.rrr, opacity), clusterColor, 0.8);
    } else {
      outputFrag = vec4(brainColor.rrr, opacity);
      //outputFrag = vec4(brainColor.rrr, 0.0);
      //discard;
    }
  }
  
  
}


