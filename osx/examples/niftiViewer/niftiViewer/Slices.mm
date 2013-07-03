
#include "Includes.hpp"

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include "Texture.hpp"
#include "Camera.hpp"

//NIFTI stuff...
#include "nifti1.h"
#include "nifti1_io.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef signed short MY_DATATYPE;
//typedef unsigned char MY_DATATYPE;
#define MIN_HEADER_SIZE 348
#define NII_HEADER_SIZE 352
//END NIFTI stuff...


#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))

#define RESOURCES_DIR "/Dropbox/XCodeProjects/aluminum/osx/examples/niftiViewer/resources/"



using namespace aluminum;

class NiftiViewer_Slices : public RendererOSX {
public:
    
    char* HOME = (char *) [NSHomeDirectory() UTF8String];
    
    Camera camera;
   
    int numSlices = 100;
    MeshBuffer mbs[100];
    
    
    mat4 model, view, proj;
    
    Program program;
    
    GLint posLoc=0;
    GLint texCoordLoc=1;
    
    Texture texture;
    MeshBuffer mb1;
    
    float bloomAmt = 0.1;
    float orbitRadius = 1.0;
    float opacity = 0.1;
    float cameraZ = 1.5;
    
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
    
    int read_nifti_file(const char* data_file) {
        nifti_1_header hdr;
        FILE *fp;
        unsigned long ret;
        int i;
        double total;
        MY_DATATYPE *data=NULL;
        
        
        /********** open and read header */
        fp = fopen(data_file,"r");
        if (fp == NULL) {
            perror(data_file);
            fprintf(stderr, "\nError opening header file %s\n",data_file);
            exit(1);
        }
        ret = fread(&hdr, MIN_HEADER_SIZE, 1, fp);
        if (ret != 1) {
            perror(data_file);
            fprintf(stderr, "\nError reading header file %s\n",data_file);
            exit(1);
        }
        
        
        //disp_nifti_1_header( "abc", &hdr );
        
        
        
        /********** print a little header information */
        /*
         fprintf(stderr, "\n%s header information:",hdr_file);
         fprintf(stderr, "\nXYZT dimensions: %d %d %d %d",hdr.dim[1],hdr.dim[2],hdr.dim[3],hdr.dim[4]);
         fprintf(stderr, "\nDatatype code and bits/pixel: %d %d",hdr.datatype,hdr.bitpix);
         fprintf(stderr, "\nScaling slope and intercept: %.6f %.6f",hdr.scl_slope,hdr.scl_inter);
         fprintf(stderr, "\nByte offset to data in datafile: %ld",(long)(hdr.vox_offset));
         fprintf(stderr, "\n");
         */
        
        
        ret = fseek(fp, (long)(hdr.vox_offset), SEEK_SET);
        if (ret != 0) {
            perror(data_file);
            fprintf(stderr, "\nError doing fseek() to %ld in data file %s\n",(long)(hdr.vox_offset), data_file);
            exit(1);
        }
        
        
        /********** allocate buffer and read first 3D volume from data file */
        data = (MY_DATATYPE *) malloc(sizeof(MY_DATATYPE) * hdr.dim[1]*hdr.dim[2]*hdr.dim[3]);
        if (data == NULL) {
            fprintf(stderr, "\nError allocating data buffer for %s\n",data_file);
            exit(1);
        }
        ret = fread(data, sizeof(MY_DATATYPE), hdr.dim[1]*hdr.dim[2]*hdr.dim[3], fp);
        printf("ret = %ld,  size = %d\n", ret, (hdr.dim[1]*hdr.dim[2]*hdr.dim[3]));
        if (ret != hdr.dim[1]*hdr.dim[2]*hdr.dim[3]) {
            fprintf(stderr, "\nError reading volume 1 from %s (%ld)\n",data_file,ret);
            exit(1);
        }
        fclose(fp);
        
        
        /********** scale the data buffer  */
        
        if (hdr.scl_slope != 0) {
            for (i=0; i<hdr.dim[1]*hdr.dim[2]*hdr.dim[3]; i++)
                data[i] = (data[i] * hdr.scl_slope) + hdr.scl_inter;
        }
        
        
        /********** print mean of data */
        
        total = 0;
        int max = 0;
        
        for (i=0; i<hdr.dim[1]*hdr.dim[2]*hdr.dim[3]; i++) {
            total += data[i];
            if (data[i] > max){
                //printf("%d\n", data[i]);
                max = data[i];
            }
        }
        total /= (hdr.dim[1]*hdr.dim[2]*hdr.dim[3]);
        fprintf(stderr, "\nMean of volume 1 in %s is %.3f\n",data_file,total);
        
        
        
        
        /** save to 3D Texture **/
        int numBytes = hdr.dim[1]*hdr.dim[2]*hdr.dim[3];
        GLubyte *oneslice = (GLubyte *) malloc(sizeof(GLubyte) * (numBytes) );
        
        int idx = 0;
        for (i=0; i < numBytes; i++) {
            oneslice[idx++] = (GLubyte) (( (float)data[i]/(float)max ) * 255 );
        }
        
        glPixelStorei(GL_PACK_ALIGNMENT, 1);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
        texture = Texture(oneslice, 91, 109, 91, GL_RGBA, GL_RED, GL_UNSIGNED_BYTE);
        
        texture.minFilter(GL_LINEAR);
        texture.maxFilter(GL_LINEAR);
        
        return(0);
    }
    
    
    
    
    void onCreate() {
  
      const char* nii = (const char * )(HOME + std::string(RESOURCES_DIR) + "MNI152_T1_2mm.nii").c_str();
      printf("nii file = %s\n", nii);
        read_nifti_file(nii);
       
        loadProgram(program, HOME + std::string(RESOURCES_DIR) + "textureSlices");
        
        
        camera = Camera(60.0, width/(height*0.5), 0.001, 100.0);
        camera.translateZ(-cameraZ);
        
        /*
        MeshData md = MeshUtils::makeRectangle(vec2(-0.5, -0.5), vec2(0.5, 0.5), vec3(-0.5, -0.5, 0.5), vec3(1.5,1.5,0.5)    );
        mb1.init(md, posLoc, -1, texCoordLoc, -1);
        */
        
        
        float zSt = -orbitRadius/2.0;
        float zInc = (orbitRadius) / ((float)numSlices - 1);
        
        float tczInc = 1.0 / ((float)numSlices - 1);
        
        for (int i = 0; i < numSlices; i++) {
            MeshData md = MeshUtils::makeRectangle(vec3(-0.5, -0.5, zSt + (zInc * i)), vec3(0.5, 0.5, zSt + (zInc * i)), vec3(-0.15, -0.15, tczInc * i), vec3(1.15,1.15,tczInc * i)    );
            mbs[i].init(md, posLoc, -1, texCoordLoc, -1);
        }
        
        //mb1.init(MeshUtils::makeRectangle(), posLoc, -1, texCoordLoc, -1);
        
       // proj = glm::perspective(45.0, 1.0, 0.1, 100.0);
       // view = glm::lookAt(vec3(0.0,0.0,-2), vec3(0,0,0), vec3(0,1,0) );
        model = glm::mat4();
       // model = glm::translate(model, vec3(0.0,0.0,0.0));
        
        
        glEnable(GL_DEPTH_TEST);
        glViewport(0, 0, width, height);
        glClearColor(0.3,0.3,0.3,1.0);
    }
    
