#version 150

in vec3 texCoord;  // 3D texture coordinates from the vertex shader
out vec4 outputFrag;  // This is the fragment shader output

uniform sampler3D brain;  // Our brain brain
uniform vec3 cameraPos;  // camera position
//uniform vec3 step_size;   // ray step size

// uniform float percent; //val between 0.0 and 1.0, used to interpolate between times...
uniform float opacity;

//constants
const int MAX_SAMPLES = 100;    //total samples for each ray march step
const vec3 texMin = vec3(0.0);  //minimum texture access coordinate
const vec3 texMax = vec3(1.0);  //maximum texture access coordinate


void main() {

//    vec3 color = vec3(1.0,1.0,1.0);
    vec4 brainColor = vec4(texCoord, 1.0);
/*
    // get the 3D texture coordinates for lookup into the brain dataset
    vec3 dataPos = texCoord;

    //Getting the ray marching direction:
    //get the object space position by subracting 0.5 from the
    //3D texture coordinates. Then subtraact it from camera position
    //and normalize to get the ray marching direction
    vec3 geomDir = vec3(texCoord.xyz);  //normalize((texCoord-vec3(0.5)) - cameraPos);
//    vec3 geomDir = vec3(texCoord.xyz);  //normalize((texCoord-vec3(0.5)) - cameraPos);

    //multiply the raymarching direction with the step size to get the
    //sub-step size we need to take at each raymarching step
    vec3 dirStep = geomDir * step_size;

    //flag to indicate if the raymarch loop should terminate
    bool stop = false;

    //for all samples along the ray
    for (int i = 0; i < MAX_SAMPLES; i++) {
        // advance ray by dirstep
        dataPos = dataPos + dirStep;


        //The two constants texMin and texMax have a value of vec3(-1,-1,-1)
        //and vec3(1,1,1) respectively. To determine if the data value is
        //outside the brain data, we use the sign function. The sign function
        //return -1 if the value is less than 0, 0 if the value is equal to 0
        //and 1 if value is greater than 0. Hence, the sign function for the
        //calculation (sign(dataPos-texMin) and sign (texMax-dataPos)) will
        //give us vec3(1,1,1) at the possible minimum and maximum position.
        //When we do a dot product between two vec3(1,1,1) we get the answer 3.
        //So to be within the dataset limits, the dot product will return a
        //value less than 3. If it is greater than 3, we are already out of
        //the brain dataset
        stop = dot(sign(dataPos-texMin),sign(texMax-dataPos)) < 3.0;

        //if the stopping condition is true we brek out of the ray marching loop
        if (stop)
            break;

        // data fetching from the red channel of brain texture
        float sample = texture(brain, dataPos).r;

        //Opacity calculation using compositing:
        //here we use front to back compositing scheme whereby the current sample
        //value is multiplied to the currently accumulated alpha and then this product
        //is subtracted from the sample value to get the alpha from the previous steps.
        //Next, this alpha is multiplied with the current sample colour and accumulated
        //to the composited colour. The alpha value from the previous steps is then
        //accumulated to the composited colour alpha.
        float prev_alpha = sample - (sample * outputFrag.a);
        outputFrag.rgb = prev_alpha * vec3(sample) + outputFrag.rgb;
        outputFrag.a += prev_alpha;

        //early ray termination
        //if the currently composited colour alpha is already fully saturated
        //we terminated the loop
        if( outputFrag.a>0.99)
            break;
    }
*/
    brainColor = texture(brain, texCoord);
    outputFrag = vec4(brainColor.rrr, 1.0);

}
