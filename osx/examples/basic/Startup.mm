


#include <OpenGL/gl3.h>
#include <OpenGL/gl3ext.h>
#include "allocore/al_Allocore.hpp"
#include "NSGLView.h"
#include "RendererNativeOSX.h"

#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

using namespace al;

class Startup : RendererNativeOSX {
  public:

    ShaderProgram program;
    GLuint vao[1];
    GLuint vbo[1];
    GLuint ibo[1];
    GLint posLoc;
    GLint colLoc;

    //Mesh mesh;

    Vec3f vertices[6] = {
      Vec3f( -1.0, -1.0, 0.0 ), Vec3f( 0.0, 1.0, 0.0  ), Vec3f( 1.0, -1.0, 0.0  ), //vertex
      Vec3f( 1.0,0.0,0.0), Vec3f(0.0,1.0,0.0), Vec3f(0.0,0.0,1.0), //color
    };

    virtual void onCreate() {
      printf("onCreate\n");   

      char* verGL = (char*)glGetString(GL_VERSION);
      printf("GL version = %s\n", verGL);

      char* verGLSL = (char*)glGetString(GL_SHADING_LANGUAGE_VERSION);
      printf("GLSL version = %s\n", verGLSL);

      SearchPaths searchpaths;
      searchpaths.addSearchPath(searchpaths.appPath() + "../../examples/graphics3.2/");

      Shader shaderV, shaderF;
      shaderV.sourceFromFile(searchpaths, "simple.vsh", Shader::VERTEX);
      shaderF.sourceFromFile(searchpaths, "simple.fsh", Shader::FRAGMENT);

      program.attach(shaderV).attach(shaderF).link();

      posLoc = program.attribute("vertexPosition");
      colLoc = program.attribute("vertexColor");

      // Create a vertex array object
      glGenVertexArrays( 1, vao );
      glBindVertexArray( vao[0] );

      // Create and initialize a buffer object
      glGenBuffers( 1, vbo );
      glBindBuffer( GL_ARRAY_BUFFER, vbo[0] );
      glBufferData( GL_ARRAY_BUFFER, sizeof(vertices), &vertices[0], GL_DYNAMIC_DRAW );
      glBindBuffer( GL_ARRAY_BUFFER, 0 );

  
      GLuint pindices[3];
      pindices[0] = 0;
      pindices[1] = 1;
      pindices[2] = 2;

      glGenBuffers(1, ibo);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo[0]);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint)*3, pindices, GL_DYNAMIC_DRAW);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

      glBindVertexArray( 0 );

      printf("out onCreate()\n");

    }


    virtual void onFrame(){
      
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   

      Mat4f proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      Mat4f mv = Matrix4f::lookAt(Vec3f(0,0,-2.5), Vec3f(0,0,0), Vec3f(0,1,0) );

      program.begin(); {

	program.uniformMatrix4("proj", &proj[0], false);
	program.uniformMatrix4("mv", &mv[0], false);

	glBindVertexArray( vao[0] ); {
    
	  glEnableVertexAttribArray( posLoc );
	  glEnableVertexAttribArray( colLoc );
	  
	  glBindBuffer( GL_ARRAY_BUFFER, vbo[0] ); {
	    glVertexAttribPointer( posLoc, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0*sizeof(Vec3f)));
	    glVertexAttribPointer( colLoc, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(3*sizeof(Vec3f)));
	  } glBindBuffer( GL_ARRAY_BUFFER, 0 );

	  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo[0]); {
	    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
	  } glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

	  glDisableVertexAttribArray( posLoc ) ; 
	  glDisableVertexAttribArray( colLoc ) ; 
	}

      } program.end();


    }
};

int main(){ 

  [NSGLView start:new Startup()];

  return 0;
}
