#ifndef INCLUDE_AL_FBO2_HPP
#define INCLUDE_AL_FBO2_HPP

#include <string>
#include <OpenGL/gl3.h>
#include <OpenGL/gl3ext.h>
#include "Texture.hpp"

namespace al{

//@class Texture;


class FBO {
  
public:

GLuint width;
GLuint height;

 //FBO(Texture t);
 FBO(); //if you use this version you *must* call setTargetTexture manually!
 FBO& create();
 FBO& attach(const Texture t);
 


 FBO& bind(Texture t);
 FBO& bind();
 FBO& unbind();

 Texture texture;
 GLuint fboID;

private:
 //FBO(); 
};
}
#endif

