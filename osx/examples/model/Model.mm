
#include "Includes.hpp"

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Behavior.hpp"
#include "Texture.hpp"

using namespace aluminum;

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

    MeshBuffer mb;

    Behavior rotateBehavior;
    Behavior lightBehavior;

    void loadMeshes(const std::string& name) {
      mb = MeshUtils::loadMesh(name, posLoc, normalLoc, -1, -1);
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
      //loadMeshes("resources/angel.obj");
      //loadMeshes("resources/test.nff");
      //loadMeshes("resources/test3.obj");
      //loadMeshes("resources/A1.obj");
      //loadMeshes("resources/toyplane.obj");

      proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
      view = glm::lookAt(vec3(0.0,0.0,-5), vec3(0,0,0), vec3(0,1,0) );
      model = glm::rotate(glm::mat4(), 180.0f, vec3(0.0,1.0,0.0));
      //model = glm::translate(model, vec3(0.0f,-0.0f,0.0f));

      glEnable(GL_DEPTH_TEST);
      glClearColor(0.3,0.3,0.3,1.0);

      rotateBehavior = Behavior(now()).delay(1000).length(5000).range(vec3(180.0, 90.0, 360.0)).reversing(true).repeats(-1).sine();
      lightBehavior = Behavior(now()).range(2.0).length(20000).reversing(true).repeats(-1).sine(Easing::IN);

    }

    void updateModel() {

      lightPosX += lightBehavior.tick(now()).offset();

      vec3 totals = rotateBehavior.tick(now()).totals();
      model = glm::mat4();
      //model = glm::translate(model, vec3(0.0f,-2.0f,0.0f));
      model = glm::rotate(model, 180.0f, vec3(0.0f,1.0f,0.0f));
      model = glm::rotate(model, totals.x, vec3(1.0f,0.0f,0.0f));
      model = glm::rotate(model, totals.y, vec3(0.0f,1.0f,0.0f));
      model = glm::rotate(model, totals.z, vec3(0.0f,0.0f,1.0f));

    }

    void onFrame() {

      glViewport(0, 0, width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      updateModel();

      program.bind(); {
	glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model));
	glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(view));
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));

	glUniform3f(program.uniform("lightPos"), lightPosX, 0.0f, -0.3f);
	glUniform3fv(program.uniform("ambient"), 1, ptr(ambient)); 
	glUniform3fv(program.uniform("diffuse"), 1, ptr(diffuse)); 
	glUniform3fv(program.uniform("specular"), 1, ptr(specular)); 

	mb.draw();

      } program.unbind();

    }
};

int main() {
  return ModelExample().start(); 
}
