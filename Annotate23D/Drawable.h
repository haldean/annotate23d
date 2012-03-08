//
//  Drawable.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

struct mesh_struct {
  uint size;
  GLfloat* data;
} typedef Mesh;

@interface Drawable : NSObject {
  CGMutablePathRef path;
}

@property (assign) CGPoint com;

- (Mesh)generateMesh;
- (CGMutablePathRef)getPath;
- (void)translate:(CGPoint)translate;
- (void)scaleBy:(CGFloat)factor;
- (void)rotateBy:(CGFloat)angle;

+ (Drawable*)withPoints:(NSArray*)points;

@end
