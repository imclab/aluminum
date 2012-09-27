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
using glm::ivec4;
using glm::mat4;

namespace aluminum {

  int MAX_FBO_SIZE = 1024;
 
  /* Font factory methods to build either a Text2D or a Text3D */
  
  Text2D Font::signedDistanceText2D(const string& _text) {
    return Text2D::Text2D(*this, _text, true);
  }

  Text3D Font::signedDistanceText3D(const string& _text) {
    return Text3D::Text3D(*this, _text, true);
  }

  Text2D Font::text2D(const string& _text) {
    return Text2D::Text2D(*this, _text, false);
  }

  Text3D Font::text3D(const string& _text) {
    return Text3D::Text3D(*this, _text, false);
  }

  /* Text3D */
  
  Text3D::Text3D() : Text() {initDefaultVals3D();}
  Text3D::Text3D(Font& f, const std::string& text) : Text(f, text) {initDefaultVals3D();}
  Text3D::Text3D(Font& _f, const string& _text, bool _useSignedDistance) : Text(_f, _text, _useSignedDistance) {initDefaultVals3D();}

  void Text3D::initDefaultVals3D() {
  }

  void Text3D::mesh3D(mat4 M, mat4 V, mat4 P, ivec4 VP) {

    //center...
    vec4 p0 = V * M * vec4(0, 0, 0, 1);    
    vec4 p1 = V * M * vec4(meshW, meshH, 0, 1);    
    float z = (p0.z + p1.z) / 2.0;
    
    //cout << "p0 : " << glm::to_string(p0) << "\n";
    //cout << "p1 : " << glm::to_string(p1) << "\n";
    //cout << "z: " << z << " \n";

    vec3 sLL = glm::project(vec3(-meshW/2.0, -meshH/2.0, z), mat4(), P, VP);
    vec3 sUR = glm::project(vec3(meshW/2.0, meshH/2.0, z), mat4(), P, VP);
    textureW = (sUR.x - sLL.x);
    textureH = (sUR.y - sLL.y);

    //printf("in meshFromWidth PROJECT : texture W/H = %d/%d\n", textureW, textureH);

    mesh(vec2(0,0), vec2(meshW, meshH));
    updateTexture();
  }

  
  Text3D& Text3D::meshFromWidth(float w, mat4 M, mat4 V, mat4 P, ivec4 VP) {
    meshW = w;
    meshH = w * ((float)pixelH/(float)pixelW);

    mesh3D(M, V, P, VP);
    return *this;
  }

  Text3D& Text3D::meshFromHeight(float h, mat4 M, mat4 V, mat4 P, ivec4 VP) {
    meshH = h;
    meshW = h * ((float)pixelW/(float)pixelH);
    mesh3D(M, V, P, VP);
    return *this;
  }

  Text3D& Text3D::meshBox(float w, float h, mat4 M, mat4 V, mat4 P, ivec4 VP) {
    meshW = w;
    meshH = h;
    mesh3D(M, V, P, VP);
    return *this;
  }
 
 

  Text2D::Text2D() : Text() {initDefaultVals2D();}
  Text2D::Text2D(Font& f, const std::string& text) : Text(f, text) {initDefaultVals2D();}
  Text2D::Text2D(Font& _f, const string& _text, bool _useSignedDistance) : Text(_f, _text, _useSignedDistance) {initDefaultVals2D();}

  void Text2D::initDefaultVals2D() {
    penX = 0;
    penY = 0;

    justifyX=-1;
    justifyY=-1;
  }

  void Text2D::mesh2D(int sw, int sh) {
    //assuming -1->+1 for screen //in reality use glProject method
    textureW = sw * (meshW * 0.5);
    textureH = sh * (meshH * 0.5);
  }

  Text2D& Text2D::meshFromWidth(float w, int sw, int sh) {
    float scaleW = ( ((float)font.lineHeight/(float)sw) / (float)(font.lineHeight) ) ;
    float scaleH = ( ((float)font.lineHeight/(float)sh) / (float)(font.lineHeight) ) ;

    float ar = scaleH/scaleW;

    meshW = w;
    meshH = w * ((float)pixelH/(float)pixelW) * ar;
    
    mesh2D(sw, sh);
    return updateMesh();
  }

