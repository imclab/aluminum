#ifndef INCLUDE_OSX_INCLUDES_HPP
#define INCLUDE_OSX_INCLUDES_HPP


#include "CocoaGL.h"
#include "RendererOSX.h"


#ifdef __OBJC__

#import <OpenGL/gl3.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>
#import <Carbon/Carbon.h>

#endif

#include <cstdio>
#include <stdio.h>
#include <string.h>
#include <string>
#include <chrono>  
#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <map>
#include <algorithm>

#include <glm/glm.hpp>
#include <glm/core/_fixes.hpp>
#include <glm/gtx/string_cast.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_access.hpp>
#include <glm/gtc/type_ptr.hpp>
//#include <glm/gtc/random.hpp>
#include <glm/gtx/random.hpp>

#include "assimp/Importer.hpp"
#include "assimp/scene.h"
#include "assimp/postprocess.h"
#include "assimp/cimport.h"
#include "assimp/types.h"
#include "assimp/matrix4x4.h"

#include "FreeImage.h"


//if these become the more stable, it might make sense to uncomment these so that they are also precomipled. 

/*
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Camera.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include "Texture.hpp"
#include "FBO.hpp"
#include "Font.hpp"
#include "Utils.hpp"
#include "Behavior.hpp"

*/


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

