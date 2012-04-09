//
//  EllipsoidTransformer.m
//  Annotate23D
//
//  Created by William Brown on 2012/03/21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EllipsoidTransformer.h"
#import "MathDefs.h"

/* Represents no handle selected */
#define NO_SELECTION -1

@implementation EllipsoidTransformer

@synthesize ellipsoid;

- (id) initWithEllipsoid:(Ellipsoid *)shape {
  self = [self init];
  ellipsoid = shape;
  selectedHandle = NO_SELECTION;
  return self;
}

- (CGPoint) positiveMajor {
  CGPoint posmaj = [ellipsoid com];
  posmaj.x += [ellipsoid a] * cosf([ellipsoid phi]);
  posmaj.y += [ellipsoid a] * sinf([ellipsoid phi]);
  return posmaj;
}

- (CGPoint) negativeMajor {
  CGPoint negmaj = [ellipsoid com];
  negmaj.x -= [ellipsoid a] * cosf([ellipsoid phi]);
  negmaj.y -= [ellipsoid a] * sinf([ellipsoid phi]);
  return negmaj;
}

- (CGPoint) positiveMinor {
  CGPoint posmin = [ellipsoid com];
  posmin.x += [ellipsoid b] * sinf([ellipsoid phi]);
  posmin.y -= [ellipsoid b] * cosf([ellipsoid phi]);
  return posmin;
}

- (CGPoint) negativeMinor {
  CGPoint negmin = [ellipsoid com];
  negmin.x -= [ellipsoid b] * sinf([ellipsoid phi]);
  negmin.y += [ellipsoid b] * cosf([ellipsoid phi]);
  return negmin;
}

#pragma mark User interaction

- (bool) tapAt:(CGPoint)pt {
  float closest_squared_dist = -1;
  
  /* i == 0: negative direction. i == 1: positive direction. */
  for (int i = 0; i <= 1; i++) {
    /* j == 0: major axis. j == 1: minor axis. */
    for (int j = 0; j <= 1; j++) {
      float sqdist;
      if (i == 1 && j == 0)
        sqdist = squareDistance(pt, [self positiveMajor]);
      else if (i == 1 && j == 1)
        sqdist = squareDistance(pt, [self positiveMinor]);
      else if (i == 0 && j == 0)
        sqdist = squareDistance(pt, [self negativeMajor]);
      else if (i == 0 && j == 1)
        sqdist = squareDistance(pt, [self negativeMinor]);
      
      if (closest_squared_dist < 0 || sqdist < closest_squared_dist) {
        selectedHandle = i;
        selectedHandleType = j == 0 ? MAJOR_AXIS : MINOR_AXIS;
        closest_squared_dist = sqdist;
      }
    }
  }
  
  if (closest_squared_dist > HANDLE_TOUCH_RADIUS_SQUARED) {
    selectedHandle = NO_SELECTION;
    return CGPathContainsPoint([ellipsoid getPath], NULL, pt, false);
  }
  
  return YES;
}

- (void) trsFor:(UITouch*) touch1 to:(UITouch*) touch2 inView:(UIView*) view {
  Vec2 touch1_start = VectorForPoint([touch1 previousLocationInView:view]);
  Vec2 touch2_start = VectorForPoint([touch2 previousLocationInView:view]);
  
  Vec2 touch1_end = VectorForPoint([touch1 locationInView:view]);
  Vec2 touch2_end = VectorForPoint([touch2 locationInView:view]);
  
  Vec2 line_start = touch1_start - touch2_start;
  double start_length = line_start.norm();
  line_start /= start_length;
  
  Vec2 line_end = touch1_end - touch2_end;
  double end_length = line_end.norm();
  line_end /= end_length;
  
  Vec2 translate = touch1_end - touch1_start;
  double rotate = (atan2(line_end[1], line_end[0])
                   - atan2(line_start[1], line_start[0]));
  double scale = end_length / start_length;
  
  CGPoint newCom = [ellipsoid com];
  newCom.x += translate[0]; newCom.y += translate[1];
  [ellipsoid setCom:newCom];
  
  [ellipsoid setA:[ellipsoid a] * scale];
  [ellipsoid setB:[ellipsoid b] * scale];
  [ellipsoid setPhi:[ellipsoid phi] + rotate];
}

