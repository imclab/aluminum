//
//  Main.cpp
//  niftiViewer
//
//  Created by Angus Forbes on 7/7/13.
//  Copyright (c) 2013 Angus Forbes. All rights reserved.
//


#include "Slices.mm"
#include "RayCast.mm"

int main(){

//    Slices nifti = Slices();
    RayCast nifti = RayCast();
    nifti.initializeViews();

    return 0;
}


