
#import "AppDelegate.h"
#import "EAGLView.h"
#import "ViewController.h"
#import "RendererIOS.h"

@implementation AppDelegate

@synthesize window;
@synthesize glView;
@synthesize viewController;

static void* renderer;

+ (void) setRenderer:(void*)_r {
    renderer = _r;
}

+ (void*) getRenderer {
    return renderer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
//- (void) applicationDidFinishLaunching:(UIApplication *)application
{

    // Create the window programatically:
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    viewController = [ViewController alloc];
    [window addSubview:viewController.view];
    glView = [viewController.glView retain];
    
    [window makeKeyAndVisible];
    
    return YES;
	//[glView startAnimation];
 
/*
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    NSLog(@"screenBounds = %@\n", NSStringFromCGRect(screenBounds));
    
    viewController = [[ViewController alloc] initWithFrame:screenBounds];
    
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
    [self.window setRootViewController:viewController];
    
    //self.window = [[UIWindow alloc] initWithFrame: screenBounds];
    //[self.window addSubview: (UIView*) viewController.view];
    
    [self.window makeKeyAndVisible];
    
    printf("out AppDelegate application()");
    
    return YES;
*/
    
}

- (void) applicationWillResignActive:(UIApplication *)application {
	[glView stopAnimation];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	[glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[glView stopAnimation];
}

- (void) dealloc
{
	[window release];
	[glView release];
	
	[super dealloc];
}

@end
    
