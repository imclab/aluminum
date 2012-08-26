


#include "FreeGlutGLView.hpp"
#include "RendererLinux.hpp"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"

#include "Texture.hpp"
#include <vector>

using namespace al;

class TextureExample : public RendererLinux {
  public:

    Vec3f diffuse = Vec3f(0.0,1.0,0.0);
    Vec3f specular = Vec3f(1.0,1.0,1.0);
    Vec3f ambient = Vec3f(0.0,0.0,0.3);
    float lightPosX = -1.0f;
    Mat4f model, view, proj;

    Program program;
    
    GLint posLoc=0;
   // GLint normalLoc=1;
    GLint texCoordLoc=2;

    Texture texture;

    std::vector<MeshData> md;
    std::vector<MeshBuffer> mb;
      

    void loadMeshes(const std::string& name) {    
      
      MeshUtils::loadMeshes(md, name);

      for (unsigned long i = 0; i < md.size(); i++) {
	mb.push_back((MeshBuffer()).init(md[i], posLoc, -1, texCoordLoc, -1));
      }
    }

    void loadTexture(Texture& t, const std::string& name) {
      t.loadTextureData2D(t, name).create2D();
	t.dump();
    } 


    void loadProgram(Program &p, const std::string& name) {

      p.create();

      Shader sv = Shader::sourceFromFile(name + ".vsh", GL_VERTEX_SHADER);
      Shader sf = Shader::sourceFromFile(name + ".fsh", GL_FRAGMENT_SHADER);

      p.attach(sv);

      glBindAttribLocation(p.id(), posLoc, "vertexPosition");
      //glBindAttribLocation(p.id(), normalLoc, "vertexNormal");
      glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");

      p.attach(sf);

      p.link();

      p.listParams();

      printf("program.id = %d, vertex.glsl = %d, frag.glsl = %d\n", p.id(), sv.id(), sf.id());
    }

    void onCreate() {

      loadTexture(texture, "resources/hubble.jpg");

      loadProgram(program, "resources/texture");

      loadMeshes("resources/ducky.obj");

      proj = Matrix4f::perspective(45, 1.0, 0.1, 100);
      view = Matrix4f::lookAt(Vec3f(0.0,0.0,-5), Vec3f(0,0,0), Vec3f(0,1,0) );
      model = Matrix4f::identity();
      model.rotate(M_PI/2, 0,2).rotate(45.0, 1,2).rotate(8.0, 0,1);

      glEnable(GL_DEPTH_TEST);
      glViewport(0, 0, width, height);
      glClearColor(0.3,0.3,0.3,1.0);
    }

    void draw(Mat4f model) {

      lightPosX += 0.02f;
      if (lightPosX > 1.0) { lightPosX = -1.0f; }

      program.begin(); {

	glUniformMatrix4fv(program.uniform("model"), 1, 0, model.ptr());
	glUniformMatrix4fv(program.uniform("view"), 1, 0, view.ptr());
	glUniformMatrix4fv(program.uniform("proj"), 1, 0, proj.ptr());

	texture.bind(GL_TEXTURE0);

	glUniform1i(program.uniform("tex0"), 0);

	for (unsigned long i = 0; i < mb.size(); i++) {
	  mb[i].draw();	
	}

	texture.unbind(GL_TEXTURE0);

      } program.end();
    }

    void onFrame(){
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      model.rotate(0.01, 0, 1);
      draw(model);
    }
};

int main() {
  TextureExample().start(); 
  return 0;
}
