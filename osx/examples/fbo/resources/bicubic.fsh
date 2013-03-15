#version 150
precision lowp float;

/* See http://www.codeproject.com/Articles/236394/Bi-Cubic-and-Bi-Linear-Interpolation-with-GLSL */

#pragma optimize (off)
#pragma debug (on)

uniform sampler2D tex0;                       
uniform int tWidth; //= 600.0;
uniform int tHeight; //= 400.0;

in vec2 texCoord;                            
out vec4 outputFrag;

float BellFunc( float x )
{
	float f = ( x / 2.0 ) * 1.5; // Converting -2 to +2 to -1.5 to +1.5
	if( f > -1.5 && f < -0.5 )
	{
		return( 0.5 * pow(f + 1.5, 2.0));
	}
	else if( f > -0.5 && f < 0.5 )
	{
		return 3.0 / 4.0 - ( f * f );
	}
	else if( ( f > 0.5 && f < 1.5 ) )
	{
		return( 0.5 * pow(f - 1.5, 2.0));
	}
	return 0.0;
}

float CatMullRom( float x )
{
    const float B = 0.0;
    const float C = 0.5;
    float f = x;
    if( f < 0.0 )
    {
        f = -f;
    }
    if( f < 1.0 )
    {
        return ( ( 12 - 9 * B - 6 * C ) * ( f * f * f ) +
            ( -18 + 12 * B + 6 *C ) * ( f * f ) +
            ( 6 - 2 * B ) ) / 6.0;
    }
    else if( f >= 1.0 && f < 2.0 )
    {
        return ( ( -B - 6 * C ) * ( f * f * f )
            + ( 6 * B + 30 * C ) * ( f *f ) +
            ( - ( 12 * B ) - 48 * C  ) * f +
            8 * B + 24 * C)/ 6.0;
    }
    else
    {
        return 0.0;
    }
} 

float BSpline( float x )
{
  float f = x;
  if( f < 0.0 ) {
    f = -f;
  }

  if( f >= 0.0 && f <= 1.0 ) {
    return ( 2.0 / 3.0 ) + ( 0.5 ) * ( f * f * f ) - (f*f);
  }
  else if( f > 1.0 && f <= 2.0 ) {
    return 1.0 / 6.0 * pow( ( 2.0 - f  ), 3.0 );
  }
  return 1.0;
}

float Triangular( float f ) {
  f = f / 2.0;
  if( f < 0.0 )
  {
    return ( f + 1.0 );
  }
  else
  {
    return ( 1.0 - f );
  }
  return 0.0;
}

void main() {

  vec2 TexCoord = texCoord; 

  float texelSizeX = 1.0 / float(tWidth); //size of one texel 
  float texelSizeY = 1.0 / float(tHeight); //size of one texel 
  vec4 nSum = vec4( 0.0, 0.0, 0.0, 0.0 );
  vec4 nDenom = vec4( 0.0, 0.0, 0.0, 0.0 );

  
  float a = fract( TexCoord.x * float(tWidth) ); // get the decimal part
  float b = fract( TexCoord.y * float(tHeight) ); // get the decimal part

  for( int m = -1; m <=2; m++ ) {
    for( int n =-1; n<= 2; n++) {
      vec4 vecData = texture(tex0, 
	  TexCoord + vec2(texelSizeX * float( m ), texelSizeY * float( n )));

      float f  = BSpline( float( m ) - a );
      //float f  = Triangular( float( m ) - a );

      vec4 vecCooef1 = vec4( f,f,f,f );

      float f1 = BSpline ( -( float( n ) - b ) );
      //float f1 = Triangular ( -( float( n ) - b ) );
      vec4 vecCoeef2 = vec4( f1, f1, f1, f1 );
      nSum = nSum + ( vecData * vecCoeef2 * vecCooef1  );
      nDenom = nDenom + (( vecCoeef2 * vecCooef1 ));
    }
  }

  outputFrag = nSum / nDenom;
  
  /*
  if (a > 0.98) {
    outputFrag = vec4(a, texture(tex0, TexCoord).gb, 1.0);
  } else {
  //outputFrag = texture(tex0, TexCoord);
    outputFrag = vec4(0.0);
  }
  //outputFrag = texture(tex0, TexCoord);
  */

  /*

  //vec2 ij = gl_TexCoord[0].st;
  //vec2        xy = floor(ij);
  //vec2 normxy = ij - xy;

  //  vec2 st0 = ((2.0 - normxy) * normxy - 1.0) * normxy;
  //  vec2 st1 = (3.0 * normxy - 5.0) * normxy * normxy + 2.0;
  //  vec2 st2 = ((4.0 - 3.0 * normxy) * normxy + 1.0) * normxy;
  //  vec2 st3 = (normxy - 1.0) * normxy * normxy;
  //  
  vec2 st0 = vec2(2.0*xinc    )((2.0 - normxy) * normxy - 1.0) * normxy;
  vec2 st1 = (3.0 * normxy - 5.0) * normxy * normxy + 2.0;
  vec2 st2 = ((4.0 - 3.0 * normxy) * normxy + 1.0) * normxy;
  vec2 st3 = (normxy - 1.0) * normxy * normxy;

  vec4 row0 =
  st0.s * texture2D(s_tex, xy + vec2(-1.0, -1.0)) +
  st1.s * texture2D(s_tex, xy + vec2(0.0, -1.0)) +
  st2.s * texture2D(s_tex, xy + vec2(1.0, -1.0)) +
  st3.s * texture2D(s_tex, xy + vec2(2.0, -1.0));

  vec4 row1 =
  st0.s * texture2D(s_tex, xy + vec2(-1.0, 0.0)) +
  st1.s * texture2D(s_tex, xy + vec2(0.0, 0.0)) +
  st2.s * texture2D(s_tex, xy + vec2(1.0, 0.0)) +
  st3.s * texture2D(s_tex, xy + vec2(2.0, 0.0));

  vec4 row2 =
  st0.s * texture2D(s_tex, xy + vec2(-1.0, 1.0)) +
  st1.s * texture2D(s_tex, xy + vec2(0.0, 1.0)) +
  st2.s * texture2D(s_tex, xy + vec2(1.0, 1.0)) +
  st3.s * texture2D(s_tex, xy + vec2(2.0, 1.0));

  vec4 row3 =
  st0.s * texture2D(s_tex, xy + vec2(-1.0, 2.0)) +
  st1.s * texture2D(s_tex, xy + vec2(0.0, 2.0)) +
  st2.s * texture2D(s_tex, xy + vec2(1.0, 2.0)) +
  st3.s * texture2D(s_tex, xy + vec2(2.0, 2.0));

  //gl_FragColor.rgba = 0.25 * ((st0.t * row0) + (st1.t * row1) + (st2.t * row2) + (st3.t * row3));

  gl_FragColor.rgba = vec4(0.4, ij.y, 0.0, 1.0); //texture2D(s_tex, ij);
   */
}


