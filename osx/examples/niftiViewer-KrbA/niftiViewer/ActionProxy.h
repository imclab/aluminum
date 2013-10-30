#ifndef INCLUDE_PROXY
#define INCLUDE_PROXY

#import "Includes.hpp"
#import "RendererOSX.h"
#import <Foundation/Foundation.h>
//#import "Slices.h"

//@class Slices;
//using namespace aluminum;

@interface ActionProxy : NSObject {
  NSValue* target;
  id* opacitySlider;
  id* percentSlider;
}

-(id)init: (NSValue*)_target;

-(void) toggleClusters: (id)sender;
//-(void) sayHello: (id)sender;

-(void) toggleTime1: (id)sender;
-(void) toggleTime2: (id)sender;
-(void) toggleTime3: (id)sender;
-(void) toggleTime4: (id)sender;

-(void) adjustOpacity: (id)sender;
-(void) adjustPercent: (id)sender;

-(void) toggleDrawer: (id)sender;

@end

#endif