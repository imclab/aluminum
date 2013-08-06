

#include "ViewController.h"

@implementation ViewController

@synthesize glView;

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    glView = [[EAGLView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    glView.userInteractionEnabled=YES;
    [self.view addSubview:glView];
}



- (void)viewDidUnload {
    [super viewDidUnload];
}


@end
