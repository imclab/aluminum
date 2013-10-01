#ifndef INCLUDE_ALU_MESHBUFFER_HPP
#define INCLUDE_ALU_MESHBUFFER_HPP

#include "MeshData.hpp"
//#include "Includes.hpp"
#ifdef BUILD_IOS
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#endif

namespace aluminum{
  
  class MeshBuffer {
    
  public:
    
    MeshBuffer() {}
    
    //MeshBuffer& init(MeshData &_data, int p, int n, int tc, int c);
    //MeshBuffer& update(MeshData &_data, int p, int n, int tc, int c);
    MeshBuffer init(MeshData _data, int p, int n, int tc, int c);
    MeshBuffer update(MeshData _data, int p, int n, int tc, int c);
    MeshBuffer update(MeshData _data);
    
    virtual void draw();
    virtual void drawLines();
    virtual void drawTriangleStrip();
  protected:
    
    void checkAttributes(int p, int n, int tc, int c);
    template<class T> void initVBO(GLuint vboID, int loc, int size, T b);
    
    void initIBO();
    GLuint vao[1];
    GLuint vbo[4];
    GLuint ibo[4];
    
    MeshData data;
    
    bool useNormals = false;
    bool useTexCoords = false;
    bool useColors = false;
    bool useIndices = false;
    
    int pLoc = -1;
    int nLoc = -1;
    int tcLoc = -1;
    int cLoc = -1;
    
  };
  
  
} // al::

#endif
