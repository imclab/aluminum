
#import <Carbon/Carbon.h> //for key info
#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>

@interface CocoaGL : NSOpenGLView {
	CVDisplayLinkRef displayLink;
	void* renderer;
	BOOL isDragging;
	NSWindow* window;
	
BOOL cursorOn;
BOOL stereoOn;


}

+(CocoaGL* )start:(void*) _renderer;
+(CocoaGL* )start:(void*) _renderer 
  name:(NSString*)_name 
  width:(int)_width
  height:(int)_height
  xpos:(int)_xpos
  ypos:(int)_ypos;

-(id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format renderer:(void*) _renderer;
-(void) printView;
-(void) toggleFullScreen;
 

@end


