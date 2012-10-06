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

/*
#define GLM_SWIZZLE
#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>

#include <iostream>
#include <chrono>
#include <sstream> 
*/

using namespace aluminum;

using glm::to_string;
using glm::vec3;
using glm::vec4;
using glm::ivec4;
using glm::mat4;

class Holder {
  public:
    Holder() {};
    Text3D t;
    Behavior br;
    Behavior bt;
    mat4 M;
};

int NUM_TEXTS = 70; //30;

class TextExample : public RendererOSX {
  public:

    stringstream s;
    int num = 0;
    vector<Holder*> texts;
    mat4 P, V;
    ivec4 VP;

    void loadFont(Font& font, const std::string& name) {
      Texture fontTex;
      Texture::loadTexture(fontTex, name + ".png");
      Font::loadFont(font, fontTex, name);
    }

    void onCreate() {

      //P = mat4();
      //V = mat4();
      P = glm::perspective(45.0, (double)width/(double)height, 0.1, 100.0);
      V = glm::lookAt(vec3(0.0,0.0,25), vec3(0,0,0), vec3(0,1,0) );
           
   
      VP = ivec4(0,0,width,height);
   
      Font font;
      loadFont(font, "resources/checkSD"); //signed distance font

      
      for (int i = 0; i < NUM_TEXTS; i++) {
	
	Holder* h = new Holder();
	h->t = font.signedDistanceText3D("abc");
	h->t.background(vec4(0.5,0.5,0.5,0.0));
	h->t.color(Utils::randomColor(0.3, 0.7, 0.5));
        h->br = Behavior(now()).delay(500).length(Utils::randomLong(1000,10000)).range(360).repeats(-1).sine(Easing::IN).reversing(true);
        h->bt = Behavior(now()).delay(500).length(Utils::randomLong(1000,10000)).range(25.0).repeats(-1).sine(Easing::IN).reversing(true);
	h->M = mat4();


	texts.push_back(h);
      }
      
    }

    void onReshape() {
      VP = ivec4(0,0,width,height);
      P = glm::perspective(45.0, (double)width/(double)height, 0.1, 100.0);
    }

    void onFrame() {

      glViewport(0, 0, width, height);
      glClearColor(0.0, 0.0, 0.0, 1);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      for (int i = 0; i < NUM_TEXTS; i++) {

	Holder* h = texts[i];
	float totalR = h->br.tick(now()).total();
	float totalT = h->bt.tick(now()).total();
	
	s.str("");
	s << "{" << (int) (totalT) << "}";
	h->t.text(s.str());
	
	h->t.width(1.0);
	vec2 bounds = h->t.bounds();
	h->M = mat4();
	
	h->M = glm::translate(h->M, vec3(-bounds.x/2.0, -bounds.y/2.0,totalT));
	
	h->M = glm::translate(h->M, vec3(bounds.x/2.0, bounds.y/2.0,0.0));
	h->M = glm::rotate(h->M, totalR, vec3(0.0,0.0,1.0));
	h->M = glm::translate(h->M, -vec3(bounds.x/2.0, bounds.y/2.0,0.0));
	//printf("totalR = %f\n", totalR);
	h->t.draw( h->M, V, P, VP );

      }

    }
};

int main() {
  return TextExample().start("Text 3D Demo", 10, 10, 1200, 400); 
}