    void onFrame(){

        if (camera.isTransformed) {
            camera.transform();
        }

        
        model = glm::translate(model, vec3(0.5,0.5,0.5));
        if (rotateTextureX_plus) {
            model = glm::rotate(model, 1.0f, vec3(1.0,0.0,0.0));
        }
        
        if (rotateTextureX_minus) {
            model = glm::rotate(model, -1.0f, vec3(1.0,0.0,0.0));
        }
        model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
        
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glDisable (GL_DEPTH_TEST);
        glEnable (GL_BLEND);
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        //glBlendFunc (GL_ONE, GL_ONE);
        
        program.bind(); {
        
        for (int i = 0; i < numSlices; i++) {
        
        
            
            glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(camera.projection));
            glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(camera.view));
            glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model));
            
            glUniform1f(program.uniform("opacity"), opacity);
            glUniform1i(program.uniform("tex0"), 0);
            
            texture.bind(GL_TEXTURE0); {
                //mb1.draw();
                mbs[i].draw();
            } texture.unbind(GL_TEXTURE0);
            
        }
            
        } program.unbind();
    }
    
    void onReshape() {
        glViewport(0, 0, width, height);
        camera.perspective(60.0, width/(height*0.5), 0.001, 100.0);
        
    }
    
    void mouseMoved(int px, int py) {
       // bloomAmt = ((float)px/(float)width) * 0.02; //bloom between 0.00 -> 0.02
       
      
        
        
       
    }

    void mouseDragged(int px, int py) {
        printf("in Basic: mouseDragged %d/%d\n", px, py);
    }
    
    void mouseDown(int px, int py) {
        printf("in Basic: mouseDown %d/%d\n", px, py);
    }
    
    void mouseUp(int px, int py) {
        printf("in Basic: mouseUp %d/%d\n", px, py);
    }
    
    virtual void keyDown(char key, bool shift, bool control, bool command, bool option, bool function) {
        printf("keyDown!\n");
        
        
        switch(key) {
            case kVK_Space :
                camera.resetVectors();
                break;
           
            case kVK_ANSI_1 :
                rotateTextureX_plus = true;
                break;
            case kVK_ANSI_2 :
                rotateTextureX_minus = true;
                break;
            case kVK_ANSI_3 :
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, 1.0f, vec3(0.0,1.0,0.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
            case kVK_ANSI_4 :
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, -1.0f, vec3(0.0,1.0,0.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
            case kVK_ANSI_5 :
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, 1.0f, vec3(0.0,0.0,1.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
            case kVK_ANSI_6 :
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, -1.0f, vec3(0.0,0.0,1.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
            case kVK_ANSI_7 :
                opacity += 0.001;
                break;
            case kVK_ANSI_8 :
                opacity -= 0.001;
                break;

                
            case kVK_ANSI_A :
                
                std::cout<<glm::to_string(camera.posVec)<<std::endl;
                break;
                
            case kVK_ANSI_Q :
            {
             //   std::cout<<"0:"<<glm::to_string(camera.posVec)<<std::endl;
                
                camera.translateZ(cameraZ);
                camera.transform();
                camera.rotateY(2);
                camera.transform();
                camera.translateZ(-cameraZ);
                camera.transform();
           //     std::cout<<"3:"<<glm::to_string(camera.posVec)<<std::endl;
            }
                break;
                
            case kVK_ANSI_Z :
                camera.translateZ(cameraZ);
                camera.transform();
                camera.rotateY(-2);
                camera.transform();
                camera.translateZ(-cameraZ);
                camera.transform();
                
                break;
                
            case kVK_ANSI_W :
                camera.translateZ(cameraZ);
                camera.transform();
                camera.rotateX(2);
                camera.transform();
                camera.translateZ(-cameraZ);
                camera.transform();
                
             //   camera.rotateX(2);
                break;
                
            case kVK_ANSI_X :
               
                camera.translateZ(cameraZ);
                camera.transform();
                camera.rotateX(-2);
                camera.transform();
                camera.translateZ(-cameraZ);
                camera.transform();
                
             //   camera.rotateX(-2);
                break;
                
            case kVK_ANSI_E :
                camera.rotateZ(2);
                break;
                
            case kVK_ANSI_C :
                camera.rotateZ(-2);
                break;
                
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
    }
    
    void keyUp(char key, bool shift, bool control, bool command, bool option, bool function) {
        printf("keyUp!\n");
        rotateTextureX_plus = false;
        rotateTextureX_minus = false;
    }
    
};

/*
    void keyDown(char key, bool shift, bool control, bool command, bool option, bool function) {
        printf("in Basic: key = %c, shift=%d, control=%d, command=%d, option=%d, function=%d\n", key, shift, control, command, option, function);
        switch(key) {
            case kVK_ANSI_A : 
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, 1.0f, vec3(1.0,0.0,0.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
            case kVK_ANSI_Z :
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, -1.0f, vec3(1.0,0.0,0.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
            case kVK_ANSI_S :
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, 1.0f, vec3(0.0,1.0,0.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
            case kVK_ANSI_X :
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, -1.0f, vec3(0.0,1.0,0.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
            case kVK_ANSI_D :
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, 1.0f, vec3(0.0,0.0,1.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
            case kVK_ANSI_C :
                model = glm::translate(model, vec3(0.5,0.5,0.5));
                model = glm::rotate(model, -1.0f, vec3(0.0,0.0,1.0));
                model = glm::translate(model, vec3(-0.5,-0.5,-0.5));
                break;
                
        }
    }
    
};
*/


int main(){ 
    return NiftiViewer_Slices().start("aluminum::NiftiViewer", 100, 100, 400, 300);
}

