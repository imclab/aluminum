
#import <Carbon/Carbon.h> //for key info
#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>

@interface CocoaGL : NSOpenGLView {
	CVDisplayLinkRef displayLink;
	void* renderer;
	BOOL isDragging;
	NSWindow* window;
}

+(CocoaGL* )start:(void*) _renderer;
-(id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format renderer:(void*) _renderer;
-(void) printView;
-(void) toggleFullScreen;
 

@end


