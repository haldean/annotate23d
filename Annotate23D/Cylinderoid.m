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

- (void)calculateSurfacePoints {
  [surfacePoints removeAllObjects];
  
  NSMutableArray* back = [[NSMutableArray alloc] initWithCapacity:[spine count]];
  
  CLVector v0, v1 = CLVectorFromCGPoint([[spine objectAtIndex:0] CGPointValue]);
  CLVector derivative, radius1, radius2;
  
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
  
  for (int i = [back count] - 1; i >= 0; i--) {
    [surfacePoints addObject:[back objectAtIndex:i]];
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
	