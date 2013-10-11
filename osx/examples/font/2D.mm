

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

#include "Includes.hpp"

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include "Texture.hpp"
#include "FBO.hpp"
#include "Font.hpp"
#include "Utils.hpp"
#include "Behavior.hpp"
#include "ResourceHandler.h"

using namespace aluminum;

using glm::to_string;
using glm::vec3;
using glm::vec4;
using glm::ivec4;
using glm::mat4;

class Holder {
  public:
    Holder() {};
    Text2D t;
    Behavior b;
};

int NUM_TEXTS = 10; //10

class TextExample : public RendererOSX {
  public:

    GLuint vao;
    ivec4 VP;
    stringstream s;
    int num = 0;
    vector<Holder*> texts;
    Text2D tr, tl, br, bl;
    
    ResourceHandler rh;

    void loadFont(Font& font, const std::string& name) {
      Texture fontTex;
      rh.loadTexture(fontTex, name + ".png");
      //Texture::loadTexture(fontTex, name + ".png");
      fontTex.minFilter(GL_LINEAR);
      fontTex.maxFilter(GL_LINEAR);
      Font::loadFont(font, fontTex, name);
    }

    void onCreate() {

      VP = ivec4(0, 0, width, height);

      Font font;
      
      loadFont(font, "resources/yoyo"); //signed distance font
      //loadFont(font, "resources/checkSD"); //signed distance font
      //loadFont(font, "resources/Univers36"); //signed distance font
      //loadFont(font, "resources/IdealSans-Book"); //signed distance font

      for (int i = 0; i < NUM_TEXTS; i++) {

        Holder* h = new Holder();

        h->t = font.signedDistanceText2D("abc").justify(0,0);

        h->b = Behavior(now()).delay(500).length(Utils::randomLong(1000,5000)).range(1.0).repeats(-1).sine(Easing::IN).reversing(true);

        texts.push_back(h);
      }


      vec4 bc = vec4(0.0,1.0,0.0,0.8);
      vec4 fc = vec4(0.3);

      tl = font.signedDistanceText2D("top left").background(bc).color(fc);
      tr = font.signedDistanceText2D("top right").background(bc).color(fc);
      bl = font.signedDistanceText2D("bottom left").background(bc).color(fc);
      br = font.signedDistanceText2D("bottom right").background(bc).color(fc);

    }

    void onReshape() {
      VP = ivec4(0, 0, width, height);
    }

    void onFrame() {


      glViewport(0, 0, width, height);
      glClearColor(0.0, 0.0, 0.0, 1);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

/*

      for (int i = 0; i < NUM_TEXTS; i++) {

        Holder* h = texts[i];
        float total = h->b.tick(now()).total();
        s.str("");
        //s << (int) (h->t.penX * width);
        s << (int) (total * width);

        h->t.pen(total, 0.5).height(0.25).screen(width, height).background(vec4(total, 0.0, 1.0-total, 0.3)).color(vec4(1.0-total, 0.5, total, 0.3)).text(s.str()).draw();

      }
*/

      /*
         tl.pixel(0,0).height(30).screen(width,height).justify(-1,1).draw();
         bl.pixel(0,height).height(30).screen(width,height).justify(-1,-1).draw();
         tr.pixel(width,0).height(30).screen(width,height).justify(1,1).draw();
       */

      //br.pixel(width,height).size(width,height).screen(VP).justify(1,-1);
      //br.pixel(width,height).width(width).screen(VP).justify(1,-1);
      //br.pixel(width,height).height(height).screen(VP).justify(1,-1);

      //br.pen(0.0,0.0).width(0.5).screen(VP).justify(-1,-1);
      //br.pen(0.0,0.0).height(0.5).screen(VP).justify(-1,-1);
      //br.pen(0.0,0.0).size(0.5, 0.5).screen(VP).justify(-1,-1);
      bl.height(0.5);    
      bl.width(0.5);    
      ivec2 pix = br.pixels();

      //br.draw();
      bl.draw(VP);

      //printf(" pixs = %d/%d\n", pix.x, pix.y);


      //br.height(30).fbo(myFBO); //--> will draw into the FBO texture with proper size
    }
};

int main() {
  return TextExample().start("Text 2D Demo", 10, 10, 600, 200); 
}
