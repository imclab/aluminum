#include "Font.hpp"
#include "FBO.hpp"
#include "Shapes.hpp"

#include <stdio.h>
#include <string.h>
#include <map>
#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
#include <stdlib.h>

using std::map;
using std::string;

namespace al{

  Text::Text(){}

  Text::Text(Font& _f, const string& _text) {

    txtColor = Vec4f(0.0,0.0,0.0,1.0);
    bgColor = Vec4f(1.0,1.0,1.0,1.0);
    font = _f;
    text = _text;

    posLoc=0;
    texCoordLoc=1;
    loadProgram(p, "resources/font");

    justifyX=-1;
    justifyY=-1;

    mb1.init(mesh1, posLoc, -1, texCoordLoc, -1); 

    texture = makeTexture();
  }

  Text& Text::justify(float _jx, float _jy) {
    justifyX = _jx;
    justifyY = _jy;
    return *this;
  }

  Text& Text::color(Vec4f _txtColor) {
    txtColor = _txtColor;
    return *this;
  }

  Text& Text::background(Vec4f _backgroundColor) {
    bgColor = _backgroundColor;
    return *this;
  }



  Text::Text(Program& _p, Font& _f, const string& _text) {

    txtColor = Vec4f(1.0,1.0,1.0,1.0);
    //bgColor = Vec4f(1.0,1.0,1.0,0.5);
    bgColor = Vec4f(0.5,0.5,0.5,0.5);

    p = _p;
    font = _f;
    text = _text;
    posLoc=0;
    texCoordLoc=1;

    justifyX=-1;
    justifyY=-1;

    mb1.init(mesh1, posLoc, -1, texCoordLoc, -1); 

    texture = makeTexture(); //real, for FBO version
  }
  
  void Text::loadProgram(Program &p, const string& name) {
    p.create();
    p.attach(p.loadText(name + ".vsh"), GL_VERTEX_SHADER);
    glBindAttribLocation(p.id(), posLoc, "vertexPosition");
    glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");
    p.attach(p.loadText(name + ".fsh"), GL_FRAGMENT_SHADER);
    p.link();
  }

  int Text::getTextPixelWidth() {
    //loop through each char to get pixel width
    int tw = 0;
    Glyph* glyph;
    
    for( size_t i=0; i < text.length(); ++i) {
     if (font.getGlyphs().find(text[i]) == font.getGlyphs().end()) {
	tw += defaultAdvance; 
	continue;
      }
      glyph = font.getGlyphs()[text[i]];
      tw += glyph->xadvance;
    }

    return tw;
  }

  void Text::drawGlyph(Vec2f vLL, Vec2f vUR, Vec2f tLL, Vec2f tUR) {

    addRectangle(mesh1, vLL, vUR, tLL, tUR);
    mb1.update(mesh1, posLoc, -1, texCoordLoc, -1); 

    p.bind(); {

      glUniform1i(p.uniform("tex0"), 0);
      glUniform4fv(p.uniform("textColor"), 1, txtColor.ptr());
      font.texture.bind(GL_TEXTURE0); {
	mb1.draw();	
      } font.texture.unbind(GL_TEXTURE0);

    } p.unbind();

  }

  void Text::drawGlyph(MeshBuffer& mb) {
    p.bind(); {

      glUniform1i(p.uniform("tex0"), 0);
      glUniform4fv(p.uniform("textColor"), 1, txtColor.ptr());
      font.texture.bind(GL_TEXTURE0); {
	mb.draw();	
      } font.texture.unbind(GL_TEXTURE0);

    } p.unbind();
  }

  void Text::drawBackground(float bx0, float bx1, float by0, float by1, Program& p) {

    glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glEnable( GL_TEXTURE_2D );

    addRectangle(mesh1, Vec2f(bx0,by0), Vec2f(bx1,by1), Vec2f(0,0), Vec2f(1,1));
    mb1.update(mesh1, posLoc, -1, texCoordLoc, -1); 

    p.bind(); {
      glUniform4fv(p.uniform("bgColor"), 1, bgColor.ptr());
      mb1.draw();	
    } p.unbind();
  }

