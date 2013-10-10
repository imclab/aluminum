
#include "RendererIOS.h"
#include "AppDelegate.h"
#import "EAGLView.h"

RendererIOS::RendererIOS() {}

int RendererIOS::start() {
  @autoreleasepool {
    
    [AppDelegate setRenderer:this];
    
    return UIApplicationMain(nil, nil, nil, NSStringFromClass([AppDelegate class]));
    
  }
}

GLuint RendererIOS::getDefaultFrameBuffer() {
    
    AppDelegate* ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    EAGLView *ev = ad.glView;
    
    return (GLuint)[ev getDefaultFramebuffer];
    
}

/*
mouseBegan[id] = true
mouseEnded[id] = false
mousePrev[id] = 45
mouseCurrent[id] = 46
longPress = true
longPressPosition = x,y
pinching = true
pinchScale = 1.2
-- or does the display synch take care of this?? 
 (that is, do we need to keep track of touches separately from the callbacks - or is there some built in run loop that will make sure that touches + other events happen before rendering...?)
*/

//virtual method that must be implemented (if you want anything to happen)
void RendererIOS::onFrame() {}
void RendererIOS::onCreate() {}

//virtual methods to be optionally implemented by subclass,
//probably we will want to think about how to do this in a more threaded way like with RendererOSX. 
void RendererIOS::touchBegan(ivec2 mouse) {}
void RendererIOS::touchMoved(ivec2 prev, ivec2 mouse) {}
void RendererIOS::touchEnded(ivec2 mouse) {}
void RendererIOS::longPress(ivec2 mouse) {}
void RendererIOS::pinch(float scale) {}
void RendererIOS::pinchEnded() {}
