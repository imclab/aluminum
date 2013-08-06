

#ifndef __GLES2Sample__RendererIOS__
#define __GLES2Sample__RendererIOS__


#import "Includes.hpp"

using namespace std;
using glm::ivec2;

class RendererIOS {
  
public:
  
  int width = -1;
  int height = -1;
  
  RendererIOS();
  
  int start();
  
  virtual void onCreate();
  virtual void onFrame();
  
  
  virtual void touchBegan(ivec2 mouse);
  virtual void touchMoved(ivec2 prevMouse, ivec2 mouse);
  virtual void touchEnded(ivec2 mouse);
  virtual void longPress(ivec2 mouse);
  virtual void pinch(float scale);
  virtual void pinchEnded();
  
  const char* contentsOfFile(string& file);
  string pathToResource(const string& resource, const string& type);
  
};










#endif /* defined(__GLES2Sample__RendererIOS__) */
