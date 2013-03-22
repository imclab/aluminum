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
//#import "VideoPlayer.h"
#include "Metrics.h"
#include "dirent.h"

using namespace aluminum;
using std::string;

class AnalyzeFramesInFolder : public RendererOSX {

  public:

    int PIXELW = 4;
    int PIXELH = 4;
    int TOTAL_FRAMES = 44;

    Texture texture;

    Metrics metrics = Metrics(PIXELW, PIXELH, TOTAL_FRAMES);


    
    void printTexture(Texture& rt, int frameNum) {

      bool PRINT = true;
      rt.bind(); {

	int idx = 0;
	if (PRINT) printf("\n\n***Reading Frame %d\n", frameNum);
	for (int j = 0; j < rt.height; j++) {
	  for (int i = 0; i < rt.width; i++) {
	    if (PRINT) printf("pixel (%d,%d) = RGB:  ", i, j);
	    for (int v = 0; v < 4; v++) {
	      if (PRINT) printf(" %d ", rt.data[idx++]);
	    }
	    if (PRINT) printf("}\n");
	  }
	}

      } rt.unbind();
    }

  void printTexture(GLubyte* &data, int w, int h, int frameNum) {

      bool PRINT = true;

	int idx = 0;
	if (PRINT) printf("\n\n***Reading Data for Frame %d\n", frameNum);
	for (int j = 0; j < h; j++) {
	  for (int i = 0; i < w; i++) {
	    if (PRINT) printf("pixel (%d,%d) = RGB:  ", i, j);
	    for (int v = 0; v < 4; v++) {
	      if (PRINT) printf(" %d ", data[idx++]);
	    }
	    if (PRINT) printf("}\n");
	  }
	}

    }

    void loadTexture(Texture& t, const std::string& name) {
      t.loadTexture(t, name);
    } 


    void onCreate() {
      printf("starting!\n");

      DIR *dir;
      struct dirent *ent;
      if ((dir = opendir ("resources/files/MOV1/")) != NULL) {
	/* print all the files and directories within directory */

	int frameNum = 0;
	while ((ent = readdir (dir)) != NULL) {

	  string str = ent->d_name;
	  string str2 = "png";
	  unsigned found = str.find(str2);
	  
	  if (found >= 0 && found < str.length()) { //better way?
	    string path = "resources/files/MOV1/" + str;

	    cout << "path = " << path << "\n";

            int w;
            int h;
            GLubyte* data;
            Texture::loadTextureData(data, w, h, path);

            // for (int i = 0; i < w*h*4; i++) {
            //   printf("%d ", data[i]);
            // } printf("\n");

            printTexture(data, w, h, frameNum);

	    metrics.calculatePeaks(data,frameNum);
	    metrics.calculateNeighborDistance(data, frameNum);
	    metrics.calculateGlobalPeaks(data, frameNum);

	    frameNum++;
	  }
	}
	closedir (dir);

        metrics.printFinalMetrics();
        exit(0);
	
      } else {
	/* could not open directory */
	perror ("");
	exit(0);
      }

      
    }




};


int main() {
  AnalyzeFramesInFolder().start(); 

  return 0;
}
