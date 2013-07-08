
#import "Includes.hpp"

#import "RendererOSX.h"
#import "MeshBuffer.hpp"
#import "MeshData.hpp"
#import "MeshUtils.hpp"
#import "Program.hpp"
#import "Shapes.hpp"
#import "Texture.hpp"
#import "Camera.hpp"

#import "NiftiUtils.h"
#import "ActionProxy.h"

#define BUFFER_OFFSET(i) (reinterpret_cast<void*>(i))


using namespace aluminum;

class Slices : public RendererOSX {
    
public:
    bool USE_STEREO = false;
    string RESOURCES = (string)[NSHomeDirectory() UTF8String] + "/Dropbox/XCodeProjects/aluminum/osx/examples/niftiViewer/resources/";
    int numSlices = 100;
    
    Camera camera;
    
    vector<MeshBuffer> mbs;
    
    mat4 textureRotation, view, proj;
    
    Program program;
    
    GLint posLoc=0;
    GLint texCoordLoc=1;
    
    Texture brain;
    Texture cluster1_time1, cluster1_time2, cluster1_time3;
    Texture cluster2_time1, cluster2_time2, cluster2_time3;
    Texture cluster3_time1, cluster3_time2, cluster3_time3;
    Texture cluster4_time1, cluster4_time2, cluster4_time3;
    Texture cluster5_time1, cluster5_time2, cluster5_time3;
    
    MeshBuffer mb1;
    
    float bloomAmt = 0.1;
    float orbitRadius = 1.0;
    float opacity = 0.1;
    float percent = 0.0;
    float cameraZ = 0.95;
    
    bool rotateTextureX_plus = false;
    bool rotateTextureX_minus = false;
    
    int useCluster1 = 1;
    int useCluster2 = 1;
    int whichClusters = 0;
    void toggleClusters() {
        whichClusters = (whichClusters+1) % 3;
        if (whichClusters == 0) {
            useCluster1 = 1;
            useCluster2 = 1;
        } else if (whichClusters == 1) {
            useCluster1 = 1;
            useCluster2 = 0;
        } else {
            useCluster1 = 0;
            useCluster2 = 1;
        }
        
        printf("in toggleClusters... u1 = %d, u2 = %d\n", useCluster1, useCluster2);
    }
    
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
    
    
    void loadNiftiInto3DTextures (string path) {
        
        string nii_brain = (path + "MNI152_T1_2mm_brain.nii").c_str();
        string nii_c1t1 = (path + "all_s1_IC2.nii").c_str();
        string nii_c1t2 = (path + "all_s2_IC2.nii").c_str();
        string nii_c1t3 = (path + "all_s3_IC2.nii").c_str();
        string nii_c2t1 = (path + "all_s1_IC7.nii").c_str();
        string nii_c2t2 = (path + "all_s2_IC7.nii").c_str();
        string nii_c2t3 = (path + "all_s3_IC7.nii").c_str();
        string nii_c3t1 = (path + "all_s1_IC25.nii").c_str();
        string nii_c3t2 = (path + "all_s2_IC25.nii").c_str();
        string nii_c3t3 = (path + "all_s3_IC25.nii").c_str();
        string nii_c4t1 = (path + "all_s1_IC31.nii").c_str();
        string nii_c4t2 = (path + "all_s2_IC31.nii").c_str();
        string nii_c4t3 = (path + "all_s3_IC31.nii").c_str();
        string nii_c5t1 = (path + "all_s1_IC39.nii").c_str();
        string nii_c5t2 = (path + "all_s2_IC39.nii").c_str();
        string nii_c5t3 = (path + "all_s3_IC39.nii").c_str();
        
        NiftiUtils::read_nifti_file(nii_brain, brain, 16);
        NiftiUtils::read_nifti_file(nii_c1t1, cluster1_time1, 32);
        NiftiUtils::read_nifti_file(nii_c1t2, cluster1_time2, 32);
        NiftiUtils::read_nifti_file(nii_c1t3, cluster1_time3, 32);
        NiftiUtils::read_nifti_file(nii_c2t1, cluster2_time1, 32);
        NiftiUtils::read_nifti_file(nii_c2t2, cluster2_time2, 32);
        NiftiUtils::read_nifti_file(nii_c2t3, cluster2_time3, 32);
        NiftiUtils::read_nifti_file(nii_c3t1, cluster3_time3, 32);
        NiftiUtils::read_nifti_file(nii_c3t2, cluster3_time2, 32);
        NiftiUtils::read_nifti_file(nii_c3t3, cluster3_time1, 32);
        NiftiUtils::read_nifti_file(nii_c4t1, cluster4_time3, 32);
        NiftiUtils::read_nifti_file(nii_c4t2, cluster4_time2, 32);
        NiftiUtils::read_nifti_file(nii_c4t3, cluster4_time1, 32);
        NiftiUtils::read_nifti_file(nii_c5t1, cluster5_time3, 32);
        NiftiUtils::read_nifti_file(nii_c5t2, cluster5_time2, 32);
        NiftiUtils::read_nifti_file(nii_c5t3, cluster5_time1, 32);
    }
    
