
#version 150

uniform int which;
uniform float time;
uniform vec2 resolution;
uniform sampler2D tex0;
out vec4 outputFrag; 


// by @eddbiddulph
// depth of field. works best in the 1 or 0.5 modes...

uniform vec2    mouse;

const vec3 eps = vec3(0.001, 0.0, 0.0);

float f(vec3 p)
{
//orig
 //  return length(max(vec3(0.0, 0.0, 0.0), abs(mod(p, 1.0) - 0.5) - 0.15)) - 0.2;
 
//float space = 0.5;
//vec3 zero = vec3(0.0,0.0,0.0);
//vec3 pos = (mod(p, space) - 0.5*space) - 0.0;
//return length( abs(pos - 0.15) ) - 0.2; 

  
//repeat
vec3 dist = vec3(2.0); //dist between each repeated object
vec3 pos = mod(p,dist)-0.5*dist; //repeated position 

//twist
//float c = cos(20.0*pos.y);
//float s = sin(20.0*pos.y);
//mat2  m = mat2(c,-s,s,c);
//pos = vec3(m*pos.xz,pos.y);


//round box  
vec3 bsize = vec3(0.5, 0.02, 0.1);
float roundedness = 0.15;
//return length(max(abs(pos)-bsize,0.0))-roundedness;
float d1 = length(max(abs(pos)-bsize,0.0))-roundedness;

//sphere
//float radius = 0.2;
//return length(pos) - radius; 

//torus
float size = 0.4;
float thickness = 0.015;
vec2 r = vec2(length(pos.xz)-size,pos.y);
//return length(r)-thickness;
float d2 = length(r)-thickness;

//union
return min(d1,d2);

//subtraction
//return max(-d2,d1);

//blend ??
//float dd = smoothstep(0.0, 1.0, d1-d2);
//return mix(d1,d2,0.5);


//cone ? looks weird
//vec2 c = normalize(vec2(0.1, 0.05));
//float q = (length(pos.yz));
//return max( (  dot(c,vec2(q,pos.x)) ), 0.0) ;

//hex prism?
//vec3 q = abs(pos);
//vec2 h = vec2(0.5, 0.2); //height, length
//return max(q.z-h.y, max(q.x+q.y*0.57735,q.y*1.1547)-h.x);

//tri prism
//vec3 q = abs(pos);
//vec2 h = vec2(0.2, 0.2); //height, length
//return max(q.z-h.y,max(q.x*0.866025+pos.y*0.5,-pos.y)-h.x*0.5);



//return length  (max(vec3(0.0,0.0,0.0  ), abs(mod(p, 0.8) - 0.1) - 0.0)) - 0.0 ;
}

vec3 n(vec3 p)
{
    float d = f(p);
    return normalize(vec3(d - f(p - eps.xyz), d - f(p - eps.zxy), d - f(p - eps.yzx)));
}

void shade(vec3 p, vec3 e, vec3 norm, vec3 op, out vec3 diff, out vec3 spec)
{
    vec3 fp = floor(p);
    vec3 col = mix(vec3(0.2, 0.2, 0.2), vec3(1.0, 0.6, 0.6),
                                abs(cos(fp.x) * sin(fp.y + 0.2) * sin(fp.z)));
                                
    float fres = pow(1.0 - dot(e, norm), 2.0) * 2.0;
    float a = max(0.0, 1.0 - distance(p, op) * 0.1);

    spec = vec3(fres) * a;
    diff = col * a;
}

vec3 sceneNonRefl(vec3 ro, vec3 rd)
{
    vec3 old_ro = ro;


int numSteps = 1000; //100
float minDist = 0.00001; //0.001
float jumpFactor = 0.1; //1.5;


    for(int i = 0; i < numSteps; ++i)
    {
        float dist = f(ro);
        
        if(abs(dist) < minDist) //0.001
            break;
        
        ro += rd * dist * jumpFactor;
    }
    
    //vec3 diff, spec;

    //shade(ro, -rd, n(ro), old_ro, diff, spec);
    vec3 fp = floor(ro);
    vec3 col = mix(vec3(0.5, 0.5, 0.5), vec3(1.0, 0.6, 0.6),
                                abs(cos(fp.x) * sin(fp.y + 0.2) * sin(fp.z)));
    
    float a = max(0.0, 1.0 - distance(ro, old_ro) * 0.1);


    vec3 diff = (col * a);
    return diff;
}

vec3 sceneRefl(vec3 ro, vec3 rd)
{
    vec3 old_ro = ro;

int numSteps = 100;
float minDist = 0.001;
float jumpFactor = 1.5;

    for(int i = 0; i < numSteps; ++i) {
        float dist = f(ro);
        
        if(abs(dist) < minDist) { break; }
        
        ro += rd * dist * jumpFactor;  //1.5
    }
    
    vec3 norm = n(ro);
    vec3 refl = sceneNonRefl(ro + norm * 0.01, reflect(norm, rd));
    
    vec3 diff, spec;

    shade(ro, -rd, norm, old_ro, diff, spec);

    return refl * spec + diff;
}

vec3 rotateX(vec3 v, float a)
{
    float ca = cos(a), sa = sin(a);
    return vec3(v.x, ca * v.y - sa * v.z, sa * v.y + ca * v.z);
}

vec3 rotateY(vec3 v, float a)
{
    float ca = cos(a), sa = sin(a);
    return vec3(ca * v.x - sa * v.z, v.y, sa * v.x + ca * v.z);
}

float rand1(vec2 co)
{
    //return (sin(co.x));
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand2(vec2 co)
{
    //return (sin(co.y));
    return fract(cos(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

const int sum_num = 1;

void main(void)
{
    float t = time, ax = -(mouse.y - 0.5) * 3.14159, ay = -(mouse.x - 0.5) * 3.14159;
   // t = 0.0;
    // ray target on focus plane, in view space
    vec3 targ;
    targ.xy = (gl_FragCoord.xy / resolution.xy - 0.5); //* vec2(resolution.x / resolution.y, 1.0) * 1.5;
    //targ.xy = gl_FragCoord.xy * 1.5;
    targ.z = 2.0;

    vec3 sum = vec3(0.0);

    for(int i = 0; i < sum_num; ++i) {
        float fi = float(i) * 100.0;
        // ray origin (eye point) in view space
        //vec3 ro = vec3(rand1(gl_FragCoord.xy + fi), rand2(gl_FragCoord.xy + fi), 0.0) * 0.06;
        //vec3 ro = vec3( rand1(gl_FragCoord.xy + fi), rand2(gl_FragCoord.xy + fi), 0.0) * 0.0;
        vec3 ro = vec3(0.0);
	// ray direction in view space
        vec3 rd = normalize(targ - ro);
        //vec3 rd = vec3(2.0); //normalize(targ - ro);

        // perform view transforms (from view space to world space. scene is defined in world space)
        rd = rotateY(rotateX(rd, ax), ay);
        ro = rotateY(rotateX(ro, ax), ay) + vec3(cos(t * 0.2), sin(t * 0.15) * 0.1, t * 0.3);
        
      //  sum += sceneRefl(ro, rd);
        sum += sceneNonRefl(ro, rd);

    }

  outputFrag = vec4( (sum / float(sum_num)), 1.0);
}

/*
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
*/
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
