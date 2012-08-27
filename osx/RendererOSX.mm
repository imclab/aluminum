#import <Cocoa/Cocoa.h>
#include "RendererOSX.h"

RendererOSX::RendererOSX() { 
  printf("in RendererNativeOSX constructor\n");
}

int RendererOSX::start(void* app) {
  [CocoaGL start:app];
  return 0;
}

int RendererOSX::start() {
  [CocoaGL start:this];
  return 0;
}

void RendererOSX::onFrame() { }
void RendererOSX::onCreate() { }
 
CocoaGL* RendererOSX::getView() {
 // printf("about to access object-c view...\n");
 // [view printView];
  return view;
}


void RendererOSX::toggleFullScreen() {
  [view toggleFullScreen];
}

void RendererOSX::mouseDragged(int px, int py) {
  printf("mouseDragged not handled...\n");
}

void RendererOSX::mouseDown(int px, int py) {
  printf("mouseDown not handled...\n");
}

void RendererOSX::mouseUp(int px, int py) {
  printf("mouseUp not handled...\n");
}

void RendererOSX::mouseMoved(int px, int py) {
  printf("mouseMoved not handled...\n");
}

void RendererOSX::keyDown(char key, bool shift, bool control, bool command, bool option, bool function) {
  printf("keyDown not handled\n");
}

