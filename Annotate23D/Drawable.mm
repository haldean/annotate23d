//
//  Drawable.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Drawable.h"

@implementation Drawable
@synthesize com;

- (Mesh*)generateMesh {
  [NSException raise:@"Drawable is abstract" format:@"Cannot create mesh for Drawable directly."];
  return NULL;
}

- (CGMutablePathRef)getPath {
  return path;
}

- (void)translate:(CGPoint)translate {
  CGAffineTransform translation =
  CGAffineTransformMakeTranslation(translate.x, translate.y);
  path = CGPathCreateMutableCopyByTransformingPath(path, &translation);
  
  com.x += translate.x;
  com.y += translate.y;
}

- (void)scaleBy:(CGFloat)factor {
  CGAffineTransform scale =
  CGAffineTransformMakeTranslation(-com.x, -com.y);
  CGAffineTransformScale(scale, factor, factor);
  CGAffineTransformMakeTranslation(com.x, com.y);
  path = CGPathCreateMutableCopyByTransformingPath(path, &scale);
}

- (void)rotateBy:(CGFloat)angle {
  CGAffineTransform rotation =
  CGAffineTransformMakeTranslation(-com.x, -com.y);
  CGAffineTransformRotate(rotation, angle);
  CGAffineTransformTranslate(rotation, com.x, com.y);
  path = CGPathCreateMutableCopyByTransformingPath(path, &rotation);
}

+ (Drawable*)withPoints:(NSArray*)points {
  [NSException raise:@"Drawable is abstract" format:@"Cannot instantiate Drawable directly."];
  return NULL;
}

@end
