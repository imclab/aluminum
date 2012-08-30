
#import "CocoaGL.h"
#include <string>

#ifndef ALLOCORE_RENDERER_NATIVE_OSX_AGF 
#define ALLOCORE_RENDERER_NATIVE_OSX_AGF


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

