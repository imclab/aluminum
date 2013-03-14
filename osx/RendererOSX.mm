
#include "Includes.hpp"
//#import <Cocoa/Cocoa.h>
//#import "RendererOSX.h"
#import <chrono>
#import <iostream>

//#import "VideoPlayer.h"

using std::cout;
using std::chrono::duration_cast;
using std::chrono::nanoseconds;
using std::chrono::milliseconds;
using std::chrono::high_resolution_clock;


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


long RendererOSX::nowPlusMillis(long millis) {
  return currentTick + (millis * 1000000);
}

long RendererOSX::millisToNano(long millis) {
  return (millis * 1000000);
}

long RendererOSX::now() {
  return currentTick;
}

long RendererOSX::setStartTick() {
  high_resolution_clock::time_point clock = high_resolution_clock::now();
  //startTick = duration_cast<milliseconds>(clock.time_since_epoch()).count();
  startTick = duration_cast<nanoseconds>(clock.time_since_epoch()).count();
  currentTick = 0;
  return startTick;
}

long RendererOSX::tick() {
  //currentTick = duration_cast<milliseconds>(high_resolution_clock::now().time_since_epoch()).count() - startTick; 
  currentTick = duration_cast<nanoseconds>(high_resolution_clock::now().time_since_epoch()).count() - startTick; 
   return currentTick;
}

/*
//double globalTickVal;
void RendererOSX::tick() {
  NSDate *date = [NSDate date];
  //aluminum::Behavior::globalTickValue = [date timeIntervalSinceReferenceDate];
  //aluminum::Behavior::globalTickVal = [date timeIntervalSinceReferenceDate] - aluminum::Behavior::globalStartVal;
  //printf("globalTickVal = %f\n", aluminum::Behavior::globalTickVal);
  using namespace aluminum;

  Behavior::setTickVal(1.1);
}
*/


void RendererOSX::onFrame() { }
void RendererOSX::onCreate() { }
void RendererOSX::onReshape() { }

/*
void RendererOSX::tryVideoStuff() {
  //printf("hi!\n");
  VideoPlayer* vp = [[VideoPlayer alloc] init];      
  [vp test]; 

}
*/

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

