

/* HACK ALERT - I got the following error:

/usr/include/objc/objc.h:44:22: error: typedef redefinition with different types ('signed char' vs 'int32_t' (aka 'int'))
typedef signed char             BOOL; 
                                ^
/opt/local/include/FreeImage.h:139:17: note: previous definition is here
typedef int32_t BOOL;


pointing to a conflict between objc and freeimage lib. 

to fix, i updated the freeimage lib to use the type BOOL_FI instead of BOOL in all casses

(in /opt/local/include/FreeImage.h)

*/


#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include "FBO.hpp"

#include "Texture.hpp"

using namespace al;

class FBOExample : public RendererOSX {
  public:

    Vec3f diffuse = Vec3f(0.0,1.0,0.0);
    Vec3f specular = Vec3f(1.0,1.0,1.0);
    Vec3f ambient = Vec3f(0.0,0.0,0.3);
    float lightPosX = -1.0f;
    Mat4f model, view, proj;

    Program program;
    GLuint vao[1];
    GLint posLoc=0;
    GLint normalLoc=1;
    GLint texCoordLoc=2;

    MeshUtils::Scene* scene;
    MeshBuffer modelMeshBuffer[4];
    MeshBuffer cubeMeshBuffer;

    Texture texture;
    FBO fbo;

    MeshData loadModel(MeshUtils::Scene* s, int which) {
      MeshData modelMesh;
      scene->mesh(which, modelMesh);
      return modelMesh.transform(Mat4f::identity().scale(scene->getScaleVal()));
    }

    void loadScene(MeshUtils::Scene *&s, const std::string& name) {    
      s = MeshUtils::importScene(name);

      for (unsigned i=0; i< s->meshes(); i++) {
	modelMeshBuffer[i].init(loadModel(s, i), posLoc, -1, texCoordLoc, -1);
      }
    }

    void loadCube() {
      MeshData cubeData;
      addCube(cubeData, true, 0.65);
      cubeMeshBuffer.init(cubeData, posLoc, -1, texCoordLoc, -1); 
    }

    void loadTexture(Texture& t, const std::string& name) {
      t.loadTextureData2D(t, name).create2D();
    } 

    void loadProgram(Program &p, const std::string& name) {

      p.create();

      Shader sv = Shader::sourceFromFile(name + ".vsh", GL_VERTEX_SHADER);
      Shader sf = Shader::sourceFromFile(name + ".fsh", GL_FRAGMENT_SHADER);

      p.attach(sv);

      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      //glBindAttribLocation(p.id(), normalLoc, "vertexNormal");
      glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");

      p.attach(sf);

      p.link();

      p.listParams();

      printf("program.id = %d, vertex.glsl = %d, frag.glsl = %d\n", p.id(), sv.id(), sf.id());
    }

    void setUpFBO(FBO &f) {
      Texture emptyTexture = Texture(4096,4096,GL_RGBA,GL_RGBA,GL_UNSIGNED_BYTE);
      f.create().attach(emptyTexture);
    }

    void onCreate() {

      loadTexture(texture, "resources/hubble.jpg");

      loadProgram(program, "resources/texture");

      loadScene(scene, "resources/ducky.obj");
      //loadScene(scene, "resources/bunny_small.obj");

      loadCube();

      setUpFBO(fbo);
  
      proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      view = Matrix4f::lookAt(Vec3f(0.0,0.0,-5), Vec3f(0,0,0), Vec3f(0,1,0) );
      model = Matrix4f::identity();
      model.rotate(M_PI/2, 0,2).rotate(45.0, 1,2).rotate(8.0, 0,1);

      glEnable(GL_DEPTH_TEST);
      glViewport(0, 0, width, height);
      glClearColor(0.3,0.3,0.3,1.0);
    }

    void draw(Mat4f model, MeshBuffer& mb, Texture& t) {

      program.begin(); {

	glUniformMatrix4fv(program.uniform("model"), 1, 0, model.ptr());
	glUniformMatrix4fv(program.uniform("view"), 1, 0, view.ptr());
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, proj.ptr());

	t.bind(GL_TEXTURE0);

	glUniform1i(program.uniform("tex0"), 0);

	mb.draw();

	t.unbind(GL_TEXTURE0);

      } program.end();
    }

    void onFrame(){

      model.rotate(0.01, 0, 1).rotate(0.025, 0, 2).rotate(0.015, 1, 2);

      fbo.bind(); {
	glClearColor(0.3,0.3,0.3,0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	for (unsigned i=0; i< scene->meshes(); i++) {
	  draw(model, modelMeshBuffer[i], texture);
	}

      } fbo.unbind();

      glViewport(0, 0, width, height);
      glClearColor(0.0,0.0,0.0,1.0);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
      draw(model, cubeMeshBuffer, fbo.texture);

    }
};

int main() {
  FBOExample().start(); 
  return 0;
}
