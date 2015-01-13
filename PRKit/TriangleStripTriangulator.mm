//
//  TriangleStripTriangulator.m
//  PRKit
//
//  Created by Ken Madsen on 05/01/15.
//  Copyright (c) 2015 www.sagasplayground.com. All rights reserved.
//

#import "TriangleStripTriangulator.h"
#import "triangulate.h"
#import "cocos2d.h"

@implementation TriangleStripTriangulator

- (NSArray *) triangulateVertices:(NSArray *)vertices {
    // verticies coming in are stringed
    NSMutableArray* triangulatedPoints = [[NSMutableArray alloc] init];
    CGPoint c0, c1, c2, c3;
    for(int i = 0; i < vertices.count; i = i+2) {
        if(i + 3 > vertices.count) {
            // 2 verticies left, use last used verticies
            c0 = c2;
            c1 = c3;
            c2 = ((NSValue*)[vertices objectAtIndex:i]).CGPointValue;
            c3 = ((NSValue*)[vertices objectAtIndex:i + 1]).CGPointValue;
            
            // add verticies c0->c1->c2 and c1->c3->c2
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c0]];
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c1]];
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c2]];
            
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c1]];
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c3]];
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c2]];
            
        } else {
            // 4 or more
            c0 = ((NSValue*)[vertices objectAtIndex:i]).CGPointValue;
            c1 = ((NSValue*)[vertices objectAtIndex:i + 1]).CGPointValue;
            c2 = ((NSValue*)[vertices objectAtIndex:i + 2]).CGPointValue;
            c3 = ((NSValue*)[vertices objectAtIndex:i + 3]).CGPointValue;
            
            // add verticies c0->c1->c2 and c1->c3->c2
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c0]];
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c1]];
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c2]];
            
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c1]];
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c3]];
            [triangulatedPoints addObject:[NSValue valueWithCGPoint:c2]];
            
        }
    }
    return triangulatedPoints;
}

@end
