
#import "CaptureManager.h"
#include "Includes.hpp"
#include "VideoPlayer.h"
#import <chrono>
#import <iostream>
#import "Texture.hpp"


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

#import "ResourceHandler.h"

using namespace aluminum;
using std::string;


@implementation CaptureManager

@synthesize captureTexture;
@synthesize newFrame;
@synthesize ptrToImageBuffer;

- (id) init {
  if ( self = [super init] ) {
    printf("in CaptureManager constructor\n");
    isLocked = false;
    newFrame = false;
    
    session = [[AVCaptureSession alloc] init];
    [session beginConfiguration];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //get input webcam
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError * error;
    input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    [session addInput:input];
    
    //create the output pipe
    AVCaptureVideoDataOutput* dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [session addOutput:dataOutput];
    
    //conntect the output to a callback method to process the frames
    dispatch_queue_t videoCaptureQueue = dispatch_queue_create("com.example.subsystem.XYZ", NULL);
    [dataOutput setSampleBufferDelegate:self queue:videoCaptureQueue];
    dispatch_release(videoCaptureQueue);
    
    //signal that the input and output are connected
    [session commitConfiguration];
    
    //Now that the session's configuration is committed, we are able to get the resolution of the webcam.
    AVCaptureInputPort *port = [input.ports objectAtIndex:0];
    CMFormatDescriptionRef formatDescription = port.formatDescription;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    int tw = dimensions.width;
    int th = dimensions.height;
    
    //create the texture to hold the frames from the highest-resolution setting on the webcam
    captureTexture = Texture(tw, th, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
    
  }
  
  return self;
}


- (bool) isCapturing {
  return [session isRunning];
}

- (void) stopCapture {
  [session stopRunning];
}

- (void)startCapture {
  [session startRunning];
  
}



- (bool) checkForNewBytes {
  
  if ([self isCapturing] && newFrame == true) {
    newFrame = false;
    return true;
  }
  
  return false;
}


- (bool) checkForNewFrame {
  
  if ([self isCapturing] && newFrame == true) {
    captureTexture.bind(GL_TEXTURE0); {
      
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, captureTexture.width, captureTexture.height, 0, GL_BGRA, GL_UNSIGNED_BYTE, ptrToImageBuffer);
    } captureTexture.unbind(GL_TEXTURE0);
    
    newFrame = false;
    return true;
  }
  
  return false;
  
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  
  if (newFrame == true) {
    printf("can't accept a new frame while old one is being processed\n");
  } else {
    
    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress( imageBuffer, 0 );
    
    ptrToImageBuffer = (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    newFrame = true;
  }
}

@end
