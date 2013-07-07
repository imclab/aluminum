

#ifndef ALLOCORE_RENDERER_OSX
#define ALLOCORE_RENDERER_OSX

#import "CocoaGL.h"
//#import <string>
//class CocoaGL;

class RendererOSX {
  
public:
  
  RendererOSX();
  
  //basic windowing
  int start();
  int start(std::string _name, int x, int y, int w, int h);
  CocoaGL* makeGLView(int w, int h); //for putting the GL view in a more complicated app with multiple views, etc
  
  
  void toggleFullScreen();
  
  virtual void onCreate();
  virtual void onFrame();
  virtual void onReshape();
  
  
  int width;
  int height;
  
  
  long setStartTick(); //set base nanos - called by Cocoa at init
  long tick(); //calculate amount of time passed since start of program - called by Cocoa prior to each onFrame
  long now(); //get amount of time passed, assumes calculated already with tick()
  
  long nowPlusMillis(long millis);
  long millisToNano(long millis);
  long startTick;
  long currentTick;
  
  virtual void mouseDragged(int px, int py);
  virtual void mouseDown(int px, int py);
  virtual void mouseUp(int px, int py);
  virtual void mouseMoved(int px, int py);
  
  //these two are the old ones! we are now using a flagsChanged event to better detect modifiers
  // virtual void keyDown(char key, bool shift, bool control, bool command, bool option, bool function);
  // virtual void keyUp(char key, bool shift, bool control, bool command, bool option, bool function);
  
  bool keysDown[256];
  bool keysUp[256];
  void initializeKeyArrays();
  virtual void keyDown(char key);
  virtual void keyUp(char key);
  
  
  void initializeMouseInfo();
  bool isPressing = false;
  bool isDragging = false;
  bool isReleasing = false;
  bool isMoving = false;
  int mouseX = 0;
  int mouseY = 0;
  int previousMouseX = 0;
  int previousMouseY = 0;
  
  virtual void handleMouse();
  virtual void handleKeys();
  
  
  CocoaGL* getView();
  CocoaGL* view;
  
};



#endif

