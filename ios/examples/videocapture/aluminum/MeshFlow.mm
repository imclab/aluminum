
#import "Includes.hpp"

#import "MeshBuffer.hpp"
#import "MeshData.hpp"
#import "MeshUtils.hpp"
#import "Program.hpp"
#import "Shapes.hpp"
#import "Texture.hpp"
#include "FBO.hpp"
#import "RendererIOS.h"
#import "AppDelegate.h"

#import "ResourceHandler.h"
#import "CaptureManager.h"

#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

using namespace aluminum;
using glm::ivec2;
using glm::to_string;


//Mesh dimensions

const int MeshX = 180;//214;
const int MeshY = 134;//160;


class MeshFlow : public RendererIOS {
    
    
    
public:
    ResourceHandler rh;
    
    Program programGrad,programMesh;
    FBO fboGrad;
    MeshBuffer clipRect; // for the first texture for gradient calculation
    MeshData md;
    MeshBuffer mb;
    Texture t1;
    
    CaptureManager* cm;
    
    GLint posLoc = 0;
    GLint tcLoc = 1;
    
    mat4 proj;
    mat4 mv;
    vec2 TouchCords;
    
    mat4 webcamMatrix = mat4();
    mat4 touchMatrix = mat4();
    
    void loadProgram(Program &p, const std::string& name) {
        
        p.create();
        
        string sv = rh.pathToResource(name, "vsh");
        p.attach(rh.contentsOfFile(sv), GL_VERTEX_SHADER);
        
        glBindAttribLocation(p.id(), posLoc, "vertexPosition");
        glBindAttribLocation(p.id(), tcLoc, "vertexTexCoord");
        
        string sp = rh.pathToResource(name, "fsh");
        p.attach(rh.contentsOfFile(sp), GL_FRAGMENT_SHADER);
        
        p.link();
    }
    
    virtual void onCreate() {
        // Load our shader program
        loadProgram(programGrad, "GradientCalc");
        loadProgram(programMesh, "Meshflow");
        
        printf("%d %d \n", width, height);
        fboGrad.create(128, 128);
        
        //exit(0);
        //fboGrad.texture.wrapMode(GL_CLAMP_TO_EDGE);
        //rh.loadTexture(t1, "grid3.png");
        // create the data mesh
        //     mb.init(MeshUtils::makeClipGrid(Rxp, Ryp), posLoc, -1, tcLoc, -1);

        clipRect.init(MeshUtils::makeClipRectangle(), posLoc, -1, tcLoc, -1);
        
        // Initial values for the mesh 
        
//        // limits
        float xl = -1.0;
        float yl = -1.0;
        float xu = 1.0;
        float yu = 1.0;
        
        // nodes
        vec3* vs = new vec3[MeshX * MeshY];
        GLuint* is = new GLuint [2*(MeshX-1)*MeshY + 2*(MeshY-1)*MeshX ];
        
        // textu test
          vec3* ts = new vec3[MeshX * MeshY];
        
        
        for (int x = 0; x < MeshX; x++) {
            for (int y = 0; y < MeshY; y++) {
                
                vs[MeshX*y+x].x= xl +x*(xu-xl)/(float)(MeshX-1.0);
                vs[MeshX*y+x].y= yl +y*(yu-yl)/(float)(MeshY-1.0);
                vs[MeshX*y+x].z = 0.0f;
                
//                ts[MeshX*y+x].x = x/(float)MeshX;
//                ts[MeshX*y+x].y = 1.0 - y/(float)MeshY;
//                ts[MeshX*y+x].z = 0.0;
            }
        }
        //indexes
        
        int q = 0;
        
        
        // Horizontal lines
        
        for (int y =0; y<MeshY; y++) {
            for (int x= 0; x < MeshX-1 ; x++) {
                is[q] = x + y*MeshX;
                q++;
                is[q] = (x+1) + y*MeshX;
                q++;
            }
        }
        
        // Vertical lines
        for (int x= 0; x < MeshX ; x++) {
            for (int y =0; y<MeshY-1; y++) {
                is[q] = x + y*MeshX;
                q++;
                is[q] = x + (y+1)*MeshX;
                q++;
            }
        }
        
        
        
        md.vertex(vs,MeshX*MeshY);
        md.index(is, 2*(MeshX-1)*MeshY + 2*(MeshY-1)*MeshX);
 //       md.texCoord(ts, MeshX*MeshY);
        
        mb.init(md, posLoc, -1, -1, -1);
        delete vs;
        delete is;
        delete ts;
        
        

        
        
        
        
        
      //  mb.init(MeshUtils::makeSurface(Rxp, Ryp, -1.0, 1.0, -1.0, 1.0, true), posLoc, -1, tcLoc, -1);
        
        /* Javier -- if you are planning on doing a full screen app, you don't need to use projection - ah I see you are using the z-axis for distorting the mesh */
        // Prjection for plane (-1,1,-1,1) filling the screen
        // camera at 3.0 near plane 1.0
//        proj = glm::frustum(-1.0/10.0, 1.0/10.0, -1.0/10.0, 1.0/10.0, 1.0, 50.0);
//        mv = glm::lookAt(vec3(0,0,10.0), vec3(0,0,-5.0), vec3(0,1,0) );
        proj = glm::mat4();
        mv = glm::mat4();
        
        //set up matrices to account for webcam distortion - this is for front camera/portrait. Will be different for other orientations.
        webcamMatrix = glm::scale(webcamMatrix, vec3(-1.0,1.0,1.0));
        webcamMatrix = glm::rotate(webcamMatrix , -90.0f, vec3(0,0,1));
        mv *= webcamMatrix;
        
        touchMatrix = glm::scale(touchMatrix, vec3(1.0,-1.0,1.0));
        touchMatrix = glm::rotate(touchMatrix , -90.0f, vec3(0,0,1));
        
        
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
        
        // Gradient Calculation
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        fboGrad.bind(); {
        
            programGrad.bind(); {
            
                glUniformMatrix4fv(programGrad.uniform("mv"), 1, 0, ptr(mv));
                glUniformMatrix4fv(programGrad.uniform("proj"), 1, 0, ptr(proj));
                // sending the dimensions of the image
                glUniform2fv(programGrad.uniform("CamDims"), 1, ptr(vec2(width, height)));
                glUniform1i(programGrad.uniform("tex0"), 0);
                //glUniform1i(program.uniform("tex1"), 1);
                
                cm.captureTexture.bind(GL_TEXTURE0);{
                    clipRect.draw();
                } cm.captureTexture.unbind(GL_TEXTURE0);
                
            } programGrad.unbind();
        } fboGrad.unbind();
      
        
        glBindFramebuffer(GL_FRAMEBUFFER, getDefaultFrameBuffer());


        
        glViewport(0, 0, width, height);
        glClearColor(1.0,0.0,0.0,1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        printf("wh %d %d\n",width, height);
        
      
    // drawing the mesh
        programMesh.bind(); {
            glUniformMatrix4fv(programMesh.uniform("mv"), 1, 0, ptr(mv));
            glUniformMatrix4fv(programMesh.uniform("proj"), 1, 0, ptr(proj));
            mb.drawLines();
        } programMesh.unbind();
        
        
        
        
        
        
        
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
    
    MeshFlow().start();
    
}
