#!/bin/bash

APP="FrontBack"

EXAMPLE_DIR="$( cd "$( dirname "$0" )" && pwd )"

BASE_DIR="$EXAMPLE_DIR/../../../"
SRC_DIR="$BASE_DIR/src/"
OSX_DIR="$BASE_DIR/osx/"
LIB_DIR="$OSX_DIR/libs/"

cd $BASE_DIR

pwd

c++ -I/opt/local/include/  -I./ -isysroot /Applications/XCode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk -mmacosx-version-min=10.7 -O3  -Wreturn-type -Wformat -Wmissing-braces -Wparentheses -Wswitch -Wunused-variable -Wsign-compare -Wno-unknown-pragmas  -Woverloaded-virtual  -std=c++11  $LIB_DIR/libassimp.dylib  $LIB_DIR/libfreeimage.dylib  -framework Cocoa -framework QuartzCore -framework OpenGL -framework AppKit -framework Foundation -I./ -I$OSX_DIR -I$SRC_DIR -x objective-c++ $SRC_DIR/*.cpp $OSX_DIR/*.mm $EXAMPLE_DIR/*.mm -o $EXAMPLE_DIR/$APP

cd $EXAMPLE_DIR && ./$APP && rm ./$APP
