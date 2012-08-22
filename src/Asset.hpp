#ifndef INCLUDE_AL_GRAPHICS_ASSET2_HPP
#define INCLUDE_AL_GRAPHICS_ASSET2_HPP

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


#include "assimp/Importer.hpp"
#include "assimp/scene.h"
#include "assimp/postprocess.h"
#include "assimp/cimport.h"
#include "assimp/types.h"
#include "assimp/matrix4x4.h"

#include "MeshData.hpp" 

namespace al{

class Scene {
public:
	enum ImportPreset {
		FAST,
		QUALITY,
		MAX_QUALITY
	};


	static Scene * import(const std::string& path, ImportPreset preset = MAX_QUALITY);
	~Scene();
	
	/// return number of meshes in scene
	unsigned int meshes() const;
	/// read a mesh from the Scene:
	void mesh(unsigned int i, MeshData& mesh) const;
	/// alternative read a mesh from the Scene:
	void meshAlt(unsigned int i, MeshData& mesh) const;	
	// read all meshes:
	void meshAll(MeshData& dst) const { for (unsigned i=0; i<meshes(); i++) mesh(i, dst); }
	/// get the material index for a given mesh:
	unsigned int meshMaterial(unsigned int i) const;
	/// get the name of a given mesh
	std::string meshName(unsigned int i) const;
	
	/// get scene extents
	void getBounds(Vec3f& min, Vec3f& max) const;
	float getScaleVal() const;

	/// print out information about the Scene
	void dump() const;
	
protected:

	const aiScene * scene;
	Scene(const aiScene * scene);
};

} // al::

#endif /* include guard */
