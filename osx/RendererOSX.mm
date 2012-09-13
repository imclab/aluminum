#import <Cocoa/Cocoa.h>
#include "RendererOSX.h"


RendererOSX::RendererOSX() { 
  printf("in RendererNativeOSX constructor\n");
}

int RendererOSX::start() {
  return RendererOSX::start([[[NSProcessInfo processInfo] processName] UTF8String], 50, 40, 500, 500);
}

int RendererOSX::start(std::string _name, int x, int y, int w, int h) {

  [NSAutoreleasePool new];
 
  [CocoaGL start:this 
    name: [NSString stringWithUTF8String:_name.c_str()]
    x: x
    y: y
    w: w
    h: h
    ];

  return 0;
}

void RendererOSX::onFrame() { }
void RendererOSX::onCreate() { }
void RendererOSX::onReshape() { }
 
CocoaGL* RendererOSX::getView() {
  return view;
}

void RendererOSX::toggleFullScreen() {
  [view toggleFullScreen];
}

void RendererOSX::mouseDragged(int px, int py) {
  //printf("mouseDragged not handled...\n");
}

void RendererOSX::mouseDown(int px, int py) {
  //printf("mouseDown not handled...\n");
}

void RendererOSX::mouseUp(int px, int py) {
  //printf("mouseUp not handled...\n");
}

void RendererOSX::mouseMoved(int px, int py) {
  //printf("mouseMoved not handled...\n");
}

void RendererOSX::keyDown(char key, bool shift, bool control, bool command, bool option, bool function) {
  //printf("keyDown not handled\n");
}

