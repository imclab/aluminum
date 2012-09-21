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

using glm::to_string;
using glm::vec2;
using glm::vec3;
using glm::vec4;
using glm::mat4;

namespace al{

  Text Font::signedDistanceText(const string& _text) {
    return Text::Text(*this, _text, true);
  }

  Text Font::text(const string& _text) {
    return Text::Text(*this, _text, false);
  }

  Text::Text(){}
  Text::Text(Font& _f, const string& _text, bool _useSignedDistance) {

    font = _f;
    text = _text;

    initDefaultVals();
    initDefaultShaders(_useSignedDistance);
 
    fbo.create(1,1); //textureW, textureH);
 
    updateMesh();
    //updateTexture();
 }


  //hmm
  //if texturefont - when resizing don't need to make new texture because it won't make a difference, just scale current texture
  //if signed distance then need to make new texture of a larger/smaller size - else will get fuzzy
  //i guess the default is always resize, can't hurt
  Text& Text::updateTexture() {

  //  float tmp = 5;
  //  GLuint tw = tmp * getTextPixelWidth() + font.padding;
  //  GLuint th = tmp * font.lineHeight;
    
    if (fbo.width != textureW || fbo.height != textureH) {
      texture = Texture(textureW, textureH, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
      fbo.replace(texture, RBO(textureW, textureH, GL_DEPTH_COMPONENT24));
    }
   
    fbo.bind(); {
      drawText(-1, -1, fbo.width, fbo.height, 2.0); //*tmp?
    } fbo.unbind(); 
    
    return *this;
  }

  Text::Text(Font& _f, const string& _text) {
    Text(_f, _text, false);
  }

  void Text::initDefaultShaders(bool _useSD) {

    bp.create();
    bp.attach(VSH_background, GL_VERTEX_SHADER);
    glBindAttribLocation(bp.id(), posLoc, "vertexPosition");
    bp.attach(FSH_background, GL_FRAGMENT_SHADER);
    bp.link();

    p.create();
    p.attach(VSH_font, GL_VERTEX_SHADER);
    glBindAttribLocation(p.id(), posLoc, "vertexPosition");
    glBindAttribLocation(p.id(), texCoordLoc, "vertexTexCoord");
    
    if (_useSD) {
      p.attach(FSH_signedDistanceFont, GL_FRAGMENT_SHADER);
    } else {
      p.attach(FSH_textureFont, GL_FRAGMENT_SHADER);
    }

    p.link();
  }

  Text& Text::program(Program& _p) {
    p = _p;
    return updateTexture();
  }

  Text& Text::programs(Program& _p, Program& _bp) {
    p = _p;
    bp = _bp;
    return updateTexture();
  }

  /*
  //fbo version 2
  Text::Text(Program& _p, Program& _bp, Font& _f, const string& _text) {

    bp = _bp;
    p = _p;
    font = _f;
    text = _text;

    initDefaultVals();

    FBO fbo;
    int tw = getTextPixelWidth() + font.padding;
    fbo.create(tw, font.lineHeight);

    fbo.bind(); {
      drawText(-1, -1, fbo.width, fbo.height, 2.0);
      texture = fbo.texture;
    } fbo.unbind(); 

    //  texture = makeTexture(); //real, for FBO version
  }
  */

  Text& Text::mesh(vec2 LL, vec2 UR) {
    MeshData md;
    addRectangle(md, LL, UR, vec2(0,0), vec2(1,1));
    meshBuffer.init(md, posLoc, -1, texCoordLoc, -1); 
    return *this;
  }

  //set mesh to the exact size of the font 
  Text&  Text::mesh(int sw, int sh) {
   return mesh(sw, sh, 1.0);
  }

  //set mesh to the size of the font * a scalar -- really sjould use a glProject
  Text&  Text::mesh(int sw, int sh, float scaleFont) {
    float scaleW = ( ((float)font.lineHeight/(float)sw) / (float)(font.lineHeight) ) * (2.0 * scaleFont);
    float scaleH = ( ((float)font.lineHeight/(float)sh) / (float)(font.lineHeight) ) * (2.0 * scaleFont);
    meshW = (getTextPixelWidth() + font.padding) * scaleW;
    meshH = font.lineHeight * scaleH; //use font.highestChar for a tighter fit
    textureW = (int) (pixelW * scaleFont);
    textureH = (int) (pixelH * scaleFont);
    return updateMesh();
    
    //float bx0, bx1, by0, by1; 
    //justifyText(penX, penY, meshW, meshH, bx0, bx1, by0, by1);
    //mesh(vec2(bx0,by0), vec2(bx1,by1));
    //return *this;
  }

  //testing... really would use glProject to get pixel sizes...
  Text& Text::meshFromWidth(float w, int sw, int sh) {
    meshW = w * 1.0;
    meshH = w * ((float)pixelH/(float)pixelW) * 1.0;

    //assuming -1->+1 for screen //in reality use glProject method
    textureW = sw * (meshW * 0.5);
    textureH = sh * (meshH * 0.5);
  
    return updateMesh();
  }

  Text& Text::meshFromHeight(float h, int sw, int sh) {
    meshW = h * ((float)pixelW/(float)pixelH);
    meshH = h;

    //assuming -1->+1 for screen //in reality use glProject method
    textureW = sw * (meshW * 0.5);
    textureH = sh * (meshH * 0.5);
    return updateMesh();
  }


  /*
  Text& Text::meshFromWidth(float w) {
    meshW = w;
    meshH = w * ((float)pixelH/(float)pixelW);
    textureW = pixelW * 1;
    textureH = pixelH * 1;
    return updateMesh();
    //float bx0, bx1, by0, by1; 
    //justifyText(penX, penY, meshW, meshH, bx0, bx1, by0, by1);
    //mesh(vec2(bx0,by0), vec2(bx1,by1));
    //return *this;
  }

  Text& Text::meshFromHeight(float h) {
    meshW = h * ((float)texture.width/(float)texture.height);
    meshH = h;
    return updateMesh();
    //float bx0, bx1, by0, by1; 
    //justifyText(penX, penY, meshW, meshH, bx0, bx1, by0, by1);
    //mesh(vec2(bx0,by0), vec2(bx1,by1));
    //return *this;
  }
  */

  //private - called when justify or pen is changed
  Text& Text::updateMesh() {
    float bx0, bx1, by0, by1; 
    justifyText(penX, penY, justifyX, justifyY, meshW, meshH, bx0, bx1, by0, by1);
    printf( "bx0/by0, bx1/by1 = %f/%f, %f,%f \n", bx0, by1, bx1, by1);
    mesh(vec2(bx0,by0), vec2(bx1,by1));
    updateTexture();
    return *this;
  }

  void Text::initDefaultVals() {

    txtColor = vec4(1.0,0.0,0.0,1.0);
    bgColor = vec4(1.0,1.0,1.0,1.0);

    posLoc=0;
    texCoordLoc=1;

    penX = 0;
    penY = 0;

    justifyX=-1;
    justifyY=-1;
  
    meshW = 1.0;
    meshH = 1.0;
   
    pixelW = getTextPixelWidth() + font.padding;
    pixelH = font.lineHeight;

    textureW = pixelW;
    textureH = pixelH;

    mb1.init(mesh1, posLoc, -1, texCoordLoc, -1); 
  }

  Text& Text::justify(float _jx, float _jy) {
    justifyX = _jx;
    justifyY = _jy;
    updateMesh();
    return *this;
  }

  Text& Text::pen(float _jx, float _jy) {
    penX = _jx;
    penY = _jy;
    updateMesh();
    return *this;
  }

  Text& Text::color(vec4 _txtColor) {
    txtColor = _txtColor;
    return updateTexture();
  }

  Text& Text::background(vec4 _backgroundColor) {
    bgColor = _backgroundColor;
    return updateTexture();
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

  void Text::drawGlyph(vec2 vLL, vec2 vUR, vec2 tLL, vec2 tUR) {

    MeshData md;
    addRectangle(md, vLL, vUR, tLL, tUR);
    mb1.update(md, posLoc, -1, texCoordLoc, -1); 

    p.bind(); {

      glUniform1i(p.uniform("tex0"), 0);
      glUniform4fv(p.uniform("textColor"), 1, glm::value_ptr(txtColor));
      font.texture.bind(GL_TEXTURE0); {
	mb1.draw();	
      } font.texture.unbind(GL_TEXTURE0);

    } p.unbind();
  }

  /*
  void Text::drawGlyph(MeshBuffer& mb) {
    p.bind(); {

      glUniform1i(p.uniform("tex0"), 0);
      glUniform4fv(p.uniform("textColor"), 1, txtColor.ptr());
      font.texture.bind(GL_TEXTURE0); {
	mb.draw();	
      } font.texture.unbind(GL_TEXTURE0);

    } p.unbind();
  }
  */

  void Text::drawBackground(float bx0, float bx1, float by0, float by1) {

    glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glEnable( GL_TEXTURE_2D );
  
    MeshData md;
    addRectangle(md, vec2(bx0,by0), vec2(bx1,by1), vec2(0,0), vec2(1,1));
    mb1.update(md, posLoc, -1, texCoordLoc, -1); 

    bp.bind(); {
      glUniform4fv(bp.uniform("bgColor"), 1, glm::value_ptr(bgColor));
      mb1.draw();	
    } bp.unbind();
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

  void Text::justifyText(const float pen_x, const float pen_y, const float j_x, const float j_y, const float bw, const float bh, float &bx0, float &bx1, float &by0, float &by1) {

    //justify x
    float jx = (-bw/2) -j_x * 0.5 * bw;
    bx0 = pen_x + jx;
    bx1 = bx0 + bw;

    //justify y
    float jy = (-bh/2) -j_y * 0.5 * bh;
    by0 = pen_y + jy;
    by1 = by0 + bh;
  }

  
  //draws text to screen (or into an FBO) - not using screenW/H
  void Text::drawText(float pen_x, float pen_y, float screenW, float screenH, float scaleFont) {

    float scaleToTextureW = (float)textureW / (float)pixelW;
    float scaleToTextureH = (float)textureH / (float)pixelH;

    //scale from texture space to clip space
    float scaleToClipW = 1.0 / (textureW/2.0);
    float scaleToClipH = 1.0 / (textureH/2.0);

    float scaleW = scaleToTextureW * scaleToClipW;
    float scaleH = scaleToTextureH * scaleToClipH;


//    float scaleW = ( ((float)font.lineHeight/(float)screenW) / (float)(font.lineHeight) ) * scaleFont;
//    float scaleH = ( ((float)font.lineHeight/(float)screenH) / (float)(font.lineHeight) ) * scaleFont;
    printf("pixelW , pixelH = %d %d\n", pixelW , pixelH );
    printf("textureW , textureH = %d %d\n", textureW , textureH );
    printf("scaleW , scaleH = %f %f\n", scaleW , scaleH );
    printf("meshW, meshH = %f %f\n", meshW, meshH );


    //TranslateYOffset = -(fontHeight - font.base) * (yScale*0.5);

    //calculate background extent
  //  float bw = (getTextPixelWidth() + font.padding) * scaleW;
  //  float bh = font.lineHeight * scaleH; //use font.highestChar for a tighter fit
    float bx0, bx1, by0, by1; 

    //justify 
    //justifyText(pen_x, pen_y, justifyX, justifyY, bw, bh, bx0, bx1, by0, by1);  //real one
    //justifyText(-1,-1, -1,-1, bw, bh, bx0, bx1, by0, by1);

     bx0 = -1;
     bx1 = 1;
     by0 = -1;
     by1 = 1;

 //   printf("bx0/bx1/by0/by1 = %f/%f/%f/%f\n", bx0, bx1, by0, by1);
 //   printf("bw/bh = %f/%f\n", bw, bh);

    //draw background...
    drawBackground(bx0, bx1, by0, by1);

    //draw glyphs...
    pen_x = bx0 + ((font.padding/2) * scaleW);
    pen_y = by0;

    float x, y, w, h, s0, s1, t0, t1;
    Glyph* glyph;

    for( size_t i=0; i < text.length(); ++i) {

      if (getGlyphLocationInFontAtlas(text[i], glyph, pen_x, pen_y, scaleW, scaleH, x,y,w,h,s0,s1,t0,t1)) {

	drawGlyph( vec2(x,y), vec2(x+w, y+h), vec2(s0,t0), vec2(s1,t1) );
	pen_x += glyph->xadvance * scaleW; 

      } else {
	pen_x += defaultAdvance * scaleW;
      }

    }
  }

  //draws text to screen (or into an FBO)
  void Text::drawText2(float pen_x, float pen_y, float screenW, float screenH, float scaleFont) {

    float scaleW = ( ((float)font.lineHeight/(float)screenW) / (float)(font.lineHeight) ) * scaleFont;
    float scaleH = ( ((float)font.lineHeight/(float)screenH) / (float)(font.lineHeight) ) * scaleFont;
  //  printf("scaleW , scaleH = %f %f\n", scaleW , scaleH );


    //TranslateYOffset = -(fontHeight - font.base) * (yScale*0.5);

    //calculate background extent
    float bw = (getTextPixelWidth() + font.padding) * scaleW;
    float bh = font.lineHeight * scaleH; //use font.highestChar for a tighter fit
    float bx0, bx1, by0, by1; 

    //justify 
    //justifyText(pen_x, pen_y, justifyX, justifyY, bw, bh, bx0, bx1, by0, by1);  //real one
    justifyText(-1,-1, -1,-1, bw, bh, bx0, bx1, by0, by1);

    // bx0 = -1;
    // bx1 = 1;
    // by0 = -1;
    // by1 = 1;

 //   printf("bx0/bx1/by0/by1 = %f/%f/%f/%f\n", bx0, bx1, by0, by1);
 //   printf("bw/bh = %f/%f\n", bw, bh);

    //draw background...
    drawBackground(bx0, bx1, by0, by1);

    //draw glyphs...
    pen_x = bx0 + ((font.padding/2) * scaleW);
    pen_y = by0;

    float x, y, w, h, s0, s1, t0, t1;
    Glyph* glyph;

    for( size_t i=0; i < text.length(); ++i) {

      if (getGlyphLocationInFontAtlas(text[i], glyph, pen_x, pen_y, scaleW, scaleH, x,y,w,h,s0,s1,t0,t1)) {

	drawGlyph( vec2(x,y), vec2(x+w, y+h), vec2(s0,t0), vec2(s1,t1) );
	pen_x += glyph->xadvance * scaleW; 

      } else {
	pen_x += defaultAdvance * scaleW;
      }

    }
  }

  /*
  //writes text into FBO
  Texture Text::makeTexture() {

    int tw = getTextPixelWidth() + font.padding;

    FBO fbo;
    fbo.create(tw, font.lineHeight);

    //cout << "text rect: " << text << " has pixel dimensions of " << tw << "/" << th << "\n";

    //scale * 2 because drawing into the clip space of the fbo which is -1.0->+1.0, i.e. w & h both = 2.0
    float xScale = 1.0/(tw*0.5);  
    float yScale = 1.0/(font.lineHeight*0.5);  //font.highestChar for a tighter fit

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

//	printf("2 x/y x+w/y+h = %f/%f/%f/%f\n", x, y, x+w, y+h);
//	printf("s0/t0 s1/t1 = %f/%f/%f/%f\n", s0, t0, s1, t1);

	addRectangle(mesh1, vec2(x,y), vec2(x+w, y+h), vec2(s0,t0), vec2(s1,t1));

	mb1.update(mesh1, posLoc, -1, texCoordLoc, -1); 

	drawGlyph(mb1);

	pen_x += glyph->xadvance; 
      }

    } fbo.unbind();

    return fbo.texture;
  }
  */

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


