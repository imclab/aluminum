


//#include <Cocoa/Cocoa.h>
#include <OpenGL/gl3.h>
#include <OpenGL/gl3ext.h>

#include "Shader.hpp"
#include "NSGLView.h"
#include "RendererNativeOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "Shapes.hpp"


//only needed if we are using interleaved vbos
#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

using namespace al;

class FrontBack : public RendererNativeOSX {
  public:

    ShaderProgram program;
    GLuint vao[2];
    GLint posLoc = 0;
    GLint normalLoc = 1;
    Mat4f model, view1, view2, proj;
    MeshData mesh1, mesh2, mesh3;
    MeshBuffer mb1, mb2;

 Vec3f diffuse = Vec3f(0.0,1.0,0.0);
    Vec3f specular = Vec3f(1.0,1.0,1.0);
    Vec3f ambient = Vec3f(0.0,0.0,0.3);

    /*
       Vec3f vertices[6] = {
       Vec3f( -1.0, -1.0, 0.0 ), Vec3f( 0.0, 1.0, 0.0  ), Vec3f( 1.0, -1.0, 0.0  ), //vertex
       Vec3f( 1.0,0.0,0.0), Vec3f(0.0,1.0,0.0), Vec3f(0.0,0.0,1.0), //color
       };
     */

    void printVersion() {
      char* verGL = (char*)glGetString(GL_VERSION);
      printf("GL version = %s\n", verGL);

      char* verGLSL = (char*)glGetString(GL_SHADING_LANGUAGE_VERSION);
      printf("GLSL version = %s\n", verGLSL);
    }


    void createMesh1() {

      float angle = 45.0f;

      addCube(mesh1, true, 0.25);

    //  addSphere(mesh1, 0.5, 100, 100);
      mesh1.primitive(GL_TRIANGLES);

/*
      Mat4f xfm;
      xfm.setIdentity();
      //xfm.rotate(M_PI/2, 0,2).rotate(angle, 1,2).rotate(angle*8, 0,1);
      //xfm.scale(Vec3f(1.5, 0.2, 0.5));
      xfm.scale(Vec3f(0.3, 0.3, 0.5));
      xfm.translate(Vec3f(0.0, 0.0, 0.0));
*/
   //   mesh1.transform(xfm);
  //    mesh1.generateNormals();
    }


    void createMesh2() {

      float angle = 45.0f;

      addSphere(mesh2, 1.0, 160, 160);

      //mesh2 = makeSphere(1.0, 8,8 );
      mesh2.primitive(GL_TRIANGLES);

      Mat4f xfm;
      xfm.setIdentity();
      //xfm.rotate(M_PI/2, 0,2).rotate(angle, 1,2).rotate(angle*8, 0,1);
      //xfm.scale(Vec3f(1.5, 0.2, 0.5));
      xfm.scale(Vec3f(0.3, 0.3, 0.5));
      xfm.translate(Vec3f(-0.3, 0.0, 0.0));

      mesh2.transform(xfm);
      mesh2.generateNormals();
    }

    void createMesh3() {
     float angle = 45.0f;

      addSphere(mesh3, 1.0, 16, 16);

      //mesh2 = makeSphere(1.0, 8,8 );
      mesh3.primitive(GL_TRIANGLES);

      Mat4f xfm;
      xfm.setIdentity();
      //xfm.rotate(M_PI/2, 0,2).rotate(angle, 1,2).rotate(angle*8, 0,1);
      //xfm.scale(Vec3f(1.5, 0.2, 0.5));
      xfm.scale(Vec3f(0.3, 0.3, 0.5));
      xfm.translate(Vec3f(-0.3, 0.0, 0.0));

      mesh3.transform(xfm);
      mesh3.generateNormals();
     
    }

   void loadProgram(ShaderProgram &p, const std::string& name) {

      p.create();

      Shader sv = Shader::sourceFromFile(name + ".vsh", GL_VERTEX_SHADER);
      Shader sf = Shader::sourceFromFile(name + ".fsh", GL_FRAGMENT_SHADER);

      p.attach(sv);

      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      glBindAttribLocation(p.id(), normalLoc, "vertexNormal");
      //glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");

      p.attach(sf);

      p.link();

      p.listParams();


      if (sv.log() != NULL) {
	printf("vert %s\n", sv.log());
	exit(0);
      }
      if (sf.log() != NULL) {
	printf("frag %s\n", sf.log());
	exit(0);
      }


      printf("program.id = %d, vertex.glsl = %d, frag.glsl = %d\n", p.id(), sv.id(), sf.id());
    }

