#include <cstdio>
#include <iostream>
#include <sstream>
#include "Camera.hpp"

namespace al{

#define radians(x) (x * M_PI / 180.0f)
#define degrees(x) (180.0 * x / M_PI)

  Camera::Camera() { };

  //Perspective Camera
  Camera::Camera(float _fovy, float _aspect, float _nearPlane, float _farPlane) {
    resetVectors();
    perspective(_fovy, _aspect, _nearPlane, _farPlane);
  }

  Camera& Camera::resetVectors() {
    posVec = Vec3f(0.0, 0.0, 0.0);
    viewVec = Vec3f(0.0, 0.0f, -1.0);
    rightVec = Vec3f(1.0, 0.0, 0.0);
    upVec = Vec3f(0.0, 1.0, 0.0);  
    isTransformed = true;
    return *this;
  }

  Camera& Camera::perspective(float _fovy, float _aspect, float _nearPlane, float _farPlane) {
    fovy = _fovy;
    nearPlane = _nearPlane;
    farPlane = _farPlane;
    aspect = _aspect;
    projection = Matrix4f::perspective(fovy, aspect, nearPlane, farPlane);

    isTransformed = true;
    return *this;
  }

  //just temp for debugging
  void Camera::printMatrix(Matrix4f m) {

    printf("%+.2f ", m[0]);
    printf("%+.2f ", m[4]);
    printf("%+.2f ", m[8]);
    printf("%+.2f ", m[12]);
    printf("%+.2f ", m[1]);
    printf("%+.2f ", m[5]);
    printf("%+.2f ", m[9]);
    printf("%+.2f ", m[13]);
    printf("%+.2f ", m[2]);
    printf("%+.2f ", m[6]);
    printf("%+.2f ", m[10]);
    printf("%+.2f ", m[14]);
    printf("%+.2f ", m[3]);
    printf("%+.2f ", m[7]);
    printf("%+.2f ", m[11]);
    printf("%+.2f ", m[15]);

    // for (int i = 0; i < 16; i++) {
    //   printf("%+.2f ", m[i]);
    // }
    printf("\n");
    /*
       printf("{ %f, %f, %f, %f,\n", m[0], m[4], m[8], m[12]);
       printf("%f, %f, %f, %f,\n", m[1], m[5], m[9], m[13]);
       printf("%f, %f, %f, %f,\n", m[2], m[6], m[10], m[14]);
       printf("%f, %f, %f, %f } \n", m[3], m[7], m[11], m[15]);
       */
  }


  Matrix4f Camera::reverseRotationMatrix(Matrix4f m) {
    /*
    Vec3f vv = ArbitraryRotate(viewVec, 180.0, upVec);
    Vec3f rv = cross(vv, upVec);
 
    return Matrix4f(
	rv.x, rv.y, rv.z, 0,
	upVec.x, upVec.y, upVec.z, 0, 
	vv.x, vv.y, vv.z, 0,
	0,0,0,1);
    */
    return Matrix4f( 
    	-m[0], -m[4], -m[8], 0,
	m[1], m[5], m[9], 0,
	-m[2], -m[6], -m[10], 1,
        0,0,0,1	); 

  }


  Camera& Camera::transform() {
    Matrix4f rM = Matrix4f(
	rightVec.x, rightVec.y, rightVec.z, 0,
	upVec.x, upVec.y, upVec.z, 0, 
	viewVec.x, viewVec.y, viewVec.z, 0,
	0,0,0,1);

    Matrix4f tM = Matrix4f::translate( posVec.x, posVec.y, posVec.z ); 

    view = rM * tM;
    backView = reverseRotationMatrix(rM) * tM;
    
    //printMatrix(rM);
    //printMatrix(brM);
    //printf("\n");
    isTransformed = false;

    return *this;
  }

  Camera& Camera::translate(Vec3f dists) {
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

  Camera& Camera::rotate(Vec3f angles) {
    rotateX(angles.x);
    rotateY(angles.y);
    rotateZ(angles.z);
    isTransformed = true;
    return *this;
  }

  Camera& Camera::rotateX (float angle) {
    viewVec = ArbitraryRotate(viewVec, angle, rightVec);
    upVec = cross(viewVec, rightVec);
    upVec *= -1;
    isTransformed = true;
    return *this;
  }

  Camera& Camera::rotateY (float angle) {
    viewVec = ArbitraryRotate(viewVec, angle, upVec);
    rightVec = cross(viewVec, upVec);
  //  rightVec *= -1;
    isTransformed = true;
    return *this;
  }

  Camera& Camera::rotateZ (float angle) {
    rightVec = ArbitraryRotate(rightVec, angle, viewVec);
    upVec = cross(viewVec, rightVec);
    upVec *= -1.0;
    isTransformed = true;
    return *this;
  }

  //via Paul Bourke
  Vec3f Camera::ArbitraryRotate(Vec3f p, float theta, Vec3f r) {
    Vec3f q = Vec3f(0.0,0.0,0.0);
    double costheta,sintheta;

    p = p.normalize();
    r = r.normalize();

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

    q = q.normalize();

    return(q);
  }


};

