

#include "RendererIOS.h"
#include "AppDelegate.h"


using namespace std;

RendererIOS::RendererIOS() {}


int RendererIOS::start() {
  @autoreleasepool {
    
    [AppDelegate setRenderer:this];
    
    return UIApplicationMain(nil, nil, nil, NSStringFromClass([AppDelegate class]));
    
  }
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

const char* RendererIOS::contentsOfFile(string& file) {
  NSString* filePath = [[NSString alloc] initWithUTF8String:file.c_str()];
  NSString* contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
  return [contents UTF8String];
}


string RendererIOS::pathToResource(const string& resource, const string& type) {
  
  NSString* resourcePath = [[NSString alloc] initWithUTF8String:resource.c_str()];
  NSString* typePath = [[NSString alloc] initWithUTF8String:type.c_str()];
  NSBundle* mainBundle = [NSBundle mainBundle];
  NSString* fullPath = [mainBundle pathForResource:resourcePath ofType:typePath];
  
  cout << "in GetPathForResourceOfType(...), pathStr = " << [fullPath UTF8String] << "\n";
  return [fullPath UTF8String];
}
