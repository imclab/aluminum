//
//  Main.cpp
//  niftiViewer
//
//  Created by Angus Forbes on 7/7/13.
//  Copyright (c) 2013 Angus Forbes. All rights reserved.
//

#include "Basic.mm"
#include "Slices.mm"

int main(){
  ///// the normal way to create a full screen app
  //return Slices().start("aluminum::ICA Viewer", 100, 100, 400, 300);
  
  ///// to get just the GL view, so you can add it yourself to a more complicated view hierarchy
//  Slices* nifti = new Slices();
//  nifti->doStuff();
  Slices nifti = Slices();
  nifti.initializeViews();

}

/*
int main(){
  //    return NiftiViewer().start("aluminum::NiftiViewer", 100, 100, 400, 300);
  NiftiViewer* nifti = new NiftiViewer();
  NSView* glv = nifti->makeGLView(400, 300);
  
  [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  
  id appName = @"testcustom";
  
  
  // Set up the window to hold the CocoaGL view
  id window = [CocoaGL setUpAppWindow:appName
                                    x: 100
                                    y: 100
                                    w: 400
                                    h: 300];
  
  [CocoaGL setUpMenuBar:(CocoaGL*)glv name:appName];
  
  NSSplitView* parentView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
  [parentView setVertical:YES];
  [window setContentView:parentView];
  
  NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 200, 300)];
  NSRect frame = NSMakeRect(10, 40, 90, 40);
  NSButton* pushButton = [[NSButton alloc] initWithFrame: frame]; pushButton.bezelStyle = NSRoundedBezelStyle;
  
  ActionProxy* p = [[ActionProxy alloc] init];
  [p setTheTarget:[NSValue valueWithPointer:nifti]];
  
  [pushButton setTarget:p];
  [pushButton setAction:@selector(buttonAction2:)];
  
  [view addSubview:pushButton];
  
  [[window contentView] addSubview:view];
  [[window contentView] addSubview:glv];
  
  [NSApp activateIgnoringOtherApps:YES]; //brings application to front on startup
  [NSApp run];
  
}
*/