  bool Text::getGlyphLocationInFontAtlas(const char c, Glyph* &glyph, const float pen_x, const float pen_y, const float scaleW, const float scaleH, float& x, float& y, float& w, float& h, float& s0, float& s1, float& t0,float& t1) {

    if (font.getGlyphs().find(c) == font.getGlyphs().end()) {
      return false;
    }

    glyph = font.getGlyphs()[c];

    x = pen_x + ((glyph->xoff - font.padding/2) * scaleW);
    y = pen_y + ( (-font.base + glyph->yoff-glyph->h - font.padding/2) * scaleH); 
    w = ((glyph->w + font.padding) * (scaleW)); 
    h = ((glyph->h + font.padding) * (scaleH));

    s0 = glyph->s0;
    s1 = glyph->s1;
    t0 = (1.0 - glyph->t1);
    t1 = (1.0 - glyph->t0);

    return true; 
  }

  void Text::justifyText(const float pen_x, const float pen_y, const float bw, const float bh, float &bx0, float &bx1, float &by0, float &by1) {

    //justify x
    float jx = (-bw/2) -justifyX * 0.5 * bw;
    bx0 = pen_x + jx;
    bx1 = bx0 + bw;

    //justify y
    float jy = (-bh/2) -justifyY * 0.5 * bh;
    by0 = pen_y + jy;
    by1 = by0 + bh;
  }


  //draws text to screen, every frame
  void Text::drawText(Program& backgroundProgram, float pen_x, float pen_y, float sw, float sh, float scaleFont) {

    int th = font.lineHeight; 
    float scaleW = ( ((float)th/(float)sw) / (float)(th) ) * scaleFont;
    float scaleH = ( ((float)th/(float)sh) / (float)(th) ) * scaleFont;

    //TranslateYOffset = -(fontHeight - font.base) * (yScale*0.5);


    //calculate background extent
    float bw = (getTextPixelWidth() + font.padding) * scaleW;
    float bh = font.lineHeight * scaleH; //use font.highestChar for a tighter fit
    float bx0, bx1, by0, by1; 

    //justify 
    justifyText(pen_x, pen_y, bw, bh, bx0, bx1, by0, by1);

    //draw background...
    drawBackground(bx0, bx1, by0, by1, backgroundProgram);


    //draw glyphs...
    pen_x = bx0 + ((font.padding/2) * scaleW);
    pen_y = by0;

    float x, y, w, h, s0, s1, t0, t1;
    Glyph* glyph;

    for( size_t i=0; i < text.length(); ++i) {

      if (getGlyphLocationInFontAtlas(text[i], glyph, pen_x, pen_y, scaleW, scaleH, x,y,w,h,s0,s1,t0,t1)) {

	drawGlyph( Vec2f(x,y), Vec2f(x+w, y+h), Vec2f(s0,t0), Vec2f(s1,t1) );
	pen_x += (glyph->xadvance * scaleW); 

      } else {
	pen_x += defaultAdvance;       
      }

    }
  }

  //writes text into FBO
  Texture Text::makeTexture() {

    int th = font.lineHeight; //font.highestChar for a tighter fit
    int tw = getTextPixelWidth() + font.padding;

    FBO fbo;
    fbo.create(tw, th);

    //cout << "text rect: " << text << " has pixel dimensions of " << tw << "/" << th << "\n";

    //scale * 2 because drawing into the clip space of the fbo which is -1.0->+1.0, i.e. w & h both = 2.0
    float xScale = 1.0/(tw*0.5);  
    float yScale = 1.0/(th*0.5);

    //TranslateYOffset = -(fontHeight - font.base) * (yScale*0.5);

    float pen_x = font.padding/2, x, y, w, h, s0, s1, t0, t1;
    Glyph* glyph;

    fbo.bind(); {
      glEnable( GL_BLEND );
      glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
      glEnable( GL_TEXTURE_2D );
      glClearColor( bgColor.x, bgColor.y, bgColor.z, bgColor.w );
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      for( size_t i=0; i < text.length(); ++i) {

	if (font.getGlyphs().find(text[i]) == font.getGlyphs().end()) {
	  pen_x += defaultAdvance; 
	  continue;
	}

	glyph = font.getGlyphs()[text[i]];

	x = -1.0 + ((pen_x + glyph->xoff - font.padding/2) * xScale);
	y = -1.0 + ( (-font.base + glyph->yoff-glyph->h - font.padding/2) * yScale);
	w = ((glyph->w + font.padding) * (xScale*1.0)); 
	h = ((glyph->h + font.padding) * (yScale*1.0));

	s0 = glyph->s0 ;
	s1 = glyph->s1 ;
	t0 = 1.0 - glyph->t1;
	t1 = 1.0 - glyph->t0;

	addRectangle(mesh1, Vec2f(x,y), Vec2f(x+w, y+h), Vec2f(s0,t0), Vec2f(s1,t1));

	mb1.update(mesh1, posLoc, -1, texCoordLoc, -1); 

	drawGlyph(mb1);

	pen_x += glyph->xadvance; 
      }

    } fbo.unbind();

    return fbo.texture;
  }


