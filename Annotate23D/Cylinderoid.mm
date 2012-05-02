//
//  Cylinderoid.m
//  Annotate23D
//

#import "Cylinderoid.h"
#import "MathDefs.h"

#define RINGS_IN_CAP 30
#define DEFAULT_RADIUS 40.0
#define SEGMENTS_IN_CIRCLE 16
#define MIN_DISTANCE_BETWEEN_RINGS 30
#define SMOOTHING_STEPS 100
#define NO_TILT (NAN)

@implementation Cylinderoid
@synthesize spine, radii, com, tilt, capRadius1, capRadius2;
@synthesize lengthConstraint, connectionConstraint, mirrorAnnotation,
            alignmentConstraint, radiusConstraints, tiltConstraints;

- (NSMutableArray*) tiltWithConstraints {
  NSMutableArray* newtilt = [[NSMutableArray alloc] initWithArray:tilt copyItems:false];
  for (SameTiltAnnotation* sta in tiltConstraints) {
    int handle = [sta first] == self ? [sta firstHandleIndex] : [sta secondHandleIndex];
    NSNumber* targetTilt = [NSNumber numberWithFloat:[sta targetTilt]];
    [newtilt replaceObjectAtIndex:handle withObject:targetTilt];
  }
  return newtilt;
}

/* Helper macros for tiltAtIndex */
#define TILT_AT(x) ([[_tilt objectAtIndex:(x)] doubleValue])
#define TILT_DEFINED_AT(x) (!isnan(TILT_AT(x)))
- (double) tiltAtIndex:(int)i withTilts:(NSMutableArray*)_tilt {  
  if (TILT_DEFINED_AT(i)) return TILT_AT(i);
  int previous = i, next = i;
  while (previous >= 0 && !TILT_DEFINED_AT(previous)) previous--;
  while (next < [tilt count] && !TILT_DEFINED_AT(next)) next++;
  
  bool use_previous = previous >= 0;
  bool use_next = next < [tilt count];
  if (!use_previous && !use_next) return 0;
  if (!use_previous) return TILT_AT(next);
  if (!use_next) return TILT_AT(previous);
  
  float previous_dist = i - previous, next_dist = next - i;
  float previous_tilt = TILT_AT(previous), next_tilt = TILT_AT(next);
  float interp = previous_dist * next_tilt + next_dist * previous_tilt;
  interp /= previous_dist + next_dist;
  return interp;
}

- (bool) hasTiltAt:(int)i {
  NSMutableArray* _tilt = tilt;
  return TILT_DEFINED_AT(i);
}

- (Vec2) derivativeAtSpineIndex:(int)i {
  if ([spine count] < 2) {
    return Vec2::Zero();
  }
  
  Vec2 v0, v1;
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
  
  Vec2 derivative = v1 - v0;
  derivative.normalize();
  return derivative;
}

- (CGPoint) cgDerivativeAtIndex:(int) i {
  Vec2 d = [self derivativeAtSpineIndex:i];
  return CGPointMake(d[0], d[1]);
}

- (Vec3) dSpine:(NSMutableArray*)spinevecs atIndex:(int)i {
  if ([spinevecs count] < 2) return Vec3::Zero();
  
  Vec3 v0, v1;
  if (i > 0 && i < [spine count] - 1) {
    v0 = [[spinevecs objectAtIndex:i-1] vec3];
    v1 = [[spinevecs objectAtIndex:i+1] vec3];
  } else if (i == 0) {
    v0 = [[spinevecs objectAtIndex:0] vec3];
    v1 = [[spinevecs objectAtIndex:1] vec3];
  } else if (i == [spine count] - 1) {
    v0 = [[spinevecs objectAtIndex:i-1] vec3];
    v1 = [[spinevecs objectAtIndex:i] vec3];
  }
  
  Vec3 d = v1 - v0;
  d.normalize();
  return d;
}

