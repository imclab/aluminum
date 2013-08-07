//#import "EAGLView.h"
#import "Includes.hpp"
#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>

#import "Texture.hpp"

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
    bool firstTime;
    bool textureReady;
    
    int tw;
    int th;
}

@property Texture captureTexture;
@property bool newFrame;
@property bool isReady;
@property bool textureReady;
@property unsigned char *ptrToImageBuffer;

- (id) init;
- (void) startCapture;
- (void) stopCapture;
- (void) toggleCapture;
- (bool) isCapturing;
- (void) setTextureDimensions;

- (bool) nextFrame;
- (bool) updateTextureWithNextFrame;

@end
