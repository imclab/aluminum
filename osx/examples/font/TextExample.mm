

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
#include "Behavior.hpp"

#define GLM_SWIZZLE
#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>

#include <iostream>
#include <chrono>


using namespace aluminum;

using glm::to_string;
using glm::vec3;
using glm::vec4;
using glm::ivec4;
using glm::mat4;

class TextExample : public RendererOSX {
  public:

    mat4 model, view, proj;

    Program program, singleTexture, backgroundProgram;

    GLint posLoc=0;
    GLint texCoordLoc=1;

    Texture texture;
    Text text;
    Text text2;

    Behavior beh;
    Behavior beh2;

    void loadProgram(Program& p, const std::string& name) {

      p.create();

      p.attach(p.loadText(name + ".vsh"), GL_VERTEX_SHADER);
      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");

      p.attach(p.loadText(name + ".fsh"), GL_FRAGMENT_SHADER);

      p.link();
    }

    void loadFont(Font& font, const std::string& name) {
      Texture fontTex;
      Texture::loadTexture(fontTex, name + ".png");
      Font::loadFont(font, fontTex, name);
    }

    void onCreate() {

      //still need to test the glm::project method to get right font size
      //  when not using clip space!
      
      proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
      view = glm::lookAt(vec3(2.0,0.0,5.0), vec3(0,0,0), vec3(0,1,0) );

     // proj = mat4();
     // view = mat4();
      model = mat4();

      vec3 sLL = glm::project(vec3(0,0,0), view*model, proj, ivec4(0,0,width,height));
      vec3 sUR = glm::project(vec3(1,1,0), view*model, proj, ivec4(0,0,width,height));

      cout << " LL: " << glm::to_string(sLL) << " \n UR: " << glm::to_string(sUR) << "\n";



      loadProgram(singleTexture, "resources/texture");

      //loadFont(font, "resources/ooo"); //texture font
      //text2 = font.text("0001000").justify(0,0).pen(0,0).color(vec4(1,1,1,1)).background(vec4(1,0,0,1));

      Font font;
      loadFont(font, "resources/checkSD"); //signed distance font
      printf("in onCreate : font ptr = %p\n", &font);
      text2 = font.signedDistanceText("0001000").justify(1,1).pen(-1,0).color(vec4(1,1,0.0,0.5)).background(vec4(1,0,0,0.2));
       
     //text2.meshFromWidth(1.0, width, height);
     text2.meshFromWidth(2.0, model, view, proj, ivec4(0,0,width,height) );
      


      //text2.mesh(width, height, 1.0);
      //text2.meshFromWidth(1.0);

      
    beh = Behavior(now()).delay(1000).length(8000).range(360.0).repeats(-1).sine(Easing::IN).reversing(true);
    beh2 = Behavior(now()).delay(1000).length(5000).range(-5.0).repeats(-1).reversing(true);

    }


    void drawText(Text t) {
      singleTexture.bind(); {
	glUniformMatrix4fv(singleTexture.uniform("model"), 1, 0, ptr(model));
	glUniformMatrix4fv(singleTexture.uniform("view"), 1, 0, ptr(view));
	glUniformMatrix4fv(singleTexture.uniform("proj"), 1, 0, ptr(proj));

	glUniform1i(singleTexture.uniform("tex0"), 0);

	t.texture.bind(GL_TEXTURE0); {
	  t.meshBuffer.draw();	
	} t.texture.unbind(GL_TEXTURE0);

      } singleTexture.unbind();
    }

    void onReshape() {
     
      text2.meshFromWidth(1.0, width, height);
    }

    void onFrame() {

      //update view     

      float offset = beh2.tick(now()).total();
      //view = glm::lookAt(vec3(0.0,0.0,5.0+offset), vec3(0,0,0), vec3(0,1,0) );


      //update model - 3D text only

      float total = beh.tick(now()).total();
      //printf("offset = %f\n", beh.offset());
      printf("total = %f\n", total);
      model = mat4();

      model = glm::translate(model, vec3(-text2.meshW/2.0, -text2.meshH/2.0, 0.0));


      model = glm::translate(model, vec3(text2.meshW / 2.0, text2.meshH/2.0, 0.0));
      model = glm::rotate(model, total, vec3(0,0,1));   
      model = glm::translate(model, vec3(-text2.meshW / 2.0, -text2.meshH/2.0, 0.0));

      text2.meshFromWidth(2.0, model, view, proj, ivec4(0,0,width,height) );



      glViewport(0, 0, width, height);
      
      //depth test must be OFF when drawing text - should probably put this in the Font class directly...
      //glEnable( GL_DEPTH_TEST);
      glEnable( GL_BLEND );
      glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

      glClearColor(0.0, 0.0, 0.0, 1); //background color.
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      text2.drawText2(0, 0, width, height, 1.0);

      drawText(text2);
    }
};

int main() {
  return TextExample().start("TextDemo", 10, 10, 500, 500); 
}
