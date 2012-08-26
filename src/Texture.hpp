#ifndef INCLUDE_AL_TEXTURE2_HPP
#define INCLUDE_AL_TEXTURE2_HPP

#include <string>
#include "Includes.hpp"

namespace al{

  class Texture {

    public:

      Texture() {}
      static Texture& loadTextureData2D(Texture &texture, std::string file);

      Texture(int w, int h, GLint _internalFormat, GLenum _format, GLenum _type);
      Texture(GLubyte* data, int w, int h, GLint _internalFormat, GLenum _format, GLenum _type);
      void create2D();
      Texture& update() ;

Texture& bind (GLenum textureUnit);
Texture& unbind (GLenum textureUnit);
Texture& bind ();
Texture& unbind ();

      GLuint id();

      GLenum kind();
      GLint wrapMode();
      GLint minFilter();
      GLint maxFilter();
      Texture& kind(GLenum _kind);
      Texture& wrapMode(GLint _wrapMode);
      Texture& minFilter(GLint _minFilter);
      Texture& maxFilter(GLint _maxFilter);

      void dump();

       int width;
      int height;
      int depth; //only for GL_TEXTURE_3D

    protected:

      GLuint texID;

      GLubyte* data;
      GLenum mKind; //GL_TEXTURE_2D, GL_TEXTURE_3D, or GL_TEXTURE_CUBE_MAP 
      GLint internalFormat; //GL_RGBA, GL_R3_G3_B2, etc
      GLenum pixelFormat; //e.g. GL_RGBA, GL_BGRA
      GLenum type; //e.g. GL_UNSIGNED_BYTE, GL_FLOAT
     
      GLint mWrapMode;
      GLint mMinFilter;
      GLint mMaxFilter;
      //bool isBound;

  };


} // al::

#endif
