/*
 PRFilledPolygon.m
 
 PRKit:  Precognitive Research additions to Cocos2D.  http://cocos2d-iphone.org
 Contact us if you like it:  http://precognitiveresearch.com
 
 Created by Andy Sinesio on 6/25/10.
 Copyright 2011 Precognitive Research, LLC. All rights reserved.
 
 This class fills a polygon as described by an array of NSValue-encapsulated points with a texture.
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "PRFilledPolygon.h"
#import "PRRatcliffTriangulator.h"
#import "CCTexture_Private.h"
#import "CCNode_Private.h"

@interface PRFilledPolygon (privateMethods)

/**
 Recalculate the texture coordinates. Called when setTexture is called.
*/
-(void) calculateTextureCoordinates;

@end

@implementation PRFilledPolygon

@synthesize triangulator;


/**
 Returns an autoreleased polygon.  Default triangulator is used (Ratcliff's).
 */
+(id) filledPolygonWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture *) fillTexture {
    return [[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture];
}

/**
 Returns an autoreleased filled poly with a supplied triangulator.
 */
+(id) filledPolygonWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator {
    return [[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture usingTriangulator:polygonTriangulator];
}

-(id) initWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture *) fillTexture {
    return [self initWithPoints:polygonPoints andTexture:fillTexture usingTriangulator:[[PRRatcliffTriangulator alloc] init]];
}

-(id) initWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator {
    if( (self=[super init])) {
		
        self.triangulator = polygonTriangulator;
        
        [self setPoints:polygonPoints];
        self.texture = fillTexture;
        
        self.shader = [CCShader positionTextureColorShader];
    }
	
	return self;
}

-(void) setPoints: (NSArray *) points {
    if (areaTrianglePoints)
        free(areaTrianglePoints);
    if (textureCoordinates)
        free(textureCoordinates);
    
    NSArray *triangulatedPoints = [triangulator triangulateVertices:points];
    
    areaTrianglePointCount = (int)[triangulatedPoints count];
    areaTrianglePoints = (ccVertex2F *) malloc(sizeof(ccVertex2F) * areaTrianglePointCount);
    textureCoordinates = (ccVertex2F *) malloc(sizeof(ccVertex2F) * areaTrianglePointCount);
    
    for (int i = 0; i < areaTrianglePointCount; i++) {
        
#ifdef __CC_PLATFORM_IOS
        CGPoint vert = [[triangulatedPoints objectAtIndex:i] CGPointValue];
#else
        CGPoint vert = [[triangulatedPoints objectAtIndex:i] pointValue];
#endif
        areaTrianglePoints[i] = (ccVertex2F) { vert.x, vert.y };
    }
    
    [self calculateTextureCoordinates];

}

-(void) calculateTextureCoordinates {
    for (int j = 0; j < areaTrianglePointCount; j++) {
        GLfloat scale = 1.0f /_texture.pixelWidth * _texture.contentScale;
        textureCoordinates[j] = (ccVertex2F) { areaTrianglePoints[j].x * scale, areaTrianglePoints[j].y * scale };
    }
}

-(void) draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform {
    CCRenderBuffer buffer = [renderer enqueueTriangles:areaTrianglePointCount/3 andVertexes:areaTrianglePointCount withState:self.renderState globalSortOrder:0];

    
    for (int i = 0; i < areaTrianglePointCount; i++)
    {
        CCVertex vertex;
        vertex.position = GLKVector4Make(areaTrianglePoints[i].x, areaTrianglePoints[i].y, 0.0, 1.0);
        vertex.color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
        vertex.texCoord1 = GLKVector2Make(areaTrianglePoints[i].x / _texture.contentSize.width,
                                          areaTrianglePoints[i].y / _texture.contentSize.height);
        vertex.texCoord1 = GLKVector2Make(textureCoordinates[i].x,
                                          textureCoordinates[i].y);
        CCRenderBufferSetVertex(buffer, i, CCVertexApplyTransform(vertex, transform));
    }
    
    for (int i = 0; i < areaTrianglePointCount/3; i++)
    {
        CCRenderBufferSetTriangle(buffer, i, i*3, (i*3)+1, (i*3)+2);
    }
}

-(void) updateBlendFunc {
	// it's possible to have an untextured sprite
	if( !_texture || ! [_texture hasPremultipliedAlpha] ) {
		blendFunc.src = GL_SRC_ALPHA;
		blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
		//[self setOpacityModifyRGB:NO];
	} else {
		blendFunc.src = GL_ONE;
		blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
		//[self setOpacityModifyRGB:YES];
	}
}

-(void) setBlendFunc:(ccBlendFunc)blendFuncIn {
	blendFunc = blendFuncIn;
}

-(ccBlendFunc) blendFunc {
	return blendFunc;
}

-(void) setTexture:(CCTexture *) texture2D {
	
	// accept texture==nil as argument
	NSAssert( !_texture || [_texture isKindOfClass:[CCTexture class]], @"setTexture expects a CCTexture2D. Invalid argument");
	
	_texture = texture2D;
	ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT };
	[_texture setTexParameters: &texParams];
    
	
	[self updateBlendFunc];
	[self calculateTextureCoordinates];
}

-(CCTexture *) texture {
	return _texture;
}
		 
-(void) dealloc {
	free(areaTrianglePoints);
	free(textureCoordinates);
	 _texture = nil;
    triangulator = nil;
}

@end
