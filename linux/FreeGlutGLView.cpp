#include "FreeGlutGLView.hpp"


int width;
int height;
RendererLinux* renderer;

void reshape(GLint _w, GLint _h) {
	width = _w;
	height = _h;

	renderer->width = width;
	renderer->height = height;

	glViewport(0,0,width,height);

	printf("in reshape: %d %d\n", width, height);
	GLuint bbb;
	glGenVertexArrays(1, &bbb);
}

void display() {

printf("in FreeGlutGLView : display()\n");
	renderer->onFrame();
/*
	printf("in display....\n");

	glClearColor(1,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
*/
	glutSwapBuffers();
}


FreeGlutGLView* FreeGlutGLView::start(void* _renderer) {

	renderer = (RendererLinux*) _renderer;

	printf("HRERERE!\n");
	fprintf(stderr, "yo\n");

	char* argv[] = {"foo", "bar"};
	int argc = 2;

	glutInit(&argc, argv);
	glutInitContextVersion(3,2);


	glutInitContextFlags(GLUT_CORE_PROFILE | GLUT_DEBUG);

	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );

	glutInitWindowSize(200,200);
	glutCreateWindow("yay");

	
	renderer->onCreate();

	//glutDisplayFunc(&display);
	glutDisplayFunc(&display);
	glutReshapeFunc(&reshape);


	glutMainLoop();

	//glutInitDisplayMode(GL_RGBA);
	//glutInitWindowSize(200,200);
	//glutCreateWindow("test");

	return NULL;
	//return glView;

}


