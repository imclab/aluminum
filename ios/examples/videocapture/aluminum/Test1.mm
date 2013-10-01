
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

#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

using namespace aluminum;
using glm::ivec2;
using glm::to_string;

class Test1 : public RendererIOS {
    
    
    
public:
    
    ResourceHandler rh;

    
    Program program;
    
    MeshData md;
    MeshBuffer mb;
    
    GLint posLoc = 0;
    GLint colLoc = 1;
    
    mat4 proj;
    mat4 mv;
    
    void loadProgram(Program &p, const std::string& name) {
        
        p.create();
        
        string sv = rh.pathToResource(name, "vsh");
        p.attach(rh.contentsOfFile(sv), GL_VERTEX_SHADER);
        
        glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      //  glBindAttribLocation(p.id(), colLoc, "vertexColor");
        
        string sp = rh.pathToResource(name, "fsh");
        p.attach(rh.contentsOfFile(sp), GL_FRAGMENT_SHADER);
        
        p.link();
    }
    
    virtual void onCreate() {
        // Load our shader program
        loadProgram(program, "basic");
       
        
        // create the data mesh
        
        
        float xl = -1.0;
        float xu = 1.0;
        float yl = -1.0;
        float yu = 1.0;
        
        const int Ryp = 200;
        const int Rxp = 200;
        
        vec3 vs[Ryp*Rxp];
        
        for (int y =0; y<Ryp; y++) {
            for (int x=0; x < Rxp ; x++) {
                
                vs[Rxp*y+x].x= xl +x*(xu-xl)/(float)(Rxp-1.0);
                vs[Rxp*y+x].y= yl +y*(yu-yl)/(float)(Ryp-1.0);
                vs[Rxp*y+x].z = 0.0f;
                
//                 TextuCoordsA[RxA*y+x].x = TextuAmplifier.width*x/(float)RxA;
//                 TextuCoordsA[RxA*y+x].y = TextuAmplifier.height - TextuAmplifier.height*y/(float)RyA;
            }
        }
        
        
         // index vector
         GLuint is[Rxp*2*(Ryp-1)+2*(Ryp-2)];
        
        int q =0;
        
        for (int y =0; y<Ryp-1; y++) {
            for (int x=0; x < Rxp ; x++) {
                is[q] = x + y*Rxp;
                q++;
                is[q] = x + (y+1)*Rxp;
                q++;
            } 
            if( y < Ryp-2){ // the degenerate triangles
                
                //repiting last one
                is[q] = (Rxp-1) + (y+1)*Rxp;
                 q++;
                //repiting next one
                is[q] =  (y+1)*Rxp;
                q++;
            } 
        }
        
        
        
        
        
//        GLuint is[3] = {0,1,2};
        
//        vec3 vs[3] = {
//            vec3( -1.0, -1.0, 0.0 ), vec3( 0.0, 1.0, 0.0 ), vec3( 1.0, -1.0, 0.0 ) };
//        vec3 cs[3] = {
//            vec3( 1.0,0.0,0.0 ), vec3( 0.0,1.0,0.0 ), vec3( 0.0,0.0,1.0 )};
        
        md.vertex(vs,Ryp*Rxp);
//        md.vertex(vs, 3);
 //       md.color(cs, 3);
//        md.index(is, 3);
        md.index(is, Rxp*2*(Ryp-1)+2*(Ryp-2));        
//        mb.init(md, posLoc, -1, -1, colLoc);
        mb.init(md, posLoc, -1, -1, -1);
        
        // Set up modelvew and projection matrix
        proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
        mv = glm::lookAt(vec3(0,0,-2.5), vec3(0,0,0), vec3(0,1,0) );
    }
    
    virtual void onFrame(){
        const int Ryp =200;
        const int Rxp = 200;
        // Clear viewport
        glViewport(0, 0, width, height);
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        program.bind(); {
            glUniformMatrix4fv(program.uniform("mv"), 1, 0, ptr(mv));
            glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));
            
          //  glDrawElements(GL_TRIANGLE_STRIP, Rxp*2*(Ryp-1)+2*(Ryp-2) , GL_UNSIGNED_INT, 0);
            mb.drawTriangleStrip();
        } program.unbind();
        
        
    }
    
    
    
    virtual void touchBegan(ivec2 mouse) {
        cout << "touch began: " << to_string(mouse) << endl;
    }
    
    virtual void touchMoved(ivec2 prevMouse, ivec2 mouse) {
        cout << "touch moved: prev:" << to_string(prevMouse) << ", current: " << to_string(prevMouse) << endl;
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
