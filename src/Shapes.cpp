#include <math.h>
#include "Shapes.hpp"
#include <glm/glm.hpp>

namespace al{

using glm::to_string;
using glm::vec2;
using glm::vec3;
using glm::vec4;
using glm::mat4;

const double phi = (1 + sqrt(5))/2; // the golden ratio

int addTetrahedron(MeshData& m){
	static const float l = sqrt(1./3);
	static const float vertices[] = {
		 l, l, l,
		-l, l,-l,
		 l,-l,-l,
		-l,-l, l
	};

	//static const int indices[] = {0,2,1, 0,1,3, 1,2,3, 2,0,3};
	static const unsigned long indices[] = {0,2,1, 0,1,3, 1,2,3, 2,0,3};

	int Nv = sizeof(vertices)/sizeof(*vertices)/3;

	m.vertex(vertices, Nv);
	m.index(indices, sizeof(indices)/sizeof(*indices), m.vertices().size()-Nv);

	return Nv;
}



  //int addRectangle(MeshData& m, vec2 vLL, vec2 vUR, vec2 tcLL, vec2 tcUR) {
  int addRectangle(MeshData& m, vec2 vLL, vec2 vUR, vec2 tcLL, vec2 tcUR) {

    m.reset();

    vec3 v0 = vec3(vLL.x, vLL.y,0);
    vec3 v1 = vec3(vLL.x,vUR.y,0);
    vec3 v2 = vec3(vUR.x,vLL.y,0);
    vec3 v3 = vec3(vUR.x,vUR.y,0);

    vec3 t0 = vec3(tcLL.x,tcLL.y,0);
    vec3 t1 = vec3(tcLL.x,tcUR.y,0);
    vec3 t2 = vec3(tcUR.x,tcLL.y,0);
    vec3 t3 = vec3(tcUR.x,tcUR.y,0);

    m.vertex(v0); m.texCoord(t0);
    m.vertex(v1); m.texCoord(t1);
    m.vertex(v2); m.texCoord(t2);
    m.vertex(v3); m.texCoord(t3);

    int Nv = 4;

    static const unsigned long indices[] = {
      0,1,2, 2,1,3	
    };

    m.index(indices, sizeof(indices)/sizeof(*indices), m.vertices().size()-Nv);

    return Nv;
  }


int addRectangle(MeshData& m, float _w, float _h) {

  float w = _w/2.0;
  float h = _h/2.0;

  vec3 v0 = vec3(-w,-h,0);
  vec3 v1 = vec3(-w,h,0);
  vec3 v2 = vec3(w,-h,0);
  vec3 v3 = vec3(w,h,0);

  vec3 t0 = vec3(0,0,0);
  vec3 t1 = vec3(0,1,0);
  vec3 t2 = vec3(1,0,0);
  vec3 t3 = vec3(1,1,0);

  m.vertex(v0); m.texCoord(t0);
  m.vertex(v1); m.texCoord(t1);
  m.vertex(v2); m.texCoord(t2);
  m.vertex(v3); m.texCoord(t3);

  int Nv = 4;
   
  //static const int indices[] = {
  static const unsigned long indices[] = {
    0,1,2, 2,1,3	
  };

  m.index(indices, sizeof(indices)/sizeof(*indices), m.vertices().size()-Nv);

  return Nv;
}


int addRectangle(MeshData& m) {

  vec3 v0 = vec3(-1,-1,0);
  vec3 v1 = vec3(-1,1,0);
  vec3 v2 = vec3(1,-1,0);
  vec3 v3 = vec3(1,1,0);

  vec3 t0 = vec3(0,0,0);
  vec3 t1 = vec3(0,1,0);
  vec3 t2 = vec3(1,0,0);
  vec3 t3 = vec3(1,1,0);

  m.vertex(v0); m.texCoord(t0);
  m.vertex(v1); m.texCoord(t1);
  m.vertex(v2); m.texCoord(t2);
  m.vertex(v3); m.texCoord(t3);

  int Nv = 4;
   
  //static const int indices[] = {
  static const unsigned long indices[] = {
    0,1,2, 2,1,3	
  };

  m.index(indices, sizeof(indices)/sizeof(*indices), m.vertices().size()-Nv);

  return Nv;
}


int addCube(MeshData& m, bool withNormalsAndTexcoords, float s) {
  if (withNormalsAndTexcoords) {

    vec3 v0 = vec3(-s,-s,s);
    vec3 v1 = vec3(-s,s,s);
    vec3 v2 = vec3(s,-s,s);
    vec3 v3 = vec3(s,s,s);
    vec3 v4 = vec3(-s,-s,-s);
    vec3 v5 = vec3(-s,s,-s);
    vec3 v6 = vec3(s,-s,-s);
    vec3 v7 = vec3(s,s,-s);

    vec3 n0 = vec3(0,0,s);
    vec3 n1 = vec3(0,0,-s);
    vec3 n2 = vec3(0,s,0);
    vec3 n3 = vec3(0,-s,0);
    vec3 n4 = vec3(s,0,0);
    vec3 n5 = vec3(-s,0,0);

    vec3 t0 = vec3(0,0,0);
    vec3 t1 = vec3(0,1,0);
    vec3 t2 = vec3(1,0,0);
    vec3 t3 = vec3(1,1,0);

    //right 
    m.vertex(v2); m.normal(n4); m.texCoord(t0);
    m.vertex(v3); m.normal(n4); m.texCoord(t1);
    m.vertex(v6); m.normal(n4); m.texCoord(t2);
    m.vertex(v6); m.normal(n4); m.texCoord(t2);
    m.vertex(v3); m.normal(n4); m.texCoord(t1);
    m.vertex(v7); m.normal(n4); m.texCoord(t3);

    //left 
    m.vertex(v4); m.normal(n5); m.texCoord(t0);
    m.vertex(v5); m.normal(n5); m.texCoord(t1);
    m.vertex(v0); m.normal(n5); m.texCoord(t2);
    m.vertex(v0); m.normal(n5); m.texCoord(t2);
    m.vertex(v5); m.normal(n5); m.texCoord(t1);
    m.vertex(v1); m.normal(n5); m.texCoord(t3);

    //front
    m.vertex(v0); m.normal(n0); m.texCoord(t0);
    m.vertex(v1); m.normal(n0); m.texCoord(t1);
    m.vertex(v2); m.normal(n0); m.texCoord(t2);
    m.vertex(v2); m.normal(n0); m.texCoord(t2);
    m.vertex(v1); m.normal(n0); m.texCoord(t1);
    m.vertex(v3); m.normal(n0); m.texCoord(t3);

    //back
    m.vertex(v4); m.normal(n1); m.texCoord(t0);
    m.vertex(v5); m.normal(n1); m.texCoord(t1);
    m.vertex(v6); m.normal(n1); m.texCoord(t2);
    m.vertex(v6); m.normal(n1); m.texCoord(t2);
    m.vertex(v5); m.normal(n1); m.texCoord(t1);
    m.vertex(v7); m.normal(n1); m.texCoord(t3);

    //top
    m.vertex(v1); m.normal(n2); m.texCoord(t0);
    m.vertex(v5); m.normal(n2); m.texCoord(t1);
    m.vertex(v3); m.normal(n2); m.texCoord(t2);
    m.vertex(v3); m.normal(n2); m.texCoord(t2);
    m.vertex(v5); m.normal(n2); m.texCoord(t1);
    m.vertex(v7); m.normal(n2); m.texCoord(t3);

    //bottom
    m.vertex(v0); m.normal(n3); m.texCoord(t0);
    m.vertex(v4); m.normal(n3); m.texCoord(t1);
    m.vertex(v2); m.normal(n3); m.texCoord(t2);
    m.vertex(v2); m.normal(n3); m.texCoord(t2);
    m.vertex(v4); m.normal(n3); m.texCoord(t1);
    m.vertex(v6); m.normal(n3); m.texCoord(t3);

    return 6*6;

  } else {


    /*
       0	1

       2	3
       4	5

       6	7

       t	b
       | /
       l --+--	r
       /	|
       f	b

*/

    int Nv = 8;
    m.vertex(-s, s,-s);	m.vertex( s, s,-s);
    m.vertex(-s,-s,-s);	m.vertex( s,-s,-s);
    m.vertex(-s, s, s);	m.vertex( s, s, s);
    m.vertex(-s,-s, s);	m.vertex( s,-s, s);

    //static const int indices[] = {
    static const unsigned long indices[] = {
      6,5,4, 6,7,5, 7,1,5, 7,3,1, 
      3,0,1, 3,2,0, 2,4,0, 2,6,4,
      4,1,0, 4,5,1, 2,3,6, 3,7,6
    };

    m.index(indices, sizeof(indices)/sizeof(*indices), m.vertices().size()-Nv);

    return Nv;
  }
}

int addOctahedron(MeshData& m){
  static const float vertices[] = {
    1,0,0, 0, 1,0, 0,0, 1,	// 0 1 2
    -1,0,0, 0,-1,0, 0,0,-1	// 3 4 5
  };

  //static const int indices[] = {
  static const unsigned long indices[] = {
    0,1,2, 1,3,2, 3,4,2, 4,0,2,
    1,0,5, 3,1,5, 4,3,5, 0,4,5
  };

  int Nv = sizeof(vertices)/sizeof(*vertices)/3;

  m.vertex(vertices, Nv);
  m.index(indices, sizeof(indices)/sizeof(*indices), m.vertices().size()-Nv);

  return Nv;
}

// Data taken from "Platonic Solids (Regular Polytopes In 3D)"
// http://local.wasp.uwa.edu.au/~pbourke/geometry/platonic/
int addDodecahedron(MeshData& m){
  static const float a = 1.6 * 0.5;
  static const float b = 1.6 / (2 * phi);
  static const float vertices[] = {
    0, b,-a,	 b, a, 0,	-b, a, 0,	//  0  1  2
    0, b, a,	 0,-b, a,	-a, 0, b,	//  3  4  5
    a, 0, b,	 0,-b,-a,	 a, 0,-b,	//  6  7  8
    -a, 0,-b,	 b,-a, 0,	-b,-a, 0	//  9 10 11
  };

  //static const int indices[] = {
  static const unsigned long indices[] = {
    1, 0, 2,	 2, 3, 1,	 4, 3, 5,	 6, 3, 4,
    7, 0, 8,	 9, 0, 7,	10, 4,11,	11, 7,10,
    5, 2, 9,	 9,11, 5,	 8, 1, 6,	 6,10, 8,
    5, 3, 2,	 1, 3, 6,	 2, 0, 9,	 8, 0, 1,
    9, 7,11,	10, 7, 8,	11, 4, 5,	 6, 4,10
  };

  int Nv = sizeof(vertices)/sizeof(*vertices)/3;

  m.vertex(vertices, Nv);
  m.index(indices, sizeof(indices)/sizeof(*indices), m.vertices().size()-Nv);

  return Nv;
}

int addIcosahedron(MeshData& m){
  //	float b = 1. / phi;
  //	float c = 2. - phi;
  //	float vertices[] = {
  //		 c,  0,  1,   -c,  0,  1,   -b,  b,  b,    0,  1,  c,    b,  b,  b,
  //		-c,  0,  1,    c,  0,  1,    b, -b,  b,    0, -1,  c,   -b, -b,  b,
  //		 c,  0, -1,   -c,  0, -1,   -b, -b, -b,    0, -1, -c,    b, -b, -b,
  //		-c,  0, -1,    c,  0, -1,    b,  b, -b,    0,  1, -c,   -b,  b, -b,
  //		 0,  1, -c,    0,  1,  c,    b,  b,  b,    1,  c,  0,    b,  b, -b,
  //		 0,  1,  c,    0,  1, -c,   -b,  b, -b,   -1,  c,  0,   -b,  b,  b,
  //		 0, -1, -c,    0, -1,  c,   -b, -b,  b,   -1, -c,  0,   -b, -b, -b,
  //		 0, -1,  c,    0, -1, -c,    b, -b, -b,    1, -c,  0,    b, -b,  b,
  //		 1,  c,  0,    1, -c,  0,    b, -b,  b,    c,  0,  1,    b,  b,  b,
  //		 1, -c,  0,    1,  c,  0,    b,  b, -b,    c,  0, -1,    b, -b, -b,
  //		-1,  c,  0,   -1, -c,  0,   -b, -b, -b,   -c,  0, -1,   -b,  b, -b,
  //		-1, -c,  0,   -1,  c,  0,   -b,  b,  b,   -c,  0,  1,   -b, -b,  b
  //	};
  //
  //	for(int i=0; i<Nv; i+=5){
  //		vec3 v1(vertices[3*i+ 0], vertices[3*i+ 1], vertices[3*i+ 2]);
  //		vec3 v2(vertices[3*i+ 3], vertices[3*i+ 4], vertices[3*i+ 5]);
  //		vec3 v3(vertices[3*i+ 6], vertices[3*i+ 7], vertices[3*i+ 8]);
  //		vec3 v4(vertices[3*i+ 9], vertices[3*i+10], vertices[3*i+11]);
  //		vec3 v5(vertices[3*i+12], vertices[3*i+13], vertices[3*i+14]);
  //		
  //		vec3 vc = (v1+v2+v3+v4+v5)/5;
  //		
  //		plato5.vertex(v1);
  //	}

  static const float vertices[] = {
    -0.57735, -0.57735, 0.57735,
    0.934172,  0.356822, 0,
    0.934172, -0.356822, 0,
    -0.934172, 0.356822, 0,
    -0.934172, -0.356822, 0,
    0,  0.934172,  0.356822,
    0,  0.934172,  -0.356822,
    0.356822,  0,  -0.934172,
    -0.356822,  0,  -0.934172,
    0,  -0.934172,  -0.356822,
    0,  -0.934172,  0.356822,
    0.356822,  0,  0.934172,
    -0.356822,  0,  0.934172,
    0.57735,  0.57735,  -0.57735,
    0.57735,  0.57735, 0.57735,
    -0.57735,  0.57735,  -0.57735,
    -0.57735,  0.57735,  0.57735,
    0.57735,  -0.57735,  -0.57735,
    0.57735,  -0.57735,  0.57735,
    -0.57735,  -0.57735,  -0.57735
  };

  //static const int indices[] = {
  static const unsigned long indices[] = {
    18, 2, 1,	11,18, 1,	14,11, 1,	 7,13, 1,	17, 7, 1,
    2,17, 1,	19, 4, 3,	 8,19, 3,	15, 8, 3,	12,16, 3,
    0,12, 3,	 4, 0, 3,	 6,15, 3,	 5, 6, 3,	16, 5, 3,
    5,14, 1,	 6, 5, 1,	13, 6, 1,	 9,17, 2,	10, 9, 2,
    18,10, 2,	10, 0, 4,	 9,10, 4,	19, 9, 4,	19, 8, 7,
    9,19, 7,	17, 9, 7,	 8,15, 6,	 7, 8, 6,	13, 7, 6,
    11,14, 5,	12,11, 5,	16,12, 5,	12, 0,10,	11,12,10,
    18,11,10
  };

  int Nv = sizeof(vertices)/sizeof(*vertices)/3;

  m.vertex(vertices, Nv);
  m.index(indices, sizeof(indices)/sizeof(*indices), m.vertices().size()-Nv);

  return Nv;
}


// Stacks are circles cut perpendicular to the z axis while slices are circles 
// cut through the z axis.
// The top is (0,0,radius) and the bottom is (0,0,-radius).

int addSphere(MeshData& m, double radius, int slices, int stacks){

  vec3 N, V;

  struct CSin{
    CSin(double frq, double radius=1.)
      :	r(radius), i(0.), dr(cos(frq)), di(sin(frq)){}
    void operator()(){
      double r_ = r*dr - i*di;
      i = r*di + i*dr;
      r = r_;
    }
    double r,i,dr,di;
  };

  int Nv = m.vertices().size();

  CSin P( M_PI/stacks); P.r = P.dr*radius; P.i = P.di*radius;
  CSin T((M_PI*2.0)/slices);

  // Add top cap
  // Triangles have one vertex at the north pole and the others on the first
  // ring down.
  V = vec3(0,0,radius);
  //N = vec3(0,0,radius).normalize();
  N = glm::normalize(vec3(0,0,radius));
  m.vertex(V);
  m.normal(N);
  for(int i=0; i<slices; ++i){
    m.index(Nv+1 + i);
    m.index(Nv+1 + ((i+1)%slices));
    m.index(Nv);	// the north pole	
  }

  // Add rings
  for(int j=0; j<stacks-2; ++j){
    int jp1 = j+1;

    for(int i=0; i<slices; ++i){
      int ip1 = (i+1)%slices;

      int i00 = Nv+1 + j  *slices + i;
      int i10 = Nv+1 + j  *slices + ip1;
      int i01 = Nv+1 + jp1*slices + i;
      int i11 = Nv+1 + jp1*slices + ip1;
  V = vec3(T.r*P.i, T.i*P.i, P.r);
  //N = vec3(T.r*P.i, T.i*P.i, P.r).normalize();
  N = glm::normalize(vec3(T.r*P.i, T.i*P.i, P.r));

      //m.vertex(T.r*P.i, T.i*P.i, P.r);
      m.vertex(V);
      m.normal(N);
      m.index(i00);
      m.index(i01);
      m.index(i10);
      m.index(i10);
      m.index(i01);
      m.index(i11);
      T();
    }
    P();
  }

  // Add bottom ring and cap
  int icap = m.vertices().size() + slices;
  for(int i=0; i<slices; ++i){
  V = vec3(T.r*P.i, T.i*P.i, P.r);
  //N = vec3(T.r*P.i, T.i*P.i, P.r).normalize();
  N = glm::normalize(vec3(T.r*P.i, T.i*P.i, P.r));
      m.vertex(V);
      m.normal(N);
  //  m.vertex(T.r*P.i, T.i*P.i, P.r);
    m.index(icap - slices + ((i+1)%slices));
    m.index(icap - slices + i);
    m.index(icap);
    T();
  }
  //m.vertex(0,0,-radius);
  V = vec3(0,0,-radius);
  //N = vec3(0,0,-radius).normalize();
  N = glm::normalize(vec3(0,0,-radius));
  m.vertex(V);
  m.normal(N);

  return m.vertices().size()-Nv;
}


int addWireBox(MeshData& m, float w, float h, float d){

  int Nv = m.vertices().size();

  /*		6 7
		4 5
		2 3
		0 1			*/

  for(int k=-1; k<=1; k+=2){
    for(int j=-1; j<=1; j+=2){
      for(int i=-1; i<=1; i+=2){
	m.vertex(i*w, j*h, k*d);
      }}}

  static const int I[] = {
    0,1, 2,3, 4,5, 6,7,
    0,2, 1,3, 4,6, 5,7,
    0,4, 1,5, 2,6, 3,7
  };

  m.index(I, sizeof(I)/sizeof(*I), Nv);
  return m.vertices().size() - Nv;
}


int addSurface(MeshData& m, int Nx, int Ny, float width, float height){
  int Nv = m.vertices().size();

  for(int j=0; j<Ny; ++j){ float y=(float(j)/(Ny-1) - 0.5f) * height;
    for(int i=0; i<Nx; ++i){ float x=(float(i)/(Nx-1) - 0.5f) * width;
      m.vertex(x, y);
    }}

    // Note: the start and end points of each row are duplicated to create
    // degenerate triangles.
    for(int j=0; j<Ny-1; ++j){
      m.index(j*Nx + Nv);
      for(int i=0; i<Nx; ++i){
	int idx = j*Nx + i + Nv;
	m.index(idx);
	m.index(idx+Nx);
      }
      //int idx = m.indices().last();
      int idx = m.indices().back();
      m.index(idx);
    }
    return Nx*Ny;
}


}
