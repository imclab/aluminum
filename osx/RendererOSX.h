

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

  void toggleFullScreen();

  virtual void onCreate();
  virtual void onFrame();
  virtual void onReshape();
  //virtual void tryVideoStuff();

  int width;
  int height; 

  bool keysDown[256];
  bool keysUp[256];
    void initializeKeyArrays();
    
    
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
    virtual void keyDown(char key, bool shift, bool control, bool command, bool option, bool function);
    virtual void keyUp(char key, bool shift, bool control, bool command, bool option, bool function);

    virtual void keyDown(char key);
    virtual void keyUp(char key);

    
  CocoaGL* getView();
  CocoaGL* view;

};



#endif

