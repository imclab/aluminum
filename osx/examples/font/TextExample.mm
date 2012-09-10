

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
#include "FBO.hpp"
#include "Font.hpp"

#include <iostream>


using namespace al;

class TextExample : public RendererOSX {
  public:

    Mat4f model, view, proj;

    Program program, passthrough;
    
    GLint posLoc=0;
    GLint texCoordLoc=1;

    Texture texture;
    MeshBuffer mb1, mb2;
    //FBO fbo;      
    Font font;
    Text text;
    Text text2;

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

    void loadFont(Font &fa, const std::string& name) {
      //fa = Font(name);
    Texture fontTex;
    loadTexture(fontTex, name + ".png"); 


      fa.loadFont(fa, fontTex, name);
std::cout << "texture name ... " << name << "\n";
      //loadTexture(texture, name + ".png");
      //loadAtlas(name + ".fnt");

     // exit(0);
    }

    void onCreate() {

      loadProgram(program, "resources/font");
      loadProgram(passthrough, "resources/texture");
      loadFont(font, "resources/test5");
    
      text = Text(program, font, "{[;!@}]|0");
      text2 = Text(program, font, "a");


      //text = Text(program, font, "ajaja12kkj");

      MeshData mesh1;
      addRectangle(mesh1, ((float)text.texture.width/(float)text.texture.width), (float)text.texture.height/(float)text.texture.width);
      mb1.init(mesh1, posLoc, -1, texCoordLoc, -1); 

      MeshData mesh2;
      addRectangle(mesh2, ((float)text2.texture.width/(float)text2.texture.width), (float)text2.texture.height/(float)text2.texture.width);
      mb2.init(mesh2, posLoc, -1, texCoordLoc, -1); 



     proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      view = Matrix4f::lookAt(Vec3f(0.0,0.0,3), Vec3f(0,0,0), Vec3f(0,1,0) );
      //proj = Matrix4f::identity();
      //view = Matrix4f::identity();
      model = Matrix4f::identity();

        
    }

    void drawText(Text t, MeshBuffer mb) {
      passthrough.bind(); {

	glUniformMatrix4fv(passthrough.uniform("model"), 1, 0, model.ptr());
	glUniformMatrix4fv(passthrough.uniform("view"), 1, 0, view.ptr());
	glUniformMatrix4fv(passthrough.uniform("proj"), 1, 0, proj.ptr());

	glUniform1i(passthrough.uniform("tex0"), 0);

	t.texture.bind(GL_TEXTURE0); {
	  mb.draw();	
	} t.texture.unbind(GL_TEXTURE0);

      } passthrough.unbind();
    }


    void onFrame(){

      glViewport(0, 0, width, height);
      glEnable( GL_BLEND );
      glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
     
      glClearColor(0.5,0.0,0.0,1); //background color.
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      drawText(text, mb1);
      drawText(text2, mb2);
    }
};

int main() {
  return TextExample().start("TextDemo", 10, 10, 400, 400); 
}
