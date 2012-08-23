
#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>

@interface NSGLView : NSOpenGLView {
	CVDisplayLinkRef displayLink;
	void* renderer;
}

+(NSGLView* )start:(void*) _renderer;
-(id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format renderer:(void*) _renderer;
-(void) printView;
 

@end


