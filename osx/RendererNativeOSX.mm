#import <Cocoa/Cocoa.h>
#include "RendererNativeOSX.h"

RendererNativeOSX::RendererNativeOSX() { 
  printf("in RendererNativeOSX constructor\n");
}

void RendererNativeOSX::start(void* app) {
  [NSGLView start:app];
}
void RendererNativeOSX::start() {
  [NSGLView start:this];
}


void RendererNativeOSX::onFrame() { }
void RendererNativeOSX::onCreate() { }
 
void RendererNativeOSX::accessView() {
  printf("about to access object-c view...\n");
  [view printView];
}
