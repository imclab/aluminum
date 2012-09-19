#ifndef INCLUDE_AL_FBO2_HPP
#define INCLUDE_AL_FBO2_HPP

#include <string>
#include "Includes.hpp"
#include "Texture.hpp"

namespace al{

//@class Texture;




class RBO {
  public:
    RBO();
    RBO(int width, int height, GLenum format); //format = GL_DEPTH_COMPONENT24, etc
    RBO& create();
    RBO& bind();
    RBO& unbind();
    GLint id();
    
    void destroy();

    GLuint rboID;
    GLenum internalformat;
    int width;
    int height;

    
};


class FBO {
  
public:

GLuint width;
GLuint height;

 //FBO(Texture t);
 FBO();
 FBO& create(); //handle the attaching manually...
 FBO& create(int w, int h); //create a default RGBA texture with a GL_DEPTH_COMPONENT24 rbo
 FBO& create(const Texture t);
 FBO& create(const Texture t, const RBO rb);
 FBO& attach(const Texture t);
 FBO& attach(const Texture t, const RBO rb);
 FBO& replace(const Texture t); //delete old, and attach new
 FBO& replace(const Texture t, const RBO rb); //delete old, and attach new
 
 FBO& bind(Texture t, RBO rbo);
 FBO& bind(Texture t);
 FBO& bind();
 FBO& unbind();

 void checkStatus();

 Texture texture;
 RBO rbo;

 GLuint fboID;

private:
 //FBO(); 
};

}

#endif

