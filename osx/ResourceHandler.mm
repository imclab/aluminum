//
//  ResourceHandler.mm
//  aluminum
//
//  Created by Angus Forbes on 8/5/13.
//  Copyright (c) 2013 Angus Forbes. All rights reserved.
//

#include "ResourceHandler.h"
using std::cout;

ResourceHandler::ResourceHandler() {}


const char* ResourceHandler::contentsOfFile(string& file) {
    NSString* filePath = [[NSString alloc] initWithUTF8String:file.c_str()];
    NSString* contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [contents UTF8String];
}


string ResourceHandler::pathToResource(const string& resource, const string& type) {
    
    NSString* resourcePath = [[NSString alloc] initWithUTF8String:resource.c_str()];
    NSString* typePath = [[NSString alloc] initWithUTF8String:type.c_str()];
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* fullPath = [mainBundle pathForResource:resourcePath ofType:typePath];
    
    cout << "in GetPathForResourceOfType(...), pathStr = " << [fullPath UTF8String] << "\n";
    return [fullPath UTF8String];
}


void ResourceHandler::loadTexture(Texture& t, const std::string& name) {
    
    NSString* basePath = [[NSString alloc] initWithUTF8String:name.c_str()];
    NSArray* splits = [basePath componentsSeparatedByString: @"."];
    
    NSString* fileStr = [splits objectAtIndex:0];
    NSString* typeStr = [splits objectAtIndex:1];
    
    NSString* pathname = [[NSBundle mainBundle] pathForResource:fileStr ofType:typeStr];
    NSLog(@"Loading texture: %@.%@\n", fileStr, typeStr);
    
    NSLog(@"loading in texture from path: %@\n", pathname);
    NSData *texData = [[NSData alloc] initWithContentsOfFile:pathname];
    NSImage *nsimage = [[NSImage alloc] initWithData:texData];
    
    NSBitmapImageRep *imageClass = [[NSBitmapImageRep alloc] initWithData:[nsimage TIFFRepresentation]];
    [nsimage release];
    
    CGImageRef cgImage = imageClass.CGImage;
    
    int _w = (int)CGImageGetWidth(cgImage);
    int _h = (int)CGImageGetHeight(cgImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    GLubyte* data = (GLubyte*)malloc( _w * _h * 4 );
    
    CGContextRef context = CGBitmapContextCreate(data, _w, _h, 8, _w * 4, colorSpace, kCGImageAlphaNoneSkipLast);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    bool flipVertical = true;
    if(flipVertical) {
        CGContextTranslateCTM(context, 0.0, _h);
        CGContextScaleCTM(context, 1.0, -1.0);
    }
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, _w, _h), cgImage);
    CGContextRelease(context);
    
    [texData release];
    
    t = aluminum::Texture(data, _w, _h, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
    
    // return new Texture(data, _w, _h, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
}


//void ResourceHandler::checkForNewFrame(Texture &t) { }



/*
GLubyte* ResourceHandler::texture2D(const string &fname) {
    
    NSString* basePath = [[NSString alloc] initWithUTF8String:fname.c_str()];
    NSArray* splits = [basePath componentsSeparatedByString: @"."];
    
    NSString* fileStr = [splits objectAtIndex:0];
    NSString* typeStr = [splits objectAtIndex:1];
    
    NSString* pathname = [[NSBundle mainBundle] pathForResource:fileStr ofType:typeStr];
    NSLog(@"Loading texture: %@.%@\n", fileStr, typeStr);
    
    NSLog(@"loading in texture from path: %@\n", pathname);
    NSData *texData = [[NSData alloc] initWithContentsOfFile:pathname];
    NSImage *nsimage = [[NSImage alloc] initWithData:texData];
    
    NSBitmapImageRep *imageClass = [[NSBitmapImageRep alloc] initWithData:[nsimage TIFFRepresentation]];
	[nsimage release];
    
    CGImageRef cgImage = imageClass.CGImage;
    
    int _w = (int)CGImageGetWidth(cgImage);
    int _h = (int)CGImageGetHeight(cgImage);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    GLubyte* data = (GLubyte*)malloc( _w * _h * 4 );
    
    CGContextRef context = CGBitmapContextCreate(data, _w, _h, 8, _w * 4, colorSpace, kCGImageAlphaNoneSkipLast);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
    //  if(flipVertical)
    // {
    // CGContextTranslateCTM(context, 0.0, _h);
    // CGContextScaleCTM(context, 1.0, -1.0);
    // }
 
    
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, _w, _h), cgImage);
	CGContextRelease(context);
	
    [texData release];
    // return new Texture(data, _w, _h, GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE);
    
    return data;
}

*/