  Text2D& Text2D::meshFromHeight(float h, int sw, int sh) {
    float scaleW = ( ((float)font.lineHeight/(float)sw) / (float)(font.lineHeight) ) ;
    float scaleH = ( ((float)font.lineHeight/(float)sh) / (float)(font.lineHeight) ) ;

    float ar = scaleW/scaleH;
    
    meshW = h * ((float)pixelW/(float)pixelH) * ar;
    meshH = h;
   
    mesh2D(sw, sh);
    return updateMesh();
  }

  Text2D& Text2D::meshBox(float w, float h, int sw, int sh) {
    meshW = w;
    meshH = h;
    mesh2D(sw, sh);
    return updateMesh();
  }


   //set mesh to the exact size of the font - probably most common to use 
  Text2D&  Text2D::mesh(int sw, int sh) {
   return mesh(sw, sh, 1.0);
  }

  Text2D&  Text2D::mesh(int sw, int sh, float scaleFont) {
    float scaleW = ( ((float)font.lineHeight/(float)sw) / (float)(font.lineHeight) ) * (1.0 * scaleFont);
    float scaleH = ( ((float)font.lineHeight/(float)sh) / (float)(font.lineHeight) ) * (1.0 * scaleFont);
    meshW = (getTextPixelWidth() + font.padding) * scaleW;
    meshH = font.lineHeight * scaleH; //use font.highestChar for a tighter fit
    textureW = (int) (pixelW * scaleFont * 0.5);
    textureH = (int) (pixelH * scaleFont * 0.5);
    printf(".....................textureW/H = %d/%d\n", textureW, textureH);
    return updateMesh();
  }

  Text2D& Text2D::text(string _text) {
    updateText(_text);
    return *this; //you will need to call one of the mesh functions!
  }

  Text2D& Text2D::text(string _text, int sw, int sh) {
    updateText(_text);
    return meshFromHeight(meshH, sw, sh);
  }
 
  Text2D& Text2D::justify(float _jx, float _jy) {
    justifyX = _jx;
    justifyY = _jy;
    updateMesh();
    return *this;
  }
  
  Text2D& Text2D::pen(float _jx, float _jy) {
    penX = _jx;
    penY = _jy;
    updateMesh();
    return *this;
  }


  Text2D& Text2D::updateMesh() {
    float bx0, bx1, by0, by1; 
    justifyText(penX, penY, justifyX, justifyY, meshW, meshH, bx0, bx1, by0, by1);
    //printf( "bx0/by0, bx1/by1 = %f/%f, %f,%f \n", bx0, by0, bx1, by1);
    Text::mesh(vec2(bx0,by0), vec2(bx1,by1));
    updateTexture();
    return *this;
  }


  void Text2D::justifyText(const float pen_x, const float pen_y, const float j_x, const float j_y, const float bw, const float bh, float &bx0, float &bx1, float &by0, float &by1) {

    //justify x
    float jx = (-bw/2) -j_x * 0.5 * bw;
    bx0 = pen_x + jx;
    bx1 = bx0 + bw;

    //justify y
    float jy = (-bh/2) -j_y * 0.5 * bh;
    by0 = pen_y + jy;
    by1 = by0 + bh;
  }


  //draws text directly to screen - no fbo  -- do we want this?
  void Text2D::drawText2D(float screenW, float screenH, float scaleFont) {

    float scaleW = ( ((float)font.lineHeight/(float)screenW) / (float)(font.lineHeight) ) * scaleFont;
    float scaleH = ( ((float)font.lineHeight/(float)screenH) / (float)(font.lineHeight) ) * scaleFont;
  //  printf("scaleW , scaleH = %f %f\n", scaleW , scaleH );

    //TranslateYOffset = -(fontHeight - font.base) * (yScale*0.5);

    //calculate background extent
    float bw = (getTextPixelWidth() + font.padding) * scaleW;
    float bh = font.lineHeight * scaleH; //use font.highestChar for a tighter fit
    
    float bx0, bx1, by0, by1; 
    justifyText(penX, penY, justifyX, justifyY, bw, bh, bx0, bx1, by0, by1);

    //draw background...
    drawBackground(bx0, bx1, by0, by1);

    //draw glyphs...
    float pen_x = bx0 + ((font.padding/2) * scaleW);
    float pen_y = by0;

    //float x, y, w, h, s0, s1, t0, t1;
    float x0, x1, y0, y1, s0, s1, t0, t1;
    Glyph* glyph;

    for( size_t i=0; i < m_text.length(); ++i) {

       if (getGlyphLocationInFontAtlas(m_text[i], glyph, pen_x, pen_y, scaleW, scaleH, x0, x1, y0, y1,s0,s1,t0,t1)) {

	drawGlyph( vec2(x0,y0), vec2(x1, y1), vec2(s0,t0), vec2(s1,t1) );
	pen_x += glyph->xadvance * scaleW; 

      } else {
	pen_x += defaultAdvance * scaleW;
      }

    }
  }


