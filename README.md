aluminum
========

Lightweight, minimal OpenGL framework using C++11 (or Objective-C++11 on OSX/iOS). Supports OpenGL 3.2 on osx/cocoa and linux/freeglut. Supports OpenGL ES 2.0 on iOS.

***

Aluminum was initially created for the Allosphere Research Facility at UC Santa Barbara and is based on the allocore library (now called AlloSystem), written by Graham Wakefield, Lance Putnam, and others. (https://github.com/AlloSphere-Research-Group/AlloSystem). 

*** 

Required libraries: ~~freeimage~~, ~~assimp3~~, glm.

Features: active, passive, and anaglyph stereo rendering; signed-distance fonts; textured fonts; high resolution timing/animation methods (via C++11's chrono); model loading (via assimp3); texture reading/writing (via freeimage); 6DOF vector camera class; etc. 

Linux requires freeglut2.6 (or above?), see readme in linux directory.

Sample OSX/Cocoa projects using XCode 4.6.2 provided.

***

Issues - In OSX the MacPorts installation of FreeImage (installed into /opt/local/include/FreeImage.h) has some kind of type clash. Resolve by replacing all instances of BOOL in the FreeImage.h file with a unique name, like BOOL_FI. (In this header, BOOL is a tyepdef for int32, not sure what exactly the issue is, but easy enough to fix).


