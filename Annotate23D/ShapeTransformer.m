//
//  ShapeTransformer.m
//  Annotate23D
//
//  Created by William Brown on 2012/03/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShapeTransformer.h"
#import "Cylinderoid.h"
#import "CylinderoidTransformer.h"
#import "Ellipsoid.h"
#import "EllipsoidTransformer.h"

@implementation ShapeTransformer

- (void) drawShapeWithHandles:(CGContextRef)context {
  [NSException raise:@"ShapeTransformer is abstract" format:@""];
}

- (bool) tapAt:(CGPoint)pt { return NO; }
- (bool) touchesBegan:(NSSet *) touches inView:(UIView*) view {
  return NO;
}
- (void) touchesMoved:(NSSet *) touches inView:(UIView*) view {}
- (void) touchesEnded:(NSSet *) touches inView:(UIView*) view {}

+ (ShapeTransformer*) transformerForShape:(Drawable *)shape {
  if ([[shape class] isSubclassOfClass:[Cylinderoid class]]) {
    return [[CylinderoidTransformer alloc] initWithCylinderoid:(Cylinderoid*)shape];
  } else {
    return [[EllipsoidTransformer alloc] initWithEllipsoid:(Ellipsoid*)shape];
  }
  return nil;
}

@end
