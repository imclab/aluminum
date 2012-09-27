#ifndef INCLUDE_ALU_FONT_HPP
#define INCLUDE_ALU_FONT_HPP

#include <string>
#include <map>

#include "Texture.hpp"
#include "Program.hpp"
#include "MeshData.hpp"
#include "MeshBuffer.hpp"
#include "FBO.hpp"

#include <glm/glm.hpp>
#include <glm/gtx/string_cast.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_access.hpp>
#include <glm/gtc/type_ptr.hpp>


using namespace std;
using glm::vec2;
using glm::ivec4;
using glm::mat4;

namespace aluminum {


  class Text3D;
  class Text2D; //need this forward reference so that Font can call Text's constructors
  class Text; //need this forward reference so that Font can call Text's constructors 

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
      //static Font& loadFont(Texture& texture, const std::string& _file);
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
      Text2D signedDistanceText2D(const string& _text);
      Text3D signedDistanceText3D(const string& _text);

      //make a texture/mesh object out of part of the font texture
      Text2D text2D(const string& _text);
      Text3D text3D(const string& _text);




    private:
      map<char, Glyph*> glyphs;
      static Glyph* makeGlyph(std::map<std::string, std::string>& props);   
  };

  class Text {
    public:

    
      Font font;
      
      vec4 txtColor; 
      vec4 bgColor; 

      Text& program(Program& _p); //update texture
      Text& programs(Program& _p, Program& _bp); //update texture

      //Text& justify(float _jx, float _jy); //update mesh
      //Text& pen(float _px, float _py); //update mesh
      Text& color(vec4 _txtColor); //update texture
      Text& background(vec4 _bgColor); //update texture

      //can grab this data if you want to use it for non-standard things
      MeshBuffer& getMeshBuffer();
      Texture& getTexture();
      string& getText();
 
      //draw the FBO texture
      void draw(mat4 M, mat4 V, mat4 P);
      void draw(mat4 MV, mat4 P);
      void draw();

      //void drawText(float px, float py, float sw, float sh, float scaleFont);

     
      float meshW, meshH; //the w+h of the mesh buffer holding the text, in world coords (clip coords for now) 
      GLint textureW, textureH; //the w+h of the texture used (for signed dist text, can be some scalar of pixelW/H
      int pixelW, pixelH; //the w+h of text taken from the font atlas

    protected: 
      Text();
      Text(Font& f, const std::string& text);
      Text(Font& f, const std::string& text, bool _useSignedDistance);

      Text& updateTexture(); 
      int getTextPixelWidth();
      Text& mesh(vec2 LL, vec2 UR); //update mesh

      Text& updateText(string _text);


      void drawTextIntoFBO();

      string m_text;

      Program p;
      Program bp;
      Program tp;

      FBO fbo;
      MeshBuffer meshBuffer;
      Texture texture;
     
      void initDefaultVals();
      void initDefaultShaders(bool _useSD);

      //void drawGlyph(MeshBuffer& mb);
      //Texture makeTexture();
      //void makeTexture2(FBO& fbo, float pen_x, float pen_y, float screenW, float screenH, float scaleFont);

      GLint posLoc;
      GLint texCoordLoc;

      int defaultAdvance = 20; //maybe should be able to set this?

      bool getGlyphLocationInFontAtlas(const char c, Glyph* &glyph, const float pen_x, const float pen_y, const float scaleW, const float scaleH, float& x, float& y, float& w, float& h, float& s0, float& s1, float& t0,float& t1);

      void drawBackground(float bx0, float bx1, float by0, float by1);
      void drawGlyph(vec2 vLL, vec2 vUR, vec2 tLL, vec2 tUR);

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

      string VSH_singleTexture = "#version 150\n"
	"uniform mat4 proj;\n"
	"uniform mat4 modelview;\n"
	//"uniform mat4 model;\n"
	"in vec4 vertexPosition;\n"
	"in vec4 vertexTexCoord;\n"
	"out vec2 texCoord;\n"
	"void main() {\n"
	"\ttexCoord = vertexTexCoord.xy;\n"
	"\tgl_Position = proj * modelview * vertexPosition;\n"
	"}\n"; 

      string FSH_singleTexture = "#version 150\n"
	"uniform sampler2D tex0;\n"
	"in vec2 texCoord;\n"
	"out vec4 outputFrag;\n"
	"void main(){\n"
	"\toutputFrag = texture(tex0, texCoord);\n"
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


  class Text3D : public Text {
    public:
      Text3D();
      Text3D(Font& f, const std::string& text);
      Text3D(Font& f, const std::string& text, bool _useSignedDistance);
      Text3D& meshFromWidth(float w, mat4 M, mat4 V, mat4 P, ivec4 VP);
      Text3D& meshFromHeight(float h, mat4 M, mat4 V, mat4 P, ivec4 VP);
      Text3D& meshBox(float w, float h, mat4 M, mat4 V, mat4 P, ivec4 VP);
    protected:
       void initDefaultVals3D();
       void mesh3D(mat4 M, mat4 V, mat4 P, ivec4 VP);

  };


  class Text2D : public Text {
    public:
      Text2D();
      Text2D(Font& f, const std::string& text);
      Text2D(Font& f, const std::string& text, bool _useSignedDistance);
      
      //set font size based on width or height (can be fuzzy if using a texture font atlas)
      Text2D& meshFromWidth(float w, int sw, int sh);
      Text2D& meshFromHeight(float h, int sw, int sh);
      Text2D& meshBox(float w, float h, int sw, int sh);

      //for setting the font exactly to its proper size (not as important when using signed distance font atlas)
      Text2D& mesh(int screenW, int screenH);
      Text2D& mesh(int screenW, int screenH, float scaleVal);

      void drawText2D(float sw, float sh, float scaleFont);

      
      Text2D& justify(float jx, float jy);
      Text2D& pen(float _px, float _py);

      Text2D& text(string _text);
      Text2D& text(string _text, int sw, int sh);
  




    protected:
      float penX, penY, justifyX, justifyY;

      void justifyText(const float pen_x, const float pen_y, const float j_x, const float j_y, const float bw, const float bh, float &bx0, float &bx1, float &by0, float &by1); 

      void mesh2D(int sw, int sh);
      Text2D& updateMesh();
      void initDefaultVals2D();



  };


} // ::al

#endif