  Glyph::Glyph(){}

  map<char, Glyph*>& Font::getGlyphs() {
    return glyphs;
  }

  void Glyph::dump(Glyph* g){
    cout << "glyph:'" << g->val << "' x:" << g->x << " y:" << g->y << " w: " << g->w << " h: " << g->h << " xoff:" << g->xoff << " yoff: " << g->yoff << " xadvance:" << g->xadvance << "\n"; 
    cout << "s0: " << g->s0 << " s1: " << g->s1 << " t0: " << g->t0 << " t1: " << g->t1 << "\n"; 
  }

  Font::Font(){}

  Font& Font::loadFont(Font& font, Texture& fontTexture, const string& _file) {
    //font.texture = Texture::loadTextureData2D(font.texture, _file + ".png");
    font.texture = fontTexture;

    font.highestChar = 0;

    ifstream file;
    file.open( (_file + ".fnt").c_str());

    if (!file) {
      cout << "in Font::Font : error, couldn't find file : " << _file << "\n";
      exit(0);
    }

    string line;
    while(getline(file, line)) {
      
      map<string, string> props;

      string token;
      istringstream tokens(line);
      while(tokens >> token) {
	size_t pos = token.find('=');
	if(pos != string::npos) {
	  props[token.substr(0, pos)] = token.substr(pos + 1);
	}
      }

      if (props["letter"].size() > 0) {
	Glyph* g = Font::makeGlyph(props);
	font.glyphs.insert(pair<char, Glyph*>(g->val, g));

	if (g->h > font.highestChar) {
	  font.highestChar = g->h;
	}
     }

      if (props["face"].size() > 0) {
	font.face = props["face"];
      }
      if (props["size"].size() > 0) {
	font.fontSize = atof(props["size"].c_str());
      }
      if (props["lineHeight"].size() > 0) {
	font.lineHeight = atoi(props["lineHeight"].c_str());
      }
      if (props["base"].size() > 0) {
	font.base = atoi(props["base"].c_str());
      }
      if (props["scaleW"].size() > 0) {
	font.tw = atoi(props["scaleW"].c_str());
      }
      if (props["scaleH"].size() > 0) {
	font.th = atoi(props["scaleH"].c_str());
      }
      if (props["padding"].size() > 0) {
	font.padding = atoi(props["padding"].c_str());
      }
    }

    //cout << "face: " << font.face << " fontSize: " << font.fontSize << " lineHeight: " << font.lineHeight << " base: " << font.base << " tw: " << font.tw << " th: " << font.th << "\n";

    return font;
  }

  Glyph* Font::makeGlyph(map<string, string>& props) {
    Glyph* g = new Glyph();
	g->val = (char) (atoi(props["id"].c_str()));
	g->x = atoi(props["x"].c_str());
	g->y = atoi(props["y"].c_str());
	g->w = atoi(props["width"].c_str());
	g->h = atoi(props["height"].c_str());
	g->xoff = atoi(props["xoffset"].c_str());
	g->yoff = atoi(props["yoffset"].c_str());
	g->xadvance = atoi(props["xadvance"].c_str());
	g->s0 = atof(props["s0"].c_str());
	g->s1 = atof(props["s1"].c_str());
	g->t0 = atof(props["t0"].c_str());
	g->t1 = atof(props["t1"].c_str());

	return g;
  }
} // al::


/*
 float twScale = 1.0/font.tw;
    float thScale = 1.0/font.th;


	//works with glyph designer
	y = -1.0 + (fontHeight * yScale) - ((glyph.h + glyph.yoff)*yScale); //  - glyph.yoff) * yScale);
	t1 = 1.0-(glyph.y * thScale);
	t0 = 1.0-(glyph.y * thScale) - (glyph.h * thScale);


	//  s0 = glyph->x * twScale;
	//  s1 = (glyph->x * twScale) + (glyph->w * twScale) ;
	//  t0 = 1.0-(glyph->y * thScale);
	//  t1 = 1.0-(glyph->y * thScale) + (glyph->h * thScale);

//printf("x/y/w/h = %f %f %f %f\n", x,y,w,h);
	//printf("s0/s1/t0/t1 = %f %f %f %f\n", s0, s1, t0, t1);
	


*/


