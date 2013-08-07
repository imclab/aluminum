//
//  CaptureManager.h
//  aluminum
//
//  Created by Angus Forbes on 8/4/13.
//  Copyright (c) 2013 Angus Forbes. All rights reserved.
//


#import "CocoaGL.h"
#import "Includes.hpp"
#import "Texture.hpp"

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>

using namespace aluminum;

@interface CaptureManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {

  @public
    AVCaptureSession *session;
    AVCaptureDeviceInput *input;
    CVImageBufferRef imageBuffer;
    unsigned char *ptrToImageBuffer;
    
    Texture captureTexture;
    bool isLocked;
    bool newFrame;
}

@property Texture captureTexture;
@property bool newFrame;
@property unsigned char *ptrToImageBuffer;

- (id) init;
- (void) startCapture;
- (void) stopCapture;
- (bool) isCapturing;
- (bool) checkForNewFrame;
- (bool) checkForNewBytes;

//- (void)startCapture:(Texture*)tex;
- (void)processPixelBuffer:(CMSampleBufferRef)pixelBuffer;



@end
