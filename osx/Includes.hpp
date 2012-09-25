#ifndef INCLUDE_OSX_INCLUDES_HPP
#define INCLUDE_OSX_INCLUDES_HPP

#include <OpenGL/gl3.h>
#import <Cocoa/Cocoa.h>

//saves me from typing "glm::value_ptr"
#define ptr( a ) glm::value_ptr(a)






/*
class Includes {
  public:
    Includes(); //make private constructor...
    }

};
*/

/*
double globalTickVal;
void tickTime() {
  NSDate *date = [NSDate date];
  globalTickVal = [date timeIntervalSinceReferenceDate];
  //aluminum::Behavior::globalTickVal = [date timeIntervalSinceReferenceDate] - aluminum::Behavior::globalStartVal;
  //printf("globalTickVal = %f\n", aluminum::Behavior::globalTickVal);
}
*/

#endif

