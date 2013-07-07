
#include "Includes.hpp"

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include "Texture.hpp"
#include "Camera.hpp"

#include "NiftiUtils.h"

//NIFTI stuff...
#include "nifti1.h"
#include "nifti1_io.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//typedef signed short MY_DATATYPE;
//typedef unsigned char MY_DATATYPE;
#define MIN_HEADER_SIZE 348
#define NII_HEADER_SIZE 352
//END NIFTI stuff...

#define NUM_SLICES 20

#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

#define RESOURCES_DIR "/Dropbox/XCodeProjects/aluminum/osx/examples/niftiViewer/resources/"


using namespace aluminum;

class NiftiViewer_Slices : public RendererOSX {
public:
  
  char* HOME = (char *) [NSHomeDirectory() UTF8String];
  
  Camera camera;
  
  int numSlices;
  vector<MeshBuffer> mbs;
  
  
  mat4 textureRotation, view, proj;
  
  Program program;
  
  GLint posLoc=0;
  GLint texCoordLoc=1;
  
  Texture brain;
  Texture cluster1_time1, cluster1_time2, cluster1_time3;
  Texture cluster2_time1, cluster2_time2, cluster2_time3;
  
  MeshBuffer mb1;
  
  float bloomAmt = 0.1;
  float orbitRadius = 1.0;
  float opacity = 0.1;
  float percent = 0.0;
  float cameraZ = 0.95;
  
  bool rotateTextureX_plus = false;
  bool rotateTextureX_minus = false;
  
  
  
  void loadTexture(Texture& t, const std::string& name) {
    t.loadTexture(t, name);
  }
  
