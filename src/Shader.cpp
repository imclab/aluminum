#include "Shader.hpp"

#include <stdio.h>
#include <map>
#include <string>
#include <iostream>
#include <sstream>
#include <fstream>

using std::map;
using std::string;

namespace al{


const char * ShaderBase::log() const {
//	GLint lsize; get(GL_INFO_LOG_LENGTH, &lsize);
//	if(0==lsize) return NULL;
//	newLog(lsize);
//	glGetShaderInfoLog(id(), 4096, NULL, mLog);
//	//glGetInfoLogARB((GLhandleARB)handle(), 4096, NULL, mLog);
//	return mLog;

	GLint lsize; get(GL_INFO_LOG_LENGTH, &lsize);
	if(0==lsize) return NULL;

	static char buf[AL_SHADER_MAX_LOG_SIZE];
	getLog(buf);
	return buf;
}

void ShaderBase::printLog() const {
	const char * s = log();
	if(s && s[0]) printf("%s\n", s);
}

//void Shader::debug() const {

//}

void Shader::getLog(char * buf) const {
	glGetShaderInfoLog(id(), AL_SHADER_MAX_LOG_SIZE, NULL, buf);
}
void ShaderProgram::getLog(char * buf) const {
	glGetProgramInfoLog(id(), AL_SHADER_MAX_LOG_SIZE, NULL, buf);
}

/*
GLuint glCreateProgram (void);
GLuint glCreateShader (GLenum type);
void glDeleteShader (GLuint shader);
void glDeleteProgram (GLuint program);
void glDetachShader(GLuint program, GLuint shader);
*/

Shader::Shader(const std::string& source, GLenum type)
:	mSource(source), mType(type){}

Shader& Shader::compile(){ 
	//Graphics::error("glerror compile0");
  onCreate();
	//validate(); 
//	Graphics::error("glerror compile1");
	return *this; 
}

bool Shader::compiled() const {
	GLint v;
//agf	GLhandle h = (GLhandle)id();
//agf	glGetObjectParameterivARB(h, GL_COMPILE_STATUS, &v);
	glGetProgramiv(id(), GL_COMPILE_STATUS, &v); //this is the right one!!! //agf
//	Graphics::error("Shader::compiled()");
	return v;
}

void Shader::get(int pname, void * params) const { glGetShaderiv(id(), pname, (GLint *)params); }

void Shader::onCreate(){
	//mID = glCreateShader(gl_shader_type(mType));
	mID = glCreateShader(mType);
	
	
	//Graphics::error("Shader::onCreate0");
	//mHandle = glCreateShaderObjectARB(gl_shader_type(mType));
	//mID = (long)handle();
	if(mSource[0]){
		sendSource(); 
	//	Graphics::error("Shader::onCreate1");
		glCompileShader(id());
	//	Graphics::error("Shader::onCreate2");
	}
	printf("in Shader::onCreate() : id = %d\n", id());
}

void Shader::onDestroy(){ 
	//glDeleteObjectARB((GLhandleARB)handle());
	glDeleteShader(id()); 
}

void Shader::sendSource(){
	//validate();
	const char * s = mSource.c_str();
	glShaderSource(id(), 1, &s, NULL);
	//glShaderSourceARB((GLhandleARB)handle(), 1, &s, NULL);
}


//Shader& Shader::sourceFromFile( const std::string& filename, GLenum type){
Shader Shader::sourceFromFile( const std::string& filename, GLenum type){


    std::ifstream file;
    file.open(filename.c_str());

    if (!file) {
	printf("in Shader::sourceFromFile : error, couldn't find file!\n");
	exit(0);
    }

    std::stringstream stream;

    stream << file.rdbuf();

    file.close();
    //string& out
    string out = stream.str();

    return Shader(out, type);
  //return source(out, type);

//  File shader_file(v, "r", true); 
 // std::cout << "here 3!" << shader_file.readAll() << "\n";
  //return source(shader_file.readAll(), type);
}

/*
Shader& Shader::sourceFromFile( SearchPaths& sp, const std::string& v, Shader::Type type){

  File shader_file(sp.find(v), "r", true); 
  return source(shader_file.readAll(), type);
}
*/

Shader& Shader::source(const std::string& v){
  mSource = v;
  //invalidate();
  return *this;
}

Shader& Shader::source(const std::string& src, GLenum type){
  mType=type; return source(src);
}


/*
static ShaderProgram::Type param_type_from_gltype(GLenum gltype) {
  switch(gltype) {
    case GL_FLOAT:				return ShaderProgram::FLOAT;
    case GL_FLOAT_VEC2:			return ShaderProgram::VEC2;
    case GL_FLOAT_VEC3:			return ShaderProgram::VEC3;
    case GL_FLOAT_VEC4:			return ShaderProgram::VEC4;

    case GL_INT:				return ShaderProgram::INT;
    case GL_INT_VEC2:			return ShaderProgram::INT2;
    case GL_INT_VEC3:			return ShaderProgram::INT3;
    case GL_INT_VEC4:			return ShaderProgram::INT4;

    case GL_BOOL:				return ShaderProgram::BOOL;
    case GL_BOOL_VEC2:			return ShaderProgram::BOOL2;
    case GL_BOOL_VEC3:			return ShaderProgram::BOOL3;
    case GL_BOOL_VEC4:			return ShaderProgram::BOOL4;

    case GL_FLOAT_MAT2:			return ShaderProgram::MAT22;
    case GL_FLOAT_MAT3:			return ShaderProgram::MAT33;
    case GL_FLOAT_MAT4:			return ShaderProgram::MAT44;

    case GL_SAMPLER_1D:			return ShaderProgram::SAMPLER_1D;
    case GL_SAMPLER_2D:			return ShaderProgram::SAMPLER_2D;
    case GL_SAMPLER_2D_RECT: return ShaderProgram::SAMPLER_RECT;
    case GL_SAMPLER_3D:			return ShaderProgram::SAMPLER_3D;
    case GL_SAMPLER_CUBE:		return ShaderProgram::SAMPLER_CUBE;
    case GL_SAMPLER_1D_SHADOW:	return ShaderProgram::SAMPLER_1D_SHADOW;
    case GL_SAMPLER_2D_SHADOW:	return ShaderProgram::SAMPLER_2D_SHADOW;
    default:					return ShaderProgram::NONE;
  }
}
*/

ShaderProgram& ShaderProgram::create() {
  onCreate();
  return *this; 
}

ShaderProgram& ShaderProgram::attach(Shader& s) {
  //onCreate();
  //validate();
  
  s.compile();
  //agf glAttachObject((GLhandleARB)id(), (GLhandleARB)s.id());
  //
  printf("program is = %d, shader id = %d\n", id(), s.id());
  glAttachShader(id(), s.id());  //agf this is the right one!

  // TODO: check for geometry shader extensions
  //#ifdef GL_EXT_geometry_shader4
  //	printf("GL_EXT_geometry_shader4 defined\n");
  //#endif
  //#ifdef GL_ARB_geometry_shader4
  //	printf("GL_ARB_geometry_shader4 defined\n");
  //#endif

  if (s.type() == GL_GEOMETRY_SHADER) {
    /* agf	
       glProgramParameteri(id(),GL_GEOMETRY_INPUT_TYPE, mInPrim);
       glProgramParameteri(id(),GL_GEOMETRY_OUTPUT_TYPE, mOutPrim);
       glProgramParameteri(id(),GL_GEOMETRY_VERTICES_OUT,mOutVertices);
       */
  }

   if (s.log() != NULL) {
     if (s.type() == GL_VERTEX_SHADER) {
       printf ("   errors in vertex shader: \n");
     } else if (s.type() == GL_FRAGMENT_SHADER) {
       printf ("   errors in fragment shader: \n");
     }
     printf("%s\n", s.log());
 //    exit(0);
   }


  return *this; 
}
const ShaderProgram& ShaderProgram::detach(const Shader& s) const { 
  glDetachShader(id(), s.id()); 
  //glDetachObjectARB((GLhandleARB)handle(), (GLhandleARB)s.handle());
  return *this; 
}
const ShaderProgram& ShaderProgram::link(bool validate) const { 

  //  glBindFragDataLocation(id(), 0, "outputF"); //agf temp! testing on 3.2
  glLinkProgram(id()); 
  //glLinkProgramARB((GLhandleARB)handle());

  if (validate) {
		int isValid;
		glValidateProgram(id());
		//glValidateProgramARB((GLhandleARB)handle());
		glGetProgramiv(id(), GL_VALIDATE_STATUS, &isValid);
		if (!isValid) {
		  printf("in ShaderProgram::link - %d is not valid!!!\n", id());
			//Graphics::error("ShaderProgram::link");
		}
	}
	return *this; 
}

void ShaderProgram::onCreate(){ 
  
	//mHandle = glCreateProgramObjectARB();
	//mID = (long)handle();
	mID = glCreateProgram(); 
	printf("in ShaderProgram::onCreate() : id = %d\n", id());
}
void ShaderProgram::onDestroy(){ 
	glDeleteProgram(id()); 
	//glDeleteObjectARB((GLhandleARB)handle()); 
}

void ShaderProgram::use(unsigned programID){
	glUseProgram(programID);
}

const ShaderProgram& ShaderProgram::use(){ 
		use(id()); 
	return *this; 
}

bool ShaderProgram::begin(){ 
		use(id());
		return true;
}

void ShaderProgram::end() const { 
	 glUseProgram(0); 
}

bool ShaderProgram::linked() const { 
	GLint v; 
	get(GL_LINK_STATUS, &v); 
	return (v == GL_TRUE); 
}
// GLint v; glGetProgramiv(id(), GL_LINK_STATUS, &v); return v; }

const ShaderProgram& ShaderProgram::uniform(const char * name, int v0) const{
	return uniform(uniform(name), v0);
}
const ShaderProgram& ShaderProgram::uniform(const char * name, float v0) const{
	return uniform(uniform(name), v0);
}
const ShaderProgram& ShaderProgram::uniform(const char * name, float v0, float v1) const{
	return uniform(uniform(name), v0,v1);
}
const ShaderProgram& ShaderProgram::uniform(const char * name, float v0, float v1, float v2) const{
	return uniform(uniform(name), v0,v1,v2);
}
const ShaderProgram& ShaderProgram::uniform(const char * name, float v0, float v1, float v2, float v3) const{
	return uniform(uniform(name), v0,v1,v2,v3);
}
const ShaderProgram& ShaderProgram::uniform1(const char * name, const float * v, int count) const{
	glUniform1fv(uniform(name), count, v); return *this;
}
const ShaderProgram& ShaderProgram::uniform2(const char * name, const float * v, int count) const{
	glUniform2fv(uniform(name), count, v); return *this;
}
const ShaderProgram& ShaderProgram::uniform3(const char * name, const float * v, int count) const{
	glUniform3fv(uniform(name), count, v); return *this;
}
// const ShaderProgram& ShaderProgram::uniform(const char * name, Vec3f v) const{
// 	glUniform3fv(uniform(name), 1, &v[0]); return *this;
// }
const ShaderProgram& ShaderProgram::uniform4(const char * name, const float * v, int count) const{
	glUniform4fv(uniform(name), count, v); return *this;
}

const ShaderProgram& ShaderProgram::uniform(int location, int v0) const{
	glUniform1i(location, v0);	return *this;
}
const ShaderProgram& ShaderProgram::uniform(int location, float v0) const{
	glUniform1f(location, v0);	return *this;
}
const ShaderProgram& ShaderProgram::uniform(int location, float v0, float v1) const{
	glUniform2f(location, v0,v1); return *this;	
}
const ShaderProgram& ShaderProgram::uniform(int location, float v0, float v1, float v2) const{
	glUniform3f(location, v0,v1,v2); return *this;	
}
const ShaderProgram& ShaderProgram::uniform(int location, float v0, float v1, float v2, float v3) const{
	glUniform4f(location, v0,v1,v2,v3); return *this;	
}

const ShaderProgram& ShaderProgram::uniformMatrix4(const char * name, const float * v, bool transpose) const{
	glUniformMatrix4fv(uniform(name), 1, transpose, v); return *this;
}

const ShaderProgram& ShaderProgram::attribute(int location, float v0) const{
	glVertexAttrib1f(location, v0);	return *this;
}
const ShaderProgram& ShaderProgram::attribute(int location, float v0, float v1) const{
	glVertexAttrib2f(location, v0,v1); return *this;	
}
const ShaderProgram& ShaderProgram::attribute(int location, float v0, float v1, float v2) const{
	glVertexAttrib3f(location, v0,v1,v2); return *this;	
}
const ShaderProgram& ShaderProgram::attribute(int location, float v0, float v1, float v2, float v3) const{
	glVertexAttrib4f(location, v0,v1,v2,v3); return *this;	
}

const ShaderProgram& ShaderProgram::attribute(const char * name, float v0) const{
	return attribute(attribute(name), v0);
}
const ShaderProgram& ShaderProgram::attribute(const char * name, float v0, float v1) const{
	return attribute(attribute(name), v0,v1);
}
const ShaderProgram& ShaderProgram::attribute(const char * name, float v0, float v1, float v2) const{
	return attribute(attribute(name), v0,v1,v2);
}
const ShaderProgram& ShaderProgram::attribute(const char * name, float v0, float v1, float v2, float v3) const{
	return attribute(attribute(name), v0,v1,v2,v3);
}
const ShaderProgram& ShaderProgram::attribute1(const char * name, const float * v) const{
	glVertexAttrib1fv(attribute(name), v); return *this;
}
const ShaderProgram& ShaderProgram::attribute2(const char * name, const float * v) const{
	glVertexAttrib2fv(attribute(name), v); return *this;
}
const ShaderProgram& ShaderProgram::attribute3(const char * name, const float * v) const{
	glVertexAttrib3fv(attribute(name), v); return *this;
}
const ShaderProgram& ShaderProgram::attribute4(const char * name, const float * v) const{
	glVertexAttrib4fv(attribute(name), v); return *this;
}
const ShaderProgram& ShaderProgram::attribute1(int location, const double * v) const{
	glVertexAttrib1dv(location, v); return *this;
}
const ShaderProgram& ShaderProgram::attribute2(int location, const double * v) const{
	glVertexAttrib2dv(location, v); return *this;
}
const ShaderProgram& ShaderProgram::attribute3(int location, const double * v) const{
	glVertexAttrib3dv(location, v); return *this;
}
const ShaderProgram& ShaderProgram::attribute4(int location, const double * v) const{
	glVertexAttrib4dv(location, v); return *this;
}

int ShaderProgram::uniform(const char * name) const { 
	//GLint loc = glGetUniformLocationARB((GLhandleARB)handle(), name);
	GLint loc = glGetUniformLocation(id(), name);
	if (loc == -1)
        printf("No such uniform named \"%s\"\n", name);
	return loc; 
}

int ShaderProgram::attribute(const char * name) const { 
	//GLint loc = glGetAttribLocationARB((GLhandleARB)handle(), name);
	GLint loc = glGetAttribLocation(id(), name);
	if (loc == -1)
        printf("No such attribute named \"%s\"\n", name);
	return loc;  
}

void ShaderProgram::get(int pname, void * params) const { 
	glGetProgramiv(id(), pname, (GLint *)params); 
}

void ShaderProgram::listParams() const {
	GLuint program = id();
	GLint numActiveUniforms = 0;
	GLint numActiveAttributes = 0;

	glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &numActiveUniforms);
	glGetProgramiv(program, GL_ACTIVE_ATTRIBUTES, &numActiveAttributes);
	
