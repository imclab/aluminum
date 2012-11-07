#ifndef INCLUDE_ALU_MESHDATA_HPP
#define INCLUDE_ALU_MESHDATA_HPP


//#include <algorithm>
//#include <map>
//#include <string>
//#include <vector>

/*
#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_access.hpp>
#include <glm/gtc/type_ptr.hpp>
*/

#include "Includes.hpp"

namespace aluminum {

  using glm::to_string;
  using glm::ivec2;
  using glm::ivec4;
  using glm::vec3;
  using glm::vec4;
  using glm::mat4;

  using std::vector;

  /// Stores buffers related to rendering graphical objects

  /// A mesh is a collection of buffers storing vertices, colors, indices, etc.
  /// that define the geometry and coloring/shading of a graphical object.
  class MeshData {
    public:

      typedef vec3			Vertex;
      typedef vec3			Normal;
      typedef vec4			Color;
      typedef vec3			TexCoord;
      typedef unsigned int	        Index;

      typedef vector<Vertex>		Vertices;
      typedef vector<Normal>		Normals;
      typedef vector<Color>		Colors;
      typedef vector<TexCoord>	TexCoords;
      typedef vector<Index>		Indices;

      /*	
		MeshData(const MeshData& cpy) : 
		mVertices(cpy.mVertices),
		mNormals(cpy.mNormals),
		mColors(cpy.mColors),
		mTexCoords(cpy.mTexCoords),
		mIndices(cpy.mIndices),
		mPrimitive(cpy.mPrimitive)
		{}
		*/

      /// @param[out] min		minimum corner of bounding box
      /// @param[out] max		maximum corner of bounding box

      MeshData& reset();
	
      void getBounds(vec3& min, vec3& max) const;

      Vertex getCenter() const;

      void addMesh(MeshData& m2); //agf

      /// Scale all vertices to lie in [-1,1]
      void unitize(bool proportional=true);

      /// Scale all vertices
      MeshData& scale(float x, float y, float z);
      MeshData& scale(float s){ return scale(s,s,s); }

      //template <class T>
      //MeshData& scale(const Vec<3,T>& v){ return scale(v[0],v[1],v[2]); }
      //template <class T>
      MeshData& scale(const vec3& v){ return scale(v[0],v[1],v[2]); }
      //MeshData& scale(const vec3& v);

      /// Translate all vertices
      MeshData& translate(float x, float y, float z);

      //template <class T>
      //MeshData& translate(const Vec<3,T>& v){ return translate(v[0],v[1],v[2]); }
      //template <class T>
      MeshData& translate(const vec3& v) { return translate(v[0],v[1],v[2]); }

      /// Transform vertices by projective transform matrix

      /// @param[in] m		projective transform matrix
      /// @param[in] begin	beginning index of vertices
      /// @param[in] end		ending index of vertices, negative amount specify distance from one past last element
      //template <class T>
      //MeshData& transform(const Mat<4,T>& m, int begin=0, int end=-1);

      //MeshData& transform(const mat4& m, int begin=0, int end=-1);

      MeshData& transform(const mat4& m, int begin, int end);
      MeshData& transform(const mat4& m, int begin);
      MeshData& transform(const mat4& m);


      /// Invert direction of normals
      void invertNormals();

      const vector<Vertex>& vertices() const { return mVertices; }
      const vector<Normal>& normals() const { return mNormals; }
      const vector<Color>& colors() const { return mColors; }
      const vector<TexCoord>& texCoords() const { return mTexCoords; }
      const vector<Index>& indices() const { return mIndices; }

      void index(unsigned int i){ indices().push_back(i); }
      void index(const unsigned int* buf, int size){
	for(int i=0; i<size; ++i) {
	  index(buf[i]);
	}
      }

      void color(float r, float g, float b, float a=1){ color(Color(r,g,b,a)); }
      void color(const vec4& v) { color(v[0], v[1], v[2], v[3]); }

      void normal(float x, float y, float z=0){ normal(Normal(x,y,z)); }
      void normal(const Normal& v) { normals().push_back(v); }
      void normal(const vec3 *buf, int size){
	for(int i=0; i<size; ++i) normal(buf[i][0], buf[i][1], buf[i][2]);
      }

      void texCoord(float u, float v, float w){ texCoord(TexCoord(u,v,w)); }
      void texCoord(float u, float v){ texCoord(TexCoord(u,v,0.0)); }
      void texCoord(const TexCoord& v){ texCoords().push_back(v); }
      void texCoord(const vec3 *buf, int size){
	for(int i=0; i<size; ++i) texCoord(buf[i][0], buf[i][1], buf[i][2]);
      }

      void vertex(float x, float y, float z=0){ vertex(Vertex(x,y,z)); }
      void vertex(const Vertex& v){ vertices().push_back(v); }
      
      void vertex(const vec3 *buf, int size){
	for(int i=0; i<size; ++i) vertex(buf[i][0], buf[i][1], buf[i][2]);
      }


      /// Get number of faces (assumes triangles or quads)
      //	int numFaces() const { return mIndices.size() / ( ( mPrimitive == Graphics::TRIANGLES ) ? 3 : 4 ); }
      /// Get indices as triangles
      //	TriFace& indexAsTri(){ return (TriFace*) indices(); }
      /// Get indices as quads
      //	QuadFace& indexAsQuad(){ return (QuadFace*) indices(); }

      Vertices& vertices(){ return mVertices; }
      Normals& normals(){ return mNormals; }
      Colors& colors(){ return mColors; }
      TexCoords& texCoords(){ return mTexCoords; }
      Indices& indices(){ return mIndices; }

      //GLint id() {return vaoID;}
    protected:

      // Only populated (size>0) buffers will be used
      Vertices mVertices;
      Normals mNormals;
      Colors mColors;
      TexCoords mTexCoords;
      Indices mIndices;

      int mPrimitive;

      //GLint vaoID;
  };




} // al::

#endif
