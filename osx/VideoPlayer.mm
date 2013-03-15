
#include "Includes.hpp"
#include "VideoPlayer.h"
#import <chrono>
#import <iostream>
#import "Texture.hpp"

using std::cout;
using std::chrono::duration_cast;
using std::chrono::nanoseconds;
using std::chrono::milliseconds;
using std::chrono::high_resolution_clock;

//using namespace aluminum;
using std::string;



@implementation VideoPlayer

- (id) init {
  if ( self = [super init] ) {
    printf("in VideoPlayer constructor\n");
    frameReady = false;
 }

  return self;
}


- (Texture*) createVideoTexture:(const string) filename 
useAudio:(bool) useAudio 
autoPlay:(bool) autoPlay 
autoLoop:(bool) autoLoop {

  NSString* path = [NSString stringWithUTF8String: filename.c_str()];
  videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
  
  isLooping = autoLoop;  

  videoTexture = [self setUpVideoThread];
  
  if (autoPlay) {
    double pauseBeforeStarting = 2.0;
    double atTime = [[NSDate dateWithTimeIntervalSinceNow: pauseBeforeStarting] timeIntervalSinceReferenceDate];

    [self startVideoThread:atTime];
  }

  return videoTexture;
}
 


- (Texture*) setUpVideoThread {

  isLocked = false;
  
  [self playVideo];  
  
  CGSize videoSize = videoTrack.naturalSize;
  return new Texture(videoSize.width, videoSize.height, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
}


/*

  //SET UP AUDIO TRACK
  //if (useAudio) {
  //  PlayAudioResource(fname, atTime);
  //}
  
  //SET UP VIDEO TRACK
  //videoManager = [[VideoManager alloc] init];
  //[videoManager retain];
  //Texture* videoTexture = [videoManager setUpVideoThread:currentAsset isLooping:autoLoop];
 


 isLooping = autoLoop;
  isLocked = false;
  

 
  [self playVideo];  
  
  CGSize videoSize = videoTrack.naturalSize;
  videoTexture = new Texture(videoSize.width, videoSize.height, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);

  //videoTexture = Texture::CreateEmptyTexture(videoSize.width, videoSize.height, GL_BGRA, GL_UNSIGNED_BYTE);
  //printf("VIDEO size = %f %f\n", size.width, size.height);
  //return videoTexture;

 
  if (autoPlay) {

    printf("autoPlay = true\n");
    //NSLog(@"atTime = %f", atTime);

    //[self testTimer];
    [self startVideoThread:atTime];
  }

  return videoTexture;
}
*/
  
-(void) onTick:(NSTimer *)timer {
  //lets nextFrame know that there is actually a new frame waiting for it
  frameReady = true;
}

- (void) startVideoThread: (double) fireDate {

  //prevTime = [[NSDate date] timeIntervalSinceReferenceDate];
  //currTime = prevTime;

  NSTimer *t = [[NSTimer alloc] initWithFireDate: [NSDate dateWithTimeIntervalSinceReferenceDate:fireDate]
    //interval: 1.0/videoTrack.nominalFrameRate
    interval: 0.5
    target: self
    selector:@selector(onTick:)
    userInfo:nil repeats:YES];

    
  [[NSRunLoop mainRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
  [t release];
 
  //uncomment this if you want to show the first frame right away
  frameReady = true;
  [self nextFrame];
}


- (void) playVideo {

  NSError *error = nil;
  videoAssetReader = [AVAssetReader assetReaderWithAsset:videoAsset error:&error];
  [videoAssetReader retain];
  if (error) {
    NSLog(@"%@",[error localizedDescription]);
  }

  NSArray* tracksArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
  videoTrack = [tracksArray objectAtIndex:0];
  videoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];

  [videoAssetReader addOutput:videoTrackOutput];
  [videoAssetReader startReading];

}



- (void) nextFrame {

  if ([videoAssetReader status]==AVAssetReaderStatusReading) { 

    if (frameReady == false) {
      //printf("frame not ready\n");
      return;
    }
    //printf("frame ready\n");
    isLocked = true;

    videoTexture->bind(GL_TEXTURE0);

    pixelBuffer = [videoTrackOutput copyNextSampleBuffer];
    imageBuffer = CMSampleBufferGetImageBuffer(pixelBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
    unsigned char *linebase = (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(pixelBuffer);
    CMVideoDimensions videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDesc);

    //slow to do it here... rather just pass a flag to the shaders
 //   Texture::flipBufferY(linebase, videoDimensions.width, videoDimensions.height);
 //   Texture::flipBufferX(linebase, videoDimensions.width, videoDimensions.height);

    videoTexture->data = linebase;
    glTexSubImage2D(videoTexture->kind(), 0, 0, 0, videoDimensions.width, videoDimensions.height, GL_BGRA, GL_UNSIGNED_BYTE, linebase); 
 
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    CVPixelBufferRelease(imageBuffer);
    
    free(pixelBuffer);
    
    videoTexture->unbind(GL_TEXTURE0);
    
    isLocked = false;
    frameReady = false;
  } else {
    [videoAssetReader cancelReading];
    frameReady = false;
  }
  
}




@end
