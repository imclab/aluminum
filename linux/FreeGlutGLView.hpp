#ifndef INCLUDE_AL_FGGLV_HPP
#define INCLUDE_AL_FGGLV_HPP


#include "FreeGlutGLView.hpp"
#include "RendererLinux.hpp"

#define GL3_PROTOTYPES
#include <GL3/gl3.h>
#define __gl_h_
#include <GL/freeglut.h>

#include <stdio.h>


class FreeGlutGLView {

	public:
		FreeGlutGLView* glView;

		static FreeGlutGLView* start(void* _renderer);

};

#endif

