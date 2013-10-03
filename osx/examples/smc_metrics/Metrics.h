

#include "Includes.hpp"
#include <string> 


using namespace aluminum;
using std::string;
using std::cout;

class Metrics {
  
  public:


    //int NEIGHBOR_SPIKE = 256/8;
    //int PEAK_SPIKE = 256/8;
    //int GLOBAL_PEAK_SPIKE = 256/128;
    float NEIGHBOR_SPIKE;
    float PEAK_SPIKE;
    float GLOBAL_PEAK_SPIKE;

    int PIXELW;
    int PIXELH;
    int TOTAL_FRAMES;

    GLubyte *prevVals;

    //flicker per pixel
    GLubyte *basePeaks;
    int* peakDir;
    int* numberPeaks; 
    int* totalPeakVals;
    int* numberSpikes; 

    //contrast per pixel
    int* maxNeighborDistance; 
    int* numNeighborSpikes;

    //global flickr
    int baseFramePeak;
    int framePeakDir;
    int numberFramePeaks;
    int numberFrameSpikes;
    float totalFramePeakVals;
    float prevContrast;


    Metrics(int pw, int ph, int totalFrames, int range) {
      PIXELW = pw;
      PIXELH = ph;
      TOTAL_FRAMES = totalFrames;
   
    NEIGHBOR_SPIKE = range/8.0;
    PEAK_SPIKE = range/32.0;
    GLOBAL_PEAK_SPIKE = range/128.0;

//printf("NS, PS, GPS = %f %f %f\n", NEIGHBOR_SPIKE, PEAK_SPIKE, GLOBAL_PEAK_SPIKE);

      prevVals = (GLubyte*)malloc(PIXELW * PIXELH * 4);
      basePeaks = (GLubyte*)malloc(PIXELW * PIXELH * 4);
      peakDir = (int*)malloc(PIXELW * PIXELH * 4 * sizeof(int)); //-1 or 1
      numberPeaks = (int*)malloc(PIXELW * PIXELH * 4 * sizeof(int)); 
      totalPeakVals = (int*)malloc(PIXELW * PIXELH * 4 * sizeof(int));
      numberSpikes = (int*)malloc(PIXELW * PIXELH * 4 * sizeof(int));
      maxNeighborDistance = (int*)malloc(PIXELW * PIXELH * 4 * sizeof(int)); 
      numNeighborSpikes = (int*)malloc(PIXELW * PIXELH * 4 * sizeof(int)); 
    }


    void printFinalMetrics(string path) {

      int numFrames = TOTAL_FRAMES;
      //bool ASSUME_GRAYSCALE = true;

      // *** Flickr Metrics

      //spikiness = (add up all numSpikes) / (PW*PH) / numFrames 
      float videoSpikiness = 0;

      //avg peak dist = (add up all totalPeakVals) / (PW*PH) / numFrames
      float videoAvgPeakDistance = 0;

      //peakiness = (add up all numPeaks) / (PW*PH) / numFrames
      float videoPeakiness = 0;
    
      // *** Contrast Metrics

      //avg max neighbor dist = (add up all maxNeighborDistance) / (PW*PH) / numFrames
      float videoAvgNeighborDistance = 0;
      
      //contrastiness = (add up all numNeighborSpikes) / (PW * PH) / numFrames
      float videoContrastiness = 0;


      int dim = PIXELW*PIXELH;

      for (int i = 0 ; i < dim; i+=4) {
        videoSpikiness += numberSpikes[i];
        videoAvgPeakDistance += totalPeakVals[i];
        videoPeakiness += numberPeaks[i];

        videoAvgNeighborDistance += maxNeighborDistance[i];
        videoContrastiness += numNeighborSpikes[i];
      }

      //printf(" check videoSpikiness = %f \n", videoSpikiness);
      //printf(" check videoContrastiness = %f \n", videoContrastiness);

      videoSpikiness = videoSpikiness / (float)dim / (float)numFrames;
      //videoAvgPeakDistance = videoAvgPeakDistance / (float)dim / (float)numFrames;
      videoAvgPeakDistance = videoAvgPeakDistance / (float)videoPeakiness;
      videoPeakiness = videoPeakiness / (float)dim / (float)numFrames;

      videoAvgNeighborDistance = videoAvgNeighborDistance / (float)dim / (float)numFrames;
      videoContrastiness = videoContrastiness / (float)dim / ((float)numFrames);

      // *** Global Flickr

      float globalSpikiness = (float) numberFrameSpikes / (float) TOTAL_FRAMES;
      float globalAvgPeakDistance = (float) totalFramePeakVals / (float) numberFramePeaks;
      float globalPeakiness = (float) numberFramePeaks / (float) TOTAL_FRAMES;
    

      // *** REPORT

/* 
 * FLICKR * - captures small changes
  video choppiness = 
  number of large jumps (+ or - 1/8*(max-min)) in contrast per-pixel 
 
  video peakiness per pixel= 
  average frequency

  video avg peak distance per pixel =
  average amplitude

  ***

 * VARIANCE *
  video avg max neighbor distance per pixel =
  average roughness

  video contrastiness/edginess = 
  number of large jumps (+ or - 1/8*(max-min)) with neighbors


  *** 
 * FLUTTER * - captures global changes
  overall contrast of entire image
  video choppiness = 
  number of large jumps (+ or - 1/2*(max-min)) in contrast per-pixel 
 
  video peakiness overall = 
  average frequency

  video avg peak distance overall =
  average amplitude




*/
cout << "Video: " << path << "\n";
cout << "\nFLICKER: \n";

      printf("local_chopiness:%f\n", videoSpikiness);
      printf("local_amplitude:%f\n", videoAvgPeakDistance);
      printf("local_frequency:%f\n", videoPeakiness);

      cout << "\nFLUTTER: \n";

      printf("global_chopiness:%f\n", globalSpikiness);
      printf("global_amplitude:%f\n", globalAvgPeakDistance);
      printf("global_frequency:%f\n", globalPeakiness);
    
      cout << "\nVARIATION: \n";

      printf("roughness:%f\n", videoAvgNeighborDistance);
      printf("edginess:%f\n", videoContrastiness);

      cout << "\n\n\n";
          
    }


