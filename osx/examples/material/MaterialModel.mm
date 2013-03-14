
#include "Includes.hpp"

#include "Program.hpp"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "Shapes.hpp"
#include "Camera.hpp"
#include "Utils.hpp"
#include "MeshUtils.hpp"
#include "Behavior.hpp"

using namespace aluminum;

class MaterialModel : public RendererOSX {

  public:

    bool drawAnaglyph = true;
    bool drawActive = false; //requires NSOpenGLPFAStereo to be set (right now hardcoded in Cocoa.mm)


    vec3 diffuse = vec3(1.0,1.0,1.0);
    vec3 specular = vec3(1.0,1.0,1.0);
    vec3 ambient = vec3(0.0,0.0,0.3);
    float lightPosX = -1.0f;
    mat4 model; //, proj; 

    Program program;
    GLint posLoc=0;
    GLint normalLoc=1;

    MeshBuffer mb;

    Behavior rotateBehavior;
    Behavior lightBehavior;

    Camera camera;
  
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

    void onReshape() {
      printf("in reshape!!! w=%d h=%d\n", width, height);
      camera.perspective(60.0, width/(height*0.5), 0.01, 100.0);
    }

    void onCreate() {
      camera = Camera(60.0, width/(height*0.5), 0.01, 100.0);


      loadProgram(program, "resources/phong");

      loadMeshes("resources/test3.obj");

      //proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
      //view = glm::lookAt(vec3(0.0,0.0,-5), vec3(0,0,0), vec3(0,1,0) );
      model = glm::rotate(glm::mat4(), 180.0f, vec3(0.0,1.0,0.0));

      glEnable(GL_DEPTH_TEST);
     // glEnable(GL_SCISSOR_TEST);
      glEnable(GL_BLEND);
      glClearColor(0.3,0.3,0.3,1.0);

      rotateBehavior = Behavior(now()).delay(1000).length(15000).range(vec3(180.0, 90.0, 360.0)).reversing(true).repeats(-1).sine();
      lightBehavior = Behavior(now()).range(2.0).length(120000).reversing(true).repeats(-1).sine(Easing::IN);

    }

    void updateModel() {

      lightPosX += lightBehavior.tick(now()).offset();

      vec3 totals = rotateBehavior.tick(now()).totals();
      model = glm::mat4();

     // model = glm::translate(model, vec3(0,0,2));



      //model = glm::translate(model, vec3(0.0f,-2.0f,0.0f));
      model = glm::rotate(model, 180.0f, vec3(0.0f,1.0f,0.0f));
      model = glm::rotate(model, totals.x, vec3(1.0f,0.0f,0.0f));
      model = glm::rotate(model, totals.y, vec3(0.0f,1.0f,0.0f));
      model = glm::rotate(model, totals.z, vec3(0.0f,0.0f,1.0f));

    }

    void draw(mat4 proj, mat4 view) {

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

    void onFrame() {
      if (camera.isTransformed) {
	camera.transform();
      }

    //  glViewport(0, 0, width, height);
    //  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


      updateModel();

      if (drawAnaglyph) {
	glColorMask(true, false, false, true);
      }

      glViewport(0, 0, width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      draw(camera.leftProjection, camera.leftView);

      if (drawAnaglyph) {
	glClear(GL_DEPTH_BUFFER_BIT) ;
	glColorMask(false, true, true, true);
      } 

      glViewport(0, 0, width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      draw(camera.rightProjection, camera.rightView);

      glColorMask(true, true, true, true);
    }



    virtual void keyDown(char key, bool shift, bool control, bool command, bool option, bool function) {

      switch(key) {
	case kVK_Space :
	  camera.resetVectors();
	  break;

	case kVK_ANSI_A : 
	  camera.rotateY(2);
	  break;

	case kVK_ANSI_D : 
	  camera.rotateY(-2);
	  break;

	case kVK_ANSI_W : 
	  camera.rotateX(2);
	  break;

	case kVK_ANSI_X : 
	  camera.rotateX(-2);
	  break;

	case kVK_ANSI_E : 
	  camera.rotateZ(2);
	  break;

	case kVK_ANSI_C : 
	  camera.rotateZ(-2);
	  break;

	case kVK_ANSI_T : 
	  camera.translateZ(-0.5);
	  break;

	case kVK_ANSI_B : 
	  camera.translateZ(0.5);
	  break;

	case kVK_ANSI_Y : 
	  camera.translateX(0.5);
	  break;

	case kVK_ANSI_N : 
	  camera.translateX(-0.5);
	  break;

	case kVK_ANSI_U : 
	  camera.translateY(0.5);
	  break;

	case kVK_ANSI_M : 
	  camera.translateY(-0.5);
	  break;
      }
    }

};

int main() {
  return MaterialModel().start(); 
}
