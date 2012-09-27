#!/bin/bash

APP="TextExample"

EXAMPLE_DIR="$( cd "$( dirname "$0" )" && pwd )"

BASE_DIR="$EXAMPLE_DIR/../../.."
SRC_DIR="$BASE_DIR/src"
OSX_DIR="$BASE_DIR/osx"
LIB_DIR="$OSX_DIR/lib"
INCLUDE_DIR="$OSX_DIR/include"

ASSIMP="$LIB_DIR/libassimp.dylib"
FREEIMAGE="$LIB_DIR/libfreeimage.dylib" 
COCOA="-isysroot /Applications/XCode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk -mmacosx-version-min=10.7 -framework Cocoa -framework QuartzCore -framework OpenGL -framework AppKit -framework Foundation"
OPTIONS="-O3 -Wreturn-type -Wformat -Wmissing-braces -Wparentheses -Wswitch -Wunused-variable -Wsign-compare -Wno-unknown-pragmas  -Woverloaded-virtual"

INCLUDE="-I./ -I$OSX_DIR -I$SRC_DIR -I$INCLUDE_DIR"
LIBS="$ASSIMP $FREEIMAGE"
SRC=" -x objective-c++ $SRC_DIR/*.cpp $OSX_DIR/*.mm $EXAMPLE_DIR/*.mm"

cd $BASE_DIR; pwd

#COMPILE
#echo -e "\nbuilding... \n\nc++ $COCOA $OPTIONS -std=c++11 $LIBS $INCLUDE $SRC -o $EXAMPLE_DIR/$APP \n\n"
echo -e "\nbuilding... \n\nc++ $COCOA $OPTIONS -std=c++11 -stdlib=libc++ $LIBS $INCLUDE $SRC -o $EXAMPLE_DIR/$APP \n\n"
c++ $COCOA $OPTIONS -std=c++11 -stdlib=libc++ $LIBS $INCLUDE $SRC -o $EXAMPLE_DIR/$APP

#RUN
cd $EXAMPLE_DIR && ./$APP && rm ./$APP
