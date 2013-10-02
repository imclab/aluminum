
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


using namespace aluminum;
using glm::ivec2;
using glm::to_string;

class TextureExample : public RendererIOS {
    
    
    
public:
    
    
    GLint posLoc = 0;
    GLint tcLoc = 1;
    mat4 proj;
    mat4 view;
    mat4 model;
    
    Program program;
    Texture t1;
    MeshBuffer mb1;
    ResourceHandler rh;
    
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
        
        loadProgram(program, "texture");
        rh.loadTexture(t1, "javier.png");
        
        mb1.init(MeshUtils::makeRectangle(), posLoc, -1, tcLoc, -1);
        
        proj = glm::perspective( 45.0, 1.0, 0.1, 100.0 );
        view = glm::lookAt( vec3(0.0,0.0,2), vec3(0,0,0), vec3(0,1,0) );
        model = glm::mat4();
        
        glViewport(0, 0, width, height);
        glClearColor(1.0,0.3,0.3,1.0);
    }
    
    virtual void onFrame(){
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
       
        program.bind(); {
            
            glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model));
            glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(view));
            glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));
            
            glUniform1i(program.uniform("tex0"), 0);
            
            t1.bind(GL_TEXTURE0); {
                mb1.draw();
            } t1.unbind(GL_TEXTURE0);
            
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
    
    TextureExample().start();
    
}
