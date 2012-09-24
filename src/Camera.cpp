#include <cstdio>
#include <iostream>
#include <sstream>
#include "Camera.hpp"

#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_access.hpp>
#include <glm/gtc/type_ptr.hpp>

using glm::to_string;
using glm::vec3;
using glm::vec4;
using glm::mat4;

namespace al{

#define radians(x) (x * M_PI / 180.0f)
#define degrees(x) (180.0 * x / M_PI)

  Camera::Camera() { };

  //Perspective Camera
  Camera::Camera(float _fovy, float _aspect, float _nearPlane, float _farPlane) {
    resetVectors();
    perspective(_fovy, _aspect, _nearPlane, _farPlane);
    setUpStereo(5.0, 1.0);
  }

  Camera& Camera::resetVectors() {
    posVec = vec3(0.0, 0.0, 0.0);
    viewVec = vec3(0.0, 0.0f, -1.0);
    rightVec = vec3(1.0, 0.0, 0.0);
    upVec = vec3(0.0, 1.0, 0.0);  
    isTransformed = true;
    return *this;
  }

  Camera& Camera::perspective(float _fovy, float _aspect, float _nearPlane, float _farPlane) {
    fovy = _fovy;
    nearPlane = _nearPlane;
    farPlane = _farPlane;
    aspect = _aspect;

    projection = glm::perspective(fovy, aspect, nearPlane, farPlane);

    isFrontBack = true;
    isStereo = true;

    setUpStereo(5.0, 1.0);

    isTransformed = true;
    return *this;
  }

  Camera& Camera::transform() {
    
     mat4 rM = mat4(
	rightVec.x, upVec.x, viewVec.x, 0,
	rightVec.y, upVec.y, viewVec.y, 0, 
	rightVec.z, upVec.z, viewVec.z, 0,
  	0,0,0,1);

    mat4 tM = glm::translate( mat4(1.0), vec3(posVec.x, posVec.y, posVec.z) ); 

    view = rM * tM;
    
    if (isFrontBack) {
      mat4 rrM = mat4(
	-rightVec.x, upVec.x, -viewVec.x, 0,
	-rightVec.y, upVec.y, -viewVec.y, 0, 
	-rightVec.z, upVec.z, -viewVec.z, 0,
  	0,0,0,1);

      backView = rrM * tM;
    }

    if (isStereo) {
      rightView = rightTranslate * view;
      leftView = leftTranslate * view;
       
      if (isFrontBack) {
	rightBackView = rightTranslate * backView;
	leftBackView = leftTranslate * backView;
      }
    }

    isTransformed = false;

    return *this;
  }

  /* code adapted from http://quiescentspark.blogspot.com/2011/05/rendering-3d-anaglyph-in-opengl.html */
  /* The practical value of convergence depth is chosen on the basis of the shot being prepared and the type of effect (out of the screen or inside screen) used. Eye separation is typically kept at 1/30th of the convergence distance and objects closer than half the convergence distance are avoided in the scene. */

  void Camera::setUpStereo(float _convergence, float _eyeSep) {
    convergence = _convergence;
    eyeSep = _eyeSep;

    float top, bottom, leftL, rightL, leftR, rightR;

    top     = nearPlane * tan(radians(fovy)/2);
    bottom  = -top;

    float a = aspect * tan(radians(fovy)/2) * convergence;

    float b = a - eyeSep/2;
    float c = a + eyeSep/2;

    leftR   =  -c * nearPlane/convergence;
    rightR   =   b * nearPlane/convergence;

    leftL   =  -b * nearPlane/convergence;
    rightL   =   c * nearPlane/convergence;

    //rightProjection = Matrix4f::perspective(leftR, rightR, bottom, top, nearPlane, farPlane );
    //rightTranslate = Matrix4f::translate( -eyeSep/2, 0.0f, 0.0f );
    //leftProjection = Matrix4f::perspective(leftL, rightL, bottom, top, nearPlane, farPlane );
    //leftTranslate = Matrix4f::translate( eyeSep/2, 0.0f, 0.0f );
    rightProjection = glm::frustum(leftR, rightR, bottom, top, nearPlane, farPlane );
    rightTranslate = glm::translate(mat4(1.0), vec3(-eyeSep/2, 0.0f, 0.0f) );
    leftProjection = glm::frustum(leftL, rightL, bottom, top, nearPlane, farPlane );
    leftTranslate = glm::translate(mat4(1.0), vec3(eyeSep/2, 0.0f, 0.0f) );
  }    

  //Camera& Camera::translate(Vec3f dists) {
  Camera& Camera::translate(vec3 dists) {
    translateX(dists.x);
    translateY(dists.y);
    translateZ(dists.z);
    isTransformed = true;
    return *this;
  }

  Camera& Camera::translateX(float dist) {
    posVec += (rightVec * dist);
    isTransformed = true;
    return *this;
  }

  Camera& Camera::translateY(float dist) {
    posVec += (upVec * dist);
    isTransformed = true;
    return *this;
  }

  Camera& Camera::translateZ(float dist) {
    posVec += (viewVec * dist);
    isTransformed = true;
    return *this;
  }

  Camera& Camera::rotate(vec3 angles) {
    rotateX(angles.x);
    rotateY(angles.y);
    rotateZ(angles.z);
    isTransformed = true;
    return *this;
  }

  Camera& Camera::rotateX (float angle) {
    viewVec = ArbitraryRotate(viewVec, angle, rightVec);
    upVec = glm::cross(viewVec, rightVec);
    upVec *= -1;
    isTransformed = true;
    return *this;
  }

  Camera& Camera::rotateY (float angle) {
    viewVec = ArbitraryRotate(viewVec, angle, upVec);
    rightVec = glm::cross(viewVec, upVec);
    //  rightVec *= -1;
    isTransformed = true;
    return *this;
  }

  Camera& Camera::rotateZ (float angle) {
    rightVec = ArbitraryRotate(rightVec, angle, viewVec);
    upVec = glm::cross(viewVec, rightVec);
    upVec *= -1.0;
    isTransformed = true;
    return *this;
  }

  //via Paul Bourke
  vec3 Camera::ArbitraryRotate(vec3 p, float theta, vec3 r) {
    vec3 q = vec3(0.0,0.0,0.0);
    double costheta,sintheta;

    //p = p.normalize();
    //r = r.normalize();
    p = glm::normalize(vec3(p));
    r = glm::normalize(vec3(r));

    float rad = radians(theta);
    costheta = cos(rad);
    sintheta = sin(rad);

    q.x += (costheta + (1 - costheta) * r.x * r.x) * p.x;
    q.x += ((1 - costheta) * r.x * r.y - r.z * sintheta) * p.y;
    q.x += ((1 - costheta) * r.x * r.z + r.y * sintheta) * p.z;

    q.y += ((1 - costheta) * r.x * r.y + r.z * sintheta) * p.x;
    q.y += (costheta + (1 - costheta) * r.y * r.y) * p.y;
    q.y += ((1 - costheta) * r.y * r.z - r.x * sintheta) * p.z;

    q.z += ((1 - costheta) * r.x * r.z - r.y * sintheta) * p.x;
    q.z += ((1 - costheta) * r.y * r.z + r.x * sintheta) * p.y;
    q.z += (costheta + (1 - costheta) * r.z * r.z) * p.z;

    //q = q.normalize();
    q = glm::normalize(vec3(q));

    return(q);
  }


};

