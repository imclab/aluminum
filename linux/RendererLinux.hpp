
#include "FreeGlutGLView.hpp"
#include <string>

#ifndef ALLOCORE_RENDERER_NATIVE_LINUX_AGF 
#define ALLOCORE_RENDERER_NATIVE_LINUX_AGF


class RendererLinux { 
  
public:

  RendererLinux();

  //basic windowing
  void start();
  void start(std::string name);

  virtual void onCreate();
  virtual void onFrame();

  int width;
  int height; 

//  FreeGlutGLView* view;
  void accessView();

  

  
protected:
  
private:

};



#endif

