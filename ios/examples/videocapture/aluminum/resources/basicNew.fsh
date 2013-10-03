precision mediump float;
uniform sampler2D tex0;
uniform sampler2D tex1;
varying vec2 texCoord;
varying lowp vec4 color;

void main() {
    vec4 outColor; // = color;
    vec4 GridOut = texture2D(tex1, texCoord.st);
     // outColor = texture2D(tex0, texCoord.st);
//    if (outColor.a ==0.0){
//        discard;
//    }
//    else{
    GridOut = vec4(vec3(GridOut.xyz), 0.4*GridOut.w);
//    }
    gl_FragColor = GridOut;
    
}
