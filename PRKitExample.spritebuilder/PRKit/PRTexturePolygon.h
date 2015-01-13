//
//  PRTexturePolygon.h
//  PRKit
//
//  Created by Ken Madsen on 01/01/15.
//  Copyright (c) 2015 wwww.sagasplayground.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PRTriangulator.h"

@interface PRTexturePolygon : CCNode {
@private
    int areaTrianglePointCount;
    
    ccBlendFunc blendFunc;
    
    ccVertex2F *areaTrianglePoints;
    ccVertex2F *textureCoordinates;
    
    id<PRTriangulator> triangulator;
}
@property (nonatomic, strong) CCTexture *texture;
@property (nonatomic, strong) id<PRTriangulator> triangulator;
@property (nonatomic, strong) CCShader *shader;

/**
 Returns an autoreleased polygon.  Default triangulator is used (Ratcliff's).
 */
+(id) filledPolygonWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture *) fillTexture;

/**
 Returns an autoreleased filled poly with a supplied triangulator.
 */
+(id) filledPolygonWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator;

/**
 Initialize the polygon.  polygonPoints will be triangulated.  Default triangulator is used (Ratcliff).
 */
-(id) initWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture *) fillTexture;

/**
 Initialize the polygon.  polygonPoints will be triangulated using the supplied triangulator.
 */
-(id) initWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator;

-(void) setPoints: (NSArray *) points;
@end