
//#import <Cocoa/Cocoa.h>
//#include "allocore/graphics/al_Graphics.hpp"
#import "NSGLView.h"

#ifndef ALLOCORE_RENDERER_NATIVE_OSX_AGF 
#define ALLOCORE_RENDERER_NATIVE_OSX_AGF


class RendererNativeOSX { 
  
public:

  RendererNativeOSX();

  //basic windowing
  static void start(void* app);
  void start();

  virtual void onCreate();
  virtual void onFrame();

  int width;
  int height; 

  NSGLView* view;
  void accessView();

  

  
protected:
  
private:

};



#endif

