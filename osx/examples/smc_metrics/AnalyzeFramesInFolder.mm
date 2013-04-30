#include "Includes.hpp"
#include "Texture.hpp"
#include "Metrics.h"

#include <string> 
#include "dirent.h"

using namespace aluminum;
using std::string;

class AnalyzeFramesInFolder {

  public:

    //string path = "resources/files/MOV1/";
    
    int PIXELW = 8;
    int PIXELH = 8;
    int TOTAL_FRAMES = 440;

    Texture texture;
   

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


    //void onCreate() {
    void analyze(string path, int range) {
      //printf("starting!\n");

Metrics metrics = Metrics(PIXELW, PIXELH, TOTAL_FRAMES, range);

      DIR *dir;
      struct dirent *ent;
      if ((dir = opendir (path.c_str())) != NULL) {
	/* print all the files and directories within directory */

	int frameNum = 0;
	while ((ent = readdir (dir)) != NULL) {

	  string str = ent->d_name;
	  string str2 = "png";
	  unsigned found = str.find(str2);

	  if (found < str.length()) { //better way?
	    string filepath = path + "/" + str;

	    //cout << "path = " << filepath << "\n";

	    int w;
	    int h;
	    GLubyte* data;
	    Texture::loadTextureData(data, w, h, filepath);

	    // for (int i = 0; i < w*h*4; i++) {
	    //   printf("%d ", data[i]);
	    // } printf("\n");

	    // printTexture(data, w, h, frameNum);

	    metrics.calculatePeaks(data,frameNum);
	    metrics.calculateNeighborDistance(data, frameNum);
	    metrics.calculateGlobalPeaks(data, frameNum);

	    frameNum++;
	  }
	}
	closedir (dir);

	metrics.printFinalMetrics(path);
	exit(0);

      } else {
	/* could not open directory */
	perror ("");
	exit(0);
      }


    }




};


int main(int argc, char* argv[]) {
 
  if (argc != 3) {
    printf("usage: ./AnalyzeFramesInFolder path_to_folder contrastRange\n");
    exit(0);
  } 
 
  string path = argv[1];
  int range = std::stoi(argv[2]);
  //cout << "path = " << path << "\n";
  //cout << "range = " << range << "\n";
  AnalyzeFramesInFolder a;
  a.analyze(path, range);

  return 1;
}
