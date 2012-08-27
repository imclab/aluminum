
#import "CocoaGL.h"

#ifndef ALLOCORE_RENDERER_NATIVE_OSX_AGF 
#define ALLOCORE_RENDERER_NATIVE_OSX_AGF


class RendererOSX { 
  
public:

  RendererOSX();

  //basic windowing
  static int start(void* app);
  int start();

  void toggleFullScreen();

  virtual void onCreate();
  virtual void onFrame();

  int width;
  int height; 

  virtual void mouseDragged(int px, int py);
  virtual void mouseDown(int px, int py);
  virtual void mouseUp(int px, int py);
  virtual void mouseMoved(int px, int py);
  virtual void keyDown(char key, bool shift, bool control, bool command, bool option, bool function);

  CocoaGL* getView();
  CocoaGL* view;
};



#endif

