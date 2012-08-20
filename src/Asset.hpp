#ifndef INCLUDE_AL_GRAPHICS_ASSET2_HPP
#define INCLUDE_AL_GRAPHICS_ASSET2_HPP

/*!
	Asset manages the loading and parsing of 3D asset files
	Asset wraps the AssImp library.
	
	A scene contains
		- array of meshes
		- array of materials
		- array of textures
		- also: array of animations, array of lights, array of cameras
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
	
	A material contains
		- array of properties
		- helper methods for retrieving textures
	
	A node contains 
		- name
		- a 4x4 matrix transform relative to its parent
		- a list of children
		- a number of meshes (indexing scene arrays)
	
	
*/

#include "MeshData.hpp" 

namespace al{

class Scene {
public:
	enum ImportPreset {
		FAST,
		QUALITY,
		MAX_QUALITY
	};
	
	struct Node {
		class Impl;
		
		Node();
		~Node();
	
		std::string name() const;
		Impl * mImpl;
	};
	
	struct Material {
		struct TextureProperty {
			bool useTexture;
			std::string texture;
			
			TextureProperty() : useTexture(false) {}
		};
		
		Material();
		
		std::string name;
		
		// standard OpenGL properties:
		int two_sided, wireframe;
		//Color diffuse, ambient, specular, emissive;
		float diffuse[4];
		 float	ambient[4];
		 float specular[4];
	        float	emissive[4];
		float shininess;
		
		// other properites:
		int shading_model, blend_func;
		float shininess_strength, opacity, reflectivity, refracti, bump_scaling;
		//Color transparent, reflective;
		 float transparent[4];
		 float reflective[4];
		TextureProperty diffusemap, ambientmap, specularmap, opacitymap, emissivemap, shininessmap, lightmap, normalmap, heightmap, displacementmap, reflectionmap; 
		std::string background;	
		
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
	
	/// return number of materials in scene
	unsigned int materials() const;
	/// read a material from the scene
	const Material& material(unsigned int i) const;
	
	/// return number of materials in scene
	unsigned int textures() const;
	
	/// return number of nodes in scene
	unsigned int nodes() const;
	/// read a node in the scene:
	Node& node(unsigned int i) const;
	
	/// get scene extents
	void getBounds(Vec3f& min, Vec3f& max) const;
	float getScaleVal() const;

	/// print out information about the Scene
	void dump() const;
	
	/// toggle verbose mode
	static void verbose(bool b);
	
protected:

	std::vector<Material> mMaterials;

	class Impl;
	Impl * mImpl;
	
	Scene(Impl * impl);
};

} // al::

#endif /* include guard */
