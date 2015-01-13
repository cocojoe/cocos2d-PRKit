//
//  MainScene.h
//  PRKitExample
//
//  Created by Ken Madsen on 13/01/15.
//  Copyright (c) 2015 www.sagas-playground.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TextureNode.h"
#import "StencilNode.h"

@interface MainScene : CCNode {
    
}

@property (nonatomic, strong) TextureNode* texNode;
@property (nonatomic, strong) StencilNode* stenNode;

@end
