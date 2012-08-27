#include "RendererLinux.hpp"

RendererLinux::RendererLinux() { 
  printf("in RendererLinux constructor\n");
}

void RendererLinux::start() {
	printf("in RendererLinux::start()\n");
  FreeGlutGLView::start(this);
}
void RendererLinux::start(std::string name) {
	printf("in RendererLinux::start(name)\n");
  FreeGlutGLView::start(this, name);
}


void RendererLinux::onFrame() { printf("you should overwrite me in the subclass!\n"); }
void RendererLinux::onCreate() { }
 
void RendererLinux::accessView() {
  printf("about to access freeglutGL view...\n");
  //[view printView];
}
