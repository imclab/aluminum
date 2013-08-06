//
//  CaptureManager.m
//  aluminum
//
//  Created by Angus Forbes on 8/4/13.
//  Copyright (c) 2013 Angus Forbes. All rights reserved.
//

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

@synthesize abc;
@synthesize captureTexture;

- (id) init {
  if ( self = [super init] ) {
    printf("in CaptureManager constructor\n");
    isLocked = false;
    newFrame = false;
    //frameReady = false;
  }
  
  return self;
}

- (Texture*) createCaptureTexture {
    
    
 //   ResourceHandler().loadTexture(abc, "mak.png");
   
  abc = Texture(1280, 720, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
  //abc = Texture(640, 480, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
  captureTexture = &abc;
  
  //  CFRetain(captureTexture);
    
    
    printf("addr in ppb : %p\n", captureTexture);
    
    //abc = Texture(640, 480, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
    
 //   captureTexture = new Texture(640, 480, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
    [self startCapture];
    return captureTexture;

}

- (void)startCapture { //:(Texture*) _captureTexture {
    
    printf("in startCapture...\n");
    
    //captureTexture = _captureTexture;
    
    
    
    NSError * error;
    session = [[AVCaptureSession alloc] init];
    [session beginConfiguration];
    [session setSessionPreset:AVCaptureSessionPreset1280x720];
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    //input = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:&error];

    [session addInput:input];
    
    
    AVCaptureVideoDataOutput* dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    //  dispatch_queue_s* dq = [NSOperationQueue mainQueue]; //dispatch_get_main_queue();
    //dispatch_queue_s* dq = dispatch_get_main_queue();
    //[dataOutput setSampleBufferDelegate:self queue:dq];
    

    dispatch_queue_t videoCaptureQueue = dispatch_queue_create("com.example.subsystem.XYZ", NULL);
    [dataOutput setSampleBufferDelegate:self queue:videoCaptureQueue];
    
    //dispatch_release(dq);
    
    [session addOutput:dataOutput];
    [session commitConfiguration];
    [session startRunning];
    
}

- (void)processPixelBuffer:(CMSampleBufferRef)pixelBuffer {
  
  //  NSImage *image = imageFromSampleBuffer(pixelBuffer);
    
    
 // printf("processPixelBuffer IN\n");
    
    imageBuffer = CMSampleBufferGetImageBuffer(pixelBuffer);
    CVPixelBufferLockBaseAddress( imageBuffer, 0 );
   
    
    
    
    int bufferWidth = CVPixelBufferGetWidth(imageBuffer);
	int bufferHeight = CVPixelBufferGetHeight(imageBuffer);
  
    linebase = (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);
    printf("  pixel at 512 = %d\n", linebase[512]);
 
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, abc.id());
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 10, 10, 0, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
    
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
   
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    /*
  printf("width / height = %zd %zd\n", bufferWidth, bufferHeight);
  printf("addr in ppb : %p\n", captureTexture);
  //slow to do it here... rather just pass a flag to the shaders
  //   Texture::flipBufferY(linebase, videoDimensions.width, videoDimensions.height);
  //   Texture::flipBufferX(linebase, videoDimensions.width, videoDimensions.height);
  
 //  dispatch_async(dispatch_get_main_queue(), ^{
  if (abc.width == bufferWidth && abc.height == bufferHeight) {
    printf("hi! width / height = %zd %zd\n", bufferWidth, bufferHeight);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bufferWidth, bufferHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
  }
  // });
  
  //
  //  captureTexture->unbind(GL_TEXTURE0);
  //  abc.unbind(GL_TEXTURE0);
    
   CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
 // CVPixelBufferRelease(imageBuffer);
  //free(sampleBuffer);
  
  
  newFrame = true;
  
  //isLocked = false;
  
  printf("processPixelBuffer OUT\n");
     */
  
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  
  //CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  
  //[self processPixelBuffer:pixelBuffer];
  
  [self performSelectorOnMainThread:@selector(processPixelBuffer:) withObject:(id)sampleBuffer waitUntilDone:YES];
  
  //CFRelease(sampleBuffer);
}

@end
