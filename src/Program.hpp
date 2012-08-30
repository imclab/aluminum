#ifndef INCLUDE_AL_GRAPHICS_SHADER2_HPP
#define INCLUDE_AL_GRAPHICS_SHADER2_HPP

#include <string>
#include <map>

#include "Includes.hpp"

#include "allocore/math/al_Vec.hpp"
#include "allocore/math/al_Matrix4.hpp"

#define AL_SHADER_MAX_LOG_SIZE	4096

using namespace std;

namespace al{

  class Shader {
    public:

      Shader(const std::string& source, GLenum type);

      ~Shader(){}

           Shader& compile();

      GLenum type() const { return mType; }

    //  void id(GLuint v) {mID = v;}
      GLuint id() const { return mID; }
   

      const char*  log() const;


    private:
    //  std::string mSource;
      GLenum mType;
    //  void sendSource();
   GLuint mID;

      void get(int pname, void * params) const;
      void destroy();	
  };



  class Program {
    public:

      Program() {}
      ~Program() {} 

      Program& create();
      Program& attach(std::string source, GLenum type);

      std::string loadText(const std::string& v); 



      Program& attach(Shader& s);
      Program& detach(Shader& s);
      Program& link();

      // These parameters must be set before attaching geometry shaders
      //void setGeometryInputPrimitive(Graphics::Primitive prim) { mInPrim = prim; }
      //void setGeometryOutputPrimitive(Graphics::Primitive prim) { mOutPrim = prim; }
      //void setGeometryOutputVertices(unsigned int i) { mOutVertices = i; }

      void bind();
      void unbind();

      void listParams() ;
      void mapUniforms() ;
      void mapAttributes() ;

      GLint uniform(string name)  ;
      GLint attribute(string name) ;

    //  void id(GLuint v) {mID = v;}
      GLuint id() const { return mID; }
      const char* log() const;
      void destroy();


    private:

      GLuint mID;
      unsigned int mOutVertices;
      void get(int pname, void * params) const;

      map<string, GLint> uniforms;
      map<string, GLint> attributes;


  };



} // ::al

#endif
