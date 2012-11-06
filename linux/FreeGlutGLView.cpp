#include "FreeGlutGLView.hpp"
#include <iostream>
#include <sys/time.h>

int width;
int height;
RendererLinux* renderer;
static struct timeval lastTime;


FreeGlutGLView::FreeGlutGLView() {}

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

	//printf("in FreeGlutGLView : display()\n");
	renderer->onFrame();
	glutSwapBuffers();
}

void animate() {
	float dt;

	struct timeval now;
	gettimeofday(&now, NULL);
	dt = (float)(now.tv_usec - lastTime.tv_usec);
	lastTime = now;

	glutPostRedisplay();
}

void button(int button, int state, int x, int y ) {
	printf("button : %d %d %d %d\n", button, state, x, y);
}
void motion(int x, int y ) {
	printf("motion : %d %d\n", x, y);
}


void keyboard(unsigned char key, int x, int y) {
	switch(key) {

		case 27: 
			exit(0);
			break;
		case '1':
			printf("you pressed the number 1!\n");
			glutFullScreen();
			break;
		case '2':
			glutReshapeWindow(400,400);
			break;
		default: 
			printf("you pressed %c\n", key);
			break;
	}

	printf("done pressing...\n");
}

FreeGlutGLView* FreeGlutGLView::start(void* _renderer) {
	return FreeGlutGLView::start(_renderer, "allomin");
}

FreeGlutGLView* FreeGlutGLView::start(void* _renderer, std::string name) {

	renderer = (RendererLinux*) _renderer;

	printf("HRERERE!\n");
	fprintf(stderr, "yo\n");

	char* argv[] = {"foo", "bar"};
	int argc = 2;

	glutInit(&argc, argv);
	fprintf(stderr, "yo a\n");
	glutInitContextVersion(3,2);
	fprintf(stderr, "yo bbb\n");


	glutInitContextFlags(GLUT_CORE_PROFILE | GLUT_DEBUG);
	//glutInitContextFlags(GLUT_FORWARD_COMPATIBLE | GLUT_DEBUG);
	fprintf(stderr, "yo c \n");

	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
	fprintf(stderr, "yo d\n");

/*
	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_MULTISAMPLE );
	GLint buf, sample;
	glGetIntegerv (GL_SAMPLE_BUFFERS, &buf);
	glGetIntegerv (GL_SAMPLES, &sample);

	std::cout << "buf: " << buf << " samples: " << sample << " \n";
	glEnable(GL_MULTISAMPLE);
*/

	glutInitWindowSize(200,200);
	fprintf(stderr, "yo e\n");
	//glutCreateWindow(name.c_str());
	glutCreateWindow("abc");
	fprintf(stderr, "yo f\n");


//	glutGameModeString("1280x1024:32@60");
//	glutEnterGameMode();
	
	renderer->onCreate();
fprintf(stderr, "yo g\n");

	glutDisplayFunc(&display);
	glutReshapeFunc(&reshape);
	glutKeyboardFunc(&keyboard);
	glutMouseFunc(&button);
	glutMotionFunc(&motion);
	glutIdleFunc(&animate);
	fprintf(stderr, "yo h\n");

	gettimeofday(&lastTime, NULL);
	fprintf(stderr, "yo i\n");


	



	glutMainLoop();

	//glutInitDisplayMode(GL_RGBA);
	//glutInitWindowSize(200,200);
	//glutCreateWindow("test");

	return NULL;
	//return glView;

}