- (NSMutableArray*) spineVecsWithTilt {
  NSMutableArray* newspine = [[NSMutableArray alloc] initWithCapacity:[spine count]];
  NSMutableArray* tilts = [self tiltWithConstraints];
  
  Vec3 lastPoint;
  for (int i = 0; i < [spine count]; i++) {
    Vec3 spinePoint = Vec3ForPoint([[spine objectAtIndex:i] CGPointValue]);
    
    /* First find the naive (without constraints) z-value based on the tilt. 
     * Constrain the z-value of the first point to be zero. */
    if (i == 0) spinePoint.z() = 0;
    else {
      double tilt_i = [self tiltAtIndex:i withTilts:tilts];
      Vec3 delta = spinePoint - lastPoint;
      /* Ensure z is zero for the norm call on the next line. We want the length
       * of the 2-vector. */
      delta.z() = 0;
      spinePoint.z() = lastPoint.z() + delta.norm() * tan(tilt_i);
    }
    
    [newspine addObject:[NSVec3 with:spinePoint]];
    lastPoint = spinePoint;
  }
  return newspine;
}

- (NSMutableArray*) spineVecsWithConstraints {
  NSMutableArray* newspine = [self spineVecsWithTilt];
  
  /* Determine the general transform that will be applied to all points
   which reflects the satisfaction of all constraints */
  Transform<float, 3, Affine> trs;
  trs.setIdentity();
  trs.translate(Vec3ForPoint(com));
  if (lengthConstraint != nil) {
    float targetLength = [lengthConstraint targetLength];
    /* TODO this needs to change to use the spine length after applying the
     previous transformations */
    float currentLength = [self spineLength];
    float scale = targetLength / currentLength;
    trs.scale(scale);
  }
  trs.translate(-Vec3ForPoint(com));
  
  /* Apply transform to each vector */
  for (int i = 0; i < [newspine count]; i++) {
    [newspine replaceObjectAtIndex:i withObject:[NSVec3 with:trs * [[newspine objectAtIndex:i] vec3]]];
  }
  
  return newspine;
}

- (NSMutableArray*) applyConnectionConstraintsTo:(NSMutableArray*)spinevecs {
  bool useAlignment = alignmentConstraint != nil;
  bool useConnection = !useAlignment && (connectionConstraint == nil || self == [connectionConstraint first]);
  if (!useAlignment && !useConnection) {
    return spinevecs;
  }
  
  Vec3 translate;
  if (useConnection) {
    translate = Vec3ForCGVec([connectionConstraint secondTranslation]);
  } else {
    translate = Vec3ForCGVec([alignmentConstraint translationOnSpine:spinevecs]);
    NSLog(@"translate: %@", VecToStr(translate));
  }
  
  for (int i = 0; i < [spinevecs count]; i++) {
    Vec3 old = [[spinevecs objectAtIndex:i] vec3];
    [spinevecs replaceObjectAtIndex:i withObject:[NSVec3 with:old + translate]];
  }
  return spinevecs;
}

- (NSMutableArray*) radiiWithConstraints {
  NSMutableArray* newradii = [[NSMutableArray alloc] initWithArray:radii copyItems:false];
  for (SameScaleAnnotation* ssa in radiusConstraints) {
    int handle = [ssa first] == self ? [ssa firstHandleIndex] : [ssa secondHandleIndex];
    NSNumber* targetSize = [NSNumber numberWithFloat:[ssa targetRadius]];
    [newradii replaceObjectAtIndex:handle withObject:targetSize];
  }
  return newradii;
}

- (Vec3) rForD:(Vec3)d lastD:(Vec3)lastD lastR:(Vec3)lastR {
  return Vec3(-d[1], d[0], 0);
  
  /* TODO: fix this to prevent twisting */
  if (d == lastD || d == -lastD) return lastR;
  
  Vec3 omega = lastD.cross(d);
  omega.normalize();
  
  float theta = acosf(std::min(1.f, std::max(-1.f, d.dot(lastD))));
  
  AngleAxis<float> rot(theta, omega);
  Vec3 r = rot * lastR;
  
  /* Uses Rodrigues' Rotation Formula to perform Euler Axis rotation to lastR 
  Vec3 r = lastR * cosf(theta);
  r += omega.cross(lastR) * sin(theta);
  r += omega * omega.dot(lastR) * (1 - cosf(theta));
   */
  
  r.normalize();
  NSLog(@"r4d omega %@ theta %f r %@", VecToStr(omega), theta, VecToStr(r));
  return r;
}

