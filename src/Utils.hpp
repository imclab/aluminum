#ifndef INCLUDE_ALU_UTILS_HPP
#define INCLUDE_ALU_UTILS_HPP

#include <string>
#include <vector>
#include "Includes.hpp"
#include "Texture.hpp"

#include <glm/glm.hpp>

namespace aluminum {

  using std::vector;
  using glm::vec3;

  class Utils {
    public:
      Utils();
    
      static int randomInt(int min, int max);
      static vector<int> randomInts(int howMany, int min, int max);
      static float randomFloat(float min, float max);
      static vector<float> randomFloats(int howMany, float min, float max);

      
      static vec3 randomVec3(float min, float max);
      static void randomSeed();
 
      static float random();

    private:

 };


}

#endif

