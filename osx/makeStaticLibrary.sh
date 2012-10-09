#!/bin/bash

APP="2D"

OSX_DIR="$( cd "$( dirname "$0" )" && pwd )"

BASE_DIR="$OSX_DIR/.."
SRC_DIR="$BASE_DIR/src"
INCLUDE_DIR="$OSX_DIR/include"

INCLUDE="-I$OSX_DIR -I$INCLUDE_DIR" 
SRC="$SRC_DIR/*.cpp $OSX_DIR/*.mm"

cd $BASE_DIR;

### 1. COMPILE
echo -e "\nBUILDING obj files for static library... \n\nc++ -std=c++11 -stdlib=libc++ $INCLUDE $SRC "

# use -H below to double check if the headers have been precompiled
time c++ -c -x objective-c++ -include $OSX_DIR/Includes.hpp -std=c++11 -stdlib=libc++ $INCLUDE $SRC 

### 2. ARCHIVE
echo -e "\n\n\nARCHIVING obj files into static library aluminum.a..."

time ar rs $BASE_DIR/aluminum.a $BASE_DIR/*.o


### 3. CLEAN UP
rm $BASE_DIR/*.o
