
#import "CaptureManager.h"

@implementation CaptureManager

@synthesize captureTexture;
@synthesize newFrame;
@synthesize ptrToImageBuffer;
@synthesize isReady;
@synthesize textureReady;

- (id) init {
    if ( self = [super init] ) {
        
        printf("in CaptureManager constructor\n");
        
        isLocked = false;
        newFrame = false;
        isReady = false;
        firstTime = true;
        textureReady = false;
        
        session = [[AVCaptureSession alloc] init];
        [session beginConfiguration];
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        
        //[session setSessionPreset:AVCaptureSessionPreset640x480];
        
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
    newFrame = false;
}

- (void) toggleCapture {
    if ([self isCapturing]) {
        [self stopCapture];
    } else {
        [self startCapture];
    }
}

- (bool) nextFrame {
    
    if (!firstTime && !textureReady) {
        captureTexture = Texture(tw, th, GL_RGBA, GL_RGB, GL_UNSIGNED_BYTE);
        textureReady = true;
    }
    
    if ([self isCapturing] && newFrame == true) {
        newFrame = false;
        return true;
    }
    
    return false;
}

- (bool) updateTextureWithNextFrame {
    
    if (isReady && [self isCapturing] && newFrame == true) {
        captureTexture.bind(GL_TEXTURE0); {
            
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, captureTexture.width, captureTexture.height, 0, GL_BGRA, GL_UNSIGNED_BYTE, ptrToImageBuffer);
        } captureTexture.unbind(GL_TEXTURE0);
        
        newFrame = false;
        return true;
    }
    
    return false;
}

-(void) setTextureDimensions {
    AVCaptureInputPort *port = [input.ports objectAtIndex:0];
    CMFormatDescriptionRef formatDescription = port.formatDescription;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    tw = dimensions.width;
    th = dimensions.height;
    
}


/*can be used to get a specific camera from the front or back (if available) IOS only


- (void) switchFrontToBack:(NSString*) format {
    //RENDERER.IS_BUSY = true;
    [captureSession beginConfiguration];
    
    [captureSession removeInput:videoIn];
    side = @"BACK";
    
    [self addVideoInput:format];
    
    captureSession.sessionPreset = format;
    self.avTexture = RENDERER.BACK_TEX;
    
    [RENDERER configureRendererForBackFacingCamera];
    
    [captureSession commitConfiguration];
    //RENDERER.IS_BUSY = false;
}


- (void) switchBackToFront:(NSString*) format {
    //RENDERER.IS_BUSY = true;
    
    [captureSession beginConfiguration];
    
    [captureSession removeInput:videoIn];
    side = @"FRONT";
    
    [self addVideoInput:format];
    
    self.avTexture = RENDERER.FRONT_TEX;
    
    [RENDERER configureRendererForFrontFacingCamera];
    
    
    [captureSession commitConfiguration];
    //RENDERER.IS_BUSY = false;
    
}


- (AVCaptureDevice *)frontFacingCameraIfAvailable {
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices) {
        NSLog(@"name of deivce : %@ \n", device.localizedName);
        
        if (device.position == AVCaptureDevicePositionFront) {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if (!captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    NSLog(@"name of captureDeivce : %@ \n", captureDevice.localizedName);
    
    return captureDevice;
}
*/

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    //necessary for IOS? to run on main thread???
    ////[self performSelectorOnMainThread:@selector(processPixelBuffer:) withObject:(id)sampleBuffer waitUntilDone:NO];
    
    
    
    //printf("*** in captureOutput\n");
    
    if (firstTime) {
        [self setTextureDimensions];
        firstTime = false;
        
        //printf("*** captureOutput : firstTime = false\n");
    }
    
    if (!newFrame) {
        
        imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress( imageBuffer, 0 ); {
            ptrToImageBuffer = (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);
        } CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        newFrame = true;
    }
    
}

@end