  Text::Text(){}
  Text::Text(Font& _f, const string& _text, bool _useSignedDistance) {

    font = _f;
    m_text = _text;

    initDefaultVals();
    initDefaultShaders(_useSignedDistance);
 
    fbo.create(1,1); //textureW, textureH);

    mesh(vec2(0,0), vec2(meshW, meshH));
    updateTexture();
  }
 
  //grab the mesh buffer if you want to do something with it manually
  MeshBuffer& Text::getMeshBuffer() {
    return meshBuffer;
  }

  //grab the fbo texture if you want to do something with it manually
  Texture& Text::getTexture() {
    return texture;
  }


  //grab the text
  string& Text::getText() { 
    return m_text; 
  }
 

  void Text::draw() {
    draw(mat4(),mat4());
  }
  
  void Text::draw(mat4 M, mat4 V, mat4 P) {
    draw(V*M, P);
  }
     
  void Text::draw(mat4 MV, mat4 P) {
    
    tp.bind(); {
	glUniformMatrix4fv(tp.uniform("modelview"), 1, 0, ptr(MV));
	glUniformMatrix4fv(tp.uniform("proj"), 1, 0, ptr(P));

	glUniform1i(tp.uniform("tex0"), 0);

	texture.bind(GL_TEXTURE0); {
	  meshBuffer.draw();	
	} texture.unbind(GL_TEXTURE0);

      } tp.unbind();
    }


