//
//  Cylinderoid.m
//  Annotate23D
//

#import "Cylinderoid.h"
#import "CLVector.h"
#import "MathDefs.h"

#define DEFAULT_RADIUS 40.0

@implementation Cylinderoid
@synthesize spine, radii, surfacePoints;

// From http://paulbourke.net/geometry/insidepoly/. Must ask permission for use.
- (bool)pointInside:(CGPoint)p {
  int N = [surfacePoints count], counter = 0, i;
  double xinters;
  CGPoint p1, p2;
  
  p1 = [[surfacePoints objectAtIndex:0] CGPointValue];
  for (i=1;i<=N;i++) {
    p2 = [[surfacePoints objectAtIndex:i % N] CGPointValue];
    if (p.y > MIN(p1.y,p2.y)) {
      if (p.y <= MAX(p1.y,p2.y)) {
        if (p.x <= MAX(p1.x,p2.x)) {
          if (p1.y != p2.y) {
            xinters = (p.y-p1.y)*(p2.x-p1.x)/(p2.y-p1.y)+p1.x;
            if (p1.x == p2.x || p.x <= xinters)
              counter++;
          }
        }
      }
    }
    p1 = p2;
  }
  
  if (counter % 2 == 0)
    return NO;
  else
    return YES;
}

- (void)calculateSurfacePoints {
  [surfacePoints removeAllObjects];
  if ([spine count] < 2) return;
  
  NSMutableArray* back = [[NSMutableArray alloc] initWithCapacity:[spine count]];
  
  CLVector v0, v1 = CLVectorFromCGPoint([[spine objectAtIndex:0] CGPointValue]);
  CLVector derivative, radius1, radius2;
  
  { // First endcap
    v0 = CLVectorFromCGPoint([[spine objectAtIndex:0] CGPointValue]);
    v1 = CLVectorFromCGPoint([[spine objectAtIndex:2] CGPointValue]);
    derivative = CLVectorNormalize(CLVectorSubtract(v1, v0));
    
    radius1.x = -derivative.y; radius1.y = derivative.x;
    radius1 = CLVectorMultiplyScalar(radius1, [[radii objectAtIndex:0] floatValue]);
    
    for (float i = 0; i < M_PI; i += M_PI / 10) {
      radius2.x = cos(i) * radius1.x - sin(i) * radius1.y;
      radius2.y = sin(i) * radius1.x + cos(i) * radius1.y;
      radius2 = CLVectorAdd(radius2, v0);
      CGPoint rp = CGPointMake(radius2.x, radius2.y);
      [surfacePoints addObject:[NSValue valueWithCGPoint:rp]];
    }
  }
  
  // Use the forward difference to approximate the derivative of the curve
  for (int i = 1; i < [spine count] - 1; i++) {
    v0 = CLVectorFromCGPoint([[spine objectAtIndex:i-1] CGPointValue]);
    v1 = CLVectorFromCGPoint([[spine objectAtIndex:i+1] CGPointValue]);
    derivative = CLVectorNormalize(CLVectorSubtract(v1, v0));
    
    radius1.x = derivative.y; radius1.y = -derivative.x;
    radius2.x = -derivative.y; radius2.y = derivative.x;
    
    radius1 = CLVectorMultiplyScalar(radius1, [[radii objectAtIndex:i] floatValue]);
    radius2 = CLVectorMultiplyScalar(radius2, [[radii objectAtIndex:i] floatValue]);
    
    radius1 = CLVectorAdd(radius1, CLVectorFromCGPoint([[spine objectAtIndex:i] CGPointValue]));
    CGPoint rp1 = CGPointMake(radius1.x, radius1.y);
    
    radius2 = CLVectorAdd(radius2, CLVectorFromCGPoint([[spine objectAtIndex:i] CGPointValue]));
    CGPoint rp2 = CGPointMake(radius2.x, radius2.y);
    
    [surfacePoints addObject:[NSValue valueWithCGPoint:rp1]];
    [back addObject:[NSValue valueWithCGPoint:rp2]];
  }
  
  { // Second endcap
    v0 = CLVectorFromCGPoint([[spine objectAtIndex:[spine count] - 1] CGPointValue]);
    v1 = CLVectorFromCGPoint([[spine objectAtIndex:[spine count] - 3] CGPointValue]);
    derivative = CLVectorNormalize(CLVectorSubtract(v1, v0));
    
    radius1.x = -derivative.y; radius1.y = derivative.x;
    radius1 = CLVectorMultiplyScalar(radius1, [[radii objectAtIndex:0] floatValue]);
    
    for (float i = 0; i < M_PI; i += M_PI / 10) {
      radius2.x = cos(i) * radius1.x - sin(i) * radius1.y;
      radius2.y = sin(i) * radius1.x + cos(i) * radius1.y;
      radius2 = CLVectorAdd(radius2, v0);
      CGPoint rp = CGPointMake(radius2.x, radius2.y);
      [surfacePoints addObject:[NSValue valueWithCGPoint:rp]];
    }
  }
  
  for (int i = [back count] - 1; i >= 0; i--) {
    [surfacePoints addObject:[back objectAtIndex:i]];
  }
}

- (void)translate:(CGPoint)translate {
  NSLog(@"translate by %f, %f", translate.x, translate.y);
  
  for (int i = 0; i < [spine count]; i++) {
    CGPoint cgpt = [[spine objectAtIndex:i] CGPointValue];
    cgpt.x += translate.x;
    cgpt.y += translate.y;
    [spine replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:cgpt]];
  }
  
  for (int i = 0; i < [surfacePoints count]; i++) {
    CGPoint cgpt = [[surfacePoints objectAtIndex:i] CGPointValue];
    cgpt.x += translate.x;
    cgpt.y += translate.y;
    [surfacePoints replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:cgpt]];
  }
}

+ (Cylinderoid*)cylinderoidWithPoints:(NSArray *)points {
  Cylinderoid* cyl = [[Cylinderoid alloc] init];
  [cyl setSpine:[NSMutableArray arrayWithArray:points]];
  
  [cyl setRadii:[NSMutableArray arrayWithCapacity:[points count]]];
  for (int i = 0; i < [points count]; i++) {
    [[cyl radii] insertObject:[NSNumber numberWithDouble:DEFAULT_RADIUS] atIndex:i];
  }
  
  [cyl setSurfacePoints:[[NSMutableArray alloc] initWithCapacity:2*[points count]]];
  [cyl calculateSurfacePoints];
  
  return cyl;
}

@end
	