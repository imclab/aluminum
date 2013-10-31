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

class RayCast : public RendererOSX {

public:

    // Set Global vars
    bool USE_STEREO = false;
    string RESOURCES = (string)[NSHomeDirectory() UTF8String] + "/Dropbox/XCodeProjects/aluminum/osx/examples/niftiViewer-KrbA/resources/";

    Texture brain;
    Camera camera;
    Program program;

    MeshData meshData;
    MeshBuffer meshBuffer;

    vec3 stepSize;
    mat4 textureRotation, textureRotationStart, view, proj;

    GLint posLoc=0;
    GLint texCoordLoc=1;

    float bloomAmt = 0.1;
    float orbitRadius = 1.0;
    float opacity = 0.1;
    float percent = 0.0;
    float cameraZ = 5.0;  // 0.95

    bool rotateTextureX_plus = false;
    bool rotateTextureX_minus = false;

    NSSlider* opacitySlider;
    NSSlider* percentSlider;
    NSDrawer* drawerLeftSide;

    int useCluster1 = 1;
    int useCluster2 = 1;
    int useCluster3 = 1;
    int whichClusters = 0;

    const int XDIM = 91;
    const int YDIM = 109;
    const int ZDIM = 91;


    /******************************************************************
     * wrapper for Texture::loadTexture
     ******************************************************************/
    void loadTexture(Texture& t, const std::string& name) {
        printf("\n\tIn loadTexture\n");
        t.loadTexture(t, name);
    } // end of loadTexture


    /*******************************************************************
     *  Using the supplied path, creates a string of the nifti file to
     *  be loaded into a texture
     *
     *  Loads a nifti file into a 3D Texture
     *******************************************************************/
    void loadNiftiInto3DTextures(string path) {
        printf("\n\tIn loadNiftiInto3DTextures\n");
        // string nii_brain = (path + "TT_N27.nii").c_str();
        string nii_brain = (path + "MNI_2mm.nii").c_str();

        // Takes the string created above (1st param) and loads it into a texture (2nd param)
        NiftiUtils::read_nifti_file(nii_brain, brain);

    } // end of void loadNiftiInto3DTextures(string path)


    /*******************************************************************
     * Creates a Program object, then links the attached shaders to that
     * object. This in effect prepares our shaders
     *******************************************************************/
    void loadProgram(Program &p, const std::string& name) {
        printf("\n\tIn loadProgram!\n");

        p.create();  // This creates an 'empty' Program object

        // This attaches a shader object to the Program object
        //  p.loadText is doing what it sounds like...
        p.attach(p.loadText(name + ".vsh"), GL_VERTEX_SHADER);

        // This is effectively binding a named attribute variable ("vertexPosition"), with
        // a generic attribute index (posLoc)
                           //VVVV--p.id() returns a GLuint! Its basically the Program objects ID number
        glBindAttribLocation(p.id(), (GLuint) posLoc, "vertexPosition");
        glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");


        p.attach(p.loadText(name + ".fsh"), GL_FRAGMENT_SHADER);


        // This is effectively linking the Program object to the attached Shader Objects
        // thereby creating shader executables which will then be run by the GPU
        // Additionally, it maps uniforms and attributes to their Program id
        p.link();

    } // end of loadProgram


