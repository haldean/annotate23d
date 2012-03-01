//
//  Cylinderoid.m
//  Annotate23D
//

#import "Cylinderoid.h"
#import "MathDefs.h"

#define DEFAULT_RADIUS 40.0

@implementation Cylinderoid
@synthesize spine, radii;

- (void)calculateSurfacePoints {
  path = CGPathCreateMutable();
  if ([spine count] < 2) return;
  
  NSMutableArray* back = [[NSMutableArray alloc] initWithCapacity:[spine count]];
  
  Vector2f v0, v1 = VectorForPoint([[spine objectAtIndex:0] CGPointValue]);
  Vector2f derivative, radius1, radius2;
  
  { // First endcap
    v0 = VectorForPoint([[spine objectAtIndex:0] CGPointValue]);
    v1 = VectorForPoint([[spine objectAtIndex:2] CGPointValue]);
    derivative = v1 - v0;
    derivative.normalize();
    
    radius1.x() = -derivative.y(); radius1.y() = derivative.x();
    radius1 *= [[radii objectAtIndex:0] floatValue];
    
    for (float i = 0; i < M_PI; i += M_PI / 10) {
      radius2.x() = cos(i) * radius1.x() - sin(i) * radius1.y();
      radius2.y() = sin(i) * radius1.x() + cos(i) * radius1.y();
      radius2 += v0;
      
      if (i == 0) {
        CGPathMoveToPoint(path, NULL, radius2.x(), radius2.y());
      } else {
        CGPathAddLineToPoint(path, NULL, radius2.x(), radius2.y());
      }
    }
  }
  
  // Use the forward difference to approximate the derivative of the curve
  for (int i = 1; i < [spine count] - 1; i++) {
    v0 = VectorForPoint([[spine objectAtIndex:i-1] CGPointValue]);
    v1 = VectorForPoint([[spine objectAtIndex:i+1] CGPointValue]);
    derivative = v1 - v0;
    derivative.normalize();
    
    radius1.x() = derivative.y(); radius1.y() = -derivative.x();
    radius2.x() = -derivative.y(); radius2.y() = derivative.x();
    
    radius1 *= [[radii objectAtIndex:i] floatValue];
    radius2 *= [[radii objectAtIndex:i] floatValue];
    
    radius1 += VectorForPoint([[spine objectAtIndex:i] CGPointValue]);
    radius2 += VectorForPoint([[spine objectAtIndex:i] CGPointValue]);

    CGPoint rp2 = CGPointMake(radius2.x(), radius2.y());
    [back addObject:[NSValue valueWithCGPoint:rp2]];
    
    CGPathAddLineToPoint(path, NULL, radius1.x(), radius1.y());
  }
  
  { // Second endcap
    v0 = VectorForPoint([[spine objectAtIndex:[spine count] - 1] CGPointValue]);
    v1 = VectorForPoint([[spine objectAtIndex:[spine count] - 3] CGPointValue]);
    derivative = v1 - v0;
    derivative.normalize();
    
    radius1.x() = -derivative.y(); radius1.y() = derivative.x();
    radius1 *= [[radii objectAtIndex:0] floatValue];
    
    for (float i = 0; i < M_PI; i += M_PI / 10) {
      radius2.x() = cos(i) * radius1.x() - sin(i) * radius1.y();
      radius2.y() = sin(i) * radius1.x() + cos(i) * radius1.y();
      radius2 += v0;
      
      CGPathAddLineToPoint(path, NULL, radius2.x(), radius2.y());
    }
  }
  
  for (int i = [back count] - 1; i >= 0; i--) {
    CGPoint pt = [[back objectAtIndex:i] CGPointValue];
    CGPathAddLineToPoint(path, NULL, pt.x, pt.y);
  }
  
  CGPathCloseSubpath(path);
}

- (void)calculateCoM {
  com.x = 0; com.y = 0;
  CGPoint a;
  
  for (int i = 0; i < [spine count]; i++) {
    a = [[spine objectAtIndex:i] CGPointValue];
    com.x += a.x;
    com.y += a.y;
  }
  
  com.x /= [spine count];
  com.y /= [spine count];
}

- (void)translate:(CGPoint)translate {
  CGAffineTransform translation =
    CGAffineTransformMakeTranslation(translate.x, translate.y);
  for (int i = 0; i < [spine count]; i++) {
    CGPoint cgpt = [[spine objectAtIndex:i] CGPointValue];
    CGPointApplyAffineTransform(cgpt, translation);
    [spine replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:cgpt]];
  }
  
  [super translate:translate];
}

- (void)scaleBy:(CGFloat)factor {
  CGAffineTransform scale =
    CGAffineTransformMakeTranslation(-com.x, -com.y);
  CGAffineTransformScale(scale, factor, factor);
  CGAffineTransformMakeTranslation(com.x, com.y);
  
  for (int i = 0; i < [spine count]; i++) {
    CGPoint cgpt = [[spine objectAtIndex:i] CGPointValue];
    CGPointApplyAffineTransform(cgpt, scale);
    [spine replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:cgpt]];
  }
  
  [super scaleBy:factor];
}

- (void)rotateBy:(CGFloat)angle {
  CGAffineTransform rotation =
    CGAffineTransformMakeTranslation(-com.x, -com.y);
  CGAffineTransformRotate(rotation, angle);
  CGAffineTransformTranslate(rotation, com.x, com.y);
  
  for (int i = 0; i < [spine count]; i++) {
    CGPoint cgpt = [[spine objectAtIndex:i] CGPointValue];
    cgpt = CGPointApplyAffineTransform(cgpt, rotation);
    [spine replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:cgpt]];
  }
  
  [super rotateBy:angle];
}

- (void)smoothSpine:(int)factor {
  for (int iteration = factor; iteration >= 0; iteration--) {
    NSMutableArray* newSpine = [[NSMutableArray alloc] initWithCapacity:[spine count]];
    
    [newSpine addObject:[spine objectAtIndex:0]];
    for (int i = 1; i < [spine count] - 1; i++) {
      Vec2 p = VectorForPoint([[spine objectAtIndex:i] CGPointValue]);
      Vec2 p0 = VectorForPoint([[spine objectAtIndex:i-1] CGPointValue]);
      Vec2 p1 = VectorForPoint([[spine objectAtIndex:i+1] CGPointValue]);
      
      p += ((p0 - p) + (p1 - p)) * 1e-2;
      [newSpine addObject:[NSValue valueWithCGPoint:CGPointMake(p[0], p[1])]];
    }
    [newSpine addObject:[spine objectAtIndex:[spine count]-1]];
    
    spine = newSpine;
  }
}

+ (Cylinderoid*)withPoints:(NSArray *)points {
  Cylinderoid* cyl = [[Cylinderoid alloc] init];
  [cyl setSpine:[NSMutableArray arrayWithArray:points]];
  
  [cyl setRadii:[NSMutableArray arrayWithCapacity:[points count]]];
  for (int i = 0; i < [points count]; i++) {
    [[cyl radii] insertObject:[NSNumber numberWithDouble:DEFAULT_RADIUS] atIndex:i];
  }
  
  [cyl smoothSpine:1000];
  [cyl calculateSurfacePoints];
  [cyl calculateCoM];
  
  return cyl;
}

@end
	