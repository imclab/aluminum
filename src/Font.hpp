#ifndef INCLUDE_AL_FONT_AGF_HPP
#define INCLUDE_AL_FONT_AGF_HPP

#include <string>
#include <map>

//#include "Includes.hpp"
#include "Texture.hpp"
#include "Program.hpp"
#include "MeshData.hpp"
#include "MeshBuffer.hpp"


#include "allocore/math/al_Vec.hpp"
#include "allocore/math/al_Matrix4.hpp"

using namespace std;

namespace al{


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


    private:
     map<char, Glyph*> glyphs;
     static Glyph* makeGlyph(std::map<std::string, std::string>& props);   
      };


  class Text {
    public:

      Text();
      Text(Program& p, Font& f, const std::string& text);
      Text(Font& f, const std::string& text);
      Font font;
      string text;
      Texture texture;
      Program p;

      Vec4f txtColor; //= Vec4f(0.0,0.0,1.0,1.0);
      Vec4f bgColor; //= Vec4f(0.0,0.0,1.0,1.0);
	  
      GLint posLoc;
      GLint texCoordLoc;

      Text& justify(float _jx, float _jy);
      Text& color(Vec4f _txtColor);
      Text& background(Vec4f _bgColor);
   
      float justifyX;
      float justifyY;
     
      void loadProgram(Program &p, const std::string& name);

      void drawText(Program &bp, float px, float py, float sw, float sh, float scaleFont);

    private:
      int getTextPixelWidth();
      void justifyText(const float pen_x, const float pen_y, const float bw, const float bh, float &bx0, float &bx1, float &by0, float &by1); 

      void drawGlyph(MeshBuffer& mb);
      Texture makeTexture();
      int defaultAdvance = 20;

      bool getGlyphLocationInFontAtlas(const char c, Glyph* &glyph, const float pen_x, const float pen_y, const float scaleW, const float scaleH, float& x, float& y, float& w, float& h, float& s0, float& s1, float& t0,float& t1);


      void drawBackground(float bx0, float bx1, float by0, float by1, Program& p);
      void drawGlyph(Vec2f vLL, Vec2f vUR, Vec2f tLL, Vec2f tUR);

 
      //void drawBackground(Program& p, MeshBuffer& mb);

      MeshData mesh1;
      MeshBuffer mb1;


  };



} // ::al

#endif
