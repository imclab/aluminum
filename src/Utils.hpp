#ifndef INCLUDE_ALU_UTILS_HPP
#define INCLUDE_ALU_UTILS_HPP

#include "Includes.hpp"

/*
#include <string>
#include <vector>

#include "Texture.hpp"
*/  
//#include <glm/glm.hpp>

namespace aluminum {

  using std::vector;
  using glm::vec3;
  using glm::vec4;

  class Utils {
    public:
      Utils();
    
      static long randomLong(long min, long max);
      static int randomInt(int min, int max);
      static vector<int> randomInts(int howMany, int min, int max);
      static float randomFloat(float min, float max);
      static vector<float> randomFloats(int howMany, float min, float max);

      
      static vec3 randomVec3(float min, float max);

      static vec4 randomColor();
      static vec4 randomColor(float alpha);
      static vec4 randomColor(float min, float max);
      static vec4 randomColor(float min, float max, float alpha);

      static void randomSeed();

      static float random();

    private:

  };


}

#endif

