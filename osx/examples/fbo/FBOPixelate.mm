
#include "Includes.hpp"

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include "FBO.hpp"
#include "Behavior.hpp"

#include "Texture.hpp"

using namespace aluminum;

class FBOPixelate : public RendererOSX {
  public:

    mat4 model, view, proj;

    Program program;
    GLuint vao[1];
    GLint posLoc=0;
    GLint texCoordLoc=1;

    Texture texture;
    FBO fbo;
    MeshBuffer mb;



    void loadTexture(Texture& t, const std::string& name) {
      t.loadTexture(t, name);
    } 


    void loadProgram(Program &p, const std::string& name) {

      p.create();

      p.attach(p.loadText(name + ".vsh"), GL_VERTEX_SHADER);
      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");

      p.attach(p.loadText(name + ".fsh"), GL_FRAGMENT_SHADER);
      //glBindFragDataLocation(id(), 0, "frag"); //agf

      p.link();
    }

    void setUpFBO(FBO &f) {
      //these two commands are equivalent, but usually i am using FBOs with one color attachement + default depth

      //f.create().attach(Texture(256, 256, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE), RBO(256, 256, GL_DEPTH_COMPONENT24));
      //f.create(256, 256); 
      f.create(20, 20); 
      f.texture.minFilter(GL_NEAREST);
      f.texture.maxFilter(GL_NEAREST);
    }

    void onCreate() {

      //loadTexture(texture, "resources/hubble.jpg");
      //loadTexture(texture, "resources/tiny.png");
      loadTexture(texture, "resources/kobus.png");
 
      //loadProgram(program, "resources/texture");
      loadProgram(program, "resources/bicubic");
  
      setUpFBO(fbo);

      mb.init(MeshUtils::makeClipRectangle(), posLoc, -1, texCoordLoc, -1); 


      view = glm::mat4();
      proj = glm::mat4();
      model = glm::mat4();


      glEnable(GL_DEPTH_TEST);
      glViewport(0, 0, width, height);
      glClearColor(0.3,0.3,0.3,1.0);
    }

    void draw(mat4 model, MeshBuffer& mb, Texture& t) {

      program.bind(); {
	glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model));
	glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(view));
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));
	
	glUniform1i(program.uniform("tWidth"), t.width);
	glUniform1i(program.uniform("tHeight"), t.height);

	t.bind(GL_TEXTURE0); {

	  glUniform1i(program.uniform("tex0"), 0);
	  mb.draw();

	} t.unbind(GL_TEXTURE0);

      } program.unbind();
    }

    void onFrame(){


      //draw texture to offscreen buffer
      fbo.bind(); {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	draw(model, mb, texture);

      } fbo.unbind();


      //draw the offscreen buffer to the screen
      glViewport(0, 0, width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      draw(model, mb, fbo.texture);
      //draw(model, mb, texture);
    }
};

int main() {
  return FBOPixelate().start(); 
}
