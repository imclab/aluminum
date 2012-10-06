#!/bin/bash

APP="3D"

#default builder flags, can be changed with -c, -r, -b, -s, -p. Use -? for help.
BUILD=1
COMPILE=1
RUN=1
PRE=0

while getopts "crbsp?" opt; do
  case $opt in

    c) echo "...compile only"
      COMPILE=1
      RUN=0
      ;;
    r) echo "...run only"
      PRE=0
      BUILD=0
      COMPILE=0
      RUN=1
      ;;
    b) echo "...build static lib"
      BUILD=1
      ;;
    s) echo "...skip buiding static lib"
      BUILD=0
      ;;
    p) echo "...precompile headers"
      PRE=1
      ;;
    ?) echo -e "\n...help"
      echo -e "\n\tvalid flags are:"
      echo -e "\t -c : compile only"
      echo -e "\t -r : run only"
      echo -e "\t -s : skip building static lib"
      echo -e "\t -b : force building static lib"
      echo -e "\t -p : force precompiling headers"
      exit ;;

  esac
done

shift $(( OPTIND - 1 ))  # shift past the last flag or argument

echo "PRECOMPILE=$PRE BUILD=$BUILD COMPILE=$COMPILE RUN=$RUN"

EXAMPLE_DIR="$( cd "$( dirname "$0" )" && pwd )"

BASE_DIR="$EXAMPLE_DIR/../../.."
SRC_DIR="$BASE_DIR/src"
OSX_DIR="$BASE_DIR/osx"
LIB_DIR="$OSX_DIR/lib"
INCLUDE_DIR="$OSX_DIR/include"

ASSIMP="$LIB_DIR/libassimp.dylib"
FREEIMAGE="$LIB_DIR/libfreeimage.dylib" 

COCOA="-isysroot /Applications/XCode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk -mmacosx-version-min=10.7 -framework Cocoa -framework QuartzCore -framework OpenGL -framework AppKit -framework Foundation"

OPTIONS="-O3 -Wreturn-type -Wformat -Wmissing-braces -Wparentheses -Wswitch -Wunused-variable -Wsign-compare -Wno-unknown-pragmas -Woverloaded-virtual"

INCLUDE="-I./ -I$OSX_DIR -I$SRC_DIR -I$INCLUDE_DIR"
LIBS="$ASSIMP $FREEIMAGE"
SRC=" -x objective-c++ $SRC_DIR/*.cpp $OSX_DIR/*.mm $EXAMPLE_DIR/$APP.mm"

cd $BASE_DIR;


if [ "$PRE" -eq 1 ]; then 

  ### 1. PRECOMPILE headers (should only need to if Include.hpp has changed)
  echo -e "precomiling headers from Include.hpp into Include.hpp.gch...\n\n"

  $OSX_DIR/precompileHeaders.sh
fi


if [ "$BUILD" -eq 1 ]; then 

  ### 1. BUILD aluminum static lib (should only need to if changed aluminum files)
  #       assumes we've already pre-compiled Include.hpp
  echo -e "building static library using precomiled header Include.hpp.gch...\n\n"

  $OSX_DIR/makeStaticLibrary.sh
fi


if [ "$COMPILE" -eq 1 ]; then 

  ### 2. COMPILE w/aluminum lib
  echo -e "\n\n\nCOMPILING user code with aluminum static lib... \n\nc++ $COCOA $OPTIONS -std=c++11 -stdlib=libc++ $BASE_DIR/aluminum.a $LIBS $INCLUDE $EXAMPLE_DIR/$APP.mm -o $EXAMPLE_DIR/$APP"

  time c++ $COCOA $OPTIONS -std=c++11 -stdlib=libc++ $BASE_DIR/aluminum.a $LIBS $INCLUDE $EXAMPLE_DIR/$APP.mm -o $EXAMPLE_DIR/$APP

fi 


if [ "$RUN" -eq 1 ]; then 
  ### 3. RUN the app
  cd $EXAMPLE_DIR && ./$APP
fi
