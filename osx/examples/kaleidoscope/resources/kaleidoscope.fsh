
#version 150

uniform int which;
uniform float time;
uniform vec2 resolution;
uniform sampler2D tex0;
out vec4 outputFrag; 

void main(void) {

  vec2 p = -1.0 + (2.0 * (gl_FragCoord.xy / resolution.xy));
  //vec2 p = gl_FragCoord.xy / resolution.xy;
  vec2 uv;

  if (which == 0) {   
    float a = atan(p.y,p.x);
    float r = sqrt(dot(p,p));

    uv.x =          7.0*a/3.1416;
    uv.y = -time+ sin(7.0*r+time) + .7*cos(time+7.0*a);

    float w = .5+.5*(sin(time+7.0*r)+ .7*cos(time+7.0*a));

    vec3 col =  texture(tex0,uv*.5).xyz;

    outputFrag = vec4(col*w,1.0);

  } else if (which == 1) {

    float a = atan(p.y,p.x);
    float r = sqrt(dot(p,p));

    uv.x = .75*time+.1/r;
    uv.y = a/3.1416;

    vec3 col =  texture(tex0,uv).xyz;

    outputFrag = vec4(col*r,1.0);
  } else if (which == 2) {

    float r = sqrt( dot(p,p) );
    float a = atan(p.y,p.x) + 0.5*sin(0.5*r-0.5*time);

    float s = 0.5 + 0.5*cos(7.0*a);
    s = smoothstep(0.0,1.0,s);
    s = smoothstep(0.0,1.0,s);
    s = smoothstep(0.0,1.0,s);
    s = smoothstep(0.0,1.0,s);

    uv.x = time + 1.0/( r + .2*s);
    uv.y = 3.0*a/3.1416;

    float w = (0.5 + 0.5*s)*r*r;

    vec3 col = texture(tex0,uv).xyz;

    float ao = 0.5 + 0.5*cos(7.0*a);
    ao = smoothstep(0.0,0.4,ao)-smoothstep(0.4,0.7,ao);
    ao = 1.0-0.5*ao*r;

    outputFrag = vec4(col*w*ao,1.0);
  } else if ( which == 3 ) {
    float x = gl_FragCoord.x;
   float y = gl_FragCoord.y;
   float mov0 = x+y+cos(sin(time)*2.)*100.+sin(x/100.)*1000.;
   float mov1 = y / resolution.y / 0.2 + time;
   float mov2 = x / resolution.x / 0.2;
   float c1 = abs(sin(mov1+time)/2.+mov2/2.-mov1-mov2+time);
   float c2 = abs(sin(c1+sin(mov0/1000.+time)+sin(y/40.+time)+sin((x+y)/100.)*3.));
   float c3 = abs(sin(c2+cos(mov1+mov2+c2)+cos(mov2)+sin(x/1000.)));
   outputFrag = vec4( c1,c2,c3,1.0);
} 

else if (which == 4) {

 p.x *= resolution.x/resolution.y;

    float zoo = .62+.38*sin(.1*time);
    float coa = cos( 0.1*(1.0-zoo)*time );
    float sia = sin( 0.1*(1.0-zoo)*time );
    zoo = pow( zoo,8.0);
    vec2 xy = vec2( p.x*coa-p.y*sia, p.x*sia+p.y*coa);
    vec2 cc = vec2(-.745,.186) + xy*zoo;

    vec2 z  = vec2(0.0);
    vec2 z2 = z*z;
    float m2;
    float co = 0.0;


    // chrome/angelproject/nvidia/glslES don't seem to like to "break" a loop...
    // so we have to rewrite it in another way
/*
    for( int i=0; i<256; i++ )
    {
        z = cc + vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
        m2 = dot(z,z);
        if( m2>1024.0 ) break;
        co += 1.0;
    }
*/

    for( int i=0; i<256; i++ )
    {
        if( m2<1024.0 )
        {
            z = cc + vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
            m2 = dot(z,z);
            co += 1.0;
        }
    }

    co = co + 1.0 - log2(.5*log2(m2));

    co = sqrt(co/256.0);
    outputFrag = vec4( .5+.5*cos(6.2831*co+0.0),
                         .5+.5*cos(6.2831*co+0.4),
                         .5+.5*cos(6.2831*co+0.7),
                         1.0 );
}
  // vec2 p = gl_FragCoord.xy / resolution.xy;
  //outputFrag =  texture(tex0,p);
}
/*
   uniform vec2 resolution;
   uniform float time;
   uniform sampler2D tex0;
   out vec4 outputFrag; 
   void main(void)
   {
   vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / resolution.xy;
   vec2 uv;

   float a = atan(p.y,p.x);
   float r = sqrt(dot(p,p));

   uv.x =          7.0*a/3.1416;
   uv.y = -time+ sin(7.0*r+time) + .7*cos(time+7.0*a);

   float w = .5+.5*(sin(time+7.0*r)+ .7*cos(time+7.0*a));

   vec3 col =  texture2D(tex0,uv*.5).xyz;

   outputFrag = vec4(col*w,1.0);
   }
 */
