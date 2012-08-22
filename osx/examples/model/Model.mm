
#include <OpenGL/gl3.h>
#include <OpenGL/gl3ext.h>

#include "NSGLView.h"
#include "RendererNativeOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "Asset.hpp"
#include "Shader.hpp"

using namespace al;

class ShaderPhong : public RendererNativeOSX {
  public:

    Vec3f diffuse = Vec3f(0.0,1.0,0.0);
    Vec3f specular = Vec3f(1.0,1.0,1.0);
    Vec3f ambient = Vec3f(0.0,0.0,0.3);
    float lightPosX = -1.0f;
    Mat4f model, view, proj;

    ShaderProgram program;
    GLuint vao[1];
    GLint posLoc=0;
    GLint normalLoc=1;

    Scene* scene;
    MeshBuffer modelMeshBuffer[4];


    MeshData loadModel(Scene* s, int which) {
      MeshData modelMesh;
      scene->mesh(which, modelMesh);
      return modelMesh.transform(Mat4f::identity().scale(scene->getScaleVal()));
    }

    void loadScene(Scene *&s, const std::string& name) {    
      s = Scene::import(name);

      if (s==0) {
	printf("error reading .obj file...\n");
	exit(0);
      } else {
	s->dump();

	for (unsigned i=0; i< s->meshes(); i++) {
	  modelMeshBuffer[i].init(loadModel(s, i), posLoc, normalLoc, -1, -1);
	}
      }
    }

    void loadProgram(ShaderProgram &p, const std::string& name) {

      p.create();

      Shader sv = Shader::sourceFromFile(name + ".vsh", GL_VERTEX_SHADER);
      Shader sf = Shader::sourceFromFile(name + ".fsh", GL_FRAGMENT_SHADER);

      p.attach(sv);

      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      glBindAttribLocation(p.id(), normalLoc, "vertexNormal");

      p.attach(sf);

      p.link();

      p.listParams();

      printf("program.id = %d, vertex.glsl = %d, frag.glsl = %d\n", p.id(), sv.id(), sf.id());
    }

    void onCreate() {

      loadProgram(program, "resources/phong");

      //loadScene(scene, "resources/ducky.obj");
      loadScene(scene, "resources/test3.obj");

      proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      view = Matrix4f::lookAt(Vec3f(0.0,0.0,-5), Vec3f(0,0,0), Vec3f(0,1,0) );
      model = Matrix4f::identity();
      model.rotate(M_PI/2, 0,2).rotate(45.0, 1,2).rotate(8.0, 0,1);

      glEnable(GL_DEPTH_TEST);
      glViewport(0, 0, width, height);
      glClearColor(0.3,0.3,0.3,1.0);
    }

    void draw(Mat4f model) {

      lightPosX += 0.02f;
      if (lightPosX > 1.0) { lightPosX = -1.0f; }

      program.begin(); {
	glUniformMatrix4fv(program.uniform("model"), 1, 0, model.ptr());
	glUniformMatrix4fv(program.uniform("view"), 1, 0, view.ptr());
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, proj.ptr());

	glUniform3f(program.uniform("lightPos"), lightPosX, 0.0f, 0.0f);
	glUniform3fv(program.uniform("ambient"), 1, ambient.ptr()); 
	glUniform3fv(program.uniform("diffuse"), 1, diffuse.ptr()); 
	glUniform3fv(program.uniform("specular"), 1, specular.ptr()); 

	for (unsigned i=0; i< scene->meshes(); i++) {
	  modelMeshBuffer[i].draw();
	}

      } program.end();
    }

    void onFrame(){
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
     
      model.rotate(0.01, 0, 1);

      model.rotate(0.02, 0, 2);
      model.rotate(0.015, 1, 2);
      draw(model);
    }
};

int main() {
  ShaderPhong().start(); 
  return 0;
}
