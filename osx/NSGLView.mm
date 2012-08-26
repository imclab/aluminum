#import "NSGLView.h"
#import <OpenGL/gl3.h>
#include "RendererNativeOSX.h"


@interface NSGLView (PrivateMethods)
  - (void) initGL;
  - (void) drawView;


  @end

  @implementation NSGLView

  //OpenGLRenderer* m_renderer;

  -(BOOL)acceptsFirstResponder { return YES; }
  -(BOOL)becomeFirstResponder { return YES; }
  -(BOOL)resignFirstResponder { return YES; }
  -(void)mouseDragged:(NSEvent*)mouseEvent {
    NSPoint currmouse = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
    printf("mouseDragged %f/%f\n", currmouse.x, currmouse.y);

    /*if (currmouse.x == prevmouse.x && currmouse.y == prevmouse.y) {*/
    /*return;*/
    /*isDragging = NO;*/
    /*}*/

    /*isDragging = YES;*/

  }


- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
  // There is no autorelease pool when this method is called 
  // because it will be called from a background thread
  // It's important to create one or you will leak objects
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  [self drawView];

  [pool release];
  return kCVReturnSuccess;
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
  CVReturn result = [(NSGLView*)displayLinkContext getFrameForTime:outputTime];
  return result;
}


-(id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format {
  self = [super initWithFrame:frameRect pixelFormat:format];
  return(self);
}

+(NSGLView* )start:(void*) _renderer {
  
  // Sets up a minimal Cocoa window and set its content to be a OpenGL renderer
  
  [NSAutoreleasePool new];
  [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  id menubar = [[NSMenu new] autorelease];
  id appMenuItem = [[NSMenuItem new] autorelease];
  [menubar addItem:appMenuItem];
  [NSApp setMainMenu:menubar];
  id appMenu = [[NSMenu new] autorelease];
  id appName = [[NSProcessInfo processInfo] processName];
  id quitTitle = [@"Quit " stringByAppendingString:appName];
  id quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle
    action:@selector(terminate:) keyEquivalent:@"q"] autorelease];
  [appMenu addItem:quitMenuItem];
  [appMenuItem setSubmenu:appMenu];

  id window = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 200, 200)
    styleMask:NSTitledWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO]
    autorelease];
  [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
  [window setTitle:appName];
  [window makeKeyAndOrderFront:nil];

  bool resizable = true;
  [[window standardWindowButton:NSWindowZoomButton] setHidden:!resizable];
  [window setShowsResizeIndicator:resizable];

  NSRect glRect = NSMakeRect(0, 0, 200, 200);

  NSOpenGLPixelFormatAttribute attrs[] = {
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFADepthSize, 32,
    NSOpenGLPFAOpenGLProfile,
    NSOpenGLProfileVersion3_2Core,
    //NSOpenGLProfileVersionLegacy,

    //NSOpenGLPFAColorFloat,
    //NSOpenGLPFAStereo, ... etc there are a lot of interesting ones....
    0
  };

  NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
  NSGLView* glView = [[NSGLView alloc] initWithFrame:glRect pixelFormat:format renderer:_renderer];
  [format release];

  [window setContentView:glView];

  [window setAcceptsMouseMovedEvents:YES];
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp run];

  return glView;

}

-(id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format renderer:(void*) _renderer {

  self = [super initWithFrame:frameRect pixelFormat:format];
  renderer = _renderer;
  return(self);
}

- (void) prepareOpenGL
{
  [super prepareOpenGL];

  // Make all the OpenGL calls to setup rendering  
  //  and build the necessary rendering objects
  [self initGL];

  // Create a display link capable of being used with all active displays
  CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);

  // Set the renderer output callback function
  CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);

  // Set the display link for the current renderer
  CGLContextObj cglContext = (_CGLContextObject*) [[self openGLContext] CGLContextObj];
  CGLPixelFormatObj cglPixelFormat = (_CGLPixelFormatObject*) [[self pixelFormat] CGLPixelFormatObj];
  CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);

  // Activate the display link
  CVDisplayLinkStart(displayLink);
}

- (void) initGL
{
  // Make this openGL context current to the thread
  // (i.e. all openGL on this thread calls will go to this context)
  [[self openGLContext] makeCurrentContext];

  // Synchronize buffer swaps with vertical refresh rate
  GLint swapInt = 1;
  [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];

  // Init our renderer.  Use 0 for the defaultFBO which is appropriate for MacOS (but not iOS)
  //	m_renderer = [[OpenGLRenderer alloc] initWithDefaultFBO:0];
  printf("in initGL\n");

  char* verGL = (char*)glGetString(GL_VERSION);
      printf("GL version = %s\n", verGL);

      char* verGLSL = (char*)glGetString(GL_SHADING_LANGUAGE_VERSION);
      printf("GLSL version = %s\n", verGLSL);

}

- (void) reshape
{	
  [super reshape];

  // We draw on a secondary thread through the display link
  // When resizing the view, -reshape is called automatically on the main thread
  // Add a mutex around to avoid the threads accessing the context simultaneously when resizing
  CGLLockContext((_CGLContextObject*)[[self openGLContext] CGLContextObj]);

  //need to pass the size of the bounds to set up glViewport properly
  NSRect rect = [self bounds];

  ((RendererNativeOSX*)renderer)->width =  (int)rect.size.width ;
  ((RendererNativeOSX*)renderer)->height =  (int)rect.size.height ;

  CGLUnlockContext((_CGLContextObject*)[[self openGLContext] CGLContextObj]);
}

int firstTime = 0;
- (void) drawView
{	 
  [[self openGLContext] makeCurrentContext];

  // We draw on a secondary thread through the display link
  // When resizing the view, -reshape is called automatically on the main thread
  // Add a mutex around to avoid the threads accessing the context simultaneously	when resizing
  CGLLockContext((_CGLContextObject*)[[self openGLContext] CGLContextObj]);

  NSRect rect = [self bounds];

  if (firstTime == 0) {
    printf("in drawView... bounds = %f,%f,%f,%f\n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    ((RendererNativeOSX*)renderer)->view = self ;
    ((RendererNativeOSX*)renderer)->width =  (int)rect.size.width ;
    ((RendererNativeOSX*)renderer)->height =  (int)rect.size.height ;
    ((RendererNativeOSX*)renderer)->onCreate();

    firstTime = 1;
  }


  //glViewport(0, 0, (int)rect.size.width, (int)rect.size.height);
  //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  ((RendererNativeOSX*)renderer)->onFrame();
  //glFlush();

  CGLFlushDrawable((_CGLContextObject*)[[self openGLContext] CGLContextObj]);
  CGLUnlockContext((_CGLContextObject*)[[self openGLContext] CGLContextObj]);
}

- (void) printView {
  printf("I am in the view!\n");
}

- (void) dealloc
{	
  // Stop the display link BEFORE releasing anything in the view
  // otherwise the display link thread may call into the view and crash
  // when it encounters something that has been release
  CVDisplayLinkStop(displayLink);

  CVDisplayLinkRelease(displayLink);

  // Release the display link AFTER display link has been released
  //	[m_renderer release];

  [super dealloc];
}

@end