  void loadProgram(Program &p, const std::string& name) {
    
    p.create();
    
    p.attach(p.loadText(name + ".vsh"), GL_VERTEX_SHADER);
    glBindAttribLocation(p.id(), posLoc, "vertexPosition");
    glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");
    
    p.attach(p.loadText(name + ".fsh"), GL_FRAGMENT_SHADER);
    
    p.link();
  }
  
    
  
  
  void onCreate() {
    
    string nii_brain = (HOME + std::string(RESOURCES_DIR) + "MNI152_T1_2mm_brain.nii").c_str();
    string nii_c1t1 = (HOME + std::string(RESOURCES_DIR) + "all_s1_IC25.nii").c_str();
    string nii_c1t2 = (HOME + std::string(RESOURCES_DIR) + "all_s2_IC25.nii").c_str();
    string nii_c1t3 = (HOME + std::string(RESOURCES_DIR) + "all_s3_IC25.nii").c_str();
    string nii_c2t1 = (HOME + std::string(RESOURCES_DIR) + "all_s1_IC25.nii").c_str();
    string nii_c2t2 = (HOME + std::string(RESOURCES_DIR) + "all_s2_IC25.nii").c_str();
    string nii_c2t3 = (HOME + std::string(RESOURCES_DIR) + "all_s3_IC25.nii").c_str();
    
    NiftiUtils::read_nifti_file(nii_brain, brain, 16);
    NiftiUtils::read_nifti_file(nii_c1t1, cluster1_time1, 32);
    NiftiUtils::read_nifti_file(nii_c1t2, cluster1_time2, 32);
    NiftiUtils::read_nifti_file(nii_c1t3, cluster1_time3, 32);
    NiftiUtils::read_nifti_file(nii_c2t1, cluster2_time3, 32);
    NiftiUtils::read_nifti_file(nii_c2t2, cluster2_time2, 32);
    NiftiUtils::read_nifti_file(nii_c2t3, cluster2_time1, 32);
    
    
    
    loadProgram(program, HOME + std::string(RESOURCES_DIR) + "textureSlices");
    
    
    camera = Camera(60.0, width/(height*0.5), 0.001, 100.0);
    camera.translateZ(-cameraZ);
    
    /*
     MeshData md = MeshUtils::makeRectangle(vec2(-0.5, -0.5), vec2(0.5, 0.5), vec3(-0.5, -0.5, 0.5), vec3(1.5,1.5,0.5)    );
     mb1.init(md, posLoc, -1, texCoordLoc, -1);
     */
    
    
    createSlices(NUM_SLICES);
    
    //for (int i = 0; i < numSlices; i++) {
    //    MeshData md = MeshUtils::makeRectangle(vec3(-0.5, -0.5, zSt + (zInc * i)), vec3(0.5, 0.5, zSt + (zInc * i)), vec3(-0.15, -0.15, tczInc * i), vec3(1.15,1.15,tczInc * i)    );
    //    mbs[i].init(md, posLoc, -1, texCoordLoc, -1);
    // }
    
    //mb1.init(MeshUtils::makeRectangle(), posLoc, -1, texCoordLoc, -1);
    
    // proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
    // view = glm::lookAt(vec3(0.0,0.0,-2), vec3(0,0,0), vec3(0,1,0) );
    textureRotation = glm::mat4();
    // textureRotation = glm::translate(textureRotation, vec3(0.0,0.0,0.0));
    
    
    glEnable (GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glViewport(0, 0, width, height);
    glClearColor(0.3,0.3,0.3,1.0);
  }
  
  void createSlices(int num) {
    
    //if DEPTH_TEST is enables, must sort back to front
    
    numSlices = num;
    mbs.clear();
    mbs.resize(num);
    
    float zSt = orbitRadius/2.0;
    float zInc = (orbitRadius) / ((float)numSlices - 1);
    
    float tczInc = 1.0 / ((float)numSlices - 1);
    
    
    for (int i = 0; i < numSlices; i++) {
      MeshData md = MeshUtils::makeRectangle(vec3(-0.5, -0.5, zSt - (zInc * i)), vec3(0.5, 0.5, zSt - (zInc * i)), vec3(-0.15, -0.15, tczInc * i), vec3(1.15,1.15,tczInc * i)    );
      
      mbs[i].init(md, posLoc, -1, texCoordLoc, -1);
    }
    
  }
  
  //every 1/60th of a second...
  void onFrame(){
    
    handleKeys();
    handleMouse();
    
    if (camera.isTransformed) {
      camera.transform();
    }
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
    
    program.bind(); {
      
      glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(camera.projection));
      glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(camera.view));
      glUniformMatrix4fv(program.uniform("textureRotation"), 1, 0, ptr(textureRotation));
      
      glUniform1f(program.uniform("percent"), percent);
      glUniform1f(program.uniform("opacity"), opacity);
      
      glUniform1i(program.uniform("brain"), 0);
      glUniform1i(program.uniform("cluster1_time1"), 1);
      glUniform1i(program.uniform("cluster1_time2"), 2);
      glUniform1i(program.uniform("cluster1_time3"), 3);
      
      glUniform1i(program.uniform("cluster2_time1"), 4);
      glUniform1i(program.uniform("cluster2_time2"), 5);
      glUniform1i(program.uniform("cluster2_time3"), 6);
      
      brain.bind(GL_TEXTURE0);
      cluster1_time1.bind(GL_TEXTURE1);
      cluster1_time2.bind(GL_TEXTURE2);
      cluster1_time3.bind(GL_TEXTURE3);
      cluster2_time1.bind(GL_TEXTURE4);
      cluster2_time2.bind(GL_TEXTURE5);
      cluster2_time3.bind(GL_TEXTURE6);

      for (int i = 0; i < numSlices; i++) {
        mbs[i].draw();
      }
   
      brain.unbind(GL_TEXTURE0);
      cluster1_time1.unbind(GL_TEXTURE1);
      cluster1_time2.unbind(GL_TEXTURE2);
      cluster1_time3.unbind(GL_TEXTURE3);
      cluster2_time1.unbind(GL_TEXTURE4);
      cluster2_time2.unbind(GL_TEXTURE5);
      cluster2_time3.unbind(GL_TEXTURE6);

    } program.unbind();
  }
  
  void onReshape() {
    glViewport(0, 0, width, height);
    camera.perspective(60.0, width/(height*0.5), 0.001, 100.0);
  }
  
  void handleMouse() {
    
    bool movingLeft = false;
    bool movingRight = false;
    bool movingUp = false;
    bool movingDown = false;;
    
    if (abs(mouseX - previousMouseX) > abs(mouseY - previousMouseY) ) {
      if (mouseX < previousMouseX) {
        movingLeft = true;
      } else {
        movingRight = true;
      }
    } else {
      if (mouseY < previousMouseY) {
        movingUp = true;
      } else {
        movingDown = true;
      }
    }
    
    if(isDragging) {
      
      textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
      
      if (movingLeft) {
        textureRotation = glm::rotate(textureRotation, -1.0f, vec3(0.0,1.0,0.0));
      } else if (movingRight) {
        textureRotation = glm::rotate(textureRotation, 1.0f, vec3(0.0,1.0,0.0));
      } else if (movingUp) {
        textureRotation = glm::rotate(textureRotation, 1.0f, vec3(1.0,0.0,0.0));
      } else {
        textureRotation = glm::rotate(textureRotation, -1.0f, vec3(1.0,0.0,0.0));
      }
      
      textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
    }
    
    
    if (isMoving) {
      opacity = ((float)mouseX / (float)width ) ; //* 0.1;
      percent = ((float)mouseY / (float)height );
      
      printf("percent = %f, ", percent);
      printf("opacity = %f\n", opacity);
      //if (mouseY > 5 && mouseY < 1000) {
      //createSlices(mouseY);
      //}
    }
  }
  
  
  void handleKeys() {
    
    
    if (keysDown[kVK_ANSI_1]) {
      textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
      textureRotation = glm::rotate(textureRotation, 1.0f, vec3(1.0,0.0,0.0));
      textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
    }
    
    if (keysDown[kVK_ANSI_2]) {
      textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
      textureRotation = glm::rotate(textureRotation, -1.0f, vec3(1.0,0.0,0.0));
      textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
    }
    
    if (keysDown[kVK_ANSI_3]) {
      textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
      textureRotation = glm::rotate(textureRotation, 1.0f, vec3(0.0,1.0,0.0));
      textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
    }
    
    if (keysDown[kVK_ANSI_4]) {
      textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
      textureRotation = glm::rotate(textureRotation, -1.0f, vec3(0.0,1.0,0.0));
      textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
    }
    
    if (keysDown[kVK_ANSI_5]) {
      textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
      textureRotation = glm::rotate(textureRotation, 1.0f, vec3(0.0,0.0,1.0));
      textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
    }
    
    if (keysDown[kVK_ANSI_6]) {
      textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
      textureRotation = glm::rotate(textureRotation, -1.0f, vec3(0.0,0.0,1.0));
      textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
      
    }
    
    if (keysDown[kVK_ANSI_7]) {
      opacity += 0.001;
    }
    
    if (keysDown[kVK_ANSI_8]) {
      opacity -= 0.001;
    }
    
    if (keysDown[kVK_ANSI_Q]) {
      camera.translateZ(cameraZ);
      camera.rotateY(2);
      camera.translateZ(-cameraZ);
    }
    
    if (keysDown[kVK_ANSI_Z]) {
      camera.translateZ(cameraZ);
      camera.rotateY(-2);
      camera.translateZ(-cameraZ);
    }
    
    if (keysDown[kVK_ANSI_W]) {
      camera.translateZ(cameraZ);
      camera.rotateX(2);
      camera.translateZ(-cameraZ);
    }
    
    if (keysDown[kVK_ANSI_X]) {
      camera.translateZ(cameraZ);
      camera.rotateX(-2);
      camera.translateZ(-cameraZ);
    }
    
    if (keysDown[kVK_ANSI_E]) {
      camera.translateZ(cameraZ);
      camera.rotateZ(2);
      camera.translateZ(-cameraZ);
    }
    
    if (keysDown[kVK_ANSI_C]) {
      camera.translateZ(cameraZ);
      camera.rotateZ(-2);
      camera.translateZ(-cameraZ);
    }
    
    
    /*
     case kVK_ANSI_T :
     
     // orbitRadius -= 0.5;
     // camera.translateZ(0.5);
     // camera.transform();
     break;
     
     case kVK_ANSI_B :
     // orbitRadius = 0.5;
     // camera.translateZ(-0.5);
     //  camera.transform();
     break;
     
     case kVK_ANSI_Y :
     camera.translateX(0.5);
     break;
     
     case kVK_ANSI_N :
     camera.translateX(-0.5);
     break;
     
     case kVK_ANSI_U :
     camera.translateY(0.5);
     break;
     
     case kVK_ANSI_M :
     camera.translateY(-0.5);
     break;
     }
     
     */
  }
  
  
};


int main(){
  return NiftiViewer_Slices().start("aluminum::NiftiViewer", 100, 100, 400, 300);
}