    void calculatePeaks(GLubyte* &data, int frameNum) {
   
        bool PRINT = false;
    
      int idx = 0;
        if (PRINT) printf("\n\n***Reading Frame %d\n", frameNum);
        for (int j = 0; j < PIXELH; j++) {
          for (int i = 0; i < PIXELW; i++) {
            if (PRINT) printf("pixel (%d,%d) = RGB:  ", i, j);
            for (int v = 0; v < 4; v++) {
              if (PRINT) printf(" %d ", data[idx]);

              if (frameNum == 0) { //first one
                basePeaks[idx] = data[idx];
                peakDir[idx] = 1;
                numberPeaks[idx] = 0;
                numberSpikes[idx] = 0;
                totalPeakVals[idx] = 0;
              } 
              
              {
               
                 int diff = abs(data[idx] - prevVals[idx]);
                 if (diff > PEAK_SPIKE) {
                 // printf("diff = %d\n", diff);
                  numberSpikes[idx]++;
                }

                
                if (
                  (peakDir[idx] == 1 && data[idx] < prevVals[idx]) ||
                  (peakDir[idx] == -1 && data[idx] > prevVals[idx]) ) {

                //change direction
                peakDir[idx] *= -1;

                //add to totals
                numberPeaks[idx]++;
                int jump = abs(data[idx] - basePeaks[idx]);
                totalPeakVals[idx] += jump;
              
                //reset base
                basePeaks[idx] = data[idx];	

                if (v == 0) { //test red channel only 
                  //printf(" peak at %d! totalPeakVal = %d ; numberPeaks = %d ; numberSpikes = %d\n ", v, totalPeakVals[idx], numberPeaks[idx], numberSpikes[idx]);
                }
              }	      
              }
               
              //printf("idx = %d : peakDir = %d : numberPeaks = %d : prevVal = %d : curVal = %d\n", idx, peakDir[idx], numberPeaks[idx], prevVals[idx], data[idx]);
              idx++;
            }
            if (PRINT) printf("}\n");
          }
        } 
        memcpy ( prevVals, data, 4 * PIXELW * PIXELH );



    }

    /*
    void calculatePeaks(FBO& f, int frameNum) {
      f.bind(); {
        calculatePeaks(f.texture, frameNum);
      } f.unbind();
    }

    void calculatePeaks(Texture& rt, int frameNum) {

      rt.bind(); {


        //GLubyte *data = (GLubyte*)malloc(4 * rt.width * rt.height);
        //glReadPixels(0, 0, rt.width, rt.height, GL_RGBA, GL_UNSIGNED_BYTE, data);
	//const GLubyte *data = rt.data;

    //    calculatePeaks(rt.data, frameNum);

     
      } rt.unbind();
    }
    */

     void calculateGlobalPeaks(GLubyte* &data, int frameNum) {
   
   	int height = PIXELH;
	int width = PIXELW;


     float frameContrast = 0;
        for (int j = 0; j < height*width*4; j+=4) { //assume grayscale for now
          frameContrast += data[j];              
        } 

        frameContrast /= (float)(height*width);

        if (frameNum == 0) { //first one
          baseFramePeak = frameContrast;
          framePeakDir = 1;
          numberFramePeaks = 0;
          numberFrameSpikes = 0;
          totalFramePeakVals = 0;
          prevContrast = frameContrast;
        } 

        else {

          float diff = fabs(frameContrast - prevContrast);
         // printf("frame diff = %f\n", diff);
         //  printf("frame: %d , contrast = %f, numFrameSpikes = %d\n", frameNum, frameContrast, numberFrameSpikes);
           if (diff > GLOBAL_PEAK_SPIKE) {
            numberFrameSpikes++;
           
          }


          if (
              (framePeakDir == 1 && frameContrast < prevContrast) ||
              (framePeakDir == -1 && frameContrast > prevContrast) ) {

            //change direction
            framePeakDir *= -1;

            //add to totals
            numberFramePeaks++;
            float jump = fabs(frameContrast - baseFramePeak);
            totalFramePeakVals += jump;

            //reset base
            baseFramePeak = frameContrast;	
          }
        }

        prevContrast = frameContrast;


   
     }