    /*
    void loadShaders() {

      SearchPaths searchpaths;
      searchpaths.addSearchPath(searchpaths.appPath() + "../../examples/graphics3.2/");

      Shader shaderV;
      shaderV.sourceFromFile(searchpaths, "phong.vsh", Shader::VERTEX);

      Shader shaderF;
      shaderF.sourceFromFile(searchpaths, "phong.fsh", Shader::FRAGMENT);

      program.attach(shaderV);

      //set up attrib ids here manually... must be done before linking
      posLoc = 0;
      glBindAttribLocation(program.id(), posLoc, "vertexPosition");
      normalLoc = 1;
      glBindAttribLocation(program.id(), normalLoc, "vertexNormal");

      program.attach(shaderF);
      //set up frag output manually... must be done before linking
      //glBindFragDataLocation(program.id(), 10, "outputFrag");

      program.link();

      //posLoc = glGetAttribLocation(program.id(), "vertexPosition");
      //normalLoc = glGetAttribLocation(program.id(), "vertexNormal");

      if (shaderV.log() != NULL) {
	printf("vert %s\n", shaderV.log());
	exit(0);
      }
      if (shaderF.log() != NULL) {
	printf("frag %s\n", shaderF.log());
	exit(0);
      }

      program.listParams();
    }
    */
 
    void onCreate() {

      printf("in onCreate\n");   

      //printVersion();

      createMesh1();
      createMesh2();
      createMesh3();

      loadProgram(program, "resources/phong");
    
      mb1.init(mesh1, posLoc, normalLoc, -1, -1); 
      mb2.init(mesh2, posLoc, normalLoc, -1, -1); 

      proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      model = Matrix4f::identity();
      view1 = Matrix4f::lookAt(Vec3f(0.0,0.0,-2.5), Vec3f(0,0,0), Vec3f(0,1,0) );
      view2 = Matrix4f::lookAt(Vec3f(0.0,0.0,2.5), Vec3f(0.0,0,0), Vec3f(0,1,0) );
     // mv = Matrix4f::lookAt(Vec3f(0.0,0.0,0.0), Vec3f(0,0,-1.0), Vec3f(0,1,0) );
     // mv2 = Matrix4f::lookAt(Vec3f(0.0,0.0,0.0), Vec3f(0.0,0,1.0), Vec3f(0,1,0) );

      printf("out onCreate()\n");
    }


   
    float pos = -1.0f;
    void draw(Mat4f view) {

      pos += 0.01f;
      if (pos > 1.0) { pos = -1.0f; }

      program.begin(); {
	glUniformMatrix4fv(program.uniform("model"), 1, 0, model.ptr());
	glUniformMatrix4fv(program.uniform("view"), 1, 0, view.ptr());
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, proj.ptr());

	glUniform3f(program.uniform("lightPos"), pos, 0.0f, 0.0f);
	glUniform3fv(program.uniform("ambient"), 1, ambient.ptr()); 
	glUniform3fv(program.uniform("diffuse"), 1, diffuse.ptr()); 
	glUniform3fv(program.uniform("specular"), 1, specular.ptr()); 
/*
	program.uniformMatrix4("model", &model[0], false);
	program.uniformMatrix4("view", &view[0], false);
	program.uniformMatrix4("proj", &proj[0], false);
	program.uniform("lightPos", pos, 0.5f, 0.0); 
	program.uniform("ambient", 0.0f, 0.0f, 0.4f); 
	program.uniform("diffuse", 0.5f, 0.0f, 0.0f); 
	program.uniform("specular", 1.0f, 1.0f, 1.0f); 
*/
	mb1.draw();
	mb2.draw();
  
      } program.end();

    }

int frameNum = 0;
    void onFrame(){

      //printf("num vertices = %d\n", mesh.vertices().size());
      //printf("num indices = %d\n", mesh.indices().size());

/*
    if (frameNum == 100) {
printf("update!\n");
//      mb2.update(mesh3, posLoc, normalLoc, -1, -1); 
    mesh1.vertices()[0] = Vec3f(400.0, 400.0, 400.0);
      mb1.update(mesh1, posLoc, normalLoc, -1, -1); 
    }
  frameNum++;
*/
      glEnable(GL_DEPTH_TEST);
      glEnable(GL_SCISSOR_TEST);
      glEnable(GL_BLEND);

      glViewport(0, 0, width, height/2);
      glScissor(0,0,width,height/2);
      // glClearColor(1.0,0.0,0.0,1.0);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      draw(view1);

      glViewport(0, height/2, width, height/2);
      glScissor(0, height/2, width, height/2);
      //glClearColor(0.0,1.0,0.0,0.2);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      draw(view2);
    }
};

int main(){ 

FrontBack().start(); 

  return 0;
}
