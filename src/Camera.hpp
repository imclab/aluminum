#ifndef INCLUDE_AL_CAM2_HPP
#define INCLUDE_AL_CAM2_HPP

#include <string>
//#include "allocore/math/al_Vec.hpp"
//#include "allocore/math/al_Matrix4.hpp"
#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>

using glm::to_string;
using glm::vec3;
using glm::vec4;
using glm::mat4;

namespace aluminum {

  class Camera {

    public:

      Camera();
      Camera(float fovy, float aspect, float nearPlane, float farPlane); //perspective
      
      void setUpStereo(float _convergence, float _eyeSep);
      //void setupStereoRight(Matrix4f& P, Matrix4f& V); 
      //void setupStereoLeft(Matrix4f& P, Matrix4f& V); 
      
      Camera& perspective(float fovy, float aspect, float nearPlane, float farPlane); //perspective
      Camera& resetVectors();
      Camera& transform();
          
      Camera& translate(vec3 dists);
      Camera& translateX(float dist);
      Camera& translateY(float dist);
      Camera& translateZ(float dist);
      Camera& rotate(vec3 angles);
      Camera& rotateX(float angle);
      Camera& rotateY(float angle);
      Camera& rotateZ(float angle);

      float fovy, aspect, nearPlane, farPlane, convergence, eyeSep; 
      mat4 projection, view, backView;
      mat4 rightProjection, leftProjection, rightView, leftView, rightBackView, leftBackView, rightTranslate, leftTranslate;
      vec3 posVec, viewVec, rightVec, upVec;

      bool isTransformed;
      bool isFrontBack;
      bool isStereo;

    private:
	vec3 ArbitraryRotate(vec3 p, float theta, vec3 r);
  };
}
#endif

