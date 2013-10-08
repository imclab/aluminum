

#include "Includes.hpp"

#include "Texture.hpp"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "FBO.hpp"
#include "Utils.hpp"

#include "RendererOSX.h"
#include "ResourceHandler.h"


using namespace aluminum;

class CellularAutomataEx : public RendererOSX {
public:
    
    int numCols = 200;
    int numRows = 200;
    
    Program caProgram, outputProgram;
    FBO fboA, fboB;
    
    GLint posLoc=0;
    GLint texCoordLoc=1;
    
    mat4 proj, view, model;
    
    MeshBuffer clipRect, outputRect;
    
    ResourceHandler rh;
    
    void loadProgram(Program &p, const std::string& name) {
        
        bindDefaultVAO();
        
        p.create();
        
        string sv = rh.pathToResource(name, "vsh");
        p.attach(rh.contentsOfFile(sv), GL_VERTEX_SHADER);
        glBindAttribLocation(p.id(), posLoc, "vertexPosition");
        glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");
      
        
        string sp = rh.pathToResource(name, "fsh");
        p.attach(rh.contentsOfFile(sp), GL_FRAGMENT_SHADER);
        p.link();
    }
    
    void initFBOs() {
        
        fboA.create(numCols, numRows);
        fboB.create(numCols, numRows);
        
        //make sure textures are on repeat so the system will loop around walls instead of die at the edges
        fboA.texture.wrapMode(GL_REPEAT);
        fboB.texture.wrapMode(GL_REPEAT);
        
        //add some random data to the first texture to start the CA system
        Utils::randomSeed();
        GLubyte val;
        
        for (int i = 0; i < numCols * numRows * 4; i+=4) {
            if ( Utils::random() > 0.6) {
                val = 0;
            } else {
                val = 255;
            }
            
            fboB.texture.data[i] = fboB.texture.data[i+1] = fboB.texture.data[i+2] = val;
            fboB.texture.data[i+3] = 255;
        }
        
        fboB.texture.updateData();
        
    }
    
    virtual void onCreate() {
        
        loadProgram(outputProgram, "texture");
        loadProgram(caProgram, "CA");
        
        clipRect.init(MeshUtils::makeClipRectangle(), posLoc, -1, texCoordLoc, -1);
        outputRect.init(MeshUtils::makeRectangle(1.5, 1.5), posLoc, -1, texCoordLoc, -1);
        
        initFBOs();
        
        proj = glm::mat4();
        view = glm::mat4();
        model = glm::mat4();
        
        glEnable (GL_BLEND);
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        glClearColor(0.3, 0.3, 0.3, 1.0);
        
        
    }
    
    void drawOutput(Texture t) {
        
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        outputProgram.bind(); {
            
            glUniformMatrix4fv(outputProgram.uniform("model"), 1, 0, ptr(model));
            glUniformMatrix4fv(outputProgram.uniform("view"), 1, 0, ptr(view));
            glUniformMatrix4fv(outputProgram.uniform("proj"), 1, 0, ptr(proj));
            glUniform1i(outputProgram.uniform("tex0"), 0);
            
            t.bind(GL_TEXTURE0); {
                outputRect.draw();
            } t.unbind(GL_TEXTURE0);
            
        } outputProgram.unbind();
    }
    
    
    void updateSystem(FBO fbo, Texture t) {
        
        caProgram.bind(); {
            
            glUniform1f(caProgram.uniform("du"), 1.0/numCols);
            glUniform1f(caProgram.uniform("dv"), 1.0/numRows);
            
            glUniform1i(caProgram.uniform("tex"), 0);
            
            fbo.bind(); {
                t.bind(GL_TEXTURE0); {
                    clipRect.draw();
                } t.unbind(GL_TEXTURE0);
            } fbo.unbind();
            
            
        } caProgram.unbind();
    }
    
    virtual void onFrame(){
        
        handleKeys();
        handleMouse();
        
        if (frameCount % 2 == 0) {
            updateSystem(fboA, fboB.texture);
            drawOutput(fboA.texture);
        } else {
            updateSystem(fboB, fboA.texture);
            drawOutput(fboB.texture);
        }
        
    }
    
    void handleMouse() {
        if (isDragging) {
            printf("in Basic: mouseDragged %d/%d\n", mouseX, mouseY);
        }
        
        if (isMoving) {
            printf("in Basic: mouseMoved %d/%d\n", mouseX, mouseY);
        }
        
        if (isPressing) {
            printf("in Basic: mouseDown %d/%d\n", mouseX, mouseY);
        }
        
        
        if (isReleasing) {
            printf("in Basic: mouseUp %d/%d\n", mouseX, mouseY);
        }
        
        isDragging = false;
        isMoving = false;
        isPressing = false;
        isReleasing = false;
    }
    
    void handleKeys() {
        
        if (keysDown[kVK_ANSI_A]) {
            printf("you pressed an 'A'! \n");
            keysDown[kVK_ANSI_A] = false;
        }
        
        if (keysUp[kVK_ANSI_A]) {
            printf("you released an 'A'! \n");
            keysUp[kVK_ANSI_A] = false;
        }
    }
    
};

int main(){
    return CellularAutomataEx().start("aluminum::Cellular Automata", 100, 100, 800, 600);
}
