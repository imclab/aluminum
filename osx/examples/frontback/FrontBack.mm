
#include "Program.hpp"
#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "Shapes.hpp"
#include "Camera.hpp"
#include "allocore/math/al_Random.hpp"


#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_access.hpp>
#include <glm/gtc/type_ptr.hpp>



using namespace al;

class FrontBack : public RendererOSX {
  public:

    Camera camera;
    Program program;
    GLint posLoc = 0, normalLoc = 1;
    //Mat4f model1, model2, model3, model4, view1, view2;
    mat4 model1, model2, model3, model4, view1, view2;
    MeshData mesh1, mesh2, mesh3, mesh4;
    MeshBuffer mb1, mb2, mb3, mb4;

    vec3 diffuse = vec3(0.0,1.0,0.0);
    vec3 specular = vec3(1.0,1.0,1.0);
    vec3 ambient = vec3(0.0,0.0,0.3);

    void createMeshes() {

      for(int j=0; j<1 /*50*/; ++j){
	int Nv = addCube(mesh1, true, 0.5);
	//Mat4f xfm;
	//xfm.setIdentity();
	mat4 xfm = mat4();
	//xfm.scale(rnd::uniform(1.,0.2));
	xfm = glm::scale(xfm, vec3(3.0) );
	//Vec3f p;
	//rnd::ball<3>(p.elems());
	vec3 p = vec3(0.2);
	glm::normalize(p);
	//p *= 2.0; //.scale(2.0);
	xfm = glm::translate(xfm, p); //Vec3f(rnd::uniformS(20.), rnd::uniformS(20.), rnd::uniformS(20.)));
	mesh1.transform(xfm, mesh1.vertices().size()-Nv);
      }

      for(int j=0; j<1 /*100*/ ; ++j){
	int Nv = addSphere(mesh2, 0.5, 30, 30);
	
	mat4 xfm = mat4();
//	xfm.scale(rnd::uniform(0.5,0.1));
	vec3 p;
	//rnd::ball<3>(p.elems());
	//p.normalize();
	//xfm.translate(p);
//rnd::uniformS(20.), rnd::uniformS(20.), rnd::uniformS(20.)));
	////mesh2.transform(xfm, mesh2.vertices().size()-Nv);

	/*
	Mat4f xfm;
	xfm.setIdentity();
	xfm.scale(rnd::uniform(0.5,0.1));
	//xfm.translate(Vec3f(rnd::uniformS(20.), rnd::uniformS(20.), rnd::uniformS(20.)));
	Vec3f p;
	rnd::ball<3>(p.elems());
	p.normalize();
	xfm.translate(p);
//rnd::uniformS(20.), rnd::uniformS(20.), rnd::uniformS(20.)));
	mesh2.transform(xfm, mesh2.vertices().size()-Nv);
	*/
      }


      addCube(mesh3, true, 0.5);
      //addSphere(mesh1, 0.5, 160, 160);

      //addCube(mesh2, true, 0.5);
      addSphere(mesh4, 0.5, 100, 100);
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
      camera.perspective(60.0, width/(height*0.5), 0.01, 100.0);
    }

    void onCreate() {
      camera = Camera(60.0, width/(height*0.5), 0.01, 100.0);

      createMeshes();

      loadProgram(program, "resources/phong");

      mb1.init(mesh1, posLoc, normalLoc, -1, -1); 
      mb2.init(mesh2, posLoc, normalLoc, -1, -1); 
      mb3.init(mesh3, posLoc, normalLoc, -1, -1); 
      mb4.init(mesh4, posLoc, normalLoc, -1, -1); 

      glEnable(GL_DEPTH_TEST);
      glEnable(GL_SCISSOR_TEST);
      glEnable(GL_BLEND);

    }

    float pos = -0.0f;
    void draw(mat4 view) {

      pos += 0.03f;
      if (pos > 10.0) { pos = -20.0f; }

      program.bind(); {
	//glUniformMatrix4fv(program.uniform("view"), 1, 0, view.ptr());
	glUniformMatrix4fv(program.uniform("view"), 1, 0, glm::value_ptr(view));
	//glUniformMatrix4fv(program.uniform("proj"), 1, 0, camera.projection.ptr());
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, glm::value_ptr(camera.projection));

//	cout << " mat projection : " << glm::to_string(camera.projection) << "\n";

	glUniform3f(program.uniform("lightPosition"), pos, 0.0f, 0.0f);
	glUniform3fv(program.uniform("ambient"), 1, glm::value_ptr(ambient)); 
	glUniform3fv(program.uniform("diffuse"), 1, glm::value_ptr(diffuse)); 
	glUniform3fv(program.uniform("specular"), 1, glm::value_ptr(specular)); 

	glUniformMatrix4fv(program.uniform("model"), 1, 0, glm::value_ptr(model1));
	mb1.draw();

	glUniform3f(program.uniform("diffuse"), 1.0,0.0,0.0); 
	glUniformMatrix4fv(program.uniform("model"), 1, 0, glm::value_ptr(model2));
	mb2.draw();
	
	glUniform3f(program.uniform("diffuse"), 1.0,0.0,1.0); 
	glUniformMatrix4fv(program.uniform("model"), 1, 0, glm::value_ptr(model3));
	mb3.draw();
	
	glUniform3f(program.uniform("diffuse"), 0.0,0.0,1.0); 
	glUniformMatrix4fv(program.uniform("model"), 1, 0, glm::value_ptr(model4));
	mb4.draw();

      } program.unbind();

    }

    int frameNum = 0;
    float angX = 0.0;
    float angY = 0.0;
    float angZ = 0.0;

    void onFrame(){
      if (camera.isTransformed) {
	camera.transform();
      }

      angX += 0.01;
      angY += 0.007;
      angZ += 0.003;

      model1 = mat4();
      model1 = glm::translate(model1, vec3(0,0,-5));
      model2 = mat4();
      model2 = glm::translate(model2, vec3(0,0,+5));
      model3 = mat4();
      model3 = glm::translate(model3, vec3(-5,0,0));
      model4 = mat4();
      model4 = glm::translate(model4, vec3(+5,0,0));

//      model1.setIdentity().rotate(angX, 0,2).rotate(angY, 1,2).rotate(angZ, 0,1).translate(Vec3f(0,0,-5));
 //     model2.setIdentity().rotate(angX, 0,2).rotate(angY, 1,2).rotate(angZ, 0,1).translate(Vec3f(0,0,+5));
      //model1.setIdentity().translate(Vec3f(0,0,-5));
      //model2.setIdentity().translate(Vec3f(0,0,+5));
      
      //model3.setIdentity().translate(Vec3f(-5,0,0));
      //model4.setIdentity().translate(Vec3f(+5,0,0));
   //   model3.setIdentity().rotate(angX, 0,2).rotate(angY, 1,2).rotate(angZ, 0,1).translate(Vec3f(-5,0,0));
     // model4.setIdentity().rotate(angX, 0,2).rotate(angY, 1,2).rotate(angZ, 0,1).translate(Vec3f(+5,0,0));



      glViewport(0, 0, width, height/2); {
	glScissor(0,0,width,height/2);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	//draw(camera.backView);
	draw(camera.view);
      }

      glViewport(0, height/2, width, height/2); {
	glScissor(0, height/2, width, height/2);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	draw(camera.backView);
	//draw(camera.view);
      }
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

int main(){ 
  return FrontBack().start(); 
}
