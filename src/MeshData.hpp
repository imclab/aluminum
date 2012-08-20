#ifndef INCLUDE_AL_GRAPHICS_MESHDATA_HPP
#define INCLUDE_AL_GRAPHICS_MESHDATA_HPP

#include "allocore/math/al_Vec.hpp"
#include "allocore/math/al_Matrix4.hpp"
#include "allocore/types/al_Buffer.hpp"

namespace al{

/// Stores buffers related to rendering graphical objects

/// A mesh is a collection of buffers storing vertices, colors, indices, etc.
/// that define the geometry and coloring/shading of a graphical object.
class MeshData {
public:

	typedef Vec3f			Vertex;
	typedef Vec3f			Normal;
	typedef Vec4f			Color;
	typedef Vec3f			TexCoord;
	typedef unsigned int	        Index;
	typedef Vec3i			TriFace;
	typedef Vec4i			QuadFace;

	typedef Buffer<Vertex>		Vertices;
	typedef Buffer<Normal>		Normals;
	typedef Buffer<Color>		Colors;
	typedef Buffer<TexCoord>	TexCoords;
	typedef Buffer<Index>		Indices;
	

	/// @param[in] primitive	renderer-dependent primitive number
	MeshData(int primitive=0): mPrimitive(primitive){}

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

	/// Get corners of bounding box of vertices
	
	/// @param[out] min		minimum corner of bounding box
	/// @param[out] max		maximum corner of bounding box
	void getBounds(Vec3f& min, Vec3f& max) const;

	/// Get center of vertices
	Vertex getCenter() const;


	// destructive edits to internal vertices:

	/// Convert indices (if any) to flat vertex buffers
	void decompress();

	/// Extend buffers to match number of vertices
	
	/// This will resize all populated buffers to match the size of the vertex
	/// buffer. Buffers are extended by copying their last element.
	void equalizeBuffers();
	
	/// Append buffers from another mesh:
	void merge(const MeshData& src);

	/// Reset all buffers
	MeshData& reset();

	/// Scale all vertices to lie in [-1,1]
	void unitize(bool proportional=true);

	/// Scale all vertices
	MeshData& scale(float x, float y, float z);
	MeshData& scale(float s){ return scale(s,s,s); }

	template <class T>
	MeshData& scale(const Vec<3,T>& v){ return scale(v[0],v[1],v[2]); }

	/// Translate all vertices
	MeshData& translate(float x, float y, float z);
	
	template <class T>
	MeshData& translate(const Vec<3,T>& v){ return translate(v[0],v[1],v[2]); }
	
	/// Transform vertices by projective transform matrix
	
	/// @param[in] m		projective transform matrix
	/// @param[in] begin	beginning index of vertices
	/// @param[in] end		ending index of vertices, negative amount specify distance from one past last element
	template <class T>
	MeshData& transform(const Mat<4,T>& m, int begin=0, int end=-1);

	/// Generates indices for a set of vertices
	void compress();

	/// Generates normals for a set of vertices
	
	/// This method will generate a normal for each vertex in the buffer
	/// assuming the drawing primitive is a triangle. Face normals are generated
	/// if no indices are present, and averaged vertex normals are generated
	/// if indices are present. This will replace any normals currently in use.
	///
	/// @param[in] normalize	whether to normalize normals
	void generateNormals(bool normalize=true, bool equalWeightPerFace=false);
	
	/// Invert direction of normals
	void invertNormals();
	
	/// Creates a mesh filled with lines for each normal of the source
	
	/// @param[out] mesh		normal lines
	/// @param[in]  length		length of normals
	/// @param[in]  perFace		whether normals line should be generated per 
	///							face rather than per vertex
	void createNormalsMesh(MeshData& mesh, float length=0.1, bool perFace=false);

	/// Ribbonize curve
	
	/// This creates a two-dimensional ribbon from a one-dimensional space curve.
	/// The result is to be rendered with a triangle strip.
	/// @param[in] width			Width of ribbon
	/// @param[in] faceBinormal		If true, surface faces binormal vector of curve.
	///								If false, surface faces normal vector of curve.
	void ribbonize(float width=0.04, bool faceBinormal=false){
		ribbonize(&width, 0, faceBinormal);
	}

	/// Ribbonize curve

	/// This creates a two-dimensional ribbon from a one-dimensional space curve.
	/// The result is to be rendered with a triangle strip.
	/// @param[in] widths			Array specifying width of ribbon at each point along curve
	/// @param[in] widthsStride		Stride factor of width array
	/// @param[in] faceBinormal		If true, surface faces binormal vector of curve.
	///								If false, surface faces normal vector of curve.	
	void ribbonize(float * widths, int widthsStride=1, bool faceBinormal=false);


	int primitive() const { return mPrimitive; }
	const Buffer<Vertex>& vertices() const { return mVertices; }
	const Buffer<Normal>& normals() const { return mNormals; }
	const Buffer<Color>& colors() const { return mColors; }
	const Buffer<TexCoord>& texCoords() const { return mTexCoords; }
	const Buffer<Index>& indices() const { return mIndices; }


	/// Set geometric primitive
	MeshData& primitive(int prim){ mPrimitive=prim; return *this; }
	
	/// Repeat last vertex element(s)
	MeshData& repeatLast();

	/// Append index to index buffer
	void index(unsigned int i){ indices().append(i); }

	/// Append indices to index buffer	
	template <class Tindex>
	void index(const Tindex * buf, int size, Tindex indexOffset=0){
		for(int i=0; i<size; ++i) index((Index)(buf[i] + indexOffset)); }


	/// Append color to color buffer
	void color(const Color& v) { colors().append(v); }

	/// Append color to color buffer
	void color(float r, float g, float b, float a=1){ color(Color(r,g,b,a)); }
	
	/// Append color to color buffer
	template <class T>
	void color(const Vec<4,T>& v) { color(v[0], v[1], v[2], v[3]); }

	/// Append normal to normal buffer
	void normal(float x, float y, float z=0){ normal(Normal(x,y,z)); }
	
	/// Append normal to normal buffer
	void normal(const Normal& v) { normals().append(v); }


	/// Append texture coordinate to 3D texture coordinate buffer
	void texCoord(float u, float v, float w){ texCoord(TexCoord(u,v,w)); }
	
	/// Append texture coordinate to 3D texture coordinate buffer
	void texCoord(float u, float v){ texCoord(TexCoord(u,v,0.0)); }
	
	/// Append texture coordinate to 3D texture coordinate buffer
	void texCoord(const TexCoord& v){ texCoords().append(v); }


	/// Append vertex to vertex buffer
	void vertex(float x, float y, float z=0){ vertex(Vertex(x,y,z)); }
	
	/// Append vertex to vertex buffer
	void vertex(const Vertex& v){ vertices().append(v); }

	/// Append vertices to vertex buffer
	template <class T>
	void vertex(const T * buf, int size){
		for(int i=0; i<size; ++i) vertex(buf[3*i+0], buf[3*i+1], buf[3*i+2]);
	}

	/// Append vertices to vertex buffer
	template <class T>
	void vertex(const Vec<3,T> * buf, int size){
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




template <class T>
MeshData& MeshData::transform(const Mat<4,T>& m, int begin, int end){
	if(end<0) end += vertices().size()+1; // negative index wraps to end of array
	for(int i=begin; i<end; ++i){
		Vertex& v = vertices()[i];
		v.set(m * Vec<4,T>(v, 1));
	}
	return *this;
}

} // al::

#endif
