//
//  TextureNode.m
//  PRKitExample
//
//  Created by Ken Madsen on 13/01/15.
//  Copyright (c) 2015 www.sagas-playground.com. All rights reserved.
//

#import "TextureNode.h"
#import "TriangleStripTriangulator.h"

@implementation TextureNode

- (void) didLoadFromCCB {
    //
    // setup texture node with a box,
    // using a texture map
    //  a-d
    //  |\|
    //  b-c
    
    
    NSMutableArray* texPoints = [[NSMutableArray alloc] init];
    
    [texPoints addObject:[NSValue valueWithCGPoint:ccp(0, 100)]];
    [texPoints addObject:[NSValue valueWithCGPoint:ccp(0, 0)]];
    [texPoints addObject:[NSValue valueWithCGPoint:ccp(100, 80)]];
    [texPoints addObject:[NSValue valueWithCGPoint:ccp(256, 0)]];

    self.textureChild = [PRTexturePolygon filledPolygonWithPoints:texPoints andTexture:[CCTexture textureWithFile:@"blueprint.png"] usingTriangulator:[[TriangleStripTriangulator alloc] init]];
    
    [self addChild:self.textureChild];
}


@end
