

// fragment shader example from http://www.iquilezles.org/apps/shadertoy/

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Texture.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include <vector>

using namespace al;

class Kaleidoscope : public RendererOSX {

  public:

    Mat4f model, view, proj;

    Program program;
    GLint posLoc=0;
    //GLint texCoordLoc=1;
    Texture texture;


    MeshBuffer mb1;

    void loadTexture(Texture& t, const std::string& name) {
      t.loadTextureData2D(t, name).create2D();
    } 

    void loadProgram(Program &p, const std::string& name) {

      p.create();

      Shader sv = Shader::sourceFromFile(name + ".vsh", GL_VERTEX_SHADER);
      Shader sf = Shader::sourceFromFile(name + ".fsh", GL_FRAGMENT_SHADER);

      p.attach(sv);

      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      //glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");

      p.attach(sf);

      p.link();

      p.listParams();

      printf("program.id = %d, vertex.glsl = %d, frag.glsl = %d\n", p.id(), sv.id(), sf.id());
    }

    void onCreate() {

      //loadTexture(texture, "resources/hubble.jpg");
      loadTexture(texture, "resources/tex0.jpg");

      loadProgram(program, "resources/kaleidoscope");

      MeshData mesh1;
      addRectangle(mesh1);
      mb1.init(mesh1, posLoc, -1, -1, -1); 
     
      glEnable(GL_DEPTH_TEST);
      glClearColor(0.3,0.3,0.3,1.0);
 
    }

    int frame = 0;
    int switchAt = 75;
    int numberOfStates = 5;
    float time = 0.0f;
    int which = 0;
    void onFrame(){
      time += 0.043f;
      frame+=1;
      if (frame == switchAt) {
	which = (which+1)%numberOfStates;
	frame -= switchAt;
      }

      glViewport(0, 0, width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      program.begin(); {
	glUniform1i(program.uniform("which"), which);
	glUniform1f(program.uniform("time"), time);
	glUniform2f(program.uniform("resolution"), width, height);

	texture.bind(GL_TEXTURE0);

	glUniform1i(program.uniform("tex0"), 0);

	mb1.draw();	
	texture.unbind(GL_TEXTURE0);

      } program.end();

    }
};

int main() {
  return Kaleidoscope().start(); 
}
