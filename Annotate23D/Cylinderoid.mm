//
//  Cylinderoid.m
//  Annotate23D
//

#import "Cylinderoid.h"
#import "MathDefs.h"

#define RINGS_IN_CAP 10
#define DEFAULT_RADIUS 40.0
#define SEGMENTS_IN_CIRCLE 16
#define MIN_DISTANCE_BETWEEN_RINGS 30
#define SMOOTHING_STEPS 100

@implementation Cylinderoid
@synthesize spine, radii, com, capRadius1, capRadius2;


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

- (Mesh*)generateMesh {
  int i, j, k;
  int tubeRingCount = [spine count];
  int numRings = tubeRingCount + 2 * RINGS_IN_CAP;
  
  /* Triangles in the cylinder */
  int triCount = 2 * (numRings - 1) * SEGMENTS_IN_CIRCLE;
  /* Triangles in flat end cap (m - 2 triangles required for an m-gon) */
  triCount += 2 * SEGMENTS_IN_CIRCLE - 4;
  
  /* 3 verteces for each triangle */
  int vertexCount = triCount * 3;
  /* 6 floats for each triangle (3 for position, 3 for normal) */
  
  Mesh* mesh = [[Mesh alloc] initWithSize:vertexCount];
  int dataidx = 0;
  
  Vec3 **points = (Vec3**) malloc(numRings * sizeof(Vec3*));
  Vec3 **normals = (Vec3**) malloc(numRings * sizeof(Vec3*));
  for (i = 0; i < numRings; i++) {
    points[i] = (Vec3*) malloc((SEGMENTS_IN_CIRCLE) * sizeof(Vec3));
    normals[i] = (Vec3*) malloc((SEGMENTS_IN_CIRCLE) * sizeof(Vec3));
  }
  
  for (int ringIndex = 0; ringIndex < numRings; ringIndex++) {
    i = ringIndex - RINGS_IN_CAP;
    Vec3 spinePoint, radius, derivative;
    
    if (i < 0 || i >= tubeRingCount) {
      CGPoint cgSpinePoint;
      Vec2 d2d;
      float r, t;
      
      if (ringIndex < RINGS_IN_CAP) {
        cgSpinePoint = [[spine objectAtIndex:0] CGPointValue];
        d2d = [self derivativeAtSpineIndex:0];
        r = capRadius1;
        t = (float) -ringIndex / (float) RINGS_IN_CAP;
        
      } else {
        cgSpinePoint = [[spine objectAtIndex:[spine count]-1] CGPointValue];
        d2d = [self derivativeAtSpineIndex:[spine count]-1];
        r = capRadius2;
        t = (float) (ringIndex - numRings + 1 + RINGS_IN_CAP) / (float) RINGS_IN_CAP;
      }
      
      Vec3 capOrigin(cgSpinePoint.x, cgSpinePoint.y, 0);
      derivative = Vec3(d2d.x(), d2d.y(), 0);
      spinePoint = capOrigin + t * r * derivative;
      radius = Vec3(-d2d.y(), d2d.x(), 0);
      radius *= sqrt(pow(r, 2) * (1 - pow(t, 2)));
      
    } else {
      CGPoint cgSpinePoint = [[spine objectAtIndex:i] CGPointValue];
      Vec2 d2d = [self derivativeAtSpineIndex:i];
      
      spinePoint = Vec3(cgSpinePoint.x, cgSpinePoint.y, 0);
      derivative = Vec3(d2d.x(), d2d.y(), 0);
      radius = Vec3(-d2d.y(), d2d.x(), 0);
      radius *= [[radii objectAtIndex:i] doubleValue];
    }
    
    for (j = 0; j < SEGMENTS_IN_CIRCLE; j++) {
      Vec3 surfacePoint;
      if (j == 0) surfacePoint = radius;
      else {
        float theta = (float) j * 2 * M_PI / (float) SEGMENTS_IN_CIRCLE;
        AngleAxis<float> rot(theta, derivative);
        surfacePoint = rot * radius;
      }
      points[ringIndex][j] = surfacePoint + spinePoint;
      normals[ringIndex][j] = surfacePoint;
      normals[ringIndex][j].normalize();
    }
  }
  
  /* Flat end caps. This for loop is a bit hacky -- k will be either 0 or
   * numRings - 1, and therefore will act on the first and last ring. */
  for (k = 1; k < numRings; k += numRings - 2) {
    Vec3 *ring = points[k], *norm = normals[k];
    for (int t = 1; t < SEGMENTS_IN_CIRCLE - 1; t++) {
      for (i = 0; i < 3; i++, dataidx++) [mesh put:ring[0][i] at:dataidx];
      for (i = 0; i < 3; i++, dataidx++) [mesh put:norm[0][i] at:dataidx];
      for (i = 0; i < 3; i++, dataidx++) [mesh put:ring[t][i] at:dataidx];
      for (i = 0; i < 3; i++, dataidx++) [mesh put:norm[t][i] at:dataidx];
      for (i = 0; i < 3; i++, dataidx++) [mesh put:ring[t+1][i] at:dataidx];
      for (i = 0; i < 3; i++, dataidx++) [mesh put:norm[t+1][i] at:dataidx];
    }
  }
  
  /* Generate tube */
  for (i = 0; i < numRings - 1; i++) {
    for (j = 0; j < SEGMENTS_IN_CIRCLE; j++) {
      VecX v1(6), v2(6), v3(6), v4(6);
      
      v1.segment(0, 3) = points[i][j];   v1.segment(3, 3) = normals[i][j];
      v2.segment(0, 3) = points[i+1][j]; v2.segment(3, 3) = normals[i+1][j];
      
      int adjacent = j == 0 ? SEGMENTS_IN_CIRCLE - 1 : j - 1;
      v3.segment(0, 3) = points[i][adjacent];   v3.segment(3, 3) = normals[i][adjacent];
      v4.segment(0, 3) = points[i+1][adjacent]; v4.segment(3, 3) = normals[i+1][adjacent];
      
      /* triangle 123 */
      for (k = 0; k < 6; k++, dataidx++) [mesh put:v1[k] at:dataidx];
      for (k = 0; k < 6; k++, dataidx++) [mesh put:v2[k] at:dataidx];
      for (k = 0; k < 6; k++, dataidx++) [mesh put:v3[k] at:dataidx];
      
      /* triangle 234 */
      for (k = 0; k < 6; k++, dataidx++) [mesh put:v2[k] at:dataidx];
      for (k = 0; k < 6; k++, dataidx++) [mesh put:v3[k] at:dataidx];
      for (k = 0; k < 6; k++, dataidx++) [mesh put:v4[k] at:dataidx];
    }
  }
  
  
  for (i = 0; i < numRings; i++) {
    free(points[i]); free(normals[i]);
  }
  free(points); free(normals);
  return mesh;
}

