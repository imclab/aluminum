#include "MeshUtils.hpp"
//#include <map>
//#include <iostream>
//#include "MeshBuffer.hpp" 

namespace aluminum {

  using std::cout;
  using glm::to_string;

  //will merge multiple meshes
  MeshBuffer MeshUtils::loadMesh(const std::string& path, int pL, int nL, int tL, int cL) {

    Scene* s = MeshUtils::importScene(path);

    MeshData modelMesh;

    for (unsigned int i = 0; i < s->meshes(); i++) {
      MeshData tmp;
      s->meshWithIndices(i, tmp);
      
      mat4 t = mat4();
      //t = glm::translate(t, vec3(0,-13.0,0));
      t = glm::scale(t, vec3(s->getScaleVal()));
      t = glm::translate(t, -vec3(1.888721, 28.287216, 5.450432));
       tmp.transform( t );
      //tmp.transform( glm::scale(mat4(), vec3(s->getScaleVal())) );
      modelMesh.addMesh(tmp); //merge this mesh into single mesh
    }

    return MeshBuffer().init(modelMesh, pL, nL, tL, cL);

  }


  //will merge multiple meshes
  MeshData MeshUtils::loadMeshData(const std::string& path) {

    Scene* s = MeshUtils::importScene(path);

    MeshData modelMesh;

    for (unsigned int i = 0; i < s->meshes(); i++) {
      MeshData tmp;
      s->meshWithIndices(i, tmp);
      tmp.transform( glm::scale(mat4(), vec3(s->getScaleVal())) );
      modelMesh.addMesh(tmp); //merge this mesh into single mesh
    }

    return modelMesh;
  }


  //will not merge multiple meshes

  std::vector<MeshData> MeshUtils :: loadMeshDatas(const std::string& path) {

    vector<MeshData> md;

    Scene* s = MeshUtils::importScene(path);

    for (int i = s->meshes()-1; i >= 0; i--) {
      MeshData tmp;
      s->meshWithIndices(i, tmp);
      tmp.transform( glm::scale(mat4(), vec3(s->getScaleVal())) );
      //modelMesh.addMesh(tmp); //merge this mesh into single mesh
      md.push_back(tmp);
    }

    return md;
  }


  MeshUtils::Scene* MeshUtils :: importScene(const std::string& path) {

    static struct aiLogStream logStream = aiGetPredefinedLogStream(aiDefaultLogStream_STDOUT,NULL);
    aiAttachLogStream(&logStream);
    //aiEnableVerboseLogging(true);

    Assimp::Importer importer;

    int flags;

    //flags = aiProcessPreset_TargetRealtime_Fast;
    //flags = aiProcessPreset_TargetRealtime_Quality;
    flags = aiProcessPreset_TargetRealtime_MaxQuality;

    /* 
       flags =  aiProcess_Triangulate            |
       aiProcess_JoinIdenticalVertices  |
       aiProcess_GenSmoothNormals |
       aiProcess_FindInvalidData |
       aiProcess_ImproveCacheLocality |
       aiProcess_OptimizeMeshes;
    */ 

    const aiScene * scene = aiImportFile(path.c_str(), flags);

    if (scene) {
      return(new Scene(scene));
    } else {
      return NULL;
    }
  }


  vec4 vec4FromAIColor4D(aiColor4D& v) {
    return vec4(v.r, v.g, v.b, v.a);
  }

  vec3 vec3FromAIVector3D(aiVector3D& v) {
    return vec3(v.x, v.y, v.z);
  }

  vec2 vec2FromAIVector3D(aiVector3D& v) {
    return vec2(v.x, v.y);
  }

  vec3 vec3FromAIVector2D(aiVector2D& v) {
    return vec3(v.x, v.y, 0.0);
  }


  MeshUtils::Scene :: Scene(const aiScene * _scene) {
    scene = _scene;
  }

  MeshUtils::Scene :: ~Scene() {
  }


  unsigned int MeshUtils::Scene :: meshes() const {
    return scene->mNumMeshes;
  }

  void MeshUtils::Scene :: mesh(unsigned int i, MeshData& mesh) const {
    if (i < meshes()) {
      aiMesh * amesh = scene->mMeshes[i];
      if (amesh) {

	bool hasnormals = amesh->mNormals != NULL;
	bool hascolors = amesh->mColors[0] != NULL;
	bool hastexcoords = amesh->mTextureCoords[0] != NULL;

	for (unsigned int t = 0; t < amesh->mNumFaces; ++t) {
	  const struct aiFace* face = &amesh->mFaces[t];

	  for(i = 0; i < face->mNumIndices; i++) {
	    int index = face->mIndices[i];
	    if(hascolors) {
	      mesh.color(vec4FromAIColor4D(amesh->mColors[0][index]));
	    }
	    if(hasnormals) {
	      mesh.normal(vec3FromAIVector3D(amesh->mNormals[index]));
	    }
	    if(hastexcoords) {
	      mesh.texCoord(vec3FromAIVector3D(amesh->mTextureCoords[0][index]));
	    }

	    mesh.vertex(vec3FromAIVector3D(amesh->mVertices[index]));

	  }
	}

      }
    }
  }