- (CGVec*) tangentVectorAtIndex:(int)idx {
  return [self tangentVectorAtIndex:idx
                            onSpine:[self spineVecsWithConstraints]];
}

- (CGVec*) tangentVectorAtIndex:(int)idx onSpine:(NSMutableArray*)spinevecs {
  return CGVecForVec3([self dSpine:spinevecs atIndex:idx]);
}

- (CGVec*) perpVectorAtIndex:(int)idx {
  return [self perpVectorAtIndex:idx
                         onSpine:[self spineVecsWithConstraints]];
}

- (CGVec*) perpVectorAtIndex:(int)idx onSpine:(NSMutableArray*)spinevecs {
  Vec3 lastR, lastD, d, r;
  for (int i = 0; i <= idx; i++) {
    d = [self dSpine:spinevecs atIndex:i];
    if (i == 0) {
      r = Vec3(-d.y(), d.x(), 0);
    } else {
      r = [self rForD:d lastD:lastD lastR:lastR];
    }
    
    lastR = r;
    lastD = d;
  }
  
  return CGVecForVec3(r);
}

- (CGVec*) spineVectorAtIndex:(int)idx {
  NSMutableArray* spinevecs = [self spineVecsWithConstraints];
  return CGVecForVec3([[spinevecs objectAtIndex:idx] vec3]);
}

- (NSMutableArray*) spineVecsWithConnectionConstraints {
  return [self applyConnectionConstraintsTo:[self spineVecsWithConstraints]];
}

- (Mesh*) generateMeshWithConnectionConstraints:(bool)useConnection {
  NSMutableArray* spinevecs;
  if (useConnection) {
    spinevecs = [self spineVecsWithConnectionConstraints];
  } else {
    spinevecs = [self spineVecsWithConstraints];
  }
  return [self generateMeshWithSpine:spinevecs];
}

