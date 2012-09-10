

/* HACK ALERT - I got the following error:

/usr/include/objc/objc.h:44:22: error: typedef redefinition with different types ('signed char' vs 'int32_t' (aka 'int'))
typedef signed char             BOOL; 
                                ^
/opt/local/include/FreeImage.h:139:17: note: previous definition is here
typedef int32_t BOOL;


pointing to a conflict between objc and freeimage lib. 

to fix, i updated the freeimage lib to use the type BOOL_FI instead of BOOL in all casses

(in /opt/local/include/FreeImage.h)

*/


#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"

#include "Texture.hpp"
#include <vector>

using namespace al;

class TextureExample : public RendererOSX {
  public:

    Mat4f model, view, proj;

    Program program;
    
    GLint posLoc=0;
    GLint texCoordLoc=1;

    Texture texture;

    MeshBuffer mb1;
      
    void loadTexture(Texture& t, const std::string& name) {
      t.loadTextureData2D(t, name).create2D();
    } 


    void loadProgram(Program &p, const std::string& name) {

      p.create();

      p.attach(p.loadText(name + ".vsh"), GL_VERTEX_SHADER);
      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");

      p.attach(p.loadText(name + ".fsh"), GL_FRAGMENT_SHADER);

      p.link();
    }

    void onCreate() {

      loadProgram(program, "resources/texture");
      loadTexture(texture, "resources/hubble.jpg");

      MeshData mesh1;
      addRectangle(mesh1);
      mb1.init(mesh1, posLoc, -1, texCoordLoc, -1); 


      proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      view = Matrix4f::lookAt(Vec3f(0.0,0.0,-3), Vec3f(0,0,0), Vec3f(0,1,0) );
      model = Matrix4f::identity();

      glEnable(GL_DEPTH_TEST);
      glViewport(0, 0, width, height);
      glClearColor(0.3,0.3,0.3,1.0);
    }

    void draw(Mat4f model) {

      program.bind(); {

	glUniformMatrix4fv(program.uniform("model"), 1, 0, model.ptr());
	glUniformMatrix4fv(program.uniform("view"), 1, 0, view.ptr());
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, proj.ptr());

	texture.bind(GL_TEXTURE0);

	glUniform1i(program.uniform("tex0"), 0);

	mb1.draw();	

	texture.unbind(GL_TEXTURE0);

      } program.unbind();
    }

    void onFrame(){
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      draw(model);
    }
};

int main() {
  TextureExample().start(); 
  return 0;
}
