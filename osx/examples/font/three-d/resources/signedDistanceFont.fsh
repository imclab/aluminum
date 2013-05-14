
#version 150

uniform vec4 textColor;
uniform sampler2D tex0;

in vec2 texCoord;
out vec4 outputFrag; 

const float glyph_center   = 0.2; //.5 = normal, .55 = skinny

vec4 outlineColor  = vec4(0.0, 0.0, 1.0, 1.0);
const float outline_center = 0.65; //0.55; //outline sligtly to the inside
 
vec4 glowColor = vec4(0.0, 1.0, 0.0,1.0);
const float glow_center    = 0.7;


// Replacement for RSL's 'filterstep()', with fwidth() done right.
// 'threshold ' is constant , 'value ' is smoothly varying
float aastep (float threshold , float value) {
  float afwidth = 0.7 * length ( vec2(dFdx(value), dFdy(value)));
  // GLSL 's fwidth(value) is abs(dFdx(value)) + abs(dFdy(value))
  return smoothstep (threshold-afwidth, threshold+afwidth, value );
}


void main(){
  vec4 outColor = vec4(0.0,0.0,0.0,0.0);

  //for one channel
  float dist = ( texture(tex0, texCoord).r);
  float width = fwidth(dist);
  //float a = smoothstep(glyph_center-width, glyph_center+width, dist);
  float a = aastep(glyph_center, dist);

  // if (a == 0) {
  //  outputFrag = vec4(0.0,1.0,0.0,0.5); 
  // } else { 
  
  //normal single colored smooth text
  outColor = vec4(textColor.rgb, a);
  float maxa = a;

  //outline 1
  //float mu = smoothstep(0.8-width, 0.8+width, dist);
  float mu = aastep(0.5, dist);
  vec3 rgb = mix(outlineColor.rgb, outColor.rgb, mu);
  maxa = max(maxa, mu);
  outColor = vec4(rgb, maxa);

/*
  //outline 2
  //float mu2 = smoothstep(0.6-width, 0.6+width, dist);
  float mu2 = aastep(0.6, dist);
  vec3 rgb2 = mix(glowColor.rgb, outColor.rgb, mu2);
  maxa = max(maxa, mu2);
  outColor = vec4(rgb2, maxa);


  //outline 3
  //float mu3 = smoothstep(0.3-width, 0.3+width, dist);
  float mu3 = aastep(0.3, dist);
  vec3 rgb3 = mix(vec3(1.0,1.0,1.0), outColor.rgb, mu3);
  maxa = max(maxa, mu3);
  outColor = vec4(rgb3, maxa);
*/
  
  outputFrag = vec4(outColor); 

  // }

 
  //for four channel
  //vec4 outColor = texture(tex0, texCoord).rgbr;
  //float a = ( texture(tex0, texCoord).a);
  //vec4 outColor = vec4(a,a,a,a);
  //outColor *= textColor;
  //outputFrag = vec4(outColor); 

}