	printf("ShaderProgram::listParams()\n");

	for(int j=0; j < numActiveUniforms; j++)
	{
		GLsizei length;
		GLint size;
		GLenum gltype;
		char name[256];

		glGetActiveUniform(program,
							j,
							sizeof(name),
							&length,
							&size,
							&gltype,
							name);

		// check for array names
		if(name[ strlen(name)-3 ] == '[' && name[ strlen(name)-1 ] == ']') {
			name[ strlen(name)-3 ] = '\0';
		}
		

		//printf("uniform %d(%s): type %d size %d length %d\n",
		//	j, name, param_type_from_gltype(gltype), size, length);
		printf("uniform %d(%s): type %d size %d length %d\n",
			j, name, gltype, size, length);
	}

	for(int j=0; j < numActiveAttributes; j++) {
		GLsizei length;
		GLint size;
		GLenum gltype;
		char name[256];	// could query for max char length

		glGetActiveAttrib(program,
							j,
							sizeof(name),
							&length,
							&size,
							&gltype,
							name);
							
		//printf("attribute %d(%s): type %d size %d length %d\n",
		//	j, name, param_type_from_gltype(gltype), size, length);
		printf("attribute %d(%s): type %d size %d length %d\n",
			j, name, gltype, size, length);

	}
}

} // al::
