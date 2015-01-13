//
//  PRTexturePolygon.m
//  PRKit
//
//  Created by Ken Madsen on 01/01/15.
//  Copyright (c) 2015 www.sagasplayground.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRTexturePolygon.h"
#import "PRRatcliffTriangulator.h"
#import "CCTexture_Private.h"
#import "CCNode_Private.h"

@interface PRTexturePolygon (privateMethods)

/**
 Recalculate the texture coordinates. Called when setTexture is called.
 */
-(void) calculateTextureCoordinates;

@end

@implementation PRTexturePolygon

@synthesize triangulator;

/**
 Returns an autoreleased polygon.  Default triangulator is used (Ratcliff's).
 */
+(id) filledPolygonWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture *) fillTexture {
    return [[PRTexturePolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture];
}

/**
 Returns an autoreleased filled poly with a supplied triangulator.
 */
+(id) filledPolygonWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator {
    return [[PRTexturePolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture usingTriangulator:polygonTriangulator];
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
    //BOOL _flip = false;
    int vertNumber = 0;
    GLfloat scale = 1.0f /_texture.pixelWidth * _texture.contentScale;
    for(int i = 0; i < areaTrianglePointCount; i++) {
        switch (vertNumber) {
            case 0:
                textureCoordinates[i] = (ccVertex2F) { areaTrianglePoints[i].x * scale, 1.0f };
                break;
                
            case 1:
                textureCoordinates[i] = (ccVertex2F) { areaTrianglePoints[i].x * scale, 0.0f };
                break;
                
            case 2:
                textureCoordinates[i] = (ccVertex2F) { areaTrianglePoints[i].x * scale, 1.0f };
                break;
                
            case 3:
                textureCoordinates[i] = (ccVertex2F) { areaTrianglePoints[i].x * scale, 0.0f };
                break;
                
            case 4:
                textureCoordinates[i] = (ccVertex2F) { areaTrianglePoints[i].x * scale, 0.0f };
                break;
                
            case 5:
                textureCoordinates[i] = (ccVertex2F) { areaTrianglePoints[i].x * scale, 1.0f };
                break;
                
            default:
                break;
        }
        vertNumber++;
        if(vertNumber == 6) {
            vertNumber = 0;
        }
    }
}

-(void) draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform {
    if(areaTrianglePointCount > 0) {
        //
        // Texture render
        CCRenderBuffer buffer = [renderer enqueueTriangles:areaTrianglePointCount/3 andVertexes:areaTrianglePointCount withState:self.renderState globalSortOrder:0];
        for (int i = 0; i < areaTrianglePointCount; i++) {
            CCVertex vertex;
            vertex.position = GLKVector4Make(areaTrianglePoints[i].x, areaTrianglePoints[i].y, 0.0, 1.0);
            vertex.color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
            vertex.texCoord1 = GLKVector2Make(textureCoordinates[i].x,
                                              textureCoordinates[i].y);
            CCRenderBufferSetVertex(buffer, i, CCVertexApplyTransform(vertex, transform));
        }
        
        for (int i = 0; i < areaTrianglePointCount/3; i++)
        {
            CCRenderBufferSetTriangle(buffer, i, i*3, (i*3)+1, (i*3)+2);
        }        
    }
}

-(void) updateBlendFunc {
    // it's possible to have an untextured sprite
    if( !_texture || ! [_texture hasPremultipliedAlpha] ) {
        blendFunc.src = GL_SRC_ALPHA;
        blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
        //[self setOpacityModifyRGB:NO];
    } else {
        blendFunc.src = CC_BLEND_SRC;
        blendFunc.dst = CC_BLEND_DST;
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
    ccTexParams texParams = { GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE };
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
