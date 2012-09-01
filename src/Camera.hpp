#ifndef INCLUDE_AL_CAM2_HPP
#define INCLUDE_AL_CAM2_HPP

#include <string>
#include "allocore/math/al_Vec.hpp"
#include "allocore/math/al_Matrix4.hpp"

namespace al{

  class Camera {

    public:

      Camera();
      Camera(float fovy, float aspect, float nearPlane, float farPlane); //perspective
      
      void setUpStereo(float _convergence, float _eyeSep);
      void setupStereoRight(Matrix4f& P, Matrix4f& V); 
      void setupStereoLeft(Matrix4f& P, Matrix4f& V); 
      
      Camera& perspective(float fovy, float aspect, float nearPlane, float farPlane); //perspective
      Camera& resetVectors();
      Camera& transform();
          
      Camera& translate(Vec3f dists);
      Camera& translateX(float dist);
      Camera& translateY(float dist);
      Camera& translateZ(float dist);
      Camera& rotate(Vec3f angles);
      Camera& rotateX(float angle);
      Camera& rotateY(float angle);
      Camera& rotateZ(float angle);

      float fovy, aspect, nearPlane, farPlane, convergence, eyeSep; 
      Matrix4f projection, view, backView;
      Matrix4f rightProjection, leftProjection, rightView, leftView, rightBackView, leftBackView, rightTranslate, leftTranslate;
      Vec3f posVec, viewVec, rightVec, upVec;

      bool isTransformed;
      bool isFrontBack;
      bool isStereo;

      static void printMatrix(Matrix4f m);
    private:
	Matrix4f reverseRotationMatrix(Matrix4f m);
	Vec3f ArbitraryRotate(Vec3f p, float theta, Vec3f r);
  };
}
#endif

