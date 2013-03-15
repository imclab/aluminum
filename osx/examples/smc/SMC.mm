#include "Includes.hpp"

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include "Texture.hpp"
#include "FBO.hpp"

#include <string> 
#import "VideoPlayer.h"


using namespace aluminum;
using std::string;

class SMC : public RendererOSX {
  
  public:

    int PIXELW = 500;
    int PIXELH = 500;
    float SLIDE = 0.05;
    

    mat4 model, view, proj;

    Program textureProgram, processProgram, bicubicProgram;

    GLint posLoc=0;
    GLint texCoordLoc=1;

    Texture videoFrameTexture, processTextureA, processTextureB;
    Texture inputTex; 

    MeshBuffer mb1;
    MeshBuffer mb2;
    MeshBuffer mb3;

    VideoPlayer* vp;

    FBO fboPixelate;
    FBO fboProcess;
 
    


    void setUpFBOPixelate(FBO &f) {
      f.create(PIXELW, PIXELH); 
    }
    
    void setUpFBOProcess(FBO &f) {

      f.create(); //empty FBO
      processTextureA = Texture(PIXELW, PIXELH, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
      processTextureB = Texture(PIXELW, PIXELH, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
    }

    void loadTexture(Texture& t, const std::string& name) {
      t.loadTexture(t, name);
    } 

    void loadProgram(Program &p, const std::string& name) {

      p.create();

      p.attach(p.loadText(name + ".vsh"), GL_VERTEX_SHADER);
      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");

      p.attach(p.loadText(name + ".fsh"), GL_FRAGMENT_SHADER);

      p.link();
    }

    void setUpRect(MeshData &r, vec2 v, float b) {

 
	//r->reset();
	r.texCoords().push_back( vec3(1+b,2+b,3+b));
	r.texCoords().push_back( vec3(5+b,6+b,7+b));

    }

    void onCreate() {

      cout << "hi! " << endl;

      vp = [[VideoPlayer alloc] init];   

      setUpFBOPixelate(fboPixelate);
      setUpFBOProcess(fboProcess);


      string moviefile = "resources/test3.mov";
      videoFrameTexture = *[vp createVideoTexture:moviefile useAudio:false autoPlay:true autoLoop:true];

      //Texture ttt = *[vp createVideoTexture:moviefile useAudio:false autoPlay:true autoLoop:true];


      loadProgram(textureProgram, "resources/texture");
      loadProgram(bicubicProgram, "resources/bicubic");
      loadProgram(processProgram, "resources/slide");

/*
    MeshData rect2;
    MeshData rect3;
   
      cout << "hi again! " << endl;

      //MeshUtils::makeRectangle3(rect2, vec2(-1,-1), vec2(1,1), vec2(0,0), vec2(2,2));
      //MeshUtils::makeRectangle3(rect3, vec2(-1,-1), vec2(1,1), vec2(0,1), vec2(3,0));
      rect2 = MeshUtils::makeRectangle( vec2(-1,-1), vec2(1,1), vec2(0,0), vec2(2,2));
      rect3 = MeshUtils::makeRectangle( vec2(-1,-1), vec2(1,1), vec2(0,1), vec2(3,0));

    //  printf("r2 %p\n", rect2);
    //  printf("r3 %p\n", rect3);
  
      mb1.init( rect2, posLoc, -1, texCoordLoc, -1); 
      mb2.init( rect3, posLoc, -1, texCoordLoc, -1); 


    for (unsigned i=0; i < rect2.texCoords().size(); i++) {
      cout << "r2 " << glm::to_string(rect2.texCoords().at(i)) << endl;
    }
    for (unsigned i=0; i < rect3.texCoords().size(); i++) {
      cout << "r3 " << glm::to_string(rect3.texCoords().at(i)) << endl;
    }

*/
    
//      printf("wtf rect1=%p rect2=%p, rect3=%p\n", (void*)rect1, (void*)rect2, (void*)rect3);

    mb1.init(MeshUtils::makeClipRectangle(false, false), posLoc, -1, texCoordLoc, -1); 
    mb2.init(MeshUtils::makeClipRectangle(true, true), posLoc, -1, texCoordLoc, -1); 

      view = glm::mat4();
      proj = glm::mat4();
      model = glm::mat4();

      glEnable(GL_DEPTH_TEST);
      glViewport(0, 0, width, height);
      glClearColor(0.0,1.0,0.3,1.0);
    }

    int frameNum = 0;


    void calculateMetrics(FBO& f, int frameNum) {
      f.bind(); {
        calculateMetrics(f.texture, frameNum);
      } f.unbind();

    }

    void calculateMetrics(Texture& rt, int frameNum) {

        bool PRINT = false;
        rt.bind(); {

          GLubyte *data = (GLubyte*)malloc(4 * rt.width * rt.height);
          glReadPixels(0, 0, rt.width, rt.height, GL_RGBA, GL_UNSIGNED_BYTE, data);

          int idx = 0;
          if (PRINT) printf("\n\n***Reading Frame %d\n", frameNum);
          for (int i = 0; i < rt.height; i++) {
            for (int j = 0; j < rt.width; j++) {
              if (PRINT) printf("pixel (%d,%d) = RGB:  ", j, i);
              for (int v = 0; v < 4; v++) {
                if (PRINT) printf(" %d ", data[idx++]);
              }
              if (PRINT) printf("}\n");
            }
          }

        } rt.unbind();
    }

    void pingPong(int frameNum, FBO &fbo, Texture &inputTex, Texture &pA, Texture &pB) {

      if (frameNum % 2 == 0) {
        fbo.attach(pB); //we will write into texB
        inputTex = pA;
      } else {
        fbo.attach(pA); //we will write into texA
        inputTex = pB;
      }
    }


    void onFrame(){

      [vp nextFrame];

      //pixelate the video texture

      fboPixelate.bind(); {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        textureProgram.bind(); {

          glUniformMatrix4fv(textureProgram.uniform("model"), 1, 0, ptr(model));
          glUniformMatrix4fv(textureProgram.uniform("view"), 1, 0, ptr(view));
          glUniformMatrix4fv(textureProgram.uniform("proj"), 1, 0, ptr(proj));

          glUniform1i(textureProgram.uniform("tex0"), 0);

          videoFrameTexture.bind(GL_TEXTURE0); {
            mb1.draw();	
          } videoFrameTexture.unbind(GL_TEXTURE0);

        } textureProgram.unbind();
      } fboPixelate.unbind();


      //calculateMetrics(fboPixelate, frameNum);
      //calculateMetrics(videoFrameTexture, frameNum);



      //now fbo.texture should be the pixelated video

      //process - slide      
      pingPong(frameNum, fboProcess, inputTex, processTextureA, processTextureB);

      //printf("B inputTex = %i and fboProcess attach = %i\n", inputTex.id(), fboProcess.texture.id()); 

      fboProcess.bind(); {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        processProgram.bind(); {

          glUniformMatrix4fv(processProgram.uniform("model"), 1, 0, ptr(model));
          glUniformMatrix4fv(processProgram.uniform("view"), 1, 0, ptr(view));
          glUniformMatrix4fv(processProgram.uniform("proj"), 1, 0, ptr(proj));

          glUniform1i(processProgram.uniform("curTex"), 0);
          glUniform1i(processProgram.uniform("prevTex"), 1);
          glUniform1f(processProgram.uniform("slideFactor"), SLIDE);

          fboPixelate.texture.bind(GL_TEXTURE0);
          inputTex.bind(GL_TEXTURE1);

          mb1.draw();	
          fboPixelate.texture.unbind(GL_TEXTURE0);
            inputTex.unbind(GL_TEXTURE1);

          } processProgram.unbind();
      } fboProcess.unbind();

      //calculateMetrics(fboProcess, frameNum);
  
      
      //draw output to screen - using a bicubic filter?

      glViewport(0, 0, width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      Program outputProgram = textureProgram;
      //Program outputProgram = bicubicProgram;
      

      outputProgram.bind(); {

	glUniformMatrix4fv(outputProgram.uniform("model"), 1, 0, ptr(model));
	glUniformMatrix4fv(outputProgram.uniform("view"), 1, 0, ptr(view));
	glUniformMatrix4fv(outputProgram.uniform("proj"), 1, 0, ptr(proj));

	glUniform1i(outputProgram.uniform("tex0"), 0);


	//glUniform1i(outputProgram.uniform("tWidth"), fboProcess.texture.width);
	//glUniform1i(outputProgram.uniform("tHeight"), fboProcess.texture.height);
	glUniform1i(outputProgram.uniform("tWidth"), fboPixelate.texture.width);
	glUniform1i(outputProgram.uniform("tHeight"), fboPixelate.texture.height);

     
/*
	fboPixelate.texture.bind(GL_TEXTURE0); {
              mb2.draw();	
        } fboPixelate.texture.unbind(GL_TEXTURE0);
     

	videoFrameTexture.bind(GL_TEXTURE0); {
              mb2.draw();	
        } videoFrameTexture.unbind(GL_TEXTURE0);
  */   
	
        fboProcess.texture.bind(GL_TEXTURE0); {
              mb2.draw();	
        } fboProcess.texture.unbind(GL_TEXTURE0);
	

      } outputProgram.unbind();
    
    
      frameNum++;
    
    }

    void onReshape() {
      glViewport(0, 0, width, height);
    }

    void mouseMoved(int px, int py) {
    }

};


int main() {
  return SMC().start(); 
}