  Text& Text::updateTexture() {

    if (textureW >= MAX_FBO_SIZE) {
      float ar = (float) textureH / (float) textureW;
      textureW = MAX_FBO_SIZE;
      textureH = max((int)(textureW * ar), 1);
    } 

    if (textureH >= MAX_FBO_SIZE) {
      float ar = (float) textureW / (float) textureH;
      textureH = MAX_FBO_SIZE;
      textureW = max((int)(textureH * ar),1 );
     } 

    if (fbo.width != textureW || fbo.height != textureH) {
      texture = Texture(textureW, textureH, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
      fbo.replace(texture, RBO(textureW, textureH, GL_DEPTH_COMPONENT24));
    }
   
    fbo.bind(); {
      drawTextIntoFBO();
    } fbo.unbind(); 
    
    return *this;
  }

  Text::Text(Font& _f, const string& _text) {
    Text(_f, _text, false);
  }

  void Text::initDefaultShaders(bool _useSD) {

    //draw fbo texture to screen
    tp.create();
    tp.attach(VSH_singleTexture, GL_VERTEX_SHADER);
    glBindAttribLocation(tp.id(), posLoc, "vertexPosition");
    glBindAttribLocation(tp.id(), texCoordLoc, "vertexTexCoord");
    tp.attach(FSH_singleTexture, GL_FRAGMENT_SHADER);
    tp.link();

    //draw background to fbo
    bp.create();
    bp.attach(VSH_background, GL_VERTEX_SHADER);
    glBindAttribLocation(bp.id(), posLoc, "vertexPosition");
    bp.attach(FSH_background, GL_FRAGMENT_SHADER);
    bp.link();

    //draw text from either signed distance atlas or texture atlas to fbo
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

  //will be required to reset mesh + texture by calling one of the mesh functions
  Text& Text::updateText(string _t) {
    m_text = _t;
    pixelW = getTextPixelWidth() + font.padding;
    pixelH = font.lineHeight;
    return *this;
  }

  //swtich to a custom glyph drawing program
  Text& Text::program(Program& _p) {
    p = _p;
    return updateTexture();
  }

  //switch to custom background and glyph drawing programs
  Text& Text::programs(Program& _p, Program& _bp) {
    p = _p;
    bp = _bp;
    return updateTexture();
  }

  //set the text color - for use with default shaders
  Text& Text::color(vec4 _txtColor) {
    txtColor = _txtColor;
    return updateTexture();
  }

  //set the background color - for use with default shaders
  Text& Text::background(vec4 _backgroundColor) {
    bgColor = _backgroundColor;
    return updateTexture();
  }


  //private method to used to calculate meshbuffer 
  Text& Text::mesh(vec2 LL, vec2 UR) {
    MeshData md;
    addRectangle(md, LL, UR, vec2(0,0), vec2(1,1));
    meshBuffer.init(md, posLoc, -1, texCoordLoc, -1); 
    return *this;
  }


  void Text::initDefaultVals() {

    txtColor = vec4(1.0,0.0,0.0,1.0);
    bgColor = vec4(1.0,1.0,1.0,1.0);

    posLoc=0;
    texCoordLoc=1;
    
    //the dimensons of the mesh buffer, in model coords, updated by all the "mesh" functions
    meshW = 1.0;
    meshH = 1.0;

    
    //pixel dimensions of the text from the actual font altas, only changes if text changes (or switching to a tighter fit... to do)
    pixelW = getTextPixelWidth() + font.padding;
    pixelH = font.lineHeight;
    //pixelH = font.highestChar;
    
    //texture dimensions of the fbo. can be different that the pixelW/H, especially when using signed distance text. Will change if the mesh changes size, moves, rotates. Basically we want to match the texture size to how many pixels the text is taking up.
    textureW = pixelW;
    textureH = pixelH;

    mb1.init(mesh1, posLoc, -1, texCoordLoc, -1); 
  }

  int Text::getTextPixelWidth() {
    //loop through each char to get pixel width
    int tw = 0;
    Glyph* glyph;

    for( size_t i=0; i < m_text.length(); ++i) {
      if (font.getGlyphs().find(m_text[i]) == font.getGlyphs().end()) {
	tw += defaultAdvance; 
	continue;
      }
      glyph = font.getGlyphs()[m_text[i]];
      tw += glyph->xadvance;
    }

    return tw;
  }

  //draw text into fbo
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

  //draw background into fbo
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

  //return (x0,y0)(x1,y1) clip coords of glyph in font atlas and (s0,t0),(s1,t1) tex coords 
  bool Text::getGlyphLocationInFontAtlas(const char c, Glyph* &glyph, const float pen_x, const float pen_y, const float scaleW, const float scaleH, float& x0, float& x1, float& y0, float& y1, float& s0, float& s1, float& t0, float& t1) {

    if (font.getGlyphs().find(c) == font.getGlyphs().end()) {
      //if we can't find the glyph, return false to indicate need to advance some default amount
      return false;
    }

    glyph = font.getGlyphs()[c];

    //LL clipcoord
    x0 = pen_x + ((glyph->xoff - font.padding/2) * scaleW);
    y0 = pen_y + ( (-font.base + glyph->yoff-glyph->h - font.padding/2) * scaleH); 
    //UR clipcoord
    x1 = x0 + ((glyph->w + font.padding) * (scaleW)); 
    y1 = y0 + ((glyph->h + font.padding) * (scaleH));

    //LL texcoord
    s0 = glyph->s0;
    t0 = (1.0 - glyph->t1);
    
    //UR texcoord
    s1 = glyph->s1;
    t1 = (1.0 - glyph->t0);

    return true; 
  }

  
  //draws text into FBO
  void Text::drawTextIntoFBO() {

    float scaleToTextureW = (float)textureW / (float)pixelW;
    float scaleToTextureH = (float)textureH / (float)pixelH;

    //scale from texture space to clip space
    float scaleToClipW = 1.0 / (textureW/2.0);
    float scaleToClipH = 1.0 / (textureH/2.0);

    float scaleW = scaleToTextureW * scaleToClipW;
    float scaleH = scaleToTextureH * scaleToClipH;

    //TranslateYOffset = -(fontHeight - font.base) * (yScale*0.5);
    float bx0, bx1, by0, by1; 

     bx0 = -1;
     bx1 = 1;
     by0 = -1;
     by1 = 1;

    //draw background...
    drawBackground(bx0, bx1, by0, by1);

    //draw glyphs...
    float pen_x = bx0 + ((font.padding/2) * scaleW);
    float pen_y = by0;

    //float x, y, w, h, s0, s1, t0, t1;
    float x0, y0, x1, y1, s0, s1, t0, t1;
    Glyph* glyph;

    for( size_t i=0; i < m_text.length(); ++i) {

      if (getGlyphLocationInFontAtlas(m_text[i], glyph, pen_x, pen_y, scaleW, scaleH, x0, x1, y0, y1,s0,s1,t0,t1)) {

	drawGlyph( vec2(x0,y0), vec2(x1, y1), vec2(s0,t0), vec2(s1,t1) );
	pen_x += glyph->xadvance * scaleW; 

      } else {
	pen_x += defaultAdvance * scaleW;
      }

    }
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
} 