  void MeshUtils::Scene :: meshWithIndices(unsigned int i, MeshData& mesh) const {
    if (i < meshes()) {
      aiMesh * amesh = scene->mMeshes[i];
      if (amesh) {

	bool hasnormals = amesh->mNormals != NULL;
	bool hascolors = amesh->mColors[0] != NULL;
	bool hastexcoords = amesh->mTextureCoords[0] != NULL;

	//read vertices, normals, colors, texcoord
	for (unsigned int index = 0; index < amesh->mNumVertices; ++index){
	  if(hascolors) {
	    mesh.color(vec4FromAIColor4D(amesh->mColors[0][index]));
	  }
	  if(hasnormals) {
	    mesh.normal(vec3FromAIVector3D(amesh->mNormals[index]));
	  }
	  if(hastexcoords) {
	    mesh.texCoord(vec3FromAIVector3D(amesh->mTextureCoords[0][index]));
	  }
	  mesh.vertex(vec3FromAIVector3D(amesh->mVertices[index]));			
	}

	//read faces as indices
	for (unsigned int t = 0; t < amesh->mNumFaces; ++t) {

	  const struct aiFace* tface = &amesh->mFaces[t];

	  for(i = 0; i < tface->mNumIndices; i++) {
	    mesh.index( tface -> mIndices[i] );
	  }

	}
      }
    }
  }

  void get_bounding_box_for_node(const aiScene * scene, const struct aiNode* nd, vec3& min, vec3& max, aiMatrix4x4* trafo) {	
    aiMatrix4x4 prev;
    unsigned int n = 0, t;
    prev = *trafo;
    aiMultiplyMatrix4(trafo,&nd->mTransformation);
    for (; n < nd->mNumMeshes; ++n) {
      const struct aiMesh * mesh = scene->mMeshes[nd->mMeshes[n]];
      for (t = 0; t < mesh->mNumVertices; ++t) {
	aiVector3D tmp = mesh->mVertices[t];
	aiTransformVecByMatrix4(&tmp,trafo);
	min[0] = std::min(min[0],tmp.x);
	min[1] = std::min(min[1],tmp.y);
	min[2] = std::min(min[2],tmp.z);
	max[0] = std::max(max[0],tmp.x);
	max[1] = std::max(max[1],tmp.y);
	max[2] = std::max(max[2],tmp.z);
      }
    }
    for (n = 0; n < nd->mNumChildren; ++n) {
      get_bounding_box_for_node(scene, nd->mChildren[n],min,max,trafo);
    }
    *trafo = prev;
  }



  float MeshUtils::Scene :: getScaleVal() const {
    vec3 min, max;
    getBounds(min,max);
    cout << "in getScaleVal() : bounds min = " << glm::to_string(min) << ", max = " << glm::to_string(max) << "\n";
    vec3 scene_center = (min + max) * vec3(0.5,0.5,0.5);
    cout << "in getScaleVal() : scene center = " << to_string(scene_center) << "\n";

    float scaleVal = max[0] - min[0];
    scaleVal = std::max(max[1] - min[1], scaleVal);
    scaleVal = std::max(max[2] - min[2], scaleVal);
    scaleVal = 2.f / scaleVal;

    return scaleVal;
  }

  void MeshUtils::Scene :: getBounds(vec3& min, vec3& max) const {
    aiMatrix4x4 trafo;
    aiIdentityMatrix4(&trafo);
    min = vec3(1e10f, 1e10f, 1e10f);
    max = vec3(-1e10f, -1e10f, -1e10f);
    get_bounding_box_for_node(scene, scene->mRootNode,min,max,&trafo);
  }


  void dumpNode(aiNode * x, std::string indent) {
    printf("%sNode (%s) with %d meshes (", indent.c_str(), x->mName.data, x->mNumMeshes);
    for (unsigned int i=0; i<x->mNumMeshes; i++) {
      printf("%d ", x->mMeshes[i]);
    }
    printf(") and %d children\n", x->mNumChildren);
    for (unsigned int i=0; i<x->mNumChildren; i++) {
      dumpNode(x->mChildren[i], indent + "\t");
    }
  }

