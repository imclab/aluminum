

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

    Program program, passthrough, backgroundProgram;

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

    void loadBackgroundProgram(Program &p, const std::string& name) {

      p.create();

      p.attach(p.loadText(name + ".vsh"), GL_VERTEX_SHADER);
      glBindAttribLocation(p.id(), posLoc, "vertexPosition");

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


      // loadBackgroundProgram(backgroundProgram, "resources/background");

      loadProgram(passthrough, "resources/texture");

      //normal font atlas
      //loadProgram(program, "resources/textureFont");
      loadFont(font, "resources/ooo");

      //signed distance font atals
      // loadProgram(program, "resources/signedDistanceFont");
      //loadFont(font, "resources/checkSD");

      // text = Text(program, font, "{[;!@}]|0");
      //text2 = Text(backgroundProgram, font, "ajkjf38&^Q").justify(0,0).background(Vec4f(0,1,0,1)).color(Vec4f(1.0,0,0.0,1.0));

      // text2 = Text(program, backgroundProgram, font, "abcdefghij").justify(0,0).background(Vec4f(0,1,0,1)).color(Vec4f(1.0,0,0.0,1.0));

      //text2 = font.signedDistanceText("abc").justify(0,0);  
      //text2 = font.text("abcdef").justify(-1,-1).pen(-1,-1).meshFromHeight(mb2, 0.6);  
      //text2 = font.text("0001000").justify(-1,0).pen(0,0).program(program).color(Vec4f(1,1,1,1)).background(Vec4f(0,0,0,0));
      //text2 = font.signedDistanceText("0001000").justify(0,0).pen(0,0).color(Vec4f(1,1,1,1)).background(Vec4f(1,0,0,1));
      text2 = font.text("0001000").justify(0,0).pen(0,0).color(Vec4f(1,1,1,1)).background(Vec4f(1,0,0,1));

      text2.meshFromWidth(2.0, width, height);
      //text2.mesh(width, height, 1.0);
      //text2.meshFromWidth(1.0);


      //text2 = font.signedDistanceText("0001000").justify(-1,-1).pen(-1,-1).mesh(width, height).color(Vec4f(1,1,1,1)).background(Vec4f(0,0,0,0));  
      


      // proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      //  view = Matrix4f::lookAt(Vec3f(0.0,0.0,3), Vec3f(0,0,0), Vec3f(0,1,0) );
      proj = Matrix4f::identity();
      view = Matrix4f::identity();
      model = Matrix4f::identity();
    }


    void drawText(Text t) {
      passthrough.bind(); {
	glUniformMatrix4fv(passthrough.uniform("model"), 1, 0, model.ptr());
	glUniformMatrix4fv(passthrough.uniform("view"), 1, 0, view.ptr());
	glUniformMatrix4fv(passthrough.uniform("proj"), 1, 0, proj.ptr());

	glUniform1i(passthrough.uniform("tex0"), 0);

	t.texture.bind(GL_TEXTURE0); {
	  t.meshBuffer.draw();	
	} t.texture.unbind(GL_TEXTURE0);

      } passthrough.unbind();
    }

    float scaleFont = 0.99;
    float px = -1.0;
    int fn = 0;
    float textw = 0.1;
    float dir = 1;  

    void onFrame() {

/*
      text2.meshFromWidth(textw, width, height);
      textw += 0.5 * dir;
      if (textw > 8.0) {
	textw = 8.0; dir *= -1;
      }
      else if (textw < 0.1) {
	textw = 0.1; dir *= -1;
      }
      //text2.justify(px, -1);
      //text2.color(Vec4f(0.0,1.0,0.0,1.0));
      if (scaleFont < 1.0) {
	//	text2.background(Vec4f(0.0,scaleFont,0.0,1.0));
	fn++;
      }
      px += 0.01;
*/

      glViewport(0, 0, width, height);
      glEnable( GL_BLEND );
      glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

      glClearColor(0.0, 0.0, 0.0, 1); //background color.
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      text2.drawText2(0, -0.5, width, height, scaleFont);

      // scaleFont -= 0.004;

      //if (scaleFont > 1.0) {scaleFont = 0.0;}


      //text2.pen(0.0, 0.0);
      //drawText(text, mb1);
      drawText(text2);
    }
};

int main() {
  return TextExample().start("TextDemo", 10, 10, 500, 500); 
}
