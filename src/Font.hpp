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

      int glyphMesh(MeshData& m, float v_x0, float v_x1, float v_y0, float v_y1, float t_x0, float t_x1, float t_y0, float t_y1);

     void loadProgram(Program &p, const std::string& name);

      void drawText(Program &bp, float px, float py, float sw, float sh, float scaleFont);

    private:
       int getTextPixelWidth();
       void drawGlyph(MeshBuffer& mb);
       Texture makeTexture();
       int defaultAdvance = 20;

        void drawBackground(Program& p, MeshBuffer& mb);

      
  };



} // ::al

#endif
