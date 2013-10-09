//
//  ResourceHandler.h
//  aluminum
//
//  Created by Angus Forbes on 8/5/13.
//  Copyright (c) 2013 Angus Forbes. All rights reserved.
//

#ifndef __aluminum__ResourceHandler__
#define __aluminum__ResourceHandler__

#include "Includes.hpp"
#include <iostream>


#import "CocoaGL.h"
#include "Includes.hpp"
#import "Texture.hpp"
#import "Program.hpp"

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>


//using namespace aluminum;
using std::string;
//using aluminum::Texture;

//class aluminum::Texture;
///class aluminum::Program;


using namespace aluminum;

//class Texture;


class ResourceHandler {
    
public:
    
    ResourceHandler();
    
    const char* contentsOfFile(string& file);
    string pathToResource(const string& resource, const string& type);
  
    void loadProgram(Program &p, const std::string& name, int pLoc, int nLoc, int tcLoc, int cLoc);

    void loadTexture(Texture& t, const std::string& name);
};

#endif /* defined(__aluminum__ResourceHandler__) */
