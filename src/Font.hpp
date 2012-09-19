#ifndef INCLUDE_AL_FONT_AGF_HPP
#define INCLUDE_AL_FONT_AGF_HPP

#include <string>
#include <map>

//#include "Includes.hpp"
#include "Texture.hpp"
#include "Program.hpp"
#include "MeshData.hpp"
#include "MeshBuffer.hpp"
#include "FBO.hpp"


#include "allocore/math/al_Vec.hpp"
#include "allocore/math/al_Matrix4.hpp"

using namespace std;


namespace al{

  
 class Text; //need this forward reference so that Font can call Text's constructors
 class TextBuffer;
 

  class Glyph {
    public:

      Glyph();

      char val;
      int x;
      int y;
      int w;
      int h;
      int xoff;
      int yoff;
      int xadvance;
      float s0, s1, t0, t1;

      static void dump(Glyph* g);

    private:


  };

  class Font {
    public:
      Texture texture;

      Font();
      static Font& loadFont(Font& font, Texture& texture, const std::string& _file);
      int tw;
      int th;
      int lineHeight;
      int base;
      int padding;
      float fontSize;
      std::string face;
      map<char, Glyph*>& getGlyphs();
      int highestChar;


      //make a texture/mesh object out of part of the signed font texture
      Text signedDistanceText(const string& _text);
      //make a texture/mesh object out of part of the font texture
      Text text(const string& _text);




    private:
      map<char, Glyph*> glyphs;
      static Glyph* makeGlyph(std::map<std::string, std::string>& props);   
  };


  class Text {
    public:

      Text();
      Text(Font& f, const std::string& text);
      Text(Font& f, const std::string& text, bool _useSignedDistance);
      //Text(Program& _p, Program& _bp, Font& _f, const string& _text);

      Font font;
      string text;
      Texture texture;
      Program p;
      Program bp;

      Vec4f txtColor; 
      Vec4f bgColor; 

      Text& program(Program& _p); //update texture
      Text& programs(Program& _p, Program& _bp); //update texture

      Text& justify(float _jx, float _jy); //update mesh
      Text& pen(float _px, float _py); //update mesh
      Text& color(Vec4f _txtColor); //update texture
      Text& background(Vec4f _bgColor); //update texture

      void drawText2(float px, float py, float sw, float sh, float scaleFont);
      void drawText(float px, float py, float sw, float sh, float scaleFont);
      //Text& meshFromWidth(float w); //update mesh
      Text& meshFromWidth(float w, int sw, int sh);
      //Text& meshFromHeight(float h); //update mesh
      Text& meshFromHeight(float h, int sw, int sh); //update mesh
      Text& mesh(int screenW, int screenH); //update mesh
      Text& mesh(int screenW, int screenH, float scaleVal); //update mesh

      MeshBuffer meshBuffer; 

    private:
      FBO fbo;
      Text& updateMesh();
      Text& updateTexture(); 
      Text& mesh(Vec2f LL, Vec2f UR); //update mesh
     

      float meshW, meshH; //the w+h of the mesh buffer holding the text, in world coords (clip coords for now) 
      int textureW, textureH; //the w+h of the texture used (for signed dist text, can be some scalar of pixelW/H
      int pixelW, pixelH; //the w+h of text taken from the font atlas
      void initDefaultVals();
      void initDefaultShaders(bool _useSD);

      int getTextPixelWidth();
      void justifyText(const float pen_x, const float pen_y, const float j_x, const float j_y, const float bw, const float bh, float &bx0, float &bx1, float &by0, float &by1); 

      //void drawGlyph(MeshBuffer& mb);
      Texture makeTexture();
      //void makeTexture2(FBO& fbo, float pen_x, float pen_y, float screenW, float screenH, float scaleFont);

      float penX, penY, justifyX, justifyY;


      GLint posLoc;
      GLint texCoordLoc;

      int defaultAdvance = 20;

      bool getGlyphLocationInFontAtlas(const char c, Glyph* &glyph, const float pen_x, const float pen_y, const float scaleW, const float scaleH, float& x, float& y, float& w, float& h, float& s0, float& s1, float& t0,float& t1);


      void drawBackground(float bx0, float bx1, float by0, float by1);
      void drawGlyph(Vec2f vLL, Vec2f vUR, Vec2f tLL, Vec2f tUR);


      //void drawBackground(Program& p, MeshBuffer& mb);

      MeshData mesh1;
      MeshBuffer mb1;


      string VSH_background = "#version 150\n"
	"in vec4 vertexPosition;\n" 
	"void main() {\n"
	"\tgl_Position = vertexPosition;\n"
	"}\n"; 

      string FSH_background = "#version 150\n"
	"uniform vec4 color;\n"
	"out vec4 outputFrag;\n"
	"void main(){\n"
	"\toutputFrag = color;\n"
	"}\n";

      string VSH_font = "#version 150\n"
	"in vec4 vertexPosition;\n" 
	"in vec4 vertexTexCoord;\n"
	"out vec2 texCoord;\n"
	"void main() {\n"
	"\ttexCoord = vertexTexCoord.xy;\n"
	"\tgl_Position = vertexPosition;\n"
	"}\n"; 

      string FSH_textureFont = "#version 150\n"
	"uniform vec4 textColor;\n"
	"uniform sampler2D tex0;\n"
	"in vec2 texCoord;\n"
	"out vec4 outputFrag;\n"
	"void main(){\n"
	"\tfloat a = texture(tex0, texCoord).r;\n"
	"\toutputFrag = vec4(a) * textColor;\n"
	"}\n";

      string FSH_signedDistanceFont = "#version 150\n"
	"uniform vec4 textColor;\n"
    "uniform sampler2D tex0;\n"
    "in vec2 texCoord;\n"
    "out vec4 outputFrag;\n"
    "void main(){\n"
    "\tfloat dist = texture(tex0, texCoord).r;\n"
    "\tfloat width = fwidth(dist);\n"
    "\tfloat a = smoothstep(0.5-width, 0.5+width, dist);\n"
    "\toutputFrag = vec4(textColor.rgb, a);\n"
    "}\n";



  };

  /*
  //put justify, pen, etc, in here... multiple meshes possible for a single TextTexture obj - or is this overkill???
  class TextBuffer : public MeshBuffer {
    public:
      TextBuffer();
 
      MeshBuffer mb;
      float w, h;
    

  };
  */	



} // ::al

#endif
