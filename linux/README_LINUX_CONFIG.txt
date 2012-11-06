
To install gcc-4.7:

sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install gcc-4.7
sudo apt-get install g++-4.7

sudo ln -s /usr/bin/gcc-4.7 /usr/bin/gcc
sudo ln -s /usr/bin/g++-4.7 /usr/bin/g++

Remove assimp2:
sudo apt-get remove assimp-utils

Download + compile + install assimp3:

git clone git://github.com/assimp/assimp.git
cd assimp
cmake .
make -j5
sudo make install

Had an issue with compiling assimp3... followed this...
http://blogmonsalve.blogspot.com/2012/10/compilando-assimp-en-kubuntu-1204.html



Install FreeGlut2.6+ and GL3:

 sudo apt-get install freeglut3-dev

Copy http://www.opengl.org/registry/api/gl3.h to /usr/include/GL3/gl3.h