  void MeshUtils::Scene :: dump() const {
    printf("==================================================\n");
    printf("Scene\n");

    printf("%d Meshes\n", meshes());
    for (unsigned int i=0; i<meshes(); i++) {
      aiMesh * x = scene->mMeshes[i];
      printf("\t%d: %s", i, x->mName.data);
      printf(" %d vertices, %d faces; normals:%d colors:%d texcoords:%d\n", x->mNumVertices, x->mNumFaces, x->HasNormals(), x->HasVertexColors(0), x->HasTextureCoords(0));
    }

    dumpNode(scene->mRootNode, "");

    printf("==================================================\n");
  }



  MeshData MeshUtils::makeCube(float s) {

    MeshData m;

    //8 vertices
    vec3 v0 = vec3(-s,-s,s);
    vec3 v1 = vec3(-s,s,s);
    vec3 v2 = vec3(s,-s,s);
    vec3 v3 = vec3(s,s,s);
    vec3 v4 = vec3(-s,-s,-s);
    vec3 v5 = vec3(-s,s,-s);
    vec3 v6 = vec3(s,-s,-s);
    vec3 v7 = vec3(s,s,-s);

    //6 sides
    vec3 n0 = vec3(0,0,s);
    vec3 n1 = vec3(0,0,-s);
    vec3 n2 = vec3(0,s,0);
    vec3 n3 = vec3(0,-s,0);
    vec3 n4 = vec3(s,0,0);
    vec3 n5 = vec3(-s,0,0);

    //4 texcoords
    vec3 t0 = vec3(0,0,0);
    vec3 t1 = vec3(0,1,0);
    vec3 t2 = vec3(1,0,0);
    vec3 t3 = vec3(1,1,0);

    static const vec3 vs[] = { 
      v2, v3, v6, v7, //right
      v4, v5, v0, v1, //left
      v0, v1, v2, v3, //front
      v4, v5, v6, v7, //back
      v1, v5, v3, v7, //top
      v0, v4, v2, v6 //bottom
    };

    static const vec3 ns[] = { 
      n4, n4, n4, n4, 
      n5, n5, n5, n5,
      n0, n0, n0, n0,
      n1, n1, n1, n1,
      n2, n2, n2, n2,
      n3, n3, n3, n3 
    };

    static const vec3 ts[] = { 
      t0, t1, t2, t3,
      t0, t1, t2, t3,
      t0, t1, t2, t3,
      t0, t1, t2, t3,
      t0, t1, t2, t3,
      t0, t1, t2, t3 
    };

    static const unsigned int indices[] = {
      0,1,2, 2,1,3, 4,5,6, 6,5,7,
      8,9,10, 10,9,11, 12,13,14, 14,13,15,
      16,17,18, 18,17,19, 20,21,22, 22,21,23
    };

    m.vertex(vs, 24);
    m.normal(ns, 24);
    m.texCoord(ts, 24);
    m.index(indices, 36);

    return m;
  }

  MeshData MeshUtils::makeRectangle(vec3 v0, vec3 v1, vec3 v2, vec3 v3,  
      vec3 t0, vec3 t1, vec3 t2, vec3 t3) {

    MeshData m;

    vec3 n = glm::cross(v1 - v0, v2 - v0);

    static const vec3 vs[] = { v0, v1, v2, v3 };
    static const vec3 ns[] = { n, n, n, n };
    static const vec3 ts[] = { t0, t1, t2, t3 };
    static const unsigned int indices[] = { 0,1,2, 2,1,3 };

    m.vertex(vs, 4);
    m.normal(ns, 4);
    m.texCoord(ts, 4);
    m.index(indices, 6);

    return m;
  }

  MeshData MeshUtils::makeRectangle(vec2 vLL, vec2 vUR, vec2 tcLL, vec2 tcUR) {

    MeshData m;

    vec3 v0 = vec3(vLL.x, vLL.y,0);
    vec3 v1 = vec3(vLL.x,vUR.y,0);
    vec3 v2 = vec3(vUR.x,vLL.y,0);
    vec3 v3 = vec3(vUR.x,vUR.y,0);

    vec3 t0 = vec3(tcLL.x,tcLL.y,0);
    vec3 t1 = vec3(tcLL.x,tcUR.y,0);
    vec3 t2 = vec3(tcUR.x,tcLL.y,0);
    vec3 t3 = vec3(tcUR.x,tcUR.y,0);

    return makeRectangle(v0,v1,v2,v3,t0,t1,t2,t3);
  }

  MeshData MeshUtils::makeRectangle(float _w, float _h) {

    float w = _w/2.0;
    float h = _h/2.0;

    return makeRectangle(vec2(-w,-h), vec2(w,h), vec2(0,0), vec2(1,1)); 
  }

  MeshData MeshUtils::makeRectangle() {
    return makeRectangle(1,1);
  }

  MeshData MeshUtils::makeClipRectangle() {
    return makeRectangle(2,2);
  }


}

