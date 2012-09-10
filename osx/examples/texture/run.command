#!/bin/bash

APP="TextureExample"
EXAMPLE_DIR="$( cd "$( dirname "$0" )" && pwd )"

BASE_DIR="$EXAMPLE_DIR/../../../"
SRC_DIR="$BASE_DIR/src/"
OSX_DIR="$BASE_DIR/osx/"

cd $BASE_DIR

pwd

c++ -I/opt/local/include/ -I/usr/local/include/ -I/usr/include/ -I./ -Ibuild//include  -D__STDC_CONSTANT_MACROS -D__STDC_LIMIT_MACROS -arch x86_64 -isysroot /Applications/XCode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk -mmacosx-version-min=10.7 -O3 -Wc++11-extensions -Wreturn-type -Wformat -Wmissing-braces -Wparentheses -Wswitch -Wunused-variable -Wsign-compare -Wno-unknown-pragmas  -Woverloaded-virtual -L/usr/lib/ -L/opt/local/lib/ -L/usr/local/lib/ -lm -lstdc++ -std=c++11  -lassimp -lfreeimage -framework Carbon -framework IOKit -framework Cocoa -framework QuartzCore -framework OpenGL -framework AppKit -framework Foundation -I./ -I$OSX_DIR -I$SRC_DIR  $SRC_DIR/*.cpp $OSX_DIR/*.mm $EXAMPLE_DIR/*.mm -o $EXAMPLE_DIR/$APP

cd $EXAMPLE_DIR && ./$APP && rm ./$APP

#-x objective-c++
