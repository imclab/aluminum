
#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Includes.hpp"
#include "Behavior.hpp"

#include <vector>
#include <iostream>
#include <chrono>
//#include "chrono_io"
//#include <glm/glm.hpp>
//#include <glm/gtx/string_cast.hpp>
//#include <glm/gtc/matrix_transform.hpp>
//#include <glm/gtc/matrix_access.hpp>
//#include <glm/gtc/type_ptr.hpp>

using namespace aluminum;
using std::cout;
using std::chrono::duration_cast;
using std::chrono::nanoseconds;
using std::chrono::milliseconds;
using std::chrono::high_resolution_clock;

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

    high_resolution_clock::time_point curTick, prevTick;
    
    MeshBuffer mb;

    Behavior beh;

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
      //loadScene(scene, "resources/test3.obj");
      //loadScene(scene, "resources/toyplane.obj");

      proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
      view = glm::lookAt(vec3(0.0,0.0,-5), vec3(0,0,0), vec3(0,1,0) );
      model = glm::rotate(glm::mat4(), 180.0f, vec3(0.0,1.0,0.0));
      model = glm::translate(model, vec3(0.0f,-0.0f,0.0f));

      glEnable(GL_DEPTH_TEST);
      glClearColor(0.3,0.3,0.3,1.0);

      //EasingSine* es = new EasingSine(Easing::IN);
      //EasingSine* es = new EasingSine(Easing::IN);
      EasingSine es = EasingSine(Easing::IN);

      beh = Behavior(now()).delay(1000).length(3000).range(vec3(0.0, 90.0, 0.0)).reversing(true).repeats(4).polynomial(Easing::OUT, 4);
      //beh = Behavior(now()).range(360.0).length(10000);

    }

    void updateModel() {
      /*model = glm::rotate(model, 0.7f, vec3(0.0f,1.0f,0.0f));*/
      /*model = glm::rotate(model, 1.1f, vec3(1.0f,0.0f,0.0f));*/
      /*model = glm::rotate(model, 2.3f, vec3(0.0f,0.0f,1.0f));*/
      
      if (!beh.isDone) {
	vec3 totals = beh.tick(now()).totals();
	
	model = glm::mat4();
	model = glm::rotate(model, 180.0f, vec3(0.0f,1.0f,0.0f));
	
	model = glm::rotate(model, totals.x, vec3(1.0f,0.0f,0.0f));
	model = glm::rotate(model, totals.y, vec3(0.0f,1.0f,0.0f));
	model = glm::rotate(model, totals.z, vec3(0.0f,0.0f,1.0f));
  
//	cout << "offsets = " << glm::to_string(beh.offsets) << "\n";	
	cout << "totals = " << glm::to_string(totals) << "\n";	
	
	/*
	vec3 offsets = beh.tick(now());
	printf("o %f %f %f\n", offsets.x,offsets.y,offsets.z);
	//model = glm::translate(model, beh.tick(now()));
	model = glm::translate(model, offsets);
	*/
//	cout << glm::to_string(model) << "\n";

      }
      // else {
//	cout << glm::to_string(model) << "\n";
 //     }

      lightPosX += 0.02f;

      if (lightPosX > 1.0) { 
	lightPosX = -1.0f; 
      }
    }

    void onFrame() {
      //tick();
      
      glViewport(0, 0, width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      updateModel();

      program.bind(); {
	glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model));
	glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(view));
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));

	glUniform3f(program.uniform("lightPos"), lightPosX, 0.0f, 0.0f);
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