- (CGPoint)getEndpoint1 {
  Vec2 v0 = VectorForPoint([[spine objectAtIndex:0] CGPointValue]);
  Vec2 v1 = VectorForPoint([[spine objectAtIndex:2] CGPointValue]);
  Vec2 pt = v1 - v0;
  pt *= capRadius1 / pt.norm();
  pt = v0 - pt;
  return CGPointMake(pt[0], pt[1]);
}

- (CGPoint)getEndpoint2 {
  Vec2 v0 = VectorForPoint([[spine objectAtIndex:[spine count] - 1] CGPointValue]);
  Vec2 v1 = VectorForPoint([[spine objectAtIndex:[spine count] - 3] CGPointValue]);
  Vec2 pt = v1 - v0;
  pt *= capRadius2 / pt.norm();
  pt = v0 - pt;
  return CGPointMake(pt[0], pt[1]);
}

- (void)calculateSurfacePoints {
  path = CGPathCreateMutable();
  if ([spine count] < 2) return;
  
  NSMutableArray* back = [[NSMutableArray alloc] initWithCapacity:[spine count]];
  
  Vector2f v0, v1 = VectorForPoint([[spine objectAtIndex:0] CGPointValue]);
  Vector2f derivative, radius1, radius2;
  
  { // First endcap (elliptical)
    v0 = VectorForPoint([[spine objectAtIndex:0] CGPointValue]);
    v1 = VectorForPoint([[spine objectAtIndex:2] CGPointValue]);
    
    derivative = v1 - v0;
    derivative.normalize();
    
    float phi = atan2(derivative[1], derivative[0]);
    
    Vec2 cs(cosf(phi), sinf(phi)), sc(sinf(phi), -cosf(phi));
    cs *= capRadius1;
    sc *= [[radii objectAtIndex:0] floatValue];
    
    bool first_iter = YES;
    float start_t = M_PI_2;
    for (float t = start_t; t <= start_t + M_PI; t += M_PI / 12) {
      Vec2 x = v0 + cosf(t) * cs - sinf(t) * sc;
      
      if (first_iter) {
        first_iter = NO;
        CGPathMoveToPoint(path, NULL, x.x(), x.y());
      } else {
        CGPathAddLineToPoint(path, NULL, x.x(), x.y());
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
    
    radius1 *= [[radii objectAtIndex:i] doubleValue];
    radius2 *= [[radii objectAtIndex:i] doubleValue];
    
    radius1 += VectorForPoint([[spine objectAtIndex:i] CGPointValue]);
    radius2 += VectorForPoint([[spine objectAtIndex:i] CGPointValue]);

    CGPoint rp2 = CGPointMake(radius2.x(), radius2.y());
    [back addObject:[NSValue valueWithCGPoint:rp2]];
    
    CGPathAddLineToPoint(path, NULL, radius1.x(), radius1.y());
  }
  
  { // Second endcap (elliptical)
    v0 = VectorForPoint([[spine objectAtIndex:[spine count] - 1] CGPointValue]);
    v1 = VectorForPoint([[spine objectAtIndex:[spine count] - 3] CGPointValue]);
    
    derivative = v1 - v0;
    derivative.normalize();
    
    float phi = atan2(derivative[1], derivative[0]);
    
    Vec2 cs(cosf(phi), sinf(phi)), sc(sinf(phi), -cosf(phi));
    cs *= capRadius2;
    sc *= [[radii objectAtIndex:[radii count] - 1] floatValue];
    
    float start_t = M_PI_2;
    for (float t = start_t; t <= start_t + M_PI; t += M_PI / 12) {
      Vec2 x = v0 + cosf(t) * cs - sinf(t) * sc;
      CGPathAddLineToPoint(path, NULL, x.x(), x.y());
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
  NSLog(@"translate by %f, %f", translate.x, translate.y);
  for (int i = 0; i < [spine count]; i++) {
    CGPoint cgpt = [[spine objectAtIndex:i] CGPointValue];
    CGPoint newpt = CGPointMake(cgpt.x + translate.x, cgpt.y + translate.y);
    [spine replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:newpt]];
  }
  
  com.x += translate.x;
  com.y += translate.y;
  
  [self calculateSurfacePoints];
}

- (void)scaleBy:(CGFloat)factor {
  for (int i = 0; i < [spine count]; i++) {
    CGPoint cgpt = [[spine objectAtIndex:i] CGPointValue];
    CGPoint newpt = CGPointMake(factor * (cgpt.x - com.x) + com.x, 
                              factor * (cgpt.y - com.y) + com.y);
    [spine replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:newpt]];
    
    float radius = [[radii objectAtIndex:i] doubleValue];
    [radii replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:radius * factor]];
  }

  [self calculateSurfacePoints];
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

- (void)smoothSpine:(int)factor lockPoint:(int)lock {
  for (int iteration = factor; iteration >= 0; iteration--) {
    NSMutableArray* newSpine = [[NSMutableArray alloc] initWithCapacity:[spine count]];
    
    [newSpine addObject:[spine objectAtIndex:0]];
    for (int i = 1; i < [spine count] - 1; i++) {
      if (i == lock) {
        [newSpine addObject:[spine objectAtIndex:i]];
        continue;
      }
      
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

- (void)smoothRadii:(int)factor lockPoint:(int)lock {
  for (; factor >= 0; factor--) {
    NSMutableArray* newRadii = [[NSMutableArray alloc] initWithCapacity:[radii count]];
    for (int i = 0; i < [radii count]; i++) {
      if (i == lock) {
        [newRadii addObject:[radii objectAtIndex:i]];
        continue;
      }
      
      double r = [[radii objectAtIndex:i] floatValue];
      double r0 = i > 0 ? [[radii objectAtIndex:i-1] floatValue] : r;
      double r1 = i < [radii count] - 1 ? [[radii objectAtIndex:i+1] floatValue] : r;
      
      double scale = pow(10., -pow((lock - i) / 1.5, 2));
      r += ((r0 - r) + (r1 - r)) * scale;
      [newRadii addObject:[NSNumber numberWithDouble:r]];
    }
    radii = newRadii;
  }
}

- (void) resampleSpine {
  NSMutableArray* newSpine = [[NSMutableArray alloc] initWithCapacity:[spine count]];
  
  Vec2 lastLoc = VectorForPoint([[spine objectAtIndex:0] CGPointValue]);
  [newSpine addObject:[spine objectAtIndex:0]];
  
  for (int i = 1; i < [spine count]; i++) {
    NSValue* thisPoint = [spine objectAtIndex:i];
    Vec2 thisLoc = VectorForPoint([thisPoint CGPointValue]);
    if ((thisLoc - lastLoc).norm() > MIN_DISTANCE_BETWEEN_RINGS) {
      [newSpine addObject:thisPoint];
      lastLoc = thisLoc;
    }
  }
  
  /* If the resampled spine results in a spine of length 2 or less,
   * keep the old spine. It's too short to reasonably resample. */
  if ([newSpine count] > 2) spine = newSpine;
}

+ (double)integrateOverSpine:(NSArray*)spine {
  if ([spine count] == 0) return 0;
  
  double sum = 0;
  CGPoint current, last = [[spine objectAtIndex:0] CGPointValue];
  for (int i = 1; i < [spine count]; i++) {
    current = [[spine objectAtIndex:i] CGPointValue];
    sum += sqrt(pow(current.x - last.x, 2) + pow(current.y - last.y, 2));
  }
  return sum;
}

+ (Cylinderoid*)withPoints:(NSArray *)points {
  if ([points count] <= 2) return nil;
  
  Cylinderoid* cyl = [[Cylinderoid alloc] init];
  
  [cyl setSpine:[NSMutableArray arrayWithArray:points]];
  [cyl resampleSpine];
  [cyl calculateCoM];
  
  [cyl setRadii:[NSMutableArray arrayWithCapacity:[points count]]];
  for (int i = 0; i < [points count]; i++) {
    [[cyl radii] insertObject:[NSNumber numberWithDouble:DEFAULT_RADIUS] atIndex:i];
  }
  [cyl setCapRadius1:DEFAULT_RADIUS];
  [cyl setCapRadius2:DEFAULT_RADIUS];
  
  [cyl smoothSpine:SMOOTHING_STEPS lockPoint:-1];
  [cyl calculateSurfacePoints];
  
  return cyl;
}

@end
	