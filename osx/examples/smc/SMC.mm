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

    int PIXELW = 15;
    int PIXELH = 15;
    float SLIDE = 0.05;
    

    mat4 model, view, proj;

    Program textureProgram, processProgram, bicubicProgram;

    GLint posLoc=0;
    GLint texCoordLoc=1;

    Texture videoFrameTexture, processTextureA, processTextureB;
    MeshBuffer mb1;

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

    void onCreate() {

      vp = [[VideoPlayer alloc] init];   

      setUpFBOPixelate(fboPixelate);
      setUpFBOProcess(fboProcess);
      

      string moviefile = "resources/test3.mov";
      videoFrameTexture = *[vp createVideoTexture:moviefile useAudio:false autoPlay:true autoLoop:true];

      //Texture ttt = *[vp createVideoTexture:moviefile useAudio:false autoPlay:true autoLoop:true];


      loadProgram(textureProgram, "resources/texture");
      loadProgram(bicubicProgram, "resources/bicubic");
      loadProgram(processProgram, "resources/slide");
      
      mb1.init(MeshUtils::makeClipRectangle(), posLoc, -1, texCoordLoc, -1); 

      view = glm::mat4();
      proj = glm::mat4();
      model = glm::mat4();

      glEnable(GL_DEPTH_TEST);
      glViewport(0, 0, width, height);
      glClearColor(0.0,1.0,0.3,1.0);
    }

    int frameNum = 0;


    
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

      //now fbo.texture should be the pixelated video

      //process - slide
      Texture inputTex;
      
      pingPong(frameNum, fboProcess, inputTex, processTextureA, processTextureB);

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

      
      
      //draw output to screen - using a bicubic filter?

      glViewport(0, 0, width, height);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      //Program outputProgram = textureProgram;
      Program outputProgram = bicubicProgram;
      

      outputProgram.bind(); {

	glUniformMatrix4fv(bicubicProgram.uniform("model"), 1, 0, ptr(model));
	glUniformMatrix4fv(bicubicProgram.uniform("view"), 1, 0, ptr(view));
	glUniformMatrix4fv(bicubicProgram.uniform("proj"), 1, 0, ptr(proj));

	glUniform1i(bicubicProgram.uniform("tex0"), 0);


	glUniform1i(bicubicProgram.uniform("tWidth"), fboProcess.texture.width);
	glUniform1i(bicubicProgram.uniform("tHeight"), fboProcess.texture.height);

        fboProcess.texture.bind(GL_TEXTURE0); {
              mb1.draw();	
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
