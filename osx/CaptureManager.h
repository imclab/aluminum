#import "CocoaGL.h"
#import "Includes.hpp"

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
