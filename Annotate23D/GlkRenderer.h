//
//  GlkRenderer.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GlkRenderer : NSObject <GLKViewDelegate> {
  GLuint vertexArray, vertexBuffer;
}

@property (strong, nonatomic) GLKBaseEffect* effect;

- (void)setupViewMatrix:(GLKView *)view;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;

@end
