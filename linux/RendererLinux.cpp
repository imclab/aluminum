#include "RendererLinux.hpp"

RendererLinux::RendererLinux() { 
  printf("in RendererLinux constructor\n");
}

void RendererLinux::start(void* app) {
	printf("in RendererLinux::start(app)\n");
  FreeGlutGLView::start(app);
}
void RendererLinux::start() {
	printf("in RendererLinux::start()\n");
  FreeGlutGLView::start(this);
	printf("ok we did that...\n");
}


void RendererLinux::onFrame() { printf("you should overwrite me in the subclass!\n"); }
void RendererLinux::onCreate() { }
 
void RendererLinux::accessView() {
  printf("about to access freeglutGL view...\n");
  //[view printView];
}
