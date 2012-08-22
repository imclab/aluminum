#include "Asset.hpp"

#include <map>
#include <iostream>

using namespace al;

Vec4f vec4FromAIColor4D(aiColor4D& v) {
	return Vec4f(v.r, v.g, v.b, v.a);
}

Vec3f vec3FromAIVector3D(aiVector3D& v) {
	return Vec3f(v.x, v.y, v.z);
}

Vec2f vec2FromAIVector3D(aiVector3D& v) {
	return Vec2f(v.x, v.y);
}


void initLogStream() {
	static bool initializedLog = false;
	static struct aiLogStream logStream;
	if (!initializedLog) {
		initializedLog = true;
		// get a handle to the predefined STDOUT log stream and attach
		// it to the logging system. It will be active for all further
		// calls to aiImportFile(Ex) and aiApplyPostProcessing.
		logStream = aiGetPredefinedLogStream(aiDefaultLogStream_STDOUT,NULL);
		aiAttachLogStream(&logStream);
	}
}


int countNodes(const aiNode * n) {
	int count = 1;
	for (unsigned int i=0; i<n->mNumChildren; i++) {
		count += countNodes(n->mChildren[i]);
	}
	return count;
}







Scene * Scene :: import(const std::string& path, ImportPreset preset) {

  //aiEnableVerboseLogging(true);
  Assimp::Importer importer;

  initLogStream();

  /*
     int flags;
     switch (preset) {
     case FAST:
     flags = aiProcessPreset_TargetRealtime_Fast;
     break;
     case QUALITY:
     flags = aiProcessPreset_TargetRealtime_Quality;
     break;
     case MAX_QUALITY:
     flags = aiProcessPreset_TargetRealtime_MaxQuality;
     break;
     default:
     break;
     }*/

  int flags = aiProcessPreset_TargetRealtime_MaxQuality;
  /* 
     int flags =  aiProcess_Triangulate            |
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

Scene :: Scene(const aiScene * _scene) {
  scene = _scene;
}

Scene :: ~Scene() {
}

unsigned int Scene :: meshes() const {
  return scene->mNumMeshes;
}

void Scene :: mesh(unsigned int i, MeshData& mesh) const {
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

      // Mat4f xfm;
      // xfm.setIdentity();
      // //printf("scale val = %f\n", scaleVal);
      // xfm.scale(getScaleVal());
      // mesh.transform(xfm);

      // mesh.compress();
    }
  }
}

void Scene :: meshAlt(unsigned int i, MeshData& mesh) const {
  if (i < meshes()) {
    //aiMesh * amesh = mImpl->scene->mMeshes[i];
    aiMesh * amesh = scene->mMeshes[i];
    if (amesh) {
      //mesh.reset();

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
	  //printf("face idx %d\n", tface -> mIndices[i] ); 
	}
      }

      // mesh.compress();
    }
  }
}

std::string Scene :: meshName(unsigned int i) const {
  if (i < meshes()) {
    //aiMesh * amesh = mImpl->scene->mMeshes[i];
    aiMesh * amesh = scene->mMeshes[i];
    if (amesh) {
      return amesh->mName.data;
    }
  }
  return 0;
}

void get_bounding_box_for_node(const aiScene * scene, const struct aiNode* nd, Vec3f& min, Vec3f& max, aiMatrix4x4* trafo) {	
  aiMatrix4x4 prev;
  unsigned int n = 0, t;
  prev = *trafo;
  aiMultiplyMatrix4(trafo,&nd->mTransformation);
  for (; n < nd->mNumMeshes; ++n) {
    const struct aiMesh * mesh = scene->mMeshes[nd->mMeshes[n]];
    for (t = 0; t < mesh->mNumVertices; ++t) {
      aiVector3D tmp = mesh->mVertices[t];
      aiTransformVecByMatrix4(&tmp,trafo);
      min[0] = AL_MIN(min[0],tmp.x);
      min[1] = AL_MIN(min[1],tmp.y);
      min[2] = AL_MIN(min[2],tmp.z);
      max[0] = AL_MAX(max[0],tmp.x);
      max[1] = AL_MAX(max[1],tmp.y);
      max[2] = AL_MAX(max[2],tmp.z);
    }
  }
  for (n = 0; n < nd->mNumChildren; ++n) {
    get_bounding_box_for_node(scene, nd->mChildren[n],min,max,trafo);
  }
  *trafo = prev;
}



float Scene :: getScaleVal() const {
  Vec3f min, max;
  getBounds(min,max);
  Vec3f scene_center = (min + max) / 2.f;

  float scaleVal = max[0] - min[0];
  scaleVal = al::max(max[1] - min[1], scaleVal);
  scaleVal = al::max(max[2] - min[2], scaleVal);
  scaleVal = 2.f / scaleVal;

  return scaleVal;
}

void Scene :: getBounds(Vec3f& min, Vec3f& max) const {
  aiMatrix4x4 trafo;
  aiIdentityMatrix4(&trafo);
  min.set(1e10f, 1e10f, 1e10f);
  max.set(-1e10f, -1e10f, -1e10f);
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

void Scene :: dump() const {
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



