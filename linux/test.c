#define GL3_PROTOTYPES
#include <GL3/gl3.h>
#define __gl_h_


#include <GL/freeglut.h>

//#include <GL/glew.h>
//  #include <GL/glut.h>
#include <stdio.h>
#include <iostream>

int width;
int height;

void reshape(GLint _w, GLint _h) {
	width = _w;
	height = _h;

	glViewport(0,0,width,height);

	printf("in reshape: %d %d\n", width, height);
GLuint bbb;
glGenVertexArrays(1, &bbb);
}

void display() { 
	printf("in display....\n");

	glClearColor(1,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glutSwapBuffers();
}

int main(int argc, char** argv) {

	printf("hooray...\n");

	char* av[] = {"foo", "bar"};
	int ac = 2;

	glutInit(&ac, av);
	glutInitContextVersion(3,2);


	glutInitContextFlags(GLUT_CORE_PROFILE | GLUT_DEBUG);

	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );

	glutInitWindowSize(200,200);
	glutCreateWindow("yay");

	glutDisplayFunc(&display);
	glutReshapeFunc(&reshape);


	glutMainLoop();
}
