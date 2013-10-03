
#version 150

uniform vec3 ambient, diffuse, specular;
in vec3 P, N, L;

out vec4 frag; 
void main(){

  vec3 V = normalize(-P); 
  vec3 H = normalize(-reflect(L,N)); 

  //ambient
  vec3 outColor = ambient;

  //diffuse light
  float diff = max(0.0, dot(N, L));
  outColor += diff * diffuse;
  
  //specular
  float spec = pow( max(dot(H, V), 0.0), 32.0);
  outColor += spec * specular;
  if (spec > 1.0) {
    frag = vec4(1.0,0.0,0.0,1.0);
  } else {

  //outColor = (vec3(N.rgb) + 1.0 ) / 2.0;
  //outColor = (vec3(L.rrr) + 1.0 ) / 2.0;
  //outColor = (vec3(H.rgb) + 1.0 ) / 2.0;

  frag = clamp(vec4(outColor,1.0), 0.0,1.0); 
  }
}
