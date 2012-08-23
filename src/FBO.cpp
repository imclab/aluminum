#include <cstdio>
#include <iostream>
#include <sstream>
#include "FBO.hpp"

namespace al{


  
///////////////////////////////////////////////////////////////////////////////
// convert OpenGL internal format enum to string
///////////////////////////////////////////////////////////////////////////////
std::string convertInternalFormatToString(GLenum format)
{
    std::string formatName;

    switch(format)
    {
    case GL_STENCIL_INDEX:
        formatName = "GL_STENCIL_INDEX";
        break;
    case GL_DEPTH_COMPONENT:
        formatName = "GL_DEPTH_COMPONENT";
        break;
    case GL_DEPTH_STENCIL:
        formatName = "GL_DEPTH_STENCIL";
        break;
    case GL_ALPHA:
        formatName = "GL_ALPHA";
        break;
    case GL_RGB:
        formatName = "GL_RGB";
        break;
    case GL_RGBA:
        formatName = "GL_RGBA";
        break;
    case GL_R3_G3_B2:
        formatName = "GL_R3_G3_B2";
        break;
    case GL_RGB4:
        formatName = "GL_RGB4";
        break;
    case GL_RGB5:
        formatName = "GL_RGB4";
        break;
    case GL_RGB8:
        formatName = "GL_RGB8";
        break;
    case GL_RGB10:
        formatName = "GL_RGB10";
        break;
    case GL_RGB12:
        formatName = "GL_RGB12";
        break;
    case GL_RGB16:
        formatName = "GL_RGB16";
        break;
    case GL_RGBA2:
        formatName = "GL_RGBA2";
        break;
    case GL_RGBA4:
        formatName = "GL_RGBA4";
        break;
    case GL_RGB5_A1:
        formatName = "GL_RGB5_A1";
        break;
    case GL_RGBA8:
        formatName = "GL_RGBA8";
        break;
    case GL_RGB10_A2:
        formatName = "GL_RGB10_A2";
        break;
    case GL_RGBA12:
        formatName = "GL_RGBA12";
        break;
    case GL_RGBA16:
        formatName = "GL_RGBA16";
        break;
    default:
        formatName = "Unknown Format";
    }
    return formatName;
}


///////////////////////////////////////////////////////////////////////////////
// return texture parameters as string using glGetTexLevelParameteriv()
///////////////////////////////////////////////////////////////////////////////
std::string getTextureParameters(GLuint id)
{
    if(glIsTexture(id) == GL_FALSE)
        return "Not texture object";

    int width, height, format;
    std::string formatName;
    glBindTexture(GL_TEXTURE_2D, id);
    glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, &width);            // get texture width
    glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, &height);          // get texture height
    glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_INTERNAL_FORMAT, &format); // get texture internal format
    glBindTexture(GL_TEXTURE_2D, 0);

    formatName = convertInternalFormatToString(format);

    std::stringstream ss;
    ss << width << "x" << height << ", " << formatName << "(" << format << ")";

    return ss.str();
}



///////////////////////////////////////////////////////////////////////////////
// return renderbuffer parameters as string using glGetRenderbufferParameteriv
///////////////////////////////////////////////////////////////////////////////
std::string getRenderbufferParameters(GLuint id)
{
    if(glIsRenderbuffer(id) == GL_FALSE)
        return "Not Renderbuffer object";

    int width, height, format;
    std::string formatName;
    glBindRenderbuffer(GL_RENDERBUFFER, id);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);    // get renderbuffer width
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);  // get renderbuffer height
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_INTERNAL_FORMAT, &format); // get renderbuffer internal format
    glBindRenderbuffer(GL_RENDERBUFFER, 0);

    formatName = convertInternalFormatToString(format);

    std::stringstream ss;
    ss << width << "x" << height << ", " << formatName << "(" << format << ")";
    return ss.str();
}


  

