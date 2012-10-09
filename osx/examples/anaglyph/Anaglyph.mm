#include "Includes.hpp"

#include "Program.hpp"
#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "Shapes.hpp"
#include "Camera.hpp"

using namespace aluminum;

class Anaglyph : public RendererOSX {
  public:

    bool drawAnaglyph = true;
    bool drawActive = false; //requires NSOpenGLPFAStereo to be set (right now hardcoded in Cocoa.mm)

    Camera camera;
    Program program;
    GLint posLoc = 0, normalLoc = 1;
    mat4 model1, model2, model3, model4, view1, view2;
    MeshData mesh1, mesh2, mesh3, mesh4;
    MeshBuffer mb1, mb2, mb3, mb4;

    vec3 diffuse = vec3(1.0,1.0,1.0);
    vec3 specular = vec3(1.0,1.0,1.0);
    vec3 ambient = vec3(0.4,0.4,0.4);

    void createMeshes() {

      for(int j=0; j<50; ++j){
	int Nv = addCube(mesh1, true, 0.5);
	mat4 xfm;
	xfm.setIdentity();
	xfm.scale(rnd::uniform(1.,0.2));
	vec3 p;
	rnd::ball<3>(p.elems());
	
	p.normalize();
	p *= 2.0; //.scale(2.0);
	xfm.translate(p); //vec3(rnd::uniformS(20.), rnd::uniformS(20.), rnd::uniformS(20.)));
	mesh1.transform(xfm, mesh1.vertices().size()-Nv);
      }

      for(int j=0; j<100; ++j){
	int Nv = addSphere(mesh2, 0.5, 30, 30);
	mat4 xfm;
	xfm.setIdentity();
	xfm.scale(rnd::uniform(0.5,0.1));
	//xfm.translate(vec3(rnd::uniformS(20.), rnd::uniformS(20.), rnd::uniformS(20.)));
	vec3 p;
	rnd::ball<3>(p.elems());
	p.normalize();
	xfm.translate(p);
//rnd::uniformS(20.), rnd::uniformS(20.), rnd::uniformS(20.)));
	mesh2.transform(xfm, mesh2.vertices().size()-Nv);
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
    void draw(mat4 proj, mat4 view) {

      pos += 0.03f;
      if (pos > 10.0) { pos = -20.0f; }

      program.bind(); {
	glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(view));
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));

	glUniform3f(program.uniform("lightPosition"), pos, 0.0f, 0.0f);
	glUniform3fv(program.uniform("ambient"), 1, ptr(ambient)); 
	glUniform3fv(program.uniform("diffuse"), 1, ptr(diffuse)); 
	glUniform3fv(program.uniform("specular"), 1, ptr(specular)); 

	glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model1));
	mb1.draw();

	glUniform3f(program.uniform("diffuse"), 1.0,1.0,1.0); 
	glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model2));
	mb2.draw();
	
	glUniform3f(program.uniform("diffuse"), 1.0,1.0,1.0); 
	glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model3));
	mb3.draw();
	
	glUniform3f(program.uniform("diffuse"), 1.0,1.0,1.0); 
	glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model4));
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

      model1.setIdentity().rotate(angX, 0,2).rotate(angY, 1,2).rotate(angZ, 0,1).translate(vec3(0,0,-5));
      model2.setIdentity().rotate(angX, 0,2).rotate(angY, 1,2).rotate(angZ, 0,1).translate(vec3(0,0,+5));
      //model1.setIdentity().translate(vec3(0,0,-5));
      //model2.setIdentity().translate(vec3(0,0,+5));

      //model3.setIdentity().translate(vec3(-5,0,0));
      //model4.setIdentity().translate(vec3(+5,0,0));
      model3.setIdentity().rotate(angX, 0,2).rotate(angY, 1,2).rotate(angZ, 0,1).translate(vec3(-5,0,0));
      model4.setIdentity().rotate(angX, 0,2).rotate(angY, 1,2).rotate(angZ, 0,1).translate(vec3(+5,0,0));

      if (drawActive) {
	glViewport(0,0,width, height);
	glDrawBuffer(GL_BACK);                                   //draw into both back buffers
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);      //clear color and depth buffers
	glDrawBuffer(GL_BACK_LEFT);
      }

      if (drawAnaglyph) {
	glColorMask(true, false, false, true);
      }



      glViewport(0, 0, width, height/2); {
	glScissor(0,0,width,height/2);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	draw(camera.leftProjection, camera.leftView);
      }

      glViewport(0, height/2, width, height/2); {
	glScissor(0, height/2, width, height/2);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	draw(camera.leftProjection, camera.leftBackView);
      }

      if (drawAnaglyph) {
	glClear(GL_DEPTH_BUFFER_BIT) ;
	glColorMask(false, true, true, true);
      } 
	
      if (drawActive) {
	glDrawBuffer(GL_BACK_RIGHT);
      }

      glViewport(0, 0, width, height/2); {
	glScissor(0,0,width,height/2);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	draw(camera.rightProjection, camera.rightView);
      }

      glViewport(0, height/2, width, height/2); {
	glScissor(0, height/2, width, height/2);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	draw(camera.rightProjection, camera.rightBackView);
      }

      //back to normal
      glColorMask(true, true, true, true);


      /*
	 else if (drawActive) {
	 glViewport(0,0,width, height);

	 glDrawBuffer(GL_BACK);                                   //draw into both back buffers
	 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);      //clear color and depth buffers

	 glDrawBuffer(GL_BACK_LEFT); { 
      //top left
      glViewport(0, 0, width, height/2); {
      glScissor(0,0,width,height/2);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      draw(camera.leftProjection, camera.leftView);
      }
      //right left
      glViewport(0, height/2, width, height/2); {
      glScissor(0, height/2, width, height/2);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      draw(camera.leftProjection, camera.leftBackView);
      }
      }

      glDrawBuffer(GL_BACK_RIGHT); { 
      glViewport(0, 0, width, height/2); {
      glScissor(0,0,width,height/2);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      draw(camera.rightProjection, camera.rightView);
      }

      glViewport(0, height/2, width, height/2); {
      glScissor(0, height/2, width, height/2);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      draw(camera.rightProjection, camera.rightBackView);
      }
      }

      }
       */




      /*
	 glColorMask(GL_TRUE, GL_FALSE,GL_FALSE,GL_TRUE);


	 glViewport(0, 0, width, height/2); {
	 glScissor(0,0,width,height/2);
	 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	 draw(camera.view);
	 }

	 glViewport(0, height/2, width, height/2); {
	 glScissor(0, height/2, width, height/2);
	 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	 draw(camera.backView);
	 }
       */
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
  return Anaglyph().start(); 
}
