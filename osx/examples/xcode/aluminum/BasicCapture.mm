
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
   /*
    GLuint vao, vbo, ibo, indices[3] = {0,1,2};
    
    vec3 vertices[6] = {
        vec3( -1.0, -1.0, 0.0 ), vec3( 0.0, 1.0, 0.0 ), vec3( 1.0, -1.0, 0.0 ), //vertex
        vec3( 1.0,0.0,0.0 ), vec3( 0.0,1.0,0.0 ), vec3( 0.0,0.0,1.0 ), //color
    };
    */
    
    int div = 20;
    int numPts = ((1280 * 720) / div) * 2;
    vec3* vs = new vec3[numPts];
    vec4* cs = new vec4[numPts];
    unsigned int* indices = new unsigned int[numPts];
    
    
    GLint posLoc=0;
   // GLint texCoordLoc=1;
    GLint colLoc=1;
    
    mat4 proj;
    mat4 view;
    mat4 model;
    
    
    //mat4 mv;
    
      MeshData md;
    MeshBuffer mb1;
    
    CaptureManager* cm;
    Texture safeTexture;
    
    ResourceHandler rh;
    
    void loadProgram(Program &p, const std::string& name) {
        
        p.create();
        
        string sv = rh.pathToResource(name, "vsh");
        // cout << "path of vertex shader is: " << sv << endl;
        
        p.attach(rh.contentsOfFile(sv), GL_VERTEX_SHADER);
        
        glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      //  glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");
        glBindAttribLocation(p.id(), colLoc, "vertexColor");
        
        string sp = rh.pathToResource(name, "fsh");
        // cout << "path of vertex shader is: " << sp << endl;
        
        p.attach(rh.contentsOfFile(sp), GL_FRAGMENT_SHADER);
        
        p.link();
    }
    
    virtual void onCreate() {
        
        //rh.loadTexture(captureTexture, "mak.png");
      
       //safeTexture = Texture(640, 480, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
        loadProgram(program, "basic_s");
        
 //       mb1.init(MeshUtils::makeRectangle(), posLoc, -1, texCoordLoc, -1);
        
        
        
      
        
        
        
    //    vec3 vs[] = {  vec3( -1.0, -1.0, 0.0 ), vec3( 0.0, 1.0, 0.0 ), vec3( 1.0, -1.0, 0.0 ) };
    //    vec4 cs[] = {  vec4(1.0f,0.0f,0.0f,1.0f), vec4(0.0f,1.0f,0.0f,1.0f), vec4(0.0f,1.0f,0.0f,1.0f)  };
        
        
       // const unsigned int indices[] = { 0,1,2,3 };
        vs[0] = vec3(1.0,0,0);
        vs[1] = vec3(1.0,1,0);
        
        cs[0] = vec4(1.0,0,0,1);
        cs[1] = vec4(1.0,0,0,1);
        
        
        vs[2] = vec3(2,-1,0);
        vs[3] = vec3(1,1,0);
        
        cs[2] = vec4(1.0,0,0,1);
        cs[3] = vec4(1.0,0,0,1);
        
        md.vertex(vs, numPts);
        md.color(cs, numPts);
        
        for (int i = 0; i < numPts; i++) {
            indices[i] = i;
        }
        
        //  md.index(indices, 2);
        md.index(indices, numPts);
        
        mb1.init(md, posLoc, -1, -1, colLoc);
        
      //  mb1.init(MeshUtils::makeRectangle(), posLoc, -1, -1, colLoc);
        
        
        
        proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
        view = glm::lookAt(vec3(0.0,0.0,3), vec3(0,0,0), vec3(0,1,0) );
        model = glm::mat4();
        
        glEnable(GL_TEXTURE_2D);
        glEnable(GL_DEPTH_TEST);
        glViewport(0, 0, width, height);
        glClearColor(0.3,0.3,0.3,1.0);
        
        
        
        //test video capture
        cm = [[CaptureManager alloc] init];
        [cm startCapture];
      
    }
    
    void toggleCapture() {
        
        if (frameCount % 500 == 0 && frameCount > 0) {
            if ([cm isCapturing]) {
                printf("is capturing = true!\n");
                [cm stopCapture];
            } else {
                printf("is capturing = false!\n");
                [cm startCapture];
            }
        }
    }
    
    virtual void onFrame(){
        
      //  if (1 == 1) return;
        handleKeys();
        handleMouse();
        
        
        
        if ([cm checkForNewBytes]) {
        
            int bw = 1280;
            int bh = 720;
            
           // int rowsize = 1280 * 4;
            
            float sx = 1;
            float sy = 1;
            float xinc = 2.0/bw;
            float yinc = 2.0/bh;
            
            int bufferIdx = 0;
          //  int cnt = 0;
            int idx = 0;
            for (int i = 0; i < bh; i+=div) {
                for (int j = 0; j < bw; j+=div) {
                    
                    if (bufferIdx < numPts) {
                    idx = (i * bw * 4) + (j * 4);
                    
                      //  printf("c/r = %d/%d : bi = %d, idx = %d : %f %f %f\n", j, i, bufferIdx, idx, cm.ptrToImageBuffer[idx+1]/255.0, cm.ptrToImageBuffer[idx+1]/255.0, cm.ptrToImageBuffer[idx+1]/255.0);
                  
                        float r = cm.ptrToImageBuffer[idx+2]/255.0;
                        float g = cm.ptrToImageBuffer[idx+1]/255.0;
                        float b = cm.ptrToImageBuffer[idx+0]/255.0;
                        cs[bufferIdx] = vec4(r, g, b, 1);
                        cs[bufferIdx+1] = vec4(r, g, b, 1);
                        
                        //printf(" r g b %f %f %f\n",r, g, b);
                        
                        float perc = (r+g+b) / (3.0);
                        float ang = perc * (M_PI * 2);
                        float mag = perc * 0.3;
                        
                       // printf("perc ang mag %f,  %f %f \n", perc, ang, mag);
                        
                        
                        float xp = cos(ang) * mag;
                        float yp = sin(ang) * mag;
                        
                       // printf("xp yp %f %f \n", xp, yp);
                        
                    vs[bufferIdx] =   vec3(sx - xinc*j - xp, sy - yinc*i - yp, 0.0);
                    vs[bufferIdx+1] = vec3(sx - xinc*j + xp, sy - yinc*i + yp, 0.0);
                    
                    bufferIdx += 2;
                    }
                     
                }
            }
           // printf("yo");
            md.vertices().clear();
            md.vertex(vs, numPts);
            md.colors().clear();
            md.color(cs, numPts);
            
            mb1.update(md, posLoc, -1, -1, colLoc);
        }
        
        
        // Clear viewport
        glClearColor(1.0,1.0,1.0,1.0);
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        program.bind(); {
         
            glUniformMatrix4fv(program.uniform("mv"), 1, 0, ptr(view));
            glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));
            
            mb1.drawLines();
         //   mb1.draw();
            
            /*
            glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model));
            glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(view));
            glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));
            
            glUniform1i(program.uniform("tex0"), 0);
         
            if ([cm checkForNewBytes]) {
                //loop through bytes and draw lines
                
            }
          
          
            cm.captureTexture.bind(GL_TEXTURE0); {
              mb1.drawLines();
            } cm.captureTexture.unbind(GL_TEXTURE0);
          */
        } program.unbind();
        
            
        //printf("frameCount = %d\n", frameCount);
        
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
