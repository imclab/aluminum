

// fragment shader example from http://www.iquilezles.org/apps/shadertoy/

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include <vector>

using namespace al;

class Mandelbulb : public RendererOSX {

  public:

    Mat4f model, view, proj;

    Program program;
    GLint posLoc=0;
    MeshBuffer mb1;

    void loadProgram(Program &p, const std::string& name) {

      p.create();

      Shader sv = Shader::sourceFromFile(name + ".vsh", GL_VERTEX_SHADER);
      Shader sf = Shader::sourceFromFile(name + ".fsh", GL_FRAGMENT_SHADER);

      p.attach(sv);

      glBindAttribLocation(p.id(), posLoc, "vertexPosition");

      p.attach(sf);

      p.link();

      p.listParams();

      printf("program.id = %d, vertex.glsl = %d, frag.glsl = %d\n", p.id(), sv.id(), sf.id());
    }

    void onCreate() {

      loadProgram(program, "resources/bulb");

      MeshData mesh1;
      addRectangle(mesh1);
      mb1.init(mesh1, posLoc, -1, -1, -1); 
     
      glEnable(GL_DEPTH_TEST);
      glClearColor(0.3,0.3,0.3,1.0);
 
    }

    float time = 0.0f;
    
    void onFrame(){
      time += 0.043f;

      glViewport(0, 0, width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      program.begin(); {
	glUniform1f(program.uniform("time"), time);
	glUniform2f(program.uniform("resolution"), width, height);

	mb1.draw();	

      } program.end();

    }
};

int main() {
  return Mandelbulb().start(); 
}
