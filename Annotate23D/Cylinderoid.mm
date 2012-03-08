//
//  Cylinderoid.m
//  Annotate23D
//

#import "Cylinderoid.h"
#import "MathDefs.h"

#define DEFAULT_RADIUS 40.0
#define DISTANCE_BETWEEN_RINGS 20.0
#define SEGMENTS_IN_CIRCLE 8

@implementation Cylinderoid
@synthesize spine, radii;

- (double)integrateOverSpine {
  if ([spine count] == 0) return 0;
  
  double sum = 0;
  CGPoint current, last = [[spine objectAtIndex:0] CGPointValue];
  for (int i = 1; i < [spine count]; i++) {
    current = [[spine objectAtIndex:i] CGPointValue];
    sum += sqrt(pow(current.x - last.x, 2) + pow(current.y - last.y, 2));
  }
  return sum;
}

- (Vector2f) derivativeAtSpineIndex:(int)i {
  if ([spine count] < 2) {
    return Vector2f(0, 0);
  }
  
  Vector2f v0, v1;
  if (i > 0 && i < [spine count] - 1) {
    v0 = VectorForPoint([[spine objectAtIndex:i-1] CGPointValue]);
    v1 = VectorForPoint([[spine objectAtIndex:i+1] CGPointValue]);
  } else if (i == 0) {
    v0 = VectorForPoint([[spine objectAtIndex:0] CGPointValue]);
    v1 = VectorForPoint([[spine objectAtIndex:1] CGPointValue]);
  } else if (i == [spine count] - 1) {
    v0 = VectorForPoint([[spine objectAtIndex:i-1] CGPointValue]);
    v1 = VectorForPoint([[spine objectAtIndex:i] CGPointValue]);
  }
  
  Vector2f derivative = v1 - v0;
  derivative.normalize();
  return derivative;
}

- (Mesh)generateMesh {
  /*
  double spineLength = [self integrateOverSpine];
  int numRings = ceil(spineLength / DISTANCE_BETWEEN_RINGS);
   */
  int numRings = [spine count];
  int triCount = 2 * (numRings - 1) * SEGMENTS_IN_CIRCLE;
  
  Mesh result;
  /* 3 verteces for each triangle */
  result.size = triCount * 3;
  /* 6 floats for each triangle (3 for position, 3 for normal) */
  result.data = (GLfloat*) malloc(result.size * 6);
  
  int dataidx = 0;
  
  Vec3 **points = (Vec3**) malloc(numRings * sizeof(Vec3*));
  Vec3 **normals = (Vec3**) malloc(numRings * sizeof(Vec3*));
  for (int i = 0; i < numRings; i++) {
    points[i] = (Vec3*) malloc((SEGMENTS_IN_CIRCLE) * sizeof(Vec3));
    normals[i] = (Vec3*) malloc((SEGMENTS_IN_CIRCLE) * sizeof(Vec3));
  }
  
  NSLog(@"verts 2: %d", result.size);

  for (int i = 0; i < numRings; i++) {
    CGPoint cgSpinePoint = [[spine objectAtIndex:i] CGPointValue];
    Vec2 derivative2d = [self derivativeAtSpineIndex:i];
    Vec3 spinePoint(cgSpinePoint.x, cgSpinePoint.y, 0),
         derivative(derivative2d.x(), derivative2d.y(), 0),
         radius(-derivative2d.y(), derivative2d.x(), 0);
    
    radius *= [[radii objectAtIndex:i] doubleValue];
    for (int j = 0; j < SEGMENTS_IN_CIRCLE; j++) {
      Vec3 surfacePoint;
      if (j == 0) surfacePoint = radius;
      else {
        float theta = (float) j * 2 * M_PI / (float) SEGMENTS_IN_CIRCLE;
        AngleAxis<float> rot(theta, derivative);
        surfacePoint = rot * radius;
      }
      points[i][j] = surfacePoint + spinePoint;
      normals[i][j] = surfacePoint;
      normals[i][j].normalize();
    }
  }
  
  NSLog(@"verts 3: %d", result.size);
  
  for (int i = 0; i < numRings - 1; i++) {
    Vec3 *ring1 = points[i];
    Vec3 *norms1 = normals[i];
    Vec3 *ring2 = points[i+1];
    Vec3 *norms2 = normals[i+1];
    
    NSLog(@"verts 3.%d: %d", i, result.size);
    
    for (int j = 0; j < SEGMENTS_IN_CIRCLE; j++) {
      VecX v1(6), v2(6), v3(6), v4(6);
      
      v1.segment(0, 3) = ring1[j]; v1.segment(3, 3) = norms1[j];
      v2.segment(0, 3) = ring2[j]; v2.segment(3, 3) = norms2[j];
      
      int adjacent = j == 0 ? SEGMENTS_IN_CIRCLE - 1 : j - 1;
      v3.segment(0, 3) = ring1[adjacent]; v3.segment(3, 3) = norms1[adjacent];
      v4.segment(0, 3) = ring2[adjacent]; v4.segment(3, 3) = norms2[adjacent];
      
      /* triangle 123 */
      for (int i = 0; i < 6; i++, dataidx++) result.data[dataidx] = v1[i];
      for (int i = 0; i < 6; i++, dataidx++) result.data[dataidx] = v2[i];
      for (int i = 0; i < 6; i++, dataidx++) result.data[dataidx] = v3[i];
      
      /* triangle 234 */
      for (int i = 0; i < 6; i++, dataidx++) result.data[dataidx] = v2[i];
      for (int i = 0; i < 6; i++, dataidx++) result.data[dataidx] = v3[i];
      for (int i = 0; i < 6; i++, dataidx++) result.data[dataidx] = v4[i];
    }
  }
  
  for (int i = 0; i < numRings; i++) {
    free(points[i]); free(normals[i]);
  }
  free(points); free(normals);
  
  NSLog(@"verts 4: %d", result.size);
  
  NSLog(@"dataidx should be %d, dataidx is %d", result.size * 6, dataidx);
  NSLog(@"Points:");
  for (int i = 0; i < 4; i++) {
    NSLog(@"v %f %f %f, n %f %f %f",
          result.data[i*6+0], result.data[i*6+1], result.data[i*6+2],
          result.data[i*6+3], result.data[i*6+4], result.data[i*6+5]);
  }
  NSLog(@"...");
  
  return result;
}

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
	