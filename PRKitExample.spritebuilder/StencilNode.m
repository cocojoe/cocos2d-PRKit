//
//  StencilNode.m
//  PRKitExample
//
//  Created by Ken Madsen on 13/01/15.
//  Copyright (c) 2015 www.sagas-playground.com. All rights reserved.
//

#import "StencilNode.h"

@implementation StencilNode

- (void) didLoadFromCCB {
    
    
    // setup stencil node with a box using a stencil texture
    NSMutableArray* stencilPoints = [[NSMutableArray alloc] init];
    [stencilPoints addObject:[NSValue valueWithCGPoint:ccp(0, 0)]];
    [stencilPoints addObject:[NSValue valueWithCGPoint:ccp(50, 0)]];
    [stencilPoints addObject:[NSValue valueWithCGPoint:ccp(100, 120)]];
    [stencilPoints addObject:[NSValue valueWithCGPoint:ccp(0, 80)]];
    
    self.filledPoly = [PRFilledPolygon filledPolygonWithPoints:stencilPoints andTexture:[CCTexture textureWithFile:@"blueprint.png"]];
    
    [self addChild:self.filledPoly];
    
    [self setPosition:ccp(250,100)];
}


@end
