//#include "gl3.h"
#include "Program.hpp"
#include "FreeGlutGLView.hpp"
#include "RendererLinux.hpp"

#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

using namespace al;

class Basic : public RendererLinux {
  public:

    Program program;
    GLuint vao;
    GLuint vbo;
    GLuint ibo;
    GLuint indices[3] = {0,1,2};

    GLint posLoc = 0;
    GLint colLoc = 1;
    Mat4f proj;
    Mat4f mv;

    Vec3f vertices[6] = {
      Vec3f( -1.0, -1.0, 0.0 ), Vec3f( 0.0, 1.0, 0.0  ), Vec3f( 1.0, -1.0, 0.0  ), //vertex
      Vec3f( 1.0,0.0,0.0), Vec3f(0.0,1.0,0.0), Vec3f(0.0,0.0,1.0), //color
    };

    void loadProgram(Program &p, const std::string& name) {

      p.create();

      Shader sv = Shader::sourceFromFile(name + ".vsh", GL_VERTEX_SHADER);
      Shader sf = Shader::sourceFromFile(name + ".fsh", GL_FRAGMENT_SHADER);

      p.attach(sv);

      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      glBindAttribLocation(p.id(), colLoc, "vertexColor");

      p.attach(sf);

      p.link();

      p.listParams();

      printf("program.id = %d, vertex.glsl = %d, frag.glsl = %d\n", p.id(), sv.id(), sf.id());
    }

    virtual void onCreate() {

      // Load our shader program
      loadProgram(program, "resources/basic");

      // Create a vertex array object
      glGenVertexArrays( 1, &vao );
      glBindVertexArray( vao );

      // Create and initialize a buffer object
      glGenBuffers( 1, &vbo );
      glBindBuffer( GL_ARRAY_BUFFER, vbo );
      glBufferData( GL_ARRAY_BUFFER, sizeof(vertices), &vertices[0], GL_DYNAMIC_DRAW );

      glEnableVertexAttribArray( posLoc );
      glVertexAttribPointer( posLoc, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0*sizeof(Vec3f)));

      glEnableVertexAttribArray( colLoc );
      glVertexAttribPointer( colLoc, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(3*sizeof(Vec3f)));

      glGenBuffers(1, &ibo);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint)*3, indices, GL_DYNAMIC_DRAW);

      // Set up modelvew and projection matrix
      proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      mv = Matrix4f::lookAt(Vec3f(0,0,-2.5), Vec3f(0,0,0), Vec3f(0,1,0) );
    }

    virtual void onFrame(){
     
	printf("in basic-onFrame\n"); 
      // Clear viewport
      glViewport(0,0,width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      // Draw our vbos to the screen
      program.begin(); {
	program.uniformMatrix4("proj", &proj[0], false);
	program.uniformMatrix4("mv", &mv[0], false);

	glBindVertexArray( vao ); 
	glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
	glBindVertexArray( 0 ); 
      } program.end();

    }
};

int main(){ 
  Basic().start(); 
  return 0;
}
