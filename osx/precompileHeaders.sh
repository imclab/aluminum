#!/bin/bash

OSX_DIR="$( cd "$( dirname "$0" )" && pwd )"

BASE_DIR="$OSX_DIR/.."
SRC_DIR="$BASE_DIR/src"
#INCLUDE_DIR="$OSX_DIR/include"
INCLUDE_DIR="/opt/local/include"

INCLUDE="-I./ -I$OSX_DIR -I$SRC_DIR -I$INCLUDE_DIR"

cd $BASE_DIR;

### 1. PRE-COMPILE into Includes.hpp.gch

echo -e "\nPRE-COMPILING HEADERS... \n\nc++ -x objective-c++-header -std=c++11 -stdlib=libc++ $INCLUDE $OSX_DIR/Includes.hpp "  

time c++ -x objective-c++-header -std=c++11 -stdlib=libc++ $INCLUDE $OSX_DIR/Includes.hpp 

