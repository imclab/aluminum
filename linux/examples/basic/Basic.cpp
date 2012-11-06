
#include "Includes.hpp"

//#include "MeshBuffer.hpp"
//#include "MeshData.hpp"
//#include "MeshUtils.hpp"
#include "Program.hpp"
//#include "Shapes.hpp"
//#include "Texture.hpp"

#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

using glm::vec3;
using glm::mat4;

using namespace aluminum;

class Basic : public RendererLinux {
  public:

    Program program;
    GLuint vao, vbo, ibo, indices[3] = {0,1,2};

    vec3 vertices[6] = {
      vec3( -1.0, -1.0, 0.0 ), vec3( 0.0, 1.0, 0.0  ), vec3( 1.0, -1.0, 0.0  ), //vertex
      vec3( 1.0,0.0,0.0), vec3(0.0,1.0,0.0), vec3(0.0,0.0,1.0), //color
    };

    GLint posLoc = 0;
    GLint colLoc = 1;
    mat4 proj;
    mat4 mv;


    void loadProgram(Program &p, const std::string& name) {

fprintf(stderr, " in basic load program...1\n");

      p.create();
fprintf(stderr, " in basic load program...2\n");



	
     string text;
     p.loadText(text, name + ".vsh");
	cout << "text here is " << text << "\n";
      p.attach(text, GL_VERTEX_SHADER);
      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      glBindAttribLocation(p.id(), colLoc, "vertexColor");

     string text2;
     p.loadText(text2, name + ".fsh");
	cout << "text2 here is " << text2 << "\n";
      p.attach(text2, GL_FRAGMENT_SHADER);

      p.link();
fprintf(stderr, " in basic load program...5\n");
    }

    virtual void onCreate() {
fprintf(stderr, "in onCreate : basic...\n");

/*
char* verGL = (char*)glGetString(GL_VERSION);
char* verGLSL = (char*)glGetString(GLSL_VERSION);
printf("GL %s GLSL %s\n", verGL, verGLSL);
*/

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
      glVertexAttribPointer( posLoc, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0*sizeof(vec3)));

      glEnableVertexAttribArray( colLoc );
      glVertexAttribPointer( colLoc, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(3*sizeof(vec3)));

      glGenBuffers(1, &ibo);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint)*3, indices, GL_DYNAMIC_DRAW);

      // Set up modelvew and projection matrix
      proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
      mv = glm::lookAt(vec3(0,0,-2.5), vec3(0,0,0), vec3(0,1,0) );
    }

    virtual void onFrame(){

//fprintf(stderr, "in onFrame : basic...\n");

/*
char* verGL = (char*)glGetString(GL_VERSION);
char* verGLSL = (char*)glGetString(GLSL_VERSION);
printf("2... GL %s GLSL %s\n", verGL, verGLSL);
*/
	

      // Clear viewport
      glViewport(0,0,width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


      // Draw our vbos to the screen
      program.bind(); {

	glUniformMatrix4fv(program.uniform("mv"), 1, 0, ptr(mv));
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));

	glBindVertexArray( vao ); 
	glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
	glBindVertexArray( 0 ); 
      } program.unbind();

    }

/*
    void mouseDragged(int px, int py) {
      printf("in Basic: mouseDragged %d/%d\n", px, py);
    }

    void mouseMoved(int px, int py) {
      printf("in Basic: mouseMoved %d/%d\n", px, py);
    }

    void mouseDown(int px, int py) {
      printf("in Basic: mouseDown %d/%d\n", px, py);
    }

    void mouseUp(int px, int py) {
      printf("in Basic: mouseUp %d/%d\n", px, py);
    }
   
    void keyDown(char key, bool shift, bool control, bool command, bool option, bool function) {
      printf("in Basic: key = %c, shift=%d, control=%d, command=%d, option=%d, function=%d\n", key, shift, control, command, option, function);
      switch(key) {
	case kVK_ANSI_A : 
	printf("you pressed an 'A'! \n");
	break;
      }
    }
 */

};

/*
int main(){ 
  //return Basic().start("aluminum::Basic", 100, 100, 400, 300); 
  return Basic().start("aluminum::Basic", 100, 100, 400, 300); 

}
*/

int main(){ 
  Basic().start(); 
  return 0;
}
