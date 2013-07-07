/**

 The answers to :
 http://stackoverflow.com/questions/8948401/handle-cocoa-setaction-message-in-objective-c
 http://stackoverflow.com/questions/1928152/passing-a-c-object-with-an-objective-c-cocoa-event-performselector

 Were VERY helpful in figuring out how to send messages from obj-c widgets to C++
 **/
 
#import "ActionProxy.h"
#import "Slices.mm"
#import "Basic.mm"

@implementation ActionProxy

- (id)init: (NSValue*)_target {
  [super init];
  target = _target;
  return self;
}

-(void) buttonAction: (id)sender {
  ((Slices*)target)->PrintHi();
  //((Slices*)[target pointerValue])->PrintHi();
}


-(void) buttonAction2: (id)sender {
  
  ((NiftiViewer*)target)->SayHello();
  
  //((Slices*)[target pointerValue])->PrintHi();
  
}


@end