void printFramebufferInfo()
{
    std::cout << "\n===== FBO STATUS =====\n";

    // print max # of colorbuffers supported by FBO
    int colorBufferCount = 0;
    glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, &colorBufferCount);
    std::cout << "Max Number of Color Buffer Attachment Points: " << colorBufferCount << std::endl;

    int objectType;
    int objectId;

    // print info of the colorbuffer attachable image
    for(int i = 0; i < colorBufferCount; ++i)
    {
        glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER,
                                              GL_COLOR_ATTACHMENT0+i,
                                              GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE,
                                              &objectType);
        if(objectType != GL_NONE)
        {
            glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER,
                                                  GL_COLOR_ATTACHMENT0+i,
                                                  GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
                                                  &objectId);

            std::string formatName;

            std::cout << "Color Attachment " << i << ": ";
            if(objectType == GL_TEXTURE)
            {
                std::cout << "GL_TEXTURE, " << getTextureParameters(objectId) << std::endl;
            }
            else if(objectType == GL_RENDERBUFFER)
            {
                std::cout << "GL_RENDERBUFFER, " << getRenderbufferParameters(objectId) << std::endl;
            }
        }
    }

    // print info of the depthbuffer attachable image
    glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER,
                                          GL_DEPTH_ATTACHMENT,
                                          GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE,
                                          &objectType);
    if(objectType != GL_NONE)
    {
        glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER,
                                              GL_DEPTH_ATTACHMENT,
                                              GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
                                              &objectId);

        std::cout << "Depth Attachment: ";
        switch(objectType)
        {
        case GL_TEXTURE:
            std::cout << "GL_TEXTURE, " << getTextureParameters(objectId) << std::endl;
            break;
        case GL_RENDERBUFFER:
            std::cout << "GL_RENDERBUFFER, " << getRenderbufferParameters(objectId) << std::endl;
            break;
        }
    }

    // print info of the stencilbuffer attachable image
    glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER,
                                          GL_STENCIL_ATTACHMENT,
                                          GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE,
                                          &objectType);
    if(objectType != GL_NONE)
    {
        glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER,
                                              GL_STENCIL_ATTACHMENT,
                                              GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
                                              &objectId);

        std::cout << "Stencil Attachment: ";
        switch(objectType)
        {
        case GL_TEXTURE:
            std::cout << "GL_TEXTURE, " << getTextureParameters(objectId) << std::endl;
            break;
        case GL_RENDERBUFFER:
            std::cout << "GL_RENDERBUFFER, " << getRenderbufferParameters(objectId) << std::endl;
            break;
        }
    }

    std::cout << std::endl;
}



  FBO::FBO() {} 
/*
FBO::FBO(Texture& t) : texture(t) {
  //texture = NULL;
  //glGenFramebuffers(1, &fboID);
}
*/

FBO& FBO::create() {
  
  glGenFramebuffers(1, &fboID);
  //SetTargetTexture(t);
  return *this;
}

FBO& FBO::attach(Texture t) {

  width = t.width;
  height = t.height;

  texture = t;


  glBindFramebuffer(GL_FRAMEBUFFER, fboID);
  t.bind(); //is this necessary?


  GLuint rboId;
  glGenRenderbuffers(1, &rboId);


  //glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, t.id(), 0);
  glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, t.id(), 0);

  glBindRenderbuffer(GL_RENDERBUFFER, rboId);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24,
      width, height);

  glFramebufferRenderbuffer(GL_DRAW_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
      GL_RENDERBUFFER, rboId);

  glBindRenderbuffer(GL_RENDERBUFFER, 0);




  /*
  // testing adding a depth buffer to the fbo
  GLuint depthbuffer;
  glGenRenderbuffers(1, &depthbuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, depthbuffer);

  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height); 
  //this for depth test too  
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthbuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, 0);

  //  //end testing adding depth buffer to fbo
  */

  printFramebufferInfo();

  if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    printf("in FBO : ERROR!!!!: Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    exit(0);
  }

  glBindFramebuffer(GL_FRAMEBUFFER, 0);

  // glBindFramebuffer(GL_FRAMEBUFFER, defaultFBO); on IOS / EGL there is always a default framebuffer!
  //  glBindFramebuffer(GL_FRAMEBUFFER, 1); //default
  return *this;
}

//use this one if you are changing the fbo texture..
FBO& FBO::bind(Texture t) {
  attach(t);
  glViewport(0,0, width, height); //w & h MUST match the texture size
  return *this;
}

//otherwise use the one that was already bound to this fbo...
FBO& FBO::bind() {
  //printf("binding to fbo id = %d\n", fboID);
  // printf("fbo w/h = %d/%d\n", width, height);
  // printf("fbo texture w/h = %d/%d\n", texture.width, texture.height);
  glBindFramebuffer(GL_FRAMEBUFFER, fboID);
  glViewport(0,0, width, height); //w & h MUST match the texture size
  return *this;
}

FBO& FBO::unbind() {
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
  return *this;
}

};

