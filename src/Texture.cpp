#include <cstdio>

#include <FreeImage.h>
#include "Texture.hpp"


namespace al{

  Texture& Texture::loadTextureData2D(Texture& texture, std::string file) {
    const char *filename = file.c_str();
    FREE_IMAGE_FORMAT format;
    FIBITMAP *dib(0);
    BYTE *bits(0);
    int width(0), height(0);
    FREE_IMAGE_COLOR_TYPE type;
    GLenum pixFormat;

    format = FreeImage_GetFileType(filename);
    dib = FreeImage_Load(format, filename);
    bits = FreeImage_GetBits(dib);
    width = FreeImage_GetWidth(dib);
    height = FreeImage_GetHeight(dib);
    type = FreeImage_GetColorType(dib);
  
    FreeImage_Unload(dib);

    switch ( type )
    {
      case FIC_RGB:
	pixFormat = GL_RGB;
	break;
      case FIC_RGBALPHA:
	pixFormat = GL_RGBA;
	break;
      default:
	printf("format not handled!\n");
	break;
    }

    texture.kind(GL_TEXTURE_2D);

    texture.data = bits;
    texture.width = width;
    texture.height = height;
    texture.internalFormat = GL_RGBA;
    texture.pixelFormat = pixFormat;
    texture.type = GL_UNSIGNED_BYTE;
    texture.wrapMode(GL_REPEAT); //GL_CLAMP_TO_EDGE;
    texture.minFilter(GL_LINEAR);
    texture.maxFilter(GL_LINEAR);

    return texture;
    //return Texture(bits, width, height, GL_RGBA, pixFormat, GL_UNSIGNED_BYTE); 
  }


  //empty rgba texture...
  Texture::Texture(int _w, int _h, GLint _internalFormat, GLenum _pixelFormat, GLenum _type) {

    //printf("in Texture::Texture(GLubyte* _data, int _w, int _h, GLenum _format, GLenum _type)\n");

    width = _w;
    height = _h;
    internalFormat = _internalFormat; //GL_RGBA, GL_RED, etc  (the format of the openGL pixel buffer)
    pixelFormat = _pixelFormat; //GL_RGB, GL_RGBA, GL_LUMINANCE, etc  (the format of the image data)
    type = _type; //GL_UNSIGNED_BYTE, GL_FLOAT, etc
    kind(GL_TEXTURE_2D);

    wrapMode(GL_REPEAT); //GL_CLAMP_TO_EDGE;
    minFilter(GL_LINEAR);
    maxFilter(GL_LINEAR);

    data = (GLubyte*) malloc (_w*_h*4*sizeof(GLubyte));

    create2D();
  }


  Texture::Texture(GLubyte* _data, int _w, int _h, GLint _internalFormat, GLenum _pixelFormat, GLenum _type) {

    //printf("in Texture::Texture(GLubyte* _data, int _w, int _h, GLenum _format, GLenum _type)\n");

    data = _data;
    width = _w;
    height = _h;
    internalFormat = _internalFormat; //GL_RGBA, GL_RED, etc  (the format of the openGL pixel buffer)
    pixelFormat = _pixelFormat; //GL_RGB, GL_RGBA, GL_LUMINANCE, etc  (the format of the image data)
    type = _type; //GL_UNSIGNED_BYTE, GL_FLOAT, etc
    kind(GL_TEXTURE_2D);

    wrapMode(GL_REPEAT); //GL_CLAMP_TO_EDGE;
    minFilter(GL_LINEAR);
    maxFilter(GL_LINEAR);

    create2D();
  }

  void Texture::dump() {
    printf("texture id = %d\n", texID);
    printf("\tkind = %d\n", kind());
    printf("\tminFilter = %d, maxFilter = %d\n", minFilter(), maxFilter());
    printf("\twrapMode = %d\n", wrapMode());
  }

  void Texture::create2D() {
    glEnable(kind());
    glGenTextures(1, &texID);

    glBindTexture(kind(), texID); {

      glTexParameteri(kind(), GL_TEXTURE_MIN_FILTER, minFilter()); 
      glTexParameteri(kind(), GL_TEXTURE_MAG_FILTER, maxFilter());

      glTexParameteri(kind(), GL_TEXTURE_WRAP_S, wrapMode());
      glTexParameteri(kind(), GL_TEXTURE_WRAP_T, wrapMode());

      glTexImage2D(kind(), 0, internalFormat, width, height, 0, pixelFormat, type, data);

    } glBindTexture(kind(), 0);

    dump();
  }

  Texture& Texture::bind (GLenum textureUnit) {
	glActiveTexture(textureUnit); //i.e GL_TEXTURE0, etc
	glBindTexture(kind(), id());
	return *this;
  }

  Texture& Texture::unbind (GLenum textureUnit) {
	glActiveTexture(textureUnit); //i.e GL_TEXTURE0, etc
	glBindTexture(kind(), 0);
	return *this;
  }

  Texture& Texture::bind () {
	glBindTexture(kind(), id());
	return *this;
  }

  Texture& Texture::unbind () {
	glBindTexture(kind(), 0);
	return *this;
  }




  Texture& Texture::update() {

    glBindTexture(kind(), texID); {

      glTexParameteri(kind(), GL_TEXTURE_MIN_FILTER, minFilter()); 
      glTexParameteri(kind(), GL_TEXTURE_MAG_FILTER, maxFilter());

      glTexParameteri(kind(), GL_TEXTURE_WRAP_S, wrapMode());
      glTexParameteri(kind(), GL_TEXTURE_WRAP_T, wrapMode());

      glTexImage2D(kind(), 0, internalFormat, width, height, 0, pixelFormat, type, data);

    } glBindTexture(kind(), 0);

    return *this;
  }


  GLuint Texture::id() {
    return texID;
  }

  GLenum Texture::kind() {
    return mKind;
  }

  GLint Texture::wrapMode() {
    return mWrapMode;
  }
  GLint Texture::minFilter() {
    return mMinFilter;
  }

  GLint Texture::maxFilter() {
    return mMaxFilter;
  }

	
  Texture& Texture::kind(GLenum _kind) { mKind = _kind; return *this; }
  Texture& Texture::wrapMode(GLint _wrapMode) { mWrapMode = _wrapMode; return *this;}
  Texture& Texture::minFilter(GLint _minFilter) {mMinFilter = _minFilter; return *this;}
  Texture& Texture::maxFilter(GLint _maxFilter) {mMaxFilter = _maxFilter; return *this;}



} // al::