    void onCreate() {
        
        loadNiftiInto3DTextures(RESOURCES + "nifti/");
        
        loadProgram(program, RESOURCES + "textureSlices");
        
        camera = Camera(60.0, width/(height*0.5), 0.001, 100.0).translateZ(-cameraZ).convergence(40.0).eyeSep(0.5);
        
        
        createSlices(numSlices);
        
        textureRotation = glm::mat4();
        
        glEnable (GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        glEnable (GL_BLEND);
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_SCISSOR_TEST);
        
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
    void draw(mat4 useproj, mat4 useview) {
        
        program.bind(); {
            
            glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(useproj));
            glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(useview));
            glUniformMatrix4fv(program.uniform("textureRotation"), 1, 0, ptr(textureRotation));
            
            glUniform1f(program.uniform("percent"), percent);
            glUniform1f(program.uniform("opacity"), opacity);
            
            glUniform1i(program.uniform("useCluster1"), useCluster1);
            glUniform1i(program.uniform("useCluster2"), useCluster2);
            
            glUniform1i(program.uniform("brain"), 0);
            glUniform1i(program.uniform("cluster1_time1"), 1);
            glUniform1i(program.uniform("cluster1_time2"), 2);
            glUniform1i(program.uniform("cluster1_time3"), 3);
            
            glUniform1i(program.uniform("cluster2_time1"), 4);
            glUniform1i(program.uniform("cluster2_time2"), 5);
            glUniform1i(program.uniform("cluster2_time3"), 6);
            
            glUniform1i(program.uniform("cluster3_time1"), 7);
            glUniform1i(program.uniform("cluster3_time2"), 8);
            glUniform1i(program.uniform("cluster3_time3"), 9);
            
            glUniform1i(program.uniform("cluster4_time1"), 10);
            glUniform1i(program.uniform("cluster4_time2"), 11);
            glUniform1i(program.uniform("cluster4_time3"), 12);
            
            glUniform1i(program.uniform("cluster5_time1"), 13);
            glUniform1i(program.uniform("cluster5_time2"), 14);
            glUniform1i(program.uniform("cluster5_time3"), 15);
            
            brain.bind(GL_TEXTURE0);
            cluster1_time1.bind(GL_TEXTURE1);
            cluster1_time2.bind(GL_TEXTURE2);
            cluster1_time3.bind(GL_TEXTURE3);
            cluster2_time1.bind(GL_TEXTURE4);
            cluster2_time2.bind(GL_TEXTURE5);
            cluster2_time3.bind(GL_TEXTURE6);
            cluster3_time1.bind(GL_TEXTURE7);
            cluster3_time2.bind(GL_TEXTURE8);
            cluster3_time3.bind(GL_TEXTURE9);
            cluster4_time1.bind(GL_TEXTURE10);
            cluster4_time2.bind(GL_TEXTURE11);
            cluster4_time3.bind(GL_TEXTURE12);
            cluster5_time1.bind(GL_TEXTURE13);
            cluster5_time2.bind(GL_TEXTURE14);
            cluster5_time3.bind(GL_TEXTURE15);
            
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
            cluster3_time1.unbind(GL_TEXTURE7);
            cluster3_time2.unbind(GL_TEXTURE8);
            cluster3_time3.unbind(GL_TEXTURE9);
            cluster4_time1.unbind(GL_TEXTURE10);
            cluster4_time2.unbind(GL_TEXTURE11);
            cluster4_time3.unbind(GL_TEXTURE12);
            cluster5_time1.unbind(GL_TEXTURE13);
            cluster5_time2.unbind(GL_TEXTURE14);
            cluster5_time3.unbind(GL_TEXTURE15);
            
        } program.unbind();
    }
    
    //every 1/60th of a second...
    void onFrame(){
        
        handleKeys();
        handleMouse();
        
        if (camera.isTransformed) {
            camera.transform();
        }
     
        if (!USE_STEREO) {
        glViewport(0, 0, width, height); {
         glScissor(0,0,width, height);
   
         glClearColor(0.0,0.0,0.0,1.0);
            
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
         
            draw(camera.projection, camera.view);
        }
        } else {
        
        
        //Trying out passive stereo...
        
        glViewport(0, 0, width/2.0, height); {
            glScissor(0,0,width/2.0, height);
            glClearColor(0.0,0.0,0.0,1.0);
            
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            
            draw(camera.leftProjection, camera.leftView);
        }
        
        glViewport(width/2.0, 0, width/2.0, height); {
            glScissor(width/2.0, 0, width/2.0, height);
            glClearColor(0.0,0.0,0.0,1.0);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            
            draw(camera.rightProjection, camera.rightView);
        }
            
        }
    }
    
    void onReshape() {
        camera.perspective(60.0, width/(height*0.5), 0.001, 100.0).stereo(false);
    }
    
    void handleMouse() {
        
        bool movingLeft = false;
        bool movingRight = false;
        bool movingUp = false;
        bool movingDown = false;
        
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
            //printf("isMoving = true...\n");
            //printf("percent = %f, ", percent);
            //printf("opacity = %f\n", opacity);
            
            //if (mouseY > 5 && mouseY < 1000) {
            //createSlices(mouseY);
            //}
            isMoving = false; //isn't a listener that can hear when a mouse *stops*?
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
    
    void initializeViews() {
        
        
        NSView* glv = makeGLView(400, 300);
        
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        
        id appName = @"ICA Time Series";
        
        
        // Set up the window to hold the CocoaGL view
        id window = [CocoaGL setUpAppWindow:appName
                                          x: 100
                                          y: 100
                                          w: 400
                                          h: 300];
        
        [CocoaGL setUpMenuBar:(CocoaGL*)glv name:appName];
        
        ActionProxy* proxy = [[ActionProxy alloc] init:[NSValue valueWithPointer:this]];
        
        NSSplitView* parentView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
        [parentView setVertical:YES];
        [window setContentView:parentView];
        
        NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 200, 300)];
        NSRect frame = NSMakeRect(10, 40, 90, 40);
        NSButton* pushButton = [[NSButton alloc] initWithFrame: frame];
        pushButton.bezelStyle = NSRoundedBezelStyle;
        
        
        
        [pushButton setTarget:proxy];
        [pushButton setAction:@selector(toggleClusters:)];
        
        
        
        
        [view addSubview:pushButton];
        
        [[window contentView] addSubview:view];
        [[window contentView] addSubview:glv];
        
        [NSApp activateIgnoringOtherApps:YES]; //brings application to front on startup
        [NSApp run];
        
    }
    
};




