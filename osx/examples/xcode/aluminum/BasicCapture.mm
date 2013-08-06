
#include "Texture.hpp"

#include "Includes.hpp"

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"

#include "CaptureManager.h"

#include "ResourceHandler.h"

#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

using namespace aluminum;

class CaptureEx : public RendererOSX {
public:
    
    Program program;
    GLuint vao, vbo, ibo, indices[3] = {0,1,2};
    
    vec3 vertices[6] = {
        vec3( -1.0, -1.0, 0.0 ), vec3( 0.0, 1.0, 0.0 ), vec3( 1.0, -1.0, 0.0 ), //vertex
        vec3( 1.0,0.0,0.0 ), vec3( 0.0,1.0,0.0 ), vec3( 0.0,0.0,1.0 ), //color
    };
    
     
    GLint posLoc=0;
    GLint texCoordLoc=1;
    
    
    mat4 proj;
    mat4 view;
    mat4 model;
    
    
    //mat4 mv;
    
    MeshBuffer mb1;
    
    CaptureManager* cm;
    //Texture captureTexture;
    
    ResourceHandler rh;
    
    void loadProgram(Program &p, const std::string& name) {
        
        p.create();
        
        string sv = rh.pathToResource(name, "vsh");
        // cout << "path of vertex shader is: " << sv << endl;
        
        p.attach(rh.contentsOfFile(sv), GL_VERTEX_SHADER);
        
        glBindAttribLocation(p.id(), posLoc, "vertexPosition");
        glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");
        
        string sp = rh.pathToResource(name, "fsh");
        // cout << "path of vertex shader is: " << sp << endl;
        
        p.attach(rh.contentsOfFile(sp), GL_FRAGMENT_SHADER);
        
        p.link();
    }
    
    virtual void onCreate() {
        
        //rh.loadTexture(captureTexture, "mak.png");
        
        loadProgram(program, "texture");
        
        mb1.init(MeshUtils::makeRectangle(), posLoc, -1, texCoordLoc, -1);
        
        
        proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
        view = glm::lookAt(vec3(0.0,0.0,-2), vec3(0,0,0), vec3(0,1,0) );
        model = glm::mat4();
        
        glEnable(GL_TEXTURE_2D);
        glEnable(GL_DEPTH_TEST);
        glViewport(0, 0, width, height);
        glClearColor(0.3,0.3,0.3,1.0);
        
        
        
        //test video capture
        cm = [[CaptureManager alloc] init];

        [cm createCaptureTexture];
        
        
        //captureTexture = Texture(640, 480, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
        //[cm startCapture:captureTexture];
        
        
        
        
        
    }
    
    virtual void onFrame(){
        
        if (1==1) return;
       /*
         if (cm->isLocked == true) {
             printf("returing from of!\n");
             glClearColor(0.0,0.0,1.0,1.0);
             glViewport(0, 0, width, height);
             glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
             return;
         }
         
         if (cm->newFrame == false) {
             glClearColor(1.0,0.0,0.0,1.0);
             glViewport(0, 0, width, height);
             glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
         return;
         }
         */
        printf("onFrame IN\n");
        
        glClearColor(0.0,1.0,0.0,1.0);
        
        
        printf("addr in onFrame : %p\n", cm.captureTexture);
        
        
        handleKeys();
        handleMouse();
        
        // Clear viewport
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        
        // Draw our vbos to the screen
        //program.bind(); {
        
        //	glUniformMatrix4fv(program.uniform("mv"), 1, 0, ptr(mv));
        //	glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));
        
        //	glBindVertexArray( vao );
        //	glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
        //	glBindVertexArray( 0 );
        //      } program.unbind();
        
        
        program.bind(); {
            
            glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model));
            glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(view));
            glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));
            
            // glUniform1f(program.uniform("bloom"), bloomAmt);
            glUniform1i(program.uniform("tex0"), 0);
            
            
            //cm->captureTexture->bind(GL_TEXTURE0); {
            //    mb1.draw();
            //} cm->captureTexture->unbind(GL_TEXTURE0);
            
            
            
            cm.abc.bind(GL_TEXTURE0); {
                mb1.draw();
            } cm.abc.unbind(GL_TEXTURE0);
            
          
        } program.unbind();
        
        
        // cm->newFrame = false;
        
        printf("onFrame OUT\n");
        
        
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
    return CaptureEx().start("aluminum::TextureEx", 100, 100, 400, 300);
}
