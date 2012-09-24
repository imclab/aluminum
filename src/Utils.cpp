#include <cstdio>
#include <iostream>
#include <sstream>
#include <ctime> 
#include <cstdlib>

#include "Utils.hpp"

#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_access.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtx/random.hpp>


namespace aluminum {
  using std::vector;
  using glm::vec3;

  void Utils::randomSeed() {
    srand((unsigned)time(0)); 
  }

  float Utils::random() {
    return glm::compRand1(0,1);
  }

  int Utils::randomInt(int min, int max) {
    //seems like a bit of a bug for negative ints... this fixes it though
    if (min < 0) {
      min = min-1;
    } 

    if (max > 0) {
      max = max+1;
    }

    return (int) glm::compRand1(min, max);
    // return min + int( ((max-min)+1) * random() ); 
  }

  vector<int> Utils::randomInts(int howMany, int min, int max) {
    vector<int> ints;

    for(int index = 0; index < howMany; index++){ 
      ints.push_back( randomInt(min,max) );
    } 

    return ints;
  }

  float Utils::randomFloat(float min, float max) {
    return (float) glm::compRand1(min, max);
  }

  vector<float> Utils::randomFloats(int howMany, float min, float max) {
    vector<float> floats;

    for(int index = 0; index < howMany; index++){ 
      floats.push_back(randomFloat(min, max));
    } 

    return floats;
  }

  vec3 Utils::randomVec3(float min, float max) {
    return glm::compRand3(min, max);
  }


};
