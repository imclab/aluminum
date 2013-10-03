


#ifndef INCLUDE_ALU_MESHUTILS_HPP
#define INCLUDE_ALU_MESHUTILS_HPP

/*!
	Asset manages the loading and parsing of 3D asset files
	Asset wraps the AssImp library.
	
	A scene contains
		- array of meshes
		- tree of nodes, starting from a root node
		
	A mesh contains
		- name
		- material (index into scene)
		- array of vertices
		- array of normals
		- array of colors
		- array of texcoords
		- arrays of tangents, bitangents
		- bones

      	A node contains 
		- name
		- a 4x4 matrix transform relative to its parent
		- a list of children
		- a number of meshes (indexing scene arrays)
*/


#include "MeshUtils.hpp" 
#include "MeshBuffer.hpp" 
#include "MeshData.hpp" 


#include "assimp/Importer.hpp"
#include "assimp/scene.h"
#include "assimp/postprocess.h"
#include "assimp/cimport.h"
#include "assimp/types.h"
#include "assimp/matrix4x4.h"

//#include <vector>


/*
#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_access.hpp>
#include <glm/gtc/type_ptr.hpp>
*/

namespace aluminum {

  
using glm::to_string;
using glm::vec2;
using glm::vec3;
using glm::vec4;
using glm::mat4;


  class MeshUtils {

    public:

      static MeshData makeCube(float s);

      static MeshData makeRectangle(vec3 v0, vec3 v1, vec3 v2, vec3 v3, vec3 t0, vec3 t1, vec3 t2, vec3 t3);

      static MeshData makeRectangle(vec3 vLL, vec3 vUR, vec3 tcLL, vec3 tcUR);
          

      static MeshData makeRectangle(vec2 vLL, vec2 vUR, vec2 tcLL, vec2 tcUR);
      static MeshData makeRectangle(float _w, float _h);
      static MeshData makeRectangle(float _w, float _h, bool flipHoriz, bool flipVer);
      static MeshData makeClipRectangle();
      
      static MeshData makeClipRectangle(bool flipHoriz, bool flipVert);
   
      static MeshData makeRectangle();

     //static MeshData& makeRectangle3( MeshData &m, vec3 v0, vec3 v1, vec3 v2, vec3 v3, vec3 t0, vec3 t1, vec3 t2, vec3 t3);
     //static MeshData& makeRectangle3( MeshData &m, vec2 vLL, vec2 vUR, vec2 tcLL, vec2 tcUR);


#ifndef BUILD_IOS


      class Scene {
	public:

	  Scene(const aiScene * scene);
	  ~Scene();

	  const aiScene * scene;

	  /// return number of meshes in scene
	  unsigned int meshes() const;

	  /// read a mesh from the Scene:
	  void mesh(unsigned int i, MeshData& mesh) const;

	  /// alternative read a mesh from the Scene: (creates indices)
	  void meshWithIndices(unsigned int i, MeshData& mesh) const;	

	  /// get scene extents
	  void getBounds(vec3& min, vec3& max) const;
	  float getScaleVal() const;
	  void getCenter(vec3& center) const;
	  /// print out information about the Scene
	  void dump() const;

      };


      static Scene* importScene(const std::string& path);

      static std::vector<MeshData> loadMeshDatas(const std::string& path);
      static MeshData loadMeshData(const std::string& path);

      static MeshBuffer loadMesh(const std::string& path, int pL, int nL, int tL, int cL);
      
#endif      

  };

}

#endif