    /******************************************************
     *  Loads available nifti images into 3D textures,
     *  then builds a texture
     ******************************************************/
    void onCreate() {
        printf("\n\tIn onCreate!\n");

        loadNiftiInto3DTextures(RESOURCES + "nifti/"); // load the nifti images into textures
        loadProgram(program, RESOURCES + "rayCast");

        /*
        camera = Camera(60.0,
                        width/(height),
                        0.001,
                        100.0).translateZ(-cameraZ).convergence(10.0).eyeSep(1.0/30.0 * 10.0);
        */
        
        camera = Camera(60.0, width/(height*0.5), 0.001, 100.0);

    /*
     *  Constructs a texture mesh of a cube which we will
     *  later pass our ray through
     */
        meshData = MeshUtils::makeCube2(1.0f);
        meshBuffer.init(meshData, posLoc, -1, texCoordLoc, -1);


        textureRotation = glm::mat4();
        textureRotationStart = glm::mat4();

        
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_SCISSOR_TEST);
        
    } // end of onCreate


    void draw(mat4 useproj, mat4 useview) {
        // printf("\n\tIn draw!\n");

        program.bind(); {

            glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(useproj));
            glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(useview));
            glUniformMatrix4fv(program.uniform("textureRotation"), 1, 0, ptr(textureRotation));


            glUniform1i(program.uniform("brain"), 0);
            glUniform3fv(program.uniform("cameraPos"), 1, ptr(camera.posVec));
            glUniform3f(program.uniform("step_Size"), 1.0f/XDIM, 1.0f/YDIM, 1.0f/ZDIM);
            glUniform1f(program.uniform("opacity"), 1.0);

            brain.bind(GL_TEXTURE0);
                meshBuffer.draw();
            brain.unbind(GL_TEXTURE0);

        } program.unbind();
    } // end of void draw()


    //every 1/60th of a second...
    void onFrame(){

        // printf("\n\tIn onFrame!\n");

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
    }  // end of onFrame


    /******************************
    *
    *   Currently Unused
    *******************************/
    void onReshape() {
        // printf("\n\tIn onReshape!\n");

        camera.perspective(60.0, (float)width/(float)height, 0.001, 100.0);
        printf("camera: %f, %f %f", camera.posVec.x,camera.posVec.y, camera.posVec.z );
    } // Angus version



    /**********************************
    *
    * Takes care of Mouse interactions
    ***********************************/
    void handleMouse() {
        // printf("\n\tIn handleMouse!\n");

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
            textureRotation = glm::rotate(textureRotation, -3.0f, vec3(0.0,1.0,0.0));
        } else if (movingRight) {
            textureRotation = glm::rotate(textureRotation, 3.0f, vec3(0.0,1.0,0.0));
        }

        if (movingUp) {
            textureRotation = glm::rotate(textureRotation, 3.0f, vec3(1.0,0.0,0.0));
        } else if (movingDown){
            textureRotation = glm::rotate(textureRotation, -3.0f, vec3(1.0,0.0,0.0));
        }
            textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

        if (isMoving) {
            printf("X: %d, Y: %d\n", mouseX, mouseY);
            isMoving = false; //isn't a listener that can hear when a mouse *stops*?
        }
    } // end of handleMouse


    void handleKeys() {
        handleKeys_auxilliary();
        handleKeys_wasdqe();
        handleKeys_arrows();
        if (percent >= 1.0) {
            percent = 1.0;
        } else if (percent <= 0.0) {
            percent = 0.0;
        }

        if (opacity >= 1.0) {
            opacity = 1.0;
        } else if (opacity <= 0.0) {
            opacity = 0.0;
        }
    }


    void handleKeys_wasdqe() {
        float dg=1.0f;

        if (keysDown[kVK_Shift]) {
            dg=3.0f;
        }

        if (keysDown[kVK_ANSI_W]) {
          printf("Pressing W key!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, dg, vec3(1.0,0.0,0.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

        if (keysDown[kVK_ANSI_S]) {
          printf("Pressing S key!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, -dg, vec3(1.0,0.0,0.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

        if (keysDown[kVK_ANSI_A]) {
          printf("Pressing A key!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, dg, vec3(0.0,1.0,0.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

        if (keysDown[kVK_ANSI_D]) {
          printf("Pressing D key!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, -dg, vec3(0.0,1.0,0.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

        if (keysDown[kVK_ANSI_Q]) {
          printf("Pressing Q key!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, dg, vec3(0.0,0.0,1.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

        if (keysDown[kVK_ANSI_E]) {
          printf("Pressing E key!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, -dg, vec3(0.0,0.0,1.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

    }

    /*******************************************************************
     *  Dianne wanted the arrow keys to be usable for 'Old' People...they only provide
     *  basic tranlations and rotations, nothing exciting
     *******************************************************************/
    void handleKeys_arrows() {

        float dg=1.0f;
        if (keysDown[kVK_Shift]) {
            dg=3.0f;
        }

        if (keysDown[kVK_UpArrow]) {
          printf("Pressing UpArrow!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, dg, vec3(1.0,0.0,0.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

        if (keysDown[kVK_DownArrow]) {
          printf("Pressing DownArrow!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, -dg, vec3(1.0,0.0,0.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

        if (keysDown[kVK_LeftArrow]) {
          printf("Pressing LeftArrow!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, dg, vec3(0.0,1.0,0.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }

        if (keysDown[kVK_RightArrow]) {
          printf("Pressing RightArrow!\n");
          textureRotation = glm::translate(textureRotation, vec3(0.5,0.5,0.5));
          textureRotation = glm::rotate(textureRotation, -dg, vec3(0.0,1.0,0.0));
          textureRotation = glm::translate(textureRotation, vec3(-0.5,-0.5,-0.5));
        }
    }

    void handleKeys_auxilliary() {
        float amt=0.001;
        float dg=0.05;
        // if (keysDown[kVK_Shift]) {
        //     amt=-0.001;
        //     dg=-0.05;
        // }
        if (keysDown[kVK_ANSI_X]) {
            amt=-0.001;
            dg=-0.05;
            camera.translateZ(dg);
            std::cout << "Zooming!..." << glm::to_string(camera.posVec) << "\n";
        }

        if (keysDown[kVK_ANSI_O]) {
            opacity += amt;
            printf("opacity: %f\n", opacity);
        }

        // Increase the Percent
        if (keysDown[kVK_ANSI_P]) {
            percent += amt;
            printf("percent: %f\n", percent);
        }

        // Increase Z!
        if (keysDown[kVK_ANSI_Z]) {
            camera.translateZ(dg);
            std::cout << "Zooming!..." << glm::to_string(camera.posVec) << "\n";
        }

        // Take us home!
        if (keysDown[kVK_ANSI_KeypadEnter]) {
            printf("\nReset layout!\n");
            textureRotation = textureRotationStart;
            camera.resetVectors();
            camera.translateZ(-5.000000);
            opacity = 0.1;
            percent = 0.0;

        }

        if (keysDown[kVK_Space]) {
            printf("Nothing at all...\n");
        }
    }

    /**** Begin function definitions ****/

    void toggleDrawer() {
       if (([drawerLeftSide state] == NSDrawerOpenState))  {
           [drawerLeftSide close];
           printf("Closing Left drawer..\n");
       } else if (([drawerLeftSide state] == NSDrawerClosedState)) {
            [drawerLeftSide open];
            printf("Opening Left drawer..\n");
       }
    }


    // Toggle clusters on, and off
    // this is an ActionProxy function
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
    } // end of toggleClusters()


    void toggleTime1() {
        printf("In toggleTime1, useCluster1 %d\n", useCluster1);
            // whichClusters = (whichClusters+1) % 3;
        if (useCluster1 == 0) {
            useCluster1 = 1;
        } else {
            useCluster1 = 0;
        }
    }

    void toggleTime2() {
        printf("In toggleTime2, useCluster2 %d\n", useCluster2);
            // whichClusters = (whichClusters+1) % 3;
        if (useCluster2 == 0) {
            useCluster2 = 1;
        } else {
            useCluster2 = 0;
        }
    }

    void toggleTime3() {
        printf("In toggleTime3, useCluster3 %d\n", useCluster3);
            // whichClusters = (whichClusters+1) % 3;
        if (useCluster3 == 0) {
            useCluster3 = 1;
        } else {
            useCluster3 = 0;
        }
    }

    void adjustOpacity() {
        printf("In adjustOpacity, slider is == %f\n", [opacitySlider floatValue]);
        opacity = [opacitySlider floatValue];
    }


    void adjustPercent() {
        printf("In adjustPercent, slider is == %f\n", [percentSlider floatValue]);
        percent = [percentSlider floatValue];
    }


    void initializeViews() {
        // This was a really helpful resource
        // http://stackoverflow.com/questions/349927/programmatically-creating-controls-in-cocoa
        // http://stackoverflow.com/questions/717442/how-do-i-create-cocoa-interfaces-without-interface-builder

        NSView* glv = makeGLView(400, 300);
        // ActionProxy* proxy = [[ActionProxy alloc] init:[NSValue valueWithPointer:this]];

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

        // need to look into how to autoresize the window, until then its not useful to use a regular view,
        NSSplitView* parentView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
        [parentView setVertical:YES];
        [window setContentView:parentView];

        [[window contentView] addSubview:glv];
        // [[window contentView] addSubview:view];
        [NSApp activateIgnoringOtherApps:YES]; //brings application to front on startup
        [NSApp run];

    }
};


