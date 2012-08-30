
#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include <vector>

using namespace al;

class ModelExample : public RendererOSX {

  public:

    Vec3f diffuse = Vec3f(0.0,1.0,0.0);
    Vec3f specular = Vec3f(1.0,1.0,1.0);
    Vec3f ambient = Vec3f(0.0,0.0,0.3);
    float lightPosX = -1.0f;
    Mat4f model, view, proj;

    Program program;
    GLint posLoc=0;
    GLint normalLoc=1;

    std::vector<MeshData> md;
    std::vector<MeshBuffer> mb;
      

    void loadMeshes(const std::string& name) {    
      
      MeshUtils::loadMeshes(md, name);

      for (unsigned long i = 0; i < md.size(); i++) {
	mb.push_back((MeshBuffer()).init(md[i], posLoc, normalLoc, -1, -1));
      }
    }

    void loadProgram(Program &p, const std::string& name) {

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

      loadMeshes("resources/ducky.obj");
      //loadScene(scene, "resources/test3.obj");
      //loadScene(scene, "resources/toyplane.obj");

      proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      view = Matrix4f::lookAt(Vec3f(0.0,0.0,-5), Vec3f(0,0,0), Vec3f(0,1,0) );
      model = Matrix4f::identity();
      model.rotate(M_PI/2, 0,2).rotate(45.0, 1,2).rotate(8.0, 0,1);

      glEnable(GL_DEPTH_TEST);
     
    }

    void draw(Mat4f model) {
      glViewport(0, 0, width, height);
      glClearColor(0.3,0.3,0.3,1.0);


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

	for (unsigned long i = 0; i < mb.size(); i++) {
	  mb[i].draw();	
	}

	/*for (unsigned i=0; i< scene->meshes(); i++) {*/
	/*  modelMeshBuffer[i].draw();*/
	/*}*/

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
  return ModelExample().start(); 
}