- (Mesh*) generateMeshWithSpine:(NSMutableArray*)spinevecs {
  NSMutableArray* rad = [self radiiWithConstraints];
  
  int i, j, k;
  int tubeRingCount = [spinevecs count];
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
  
  Vec3 lastR, lastD;
  for (int ringIndex = 0; ringIndex < numRings; ringIndex++) {
    i = ringIndex - RINGS_IN_CAP;
    Vec3 spinePoint, radius, derivative;
    
    if (i < 0 || i >= tubeRingCount) {
      Vec3 spineVec;
      float r_maj, r_min, t;
      
      if (ringIndex < RINGS_IN_CAP) {
        spineVec = [[spinevecs objectAtIndex:0] vec3];
        derivative = [self dSpine:spinevecs atIndex:0];
        r_min = [[rad objectAtIndex:0] floatValue];
        r_maj = capRadius1;
        t = (float) -ringIndex / (float) RINGS_IN_CAP;
        
      } else {
        spineVec = [[spinevecs objectAtIndex:[spine count]-1] vec3];
        derivative = [self dSpine:spinevecs atIndex:[spine count]-1];
        r_min = [[rad objectAtIndex:[rad count]-1] floatValue];
        r_maj = capRadius2;
        t = (float) (ringIndex - numRings + 1 + RINGS_IN_CAP) / (float) RINGS_IN_CAP;
      }
      
      spinePoint = spineVec + t * r_maj * derivative;
      radius = Vec3(-derivative.y(), derivative.x(), 0);
      radius *= sqrt(pow(r_min, 2) * (1 - pow(t, 2)));
      
    } else {
      spinePoint = [[spinevecs objectAtIndex:i] vec3];
      derivative = [self dSpine:spinevecs atIndex:i];
      radius = [self rForD:derivative lastD:lastD lastR:lastR];
      radius *= [[rad objectAtIndex:i] floatValue];
      //NSLog(@"sp %@ d %@ r %@ |r| %f", VecToStr(spinePoint), VecToStr(derivative), VecToStr(radius), radius.norm());
    }
    
    lastD = derivative;
    lastR = radius;
    
    for (j = 0; j < SEGMENTS_IN_CIRCLE; j++) {
      Vec3 surfacePoint;
      if (j == 0) surfacePoint = radius;
      else {
        float theta = (float) j * 2 * M_PI / (float) SEGMENTS_IN_CIRCLE;
        AngleAxis<float> rot(theta, derivative);
        surfacePoint = rot * radius;
      }
      points[ringIndex][j] = surfacePoint + spinePoint;
      
      /* This is wrong for the endcap. Inverse transpose of scaling on sphere
       * to scale the normal. Apply inverse of scale to the normal that you would compute
       * for a sphere based on the axes of the ellipse. */
      
      /* Project surface point (= s) to major axis (projection = a), a' = a / (maj / min)^2,
       * new normal = a' + (s - a) */
      if (surfacePoint.norm() > 0) {
        normals[ringIndex][j] = surfacePoint;
      } else {
        if (ringIndex < RINGS_IN_CAP)
          normals[ringIndex][j] = derivative;
        else
          normals[ringIndex][j] = -derivative;
      }
      normals[ringIndex][j].normalize();
    }
  }
  
  /* Flat end caps. This for loop is a bit hacky -- k will be either 0 or
   * numRings - 1, and therefore will act on the first and last ring.
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
  }*/
  
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

- (Mesh*)generateMesh {
  return [self generateMeshWithConnectionConstraints:true];
}

- (CGPoint) center {
  return [[spine objectAtIndex:[spine count]/2] CGPointValue];
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
  float dist = MIN_DISTANCE_BETWEEN_RINGS;
  NSMutableArray* newSpine;
  
  do {
    newSpine = [[NSMutableArray alloc] initWithCapacity:[spine count]];
    Vec2 lastLoc = VectorForPoint([[spine objectAtIndex:0] CGPointValue]);
    [newSpine addObject:[spine objectAtIndex:0]];
    
    for (int i = 1; i < [spine count]; i++) {
      NSValue* thisPoint = [spine objectAtIndex:i];
      Vec2 thisLoc = VectorForPoint([thisPoint CGPointValue]);
      if ((thisLoc - lastLoc).norm() > dist) {
        [newSpine addObject:thisPoint];
        lastLoc = thisLoc;
      }
    }
    
    dist /= 2;
  } while ([newSpine count] <= 2 && dist > 1);
  
  /* If the resampled spine results in a spine of length 2 or less,
   * keep the old spine. It's too short to reasonably resample. */
  if ([newSpine count] > 2) spine = newSpine;
}

- (double) spineLength {
  double len = 0;
  NSMutableArray* _spine = [self spineVecsWithTilt];
  for (int i = 1; i < [_spine count]; i++) {
    len += ([[_spine objectAtIndex:i] vec3] - [[_spine objectAtIndex:i-1] vec3]).norm();
  }
  return len;
}

+ (Cylinderoid*)withPoints:(NSArray *)points {
  if ([points count] <= 2) return nil;
  
  Cylinderoid* cyl = [[Cylinderoid alloc] init];
  
  [cyl setSpine:[NSMutableArray arrayWithArray:points]];
  [cyl resampleSpine];
  [cyl calculateCoM];
  
  [cyl setRadii:[NSMutableArray arrayWithCapacity:[[cyl spine] count]]];
  for (int i = 0; i < [[cyl spine] count]; i++) {
    [[cyl radii] insertObject:[NSNumber numberWithDouble:DEFAULT_RADIUS] atIndex:i];
  }
  
  [cyl setCapRadius1:DEFAULT_RADIUS];
  [cyl setCapRadius2:DEFAULT_RADIUS];
  
  [cyl setTilt:[NSMutableArray arrayWithCapacity:[[cyl spine] count]]];
  for (int i = 0; i < [[cyl spine] count]; i++) {
    [[cyl tilt] insertObject:[NSNumber numberWithDouble:NO_TILT] atIndex:i];
  }
  
  [cyl smoothSpine:SMOOTHING_STEPS lockPoint:-1];
  [cyl calculateSurfacePoints];
  
  [cyl setLengthConstraint:nil];
  [cyl setRadiusConstraints:[[NSMutableArray alloc] initWithCapacity:1]];
  [cyl setTiltConstraints:[[NSMutableArray alloc] initWithCapacity:1]];
  
  return cyl;
}

@end
	