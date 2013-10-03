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
#include "Metrics.h"

using namespace aluminum;
using std::string;
using std::cout;
using std::endl;


class SMC : public RendererOSX {
    
public:
    
    string RESOURCES = (string)[NSHomeDirectory() UTF8String] + "/Dropbox/XCodeProjects/aluminum/osx/examples/videoprocessing/aluminum/resources/";
    
    int PIXELW = 30;
    int PIXELH = 30;
    int TOTAL_FRAMES = 250;
    float SLIDE = 1.0;
    
    
    mat4 model, view, proj;
    
    
    GLint posLoc=0;
    GLint texCoordLoc=1;
    
    
    MeshBuffer mb1;
    MeshBuffer mb2;
    MeshBuffer mb3;
    
    VideoPlayer* vp;
    
    
    Texture videoFrameTexture;
    Program textureProgram, bicubicProgram;
    FBO fboPixelate;
    
    //process video
    Program processProgram;
    Texture processTextureA, processTextureB, inputTex;
    FBO fboProcess;
    
    //get metrics on video
    Program metricProgram, averageProgram, peakProgram;
    Texture metricTextureA, metricTextureB, metricInputTexture;
    FBO fboMetric;
    
    Metrics metrics = Metrics(PIXELW, PIXELH, TOTAL_FRAMES);
    
    
    
    
    void setUpFBOPixelate(FBO &f) {
        f.create(PIXELW, PIXELH);
    }
    
    
    void setUpFBOProcess(FBO &f) {
        
        f.create(); //empty FBO
        processTextureA = Texture(PIXELW, PIXELH, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
        processTextureB = Texture(PIXELW, PIXELH, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
    }
    
    void setUpFBOMetric(FBO &f) {
        
        f.create(); //empty FBO
        metricTextureA = Texture(PIXELW, PIXELH, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
        metricTextureB = Texture(PIXELW, PIXELH, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
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
        setUpFBOMetric(fboMetric);
        
        
        string moviefile = RESOURCES +"test3.mov"; //resources/test3.mov";
        cout << "moviefile = " << moviefile <<"\n";
        videoFrameTexture = *[vp createVideoTexture:moviefile useAudio:false autoPlay:true autoLoop:true];
        
        loadProgram(textureProgram, RESOURCES + "texture");
        loadProgram(bicubicProgram, RESOURCES + "bicubic");
        loadProgram(processProgram, RESOURCES + "slide");
        loadProgram(metricProgram, RESOURCES  + "average");
        
        
        mb1.init(MeshUtils::makeClipRectangle(true, true), posLoc, -1, texCoordLoc, -1);
        mb2.init(MeshUtils::makeClipRectangle(), posLoc, -1, texCoordLoc, -1);
        
        view = glm::mat4();
        proj = glm::mat4();
        model = glm::mat4();
        
        glEnable(GL_DEPTH_TEST);
        glViewport(0, 0, width, height);
        glClearColor(0.0,1.0,0.3,1.0);
    }
    
    int frameNum = 0;
    int videoFrameNum = 0;
    
    
    
    void printTexture(FBO& f, int frameNum) {
        f.bind(); {
            printTexture(f.texture, frameNum);
        } f.unbind();
        
    }
    
    void printTexture(Texture& rt, int frameNum) {
        
        bool PRINT = false;
        rt.bind(); {
            
            GLubyte *data = (GLubyte*)malloc(4 * rt.width * rt.height);
            glReadPixels(0, 0, rt.width, rt.height, GL_RGBA, GL_UNSIGNED_BYTE, data);
            
            int idx = 0;
            if (PRINT) printf("\n\n***Reading Frame %d\n", frameNum);
            for (int j = 0; j < rt.height; j++) {
                for (int i = 0; i < rt.width; i++) {
                    if (PRINT) printf("pixel (%d,%d) = RGB:  ", i, j);
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
        
        bool newFrame = [vp nextFrame];
        
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
        
        
        //printTexture(fboPixelate, frameNum);
        //printTexture(videoFrameTexture, frameNum);
        
        if (newFrame == true) {
            printf("videoFrameNum = %d\n", videoFrameNum);
            metrics.calculatePeaks(fboPixelate, videoFrameNum);
            metrics.calculateNeighborDistance(fboPixelate, videoFrameNum);
            metrics.calculateGlobalPeaks(fboPixelate, videoFrameNum);
            
        }
        
        if (videoFrameNum == TOTAL_FRAMES) {
            metrics.printFinalMetrics();
            exit(0);
        }
        
        if (newFrame == true) {
            videoFrameNum++;
        }
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
                
                mb2.draw();
                fboPixelate.texture.unbind(GL_TEXTURE0);
                inputTex.unbind(GL_TEXTURE1);
                
            } processProgram.unbind();
        } fboProcess.unbind();
        
        //metrics
        
        Program metricProgram = averageProgram;
        
        pingPong(frameNum, fboMetric, metricInputTexture, metricTextureA, metricTextureB);
        
        fboMetric.bind(); {
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            metricProgram.bind(); {
                
                glUniformMatrix4fv(processProgram.uniform("model"), 1, 0, ptr(model));
                glUniformMatrix4fv(processProgram.uniform("view"), 1, 0, ptr(view));
                glUniformMatrix4fv(processProgram.uniform("proj"), 1, 0, ptr(proj));
                
                glUniform1i(processProgram.uniform("curTex"), 0);
                glUniform1i(processProgram.uniform("prevTex"), 1);
                glUniform1i(processProgram.uniform("frameNum"), frameNum);
                
                fboProcess.texture.bind(GL_TEXTURE0); //cur
                metricInputTexture.bind(GL_TEXTURE1); //prev metrics
                mb2.draw();
                fboProcess.texture.unbind(GL_TEXTURE0);
                metricInputTexture.unbind(GL_TEXTURE1);
                
            } metricProgram.unbind();
        } fboMetric.unbind();
        
        //printTexture(fboProcess, frameNum);
        printTexture(fboMetric, frameNum);
        
        
        
        
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
