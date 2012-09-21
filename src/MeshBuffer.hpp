#ifndef INCLUDE_AL_MESHBUFFER_HPP
#define INCLUDE_AL_MESHBUFFER_HPP


//#include "allocore/math/al_Vec.hpp"
//#include "allocore/math/al_Matrix4.hpp"
//#include "allocore/types/al_Buffer.hpp"
#include "MeshData.hpp"

#include "Includes.hpp"


namespace al{

  class MeshBuffer {
  
    public:

      MeshBuffer() {}

      MeshBuffer& init(MeshData _data, int p, int n, int tc, int c);
      MeshBuffer& update(MeshData _data, int p, int n, int tc, int c);

      virtual void draw();

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

  };


} // al::

#endif
