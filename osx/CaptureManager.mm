
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
  
      
    
      
      NSError * error;
      session = [[AVCaptureSession alloc] init];
      [session beginConfiguration];
      //[session setSessionPreset:AVCaptureSessionPreset1280x720];
      [session setSessionPreset:AVCaptureSessionPreset640x480];
    
    
     // captureTexture = Texture(1280, 720, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
      captureTexture = Texture(640, 480, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
    
    
      AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
      input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
      //input = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:&error];
      
      [session addInput:input];
      
      
      AVCaptureVideoDataOutput* dataOutput = [[AVCaptureVideoDataOutput alloc] init];
      [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
      [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
      
      
      //it doesn't seem to matter which queue i use...
      
      //  dispatch_queue_s* dq = dispatch_get_main_queue();
      //  [dataOutput setSampleBufferDelegate:self queue:dq];
      //  dispatch_release(dq);
      
      dispatch_queue_t videoCaptureQueue = dispatch_queue_create("com.example.subsystem.XYZ", NULL);
      [dataOutput setSampleBufferDelegate:self queue:videoCaptureQueue];
      dispatch_release(videoCaptureQueue);
      
      [session addOutput:dataOutput];
      [session commitConfiguration];
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
          
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 640, 480, 0, GL_BGRA, GL_UNSIGNED_BYTE, ptrToImageBuffer);
 //     glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1280, 720, 0, GL_BGRA, GL_UNSIGNED_BYTE, ptrToImageBuffer);
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
