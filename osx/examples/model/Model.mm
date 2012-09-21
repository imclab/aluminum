
#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Includes.hpp"
#include <vector>

#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_access.hpp>
#include <glm/gtc/type_ptr.hpp>

using namespace al;

class ModelExample : public RendererOSX {

  public:

    vec3 diffuse = vec3(0.0,1.0,0.0);
    vec3 specular = vec3(1.0,1.0,1.0);
    vec3 ambient = vec3(0.0,0.0,0.3);
    float lightPosX = -1.0f;
    mat4 model, view, proj;

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

      p.attach(p.loadText(name + ".vsh"), GL_VERTEX_SHADER);
      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      glBindAttribLocation(p.id(), normalLoc, "vertexNormal");

      p.attach(p.loadText(name + ".fsh"), GL_FRAGMENT_SHADER);
      //glBindFragDataLocation(id(), 0, "frag"); //agf

      p.link();
    }

    void onCreate() {

      loadProgram(program, "resources/phong");

      loadMeshes("resources/ducky.obj");
      //loadScene(scene, "resources/test3.obj");
      //loadScene(scene, "resources/toyplane.obj");

      proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
      view = glm::lookAt(vec3(0.0,0.0,-5), vec3(0,0,0), vec3(0,1,0) );
      model = glm::rotate(glm::mat4(), 180.0f, vec3(0.0,1.0,0.0));

      glEnable(GL_DEPTH_TEST);

    }

    void updateModel() {
      model = glm::rotate(model, 0.7f, vec3(0.0f,1.0f,0.0f));
      model = glm::rotate(model, 1.1f, vec3(1.0f,0.0f,0.0f));
      model = glm::rotate(model, 2.3f, vec3(0.0f,0.0f,1.0f));
    
      lightPosX += 0.02f;

      if (lightPosX > 1.0) { 
	lightPosX = -1.0f; 
      }

    }

    void onFrame() {
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      updateModel();

      glViewport(0, 0, width, height);
      glClearColor(0.3,0.3,0.3,1.0);

      program.bind(); {
	//glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model));
	glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model));
	glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(view));
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));

	glUniform3f(program.uniform("lightPos"), lightPosX, 0.0f, 0.0f);
	glUniform3fv(program.uniform("ambient"), 1, ptr(ambient)); 
	glUniform3fv(program.uniform("diffuse"), 1, ptr(diffuse)); 
	glUniform3fv(program.uniform("specular"), 1, ptr(specular)); 

	for (unsigned long i = 0; i < mb.size(); i++) {
	  mb[i].draw();	
	}

      } program.unbind();

    }
};

int main() {
  return ModelExample().start(); 
}
