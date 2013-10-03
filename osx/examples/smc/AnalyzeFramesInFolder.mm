#include "Includes.hpp"

#include "RendererOSX.h"
#include "MeshBuffer.hpp"
#include "MeshData.hpp"
#include "MeshUtils.hpp"
#include "Program.hpp"
#include "Shapes.hpp"
#include "Texture.hpp"
#include "FBO.hpp"

#include <string> 
#import "VideoPlayer.h"
#include "Metrics.h"

using namespace aluminum;
using std::string;

class AnalyzeFramesInFolder {

  public:

    int PIXELW = 4;
    int PIXELH = 4;
    int TOTAL_FRAMES = 44;

    Texture texture;

    Metrics metrics = Metrics(PIXELW, PIXELH, TOTAL_FRAMES);


    void printTexture(Texture& rt, int frameNum) {

      bool PRINT = false;
      rt.bind(); {

	GLubyte *data = (GLubyte*)malloc(4 * rt.width * rt.height);
	glReadPixels(0, 0, rt.width, rt.height, GL_RGBA, GL_UNSIGNED_BYTE, data);

	int idx = 0;
	if (PRINT) printf("\n\n***Reading Frame %d\n", frameNum);
	for (int j = 0; j < rt.height; j++) {
	  for (int i = 0; i < rt.width; i++) {
	    if (PRINT) printf("pixel (%d,%d) = RGB:  ", i, j);
	    for (int v = 0; v < 4; v++) {
	      if (PRINT) printf(" %d ", data[idx++]);
	    }
	    if (PRINT) printf("}\n");
	  }
	}

      } rt.unbind();
    }


    void loadTexture(Texture& t, const std::string& name) {
      t.loadTexture(t, name);
    } 


    void start() {
      printf("starting!\n");

      for (int i = 0; i <= TOTAL_FRAMES; i++) {
	loadTexture(texture, "resources/files/MOV1/000.png");

printf("ok!");
exit(0);
//	printTexture(texture, i);

/*
	printf("videoFrameNum = %d\n", videoFrameNum);
	metrics.calculatePeaks(fboPixelate, videoFrameNum);
	metrics.calculateNeighborDistance(fboPixelate, videoFrameNum);
	metrics.calculateGlobalPeaks(fboPixelate, videoFrameNum);

	if (videoFrameNum == TOTAL_FRAMES) {
	  metrics.printFinalMetrics();
	  exit(0);
	}

	if (newFrame == true) {
	  videoFrameNum++;
	}
*/
      }
    }




};


int main() {
  AnalyzeFramesInFolder().start(); 

  return 0;
}