     /*
    void calculateGlobalPeaks(FBO& f, int frameNum) {
      f.bind(); {
        calculateGlobalPeaks(f.texture, frameNum);
      } f.unbind();
    }

    void calculateGlobalPeaks(Texture& rt, int frameNum) {

     rt.bind(); {
        //GLubyte *data = (GLubyte*)malloc(4 * rt.width * rt.height);
        //glReadPixels(0, 0, rt.width, rt.height, GL_RGBA, GL_UNSIGNED_BYTE, data);
//	const GLubyte *data = rt.data;

     
      } rt.unbind();
    }
    */

     void calculateNeighborDistance(GLubyte* &data, int frameNum) {
   
 //GLubyte *data = (GLubyte*)malloc(4 * rt.width * rt.height);
        //glReadPixels(0, 0, rt.width, rt.height, GL_RGBA, GL_UNSIGNED_BYTE, data);
  bool PRINT = false;
	int height = PIXELH;
	int width = PIXELW;

        int idx = 0;
        if (PRINT) printf("\n\n***Reading Frame %d\n", frameNum);
        for (int j = 0; j < height; j++) {
          for (int i = 0; i < width; i++) {

            if (PRINT) printf("pixel (%d,%d) = RGB:  ", i, j);

            for (int v = 0; v < 4; v++) {
              if (PRINT) printf(" %d ", data[idx]);

              int maxDist = 0;
              //if ( v == 0 && ((i == 0 && j == 0 ) || ( i == 1 && j == 0)) ) 
              {

                //DL
                if (i > 0 && j > 0) {
                  int chkIdx = getIdxForXY(i-1,j-1,width) + v;
                  int dist = abs(data[chkIdx] - data[idx]); 
                  if (dist > maxDist) {
                    maxDist = dist;
                  }
                }

                  //L
                  if (i > 0) {
                    int chkIdx = getIdxForXY(i-1,j,width) + v;

                    int dist = abs(data[chkIdx] - data[idx]); 
                    if (dist > maxDist) {
                      maxDist = dist;
                    }

                  }

                  //UL
                  if (i > 0 && j < height - 1) {
                    int chkIdx = getIdxForXY(i-1,j+1,width) + v;
                    int dist = abs(data[chkIdx] - data[idx]); 
                    if (dist > maxDist) {
                      maxDist = dist;
                    }
                  }

                  //U
                  if (j < height - 1) {
                    int chkIdx = getIdxForXY(i,j+1,width) + v;
                    int dist = abs(data[chkIdx] - data[idx]); 
                    if (dist > maxDist) {
                      maxDist = dist;
                    }
                  }

                  //UR
                  if (i < width - 1 && j < height - 1) {
                    int chkIdx = getIdxForXY(i+1,j+1,width) + v;
                    int dist = abs(data[chkIdx] - data[idx]); 
                    if (dist > maxDist) {
                      maxDist = dist;
                    }
                  }

                  //R
                  if (i < width - 1) {
                    int chkIdx = getIdxForXY(i+1,j,width) + v;
                    int dist = abs(data[chkIdx] - data[idx]); 
                    if (dist > maxDist) {
                      maxDist = dist;
                    }
                  }

                  //DR
                  if (i < width - 1 && j > 0) {
                    int chkIdx = getIdxForXY(i+1,j-1,width) + v;
                    int dist = abs(data[chkIdx] - data[idx]); 
                    if (dist > maxDist) {
                      maxDist = dist;
                    }
                  }

                  //D
                  if (j > 0) {
                    int chkIdx = getIdxForXY(i,j-1,width) + v;
                    int dist = abs(data[chkIdx] - data[idx]); 
                    if (dist > maxDist) {
                      maxDist = dist;
                    }
                  }

                  maxNeighborDistance[idx] += maxDist;

                  //if (v == 0 && frameNum > 0) 
                  { //test just Red channel
                    // printf("pixel (%d,%d) :   ", i, j);
                    // printf("red val = %d \n", data[idx]);
                    // printf("maxDist = %d\n", maxDist);

                    if (maxDist > NEIGHBOR_SPIKE) {
                      numNeighborSpikes[idx]++;
                    }

                    //float avgMaxDist = (float)maxNeighborDistance[idx] / (float)frameNum;
                    // printf("avgMaxDist = %.5f; numNeighborSpikes = %d\n", avgMaxDist, numNeighborSpikes[idx]);
                  }
                }
                idx++;
              }

              if (PRINT) printf("}\n");
            }
          } 


     }

    int getIdxForXY(int x, int y, int rowSize) { 
      return (y * rowSize * 4) + (x * 4);
    }


};