- (void) moveHandleTo:(CGPoint)end {
  Vec2 radius = VectorForPoint(end) - VectorForPoint([ellipsoid com]);
  if (selectedHandleType == MAJOR_AXIS) {
    Vec2 axis(cosf([ellipsoid phi]), sinf([ellipsoid phi]));
    /* 2 * selectedHandle - 1 will be negative 1 for negative handle
     * and positive 1 for positive handle. */
    axis *= (2 * selectedHandle - 1) / axis.norm();
    [ellipsoid setA:axis.dot(radius)];
  } else {
    Vec2 axis(sinf([ellipsoid phi]), -cosf([ellipsoid phi]));
    axis *= (2 * selectedHandle - 1) / axis.norm();
    [ellipsoid setB:axis.dot(radius)];
  }
}

- (bool) touchesBegan:(NSSet *)touches inView:(UIView *)view {
  return YES;
}

- (void) touchesMoved:(NSSet *) touches inView:(UIView*) view {
  if (selectedHandle != NO_SELECTION && [touches count] == 1) {
    UITouch* touch = [[touches objectEnumerator] nextObject];
    CGPoint end = [touch locationInView:view];
    [self moveHandleTo:end];
  }
  
  else if ([touches count] == 1) {
    /* Translate cylinderoid */
    UITouch* touch = [[touches objectEnumerator] nextObject];
    CGPoint start = [touch previousLocationInView:view];
    CGPoint end = [touch locationInView:view];
    
    float dx = end.x - start.x, dy = end.y - start.y;
    CGPoint newCOM = [ellipsoid com];
    newCOM.x += dx;
    newCOM.y += dy;
    [ellipsoid setCom:newCOM];
    
  } else if ([touches count] == 2) {
    NSEnumerator* touchEnumerator = [touches objectEnumerator];
    UITouch* touch1 = [touchEnumerator nextObject];
    UITouch* touch2 = [touchEnumerator nextObject];
    [self trsFor:touch1 to:touch2 inView:view];
  }

  [ellipsoid calculatePath];
}

- (void) handleAt:(CGPoint)pt ofType:(EllipsoidHandleType)type onContext:(CGContextRef)context selected:(bool)selected {
  CGRect handle_rect = CGRectMake(pt.x - HANDLE_RADIUS, pt.y - HANDLE_RADIUS, 
                                  HANDLE_SIZE, HANDLE_SIZE);
  CGContextAddEllipseInRect(context, handle_rect);
  
  CGContextSetLineWidth(context, 2);
  
  if (selected)
    CGContextSetFillColor(context, (CGFloat[]) {1., 1., 1., 1.});
  else if (type == MINOR_AXIS)
    CGContextSetFillColor(context, (CGFloat[]) {1., 1., 1., .3});
  else if (type == MAJOR_AXIS)
    CGContextSetFillColor(context, (CGFloat[]) {0., 0., 0., .3});
  
  CGContextDrawPath(context, kCGPathFillStroke);
}

- (void) drawShapeWithHandles:(CGContextRef)context {
  CGContextSetLineWidth(context, 5);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0.8 blue:1. alpha:1.].CGColor);
  CGContextAddPath(context, [ellipsoid getPath]);
  CGContextDrawPath(context, kCGPathFillStroke);
  
  [self handleAt:[self positiveMajor] ofType:MAJOR_AXIS onContext:context selected:(selectedHandleType == 0 && selectedHandle == 1)];
  [self handleAt:[self negativeMajor] ofType:MAJOR_AXIS onContext:context selected:(selectedHandleType == 0 && selectedHandle == 0)];
  
  [self handleAt:[self positiveMinor] ofType:MINOR_AXIS onContext:context selected:(selectedHandleType == 1 && selectedHandle == 1)];
  [self handleAt:[self negativeMinor] ofType:MINOR_AXIS onContext:context selected:(selectedHandleType == 1 && selectedHandle == 0)];
}

@end
