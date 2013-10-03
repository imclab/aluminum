

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
}

- (id)init: (NSValue*)_target;

-(void) toggleClusters: (id)sender;
-(void) buttonAction2: (id)sender;


@end

#endif