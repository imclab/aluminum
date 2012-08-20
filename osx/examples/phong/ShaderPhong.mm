


//#include <Cocoa/Cocoa.h>
#include <OpenGL/gl3.h>
#include <OpenGL/gl3ext.h>
#include "allocore/al_Allocore.hpp"
#include "NSGLView.h"
#include "RendererNativeOSX.h"

//only needed if we are using interleaved vbos
#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

using namespace al;

class ShaderPhong : RendererNativeOSX {
  public:

    ShaderProgram program;
    GLuint vao[1], vbo[2], ibo[1];
    GLint posLoc, normalLoc;
    Mat4f mv, proj;
    Mesh mesh;

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


    void createMesh() {

      float angle = 45.0f;

      mesh.reset();
      mesh.primitive(GL_TRIANGLES);
      addSphere(mesh, 1.0, 160, 160);

      Mat4f xfm;
      xfm.setIdentity();
      //xfm.rotate(M_PI/2, 0,2).rotate(angle, 1,2).rotate(angle*8, 0,1);
      //xfm.scale(Vec3f(1.5, 0.2, 0.5));
      xfm.scale(Vec3f(0.5, 0.5, 0.5));

      mesh.transform(xfm);
      mesh.generateNormals();
    }

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

    }

    void setupVAO() {
      // Create a vertex array object
      glGenVertexArrays( 1, vao );
      glBindVertexArray( vao[0] );

      // Create and initialize vertex buffer objects (or can do a single interleaved buffer)
      glGenBuffers( 2, vbo );

      glBindBuffer( GL_ARRAY_BUFFER, vbo[0] );
      glBufferData( GL_ARRAY_BUFFER, sizeof(Vec3f) * mesh.vertices().size(), &(mesh.vertices()[0]), GL_DYNAMIC_DRAW );

      glBindBuffer( GL_ARRAY_BUFFER, vbo[1] );
      glBufferData( GL_ARRAY_BUFFER, sizeof(Vec3f) * mesh.normals().size(), &(mesh.normals()[0]), GL_DYNAMIC_DRAW );

      // Create and initialize an index buffer object 
      glGenBuffers(1, ibo);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo[0]);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLint) * mesh.indices().size(), &(mesh.indices()[0]), GL_DYNAMIC_DRAW);

      glBindVertexArray(0);
    }
    

    void onCreate() {

      printf("onCreate\n");   

      //printVersion();

      createMesh();

      loadShaders();

      setupVAO();

      proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      mv = Matrix4f::lookAt(Vec3d(-0.0,0.0,-2.5), Vec3d(0,0,0), Vec3d(0,1,0) );

      printf("out onCreate()\n");
    }

    
    void sendInterleavedVertexBuffer(int vbo, int attribute1, int size1, int attribute2, int size2) {
      glBindBuffer( GL_ARRAY_BUFFER, vbo ); {
	glEnableVertexAttribArray( attribute1 );
	glVertexAttribPointer( attribute1, size1, GL_FLOAT, GL_FALSE, size1, BUFFER_OFFSET(0*sizeof(Vec3f)));
	glEnableVertexAttribArray( attribute2 );
	glVertexAttribPointer( attribute2, size2, GL_FLOAT, GL_FALSE, size2, BUFFER_OFFSET(size1*sizeof(Vec3f)));
      }
    }     

    void sendVertexBuffer(int vbo, int attribute, int size) {
      glBindBuffer( GL_ARRAY_BUFFER, vbo ); {
	glEnableVertexAttribArray( attribute );
	//glVertexAttribPointer( attribute, size, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0*sizeof(Vec3f)));
	glVertexAttribPointer( attribute, size, GL_FLOAT, GL_FALSE, 0, 0);
      }
    }

    void sendIndexBuffer(int ibo, int numElements) {
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo); {
	glDrawElements(GL_TRIANGLES, numElements, GL_UNSIGNED_INT, 0);
      }
    }


    void onFrame(){

      //printf("num vertices = %d\n", mesh.vertices().size());
      //printf("num indices = %d\n", mesh.indices().size());


      program.begin(); {
	program.uniformMatrix4("mv", &mv[0], false);
	program.uniformMatrix4("proj", &mv[0], false);
	program.uniform("lightPos", -0.5f, 0.0f, 10.0f); 
	program.uniform("ambient", 0.0f, 0.1f, 0.0f); 
	program.uniform("diffuse", 0.5f, 0.0f, 0.0f); 
	program.uniform("specular", 1.0f, 1.0f, 1.0f); 

	glBindVertexArray( vao[0] ); {

	  sendVertexBuffer(vbo[0], posLoc, 3);
	  sendVertexBuffer(vbo[1], normalLoc, 3);
	  sendIndexBuffer(ibo[0], mesh.indices().size());

	  glDisableVertexAttribArray( posLoc ); 
	  glDisableVertexAttribArray( normalLoc ); 

	} glBindVertexArray(0);

      } program.end();


    }
};

int main(){ 

  [NSGLView start:new ShaderPhong()];

  return 0;
}
