

#ifndef INCLUDE_RENDERER_IOS_H
#define INCLUDE_RENDERER_IOS_H

#import "Includes.hpp"

using std::string;
using glm::ivec2;

class RendererIOS {
  
public:
  
  int width = -1;
  int height = -1;
  
  RendererIOS();
  
  int start();
  
  virtual void onCreate();
  virtual void onFrame();
  
  int frameCount = 0;
  
  virtual void touchBegan(ivec2 mouse);
  virtual void touchMoved(ivec2 prevMouse, ivec2 mouse);
  virtual void touchEnded(ivec2 mouse);
  virtual void longPress(ivec2 mouse);
  virtual void pinch(float scale);
  virtual void pinchEnded();
  
  const char* contentsOfFile(string& file);
  string pathToResource(const string& resource, const string& type);
  
    GLuint getDefaultFrameBuffer();
    
};

#endif