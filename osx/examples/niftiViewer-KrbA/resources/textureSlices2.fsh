#version 150

uniform sampler3D brain;

uniform sampler3D cluster1_time1;
uniform sampler3D cluster1_time2;
uniform sampler3D cluster1_time3;
uniform sampler3D cluster1_time4;

uniform sampler3D cluster2_time1;
uniform sampler3D cluster2_time2;
uniform sampler3D cluster2_time3;
uniform sampler3D cluster2_time4;

uniform sampler3D cluster3_time1;
uniform sampler3D cluster3_time2;
uniform sampler3D cluster3_time3;
uniform sampler3D cluster3_time4;

uniform sampler3D cluster4_time1;
uniform sampler3D cluster4_time2;
uniform sampler3D cluster4_time3;
//uniform sampler3D cluster4_time4;

uniform float percent; //val between 0.0 and 1.0, used to interpolate between times...
uniform float opacity;

uniform int useCluster1;
uniform int useCluster2;
uniform int useCluster3;
uniform int useCluster4;

in vec3 texCoord;
out vec4 outputFrag;


void lookUpVoxels(in sampler3D s1, in sampler3D s2, in sampler3D s3, in sampler3D s4, in vec3 tc, out vec4 t1, out vec4 t2, out vec4 t3, out vec4 t4 ) {
  t1 = texture(s1, tc);
  t2 = texture(s2, tc);
  t3 = texture(s3, tc);
  t4 = texture(s4, tc);
}


bool setColor(in float percent, in vec4 c1_t1, in vec4 c1_t2, in vec4 c1_t3, in vec4 c1_t4, in vec3 cluster1_color, out vec4 clusterColor) {

  if (percent < 0.333) {
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
  } else if (percent < 0.66) {

    float c2_o = 1.0 - ((percent-0.33)*2.0);
    float c3_o = (percent-0.33)*2.0;

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
  } else {

    float c3_i = 1.0 - ((percent-0.66)*2.0);
    float c4_o = (percent-0.66)*2.0;

    vec4 cC = vec4(cluster1_color, c3_i);
    vec4 cD = vec4(cluster1_color, c4_o);

    if (c1_t3.r > 0.0 && c1_t4.r > 0.0) {
      clusterColor = mix(cC, cD, c3_i);
      return true;
    } else if (c1_t3.r > 0.0) {
      clusterColor = cC;
      return true;
    } else if (c1_t4.r > 0.0) {
      clusterColor = cD;
      return true;
    } else {
      clusterColor = vec4(0.0);
      return false;
    }

  }
}


