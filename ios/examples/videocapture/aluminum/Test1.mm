
#import "Includes.hpp"

#import "MeshBuffer.hpp"
#import "MeshData.hpp"
#import "MeshUtils.hpp"
#import "Program.hpp"
#import "Shapes.hpp"
#import "Texture.hpp"

#import "RendererIOS.h"
#import "AppDelegate.h"

#import "ResourceHandler.h"

#import "CaptureManager.h"

#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

using namespace aluminum;
using glm::ivec2;
using glm::to_string;

const int Ryp = 600;
const int Rxp = 600;

class Test1 : public RendererIOS {
    
    
    
public:
    
    
    
    ResourceHandler rh;
    
    
    Program program;
    
    MeshData md;
    MeshBuffer mb;
    
    GLint posLoc = 0;
    //GLint tcLoc = 1;
    
    mat4 proj;
    mat4 mv;
    vec2 TouchCords;
    
    // texture variables
    
    Texture t1;
    GLint tcLoc = 1;
    
    // capture variables
    CaptureManager* cm;
    
    void loadProgram(Program &p, const std::string& name) {
        
        p.create();
        
        string sv = rh.pathToResource(name, "vsh");
        p.attach(rh.contentsOfFile(sv), GL_VERTEX_SHADER);
        
        glBindAttribLocation(p.id(), posLoc, "vertexPosition");
        //  glBindAttribLocation(p.id(), colLoc, "vertexColor");
        glBindAttribLocation(p.id(), tcLoc, "vertexTexCoord");
        
        string sp = rh.pathToResource(name, "fsh");
        p.attach(rh.contentsOfFile(sp), GL_FRAGMENT_SHADER);
        
        p.link();
    }
    
    virtual void onCreate() {
        // Load our shader program
        loadProgram(program, "basicNew");
        
        
        
        
        rh.loadTexture(t1, "grid3.png");
        // create the data mesh
        
        mb.init(MeshUtils::makeSurface(Rxp, Ryp, -1.0, 1.0, -1.0, 1.0, true), posLoc, -1, tcLoc, -1);
      
        // Prjection for plane (-1,1,-1,1) filling the screen
        // camera at 3.0 near plane 1.0
        proj = glm::frustum(-1.0/3.0, 1.0/3.0, -1.0/3.0, 1.0/3.0, 1.0, 20.0);
        mv = glm::lookAt(vec3(0,0,3.0), vec3(0,0,-5.0), vec3(0,1,0) );
        
        glEnable(GL_DEPTH_TEST);
        glEnable (GL_BLEND);
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        
        cm = [[CaptureManager alloc] init:AVCaptureSessionPresetHigh side:AVCaptureDevicePositionFront];
        [cm startCapture];
        
    }
    
    virtual void onFrame(){
        // Clear viewport
        glViewport(0, 0, width, height);
        glClearColor(1.0,1.0,1.0,1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glEnable(GL_TEXTURE_2D);
        
        
        [cm updateTextureWithNextFrame];
        
        if (!cm.textureReady) {
            return;
        }
        
      //  printf("here... drawing texture?\n");
        program.bind(); {
            glUniformMatrix4fv(program.uniform("mv"), 1, 0, ptr(mv));
            glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));
            glUniform2fv(program.uniform("MouseCords"), 1, ptr(TouchCords));
            glUniform1i(program.uniform("tex0"), 0);
            glUniform1i(program.uniform("tex1"), 1);
            t1.bind(GL_TEXTURE1); {
            cm.captureTexture.bind(GL_TEXTURE0); {
                mb.drawTriangleStrip();
            } cm.captureTexture.unbind(GL_TEXTURE0);
                } t1.unbind(GL_TEXTURE1);
            
        } program.unbind();
        
        
    }
    
    
    
    virtual void touchBegan(ivec2 mouse) {
        cout << "touch began: " << to_string(mouse) << endl;
        TouchCords.x = 2*(mouse.x/(float)width - 0.5);
        TouchCords.y = 2*(mouse.y/(float)height - 0.5);
    }
    
    virtual void touchMoved(ivec2 prevMouse, ivec2 mouse) {
        cout << "touch moved: prev:" << to_string(prevMouse) << ", current: " << to_string(prevMouse) << endl;
        TouchCords.x =  2*(mouse.x/(float)width - 0.5);
        TouchCords.y = 2*(mouse.y/(float)height - 0.5);
    }
    
    virtual void touchEnded(ivec2 mouse) {
        cout << "touch ended: " << to_string(mouse) << endl;
    }
    
    virtual void longPress(ivec2 mouse) {
        cout << "long press: " << to_string(mouse) << endl;
    }
    
    virtual void pinch(float scale) {
        cout << "pinch zoom: " << scale << endl;
    }
    virtual void pinchEnded() {
        cout << "pinch ended: " << endl;
    }
    
};


int main(int argc, char *argv[]) {
    
    Test1().start();
    
}