void main() {

  vec4 brainColor;
  vec4 clusterColor;
  vec4 clusterColorA;
  vec4 clusterColorB;
  vec4 clusterColorC;
  vec4 clusterColorD;

  vec3 cluster1_color = vec3(1.0,0.0,0.0);
  vec3 cluster2_color = vec3(0.0,1.0,0.0);
  vec3 cluster3_color = vec3(0.0,0.0,1.0);
  vec3 cluster4_color = vec3(1.0,0.5,0.0);


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

  vec4 c1_t1, c1_t2, c1_t3, c1_t4;
  vec4 c2_t1, c2_t2, c2_t3, c2_t4;
  vec4 c3_t1, c3_t2, c3_t3, c3_t4;
  vec4 c4_t1, c4_t2, c4_t3, c4_t4;

  lookUpVoxels(cluster1_time1, cluster1_time2, cluster1_time3, cluster1_time4, texCoord, c1_t1, c1_t2, c1_t3, c1_t4);
  lookUpVoxels(cluster2_time1, cluster2_time2, cluster2_time3, cluster2_time4, texCoord, c2_t1, c2_t2, c2_t3, c2_t4);
  lookUpVoxels(cluster3_time1, cluster3_time2, cluster3_time3, cluster3_time4, texCoord, c3_t1, c3_t2, c3_t3, c3_t4);
  lookUpVoxels(cluster4_time1, cluster4_time2, cluster4_time3, cluster4_time1, texCoord, c4_t1, c4_t2, c4_t3, c4_t4);

  bool useCluster = false;


  if (useCluster1 == 1 && useCluster2 == 1 && useCluster3 == 1 && useCluster4 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, c1_t4, cluster1_color, clusterColorA) ||
        setColor(percent, c2_t1, c2_t2, c2_t3, c2_t4, cluster2_color, clusterColorB) ||
        setColor(percent, c3_t1, c3_t2, c3_t3, c3_t4, cluster3_color, clusterColorC) ||
        setColor(percent, c4_t1, c4_t2, c4_t3, c4_t4, cluster4_color, clusterColorD)) {

      clusterColor = clusterColorA + clusterColorB + clusterColorC + clusterColorD;
      useCluster = true;
    }
  }
  else if (useCluster1 == 1 && useCluster2 == 1 && useCluster3 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, c1_t4, cluster1_color, clusterColorA) ||
        setColor(percent, c2_t1, c2_t2, c2_t3, c2_t4, cluster2_color, clusterColorB) ||
        setColor(percent, c3_t1, c3_t2, c3_t3, c3_t4, cluster3_color, clusterColorC)) {

      clusterColor = clusterColorA + clusterColorB + clusterColorC;
      useCluster = true;
    }
  } else if (useCluster1 == 1 && useCluster2 == 1 && useCluster4 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, c1_t4, cluster1_color, clusterColorA) ||
        setColor(percent, c2_t1, c2_t2, c2_t3, c2_t4, cluster2_color, clusterColorB) ||
        setColor(percent, c4_t1, c4_t2, c4_t3, c4_t4, cluster4_color, clusterColorD)) {

      clusterColor = clusterColorA + clusterColorB + clusterColorD;
      useCluster = true;
    }
  }
  else if (useCluster1 == 1 && useCluster3 == 1 && useCluster4 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, c1_t4, cluster1_color, clusterColorA) ||
        setColor(percent, c3_t1, c3_t2, c3_t3, c3_t4, cluster3_color, clusterColorC) ||
        setColor(percent, c4_t1, c4_t2, c4_t3, c4_t4, cluster4_color, clusterColorD)) {

      clusterColor = clusterColorA + clusterColorC + clusterColorD;
      useCluster = true;
    }
  }
  else  if (useCluster2 == 1 && useCluster3 == 1 && useCluster4 == 1) {
    if (setColor(percent, c2_t1, c2_t2, c2_t3, c2_t4, cluster2_color, clusterColorB) ||
        setColor(percent, c3_t1, c3_t2, c3_t3, c3_t4, cluster3_color, clusterColorC) ||
        setColor(percent, c4_t1, c4_t2, c4_t3, c4_t4, cluster4_color, clusterColorD)) {

      clusterColor = clusterColorB + clusterColorC + clusterColorD;
      useCluster = true;
    }
  }
  else if (useCluster1 == 1 && useCluster2 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, c1_t4, cluster1_color, clusterColorA) ||
        setColor(percent, c2_t1, c2_t2, c2_t3, c2_t4, cluster2_color, clusterColorB)) {

      clusterColor = clusterColorA + clusterColorB;
      useCluster = true;
    }
  }
  else if (useCluster1 == 1 && useCluster3 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, c1_t4, cluster1_color, clusterColorA) ||
        setColor(percent, c3_t1, c3_t2, c3_t3, c3_t4, cluster3_color, clusterColorC)) {

      clusterColor = clusterColorA + clusterColorC;
      useCluster = true;

    }
  }
  else if (useCluster1 == 1 && useCluster4 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, c1_t4, cluster1_color, clusterColorA) ||
        setColor(percent, c4_t1, c4_t2, c4_t3, c4_t4, cluster4_color, clusterColorD)) {

      clusterColor = clusterColorA + clusterColorD;
      useCluster = true;

    }
  }
  else if (useCluster2 == 1 && useCluster3 == 1) {
    if (setColor(percent, c2_t1, c2_t2, c2_t3, c2_t4, cluster2_color, clusterColorB) ||
        setColor(percent, c3_t1, c3_t2, c3_t3, c3_t4, cluster3_color, clusterColorC)) {

      clusterColor = clusterColorB + clusterColorC;
      useCluster = true;

    }
  }
  else if (useCluster2 == 1 && useCluster4 == 1) {
    if (setColor(percent, c2_t1, c2_t2, c2_t3, c2_t4, cluster2_color, clusterColorB) ||
        setColor(percent, c4_t1, c4_t2, c4_t3, c4_t4, cluster4_color, clusterColorD)) {

      clusterColor = clusterColorB + clusterColorD;
      useCluster = true;

    }
  }
  else if (useCluster3 == 1 && useCluster4 == 1) {
    if (setColor(percent, c3_t1, c3_t2, c3_t3, c3_t4, cluster3_color, clusterColorC) ||
        setColor(percent, c4_t1, c4_t2, c4_t3, c4_t4, cluster4_color, clusterColorD)) {

      clusterColor = clusterColorC + clusterColorD;
      useCluster = true;

    }
  }
  else if (useCluster1 == 1) {
    if (setColor(percent, c1_t1, c1_t2, c1_t3, c1_t4, cluster1_color, clusterColorA)) {
      clusterColor = clusterColorA;
      useCluster = true;
    }
  }
  else if (useCluster2 == 1) {
    if (setColor(percent, c2_t1, c2_t2, c2_t3, c2_t4, cluster2_color, clusterColorB)) {
      clusterColor = clusterColorB;
      useCluster = true;
    }
  }
  else if (useCluster3 == 1) {
    if (setColor(percent, c3_t1, c3_t2, c3_t3, c3_t4, cluster3_color, clusterColorC)) {
      clusterColor = clusterColorC;
      useCluster = true;
    }
  }
  else if (useCluster4 == 1) {
    if (setColor(percent, c4_t1, c4_t2, c4_t3, c4_t4, cluster4_color, clusterColorD)) {
      clusterColor = clusterColorD;
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
  // outputFrag = vec4(brainColor.rrr, opacity);

}