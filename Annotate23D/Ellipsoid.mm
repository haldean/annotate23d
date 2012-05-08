//
//  Ellipsoid.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Ellipsoid.h"
#import "MathDefs.h"

#define MAJOR_AXIS_RINGS 40
#define SEGMENTS_IN_CIRCLE 16

@implementation Ellipsoid
@synthesize com, phi, a, b;

- (Mesh*)generateMesh {
  int i, j, k;
  int triCount = 2 * MAJOR_AXIS_RINGS * SEGMENTS_IN_CIRCLE;
  int vertexCount = triCount * 3;
  
  Mesh* mesh = [[Mesh alloc] initWithSize:vertexCount];
  int dataidx = 0;
  
  Vec3 **points = (Vec3**) malloc(MAJOR_AXIS_RINGS * sizeof(Vec3*));
  Vec3 **normals = (Vec3**) malloc(MAJOR_AXIS_RINGS * sizeof(Vec3*));
  for (i = 0; i < MAJOR_AXIS_RINGS; i++) {
    points[i] = (Vec3*) malloc((SEGMENTS_IN_CIRCLE) * sizeof(Vec3));
    normals[i] = (Vec3*) malloc((SEGMENTS_IN_CIRCLE) * sizeof(Vec3));
  }
  
  Vec3 center(com.x, com.y, 0);
  Vec3 majorAxis(a, 0, 0), minorAxis(0, b, 0), derivative(1, 0, 0);
  
  AngleAxisf phiRot(phi, Vec3(0, 0, 1));
  majorAxis = phiRot * majorAxis;
  minorAxis = phiRot * minorAxis;
  derivative = phiRot * derivative;
  
  /* Calculate points and normals */
  for (i = 0; i < MAJOR_AXIS_RINGS; i++) {
    Vec3 spinePoint, radius;
    /* t varies from -1 to 1 */
    float t = (2.0 * i) / (float) MAJOR_AXIS_RINGS - 1.0;
    spinePoint = center + t * majorAxis;
    radius = minorAxis * sqrt(1 - pow(t, 2));
    
    for (j = 0; j < SEGMENTS_IN_CIRCLE; j++) {
      Vec3 surfacePoint;
      if (j == 0) surfacePoint = radius;
      else {
        float theta = (float) j * 2 * M_PI / (float) SEGMENTS_IN_CIRCLE;
        AngleAxisf rot(theta, derivative);
        surfacePoint = rot * radius;
      }
      
      points[i][j] = surfacePoint + spinePoint;
      if (surfacePoint.norm() > 0) {
        normals[i][j] = surfacePoint;
      } else {
        normals[i][j] = (t > 0 ? 1 : -1) * majorAxis;
      }
      normals[i][j].normalize();
    }
  }
  
  /* Generate rings for mesh */
  for (i = 0; i < MAJOR_AXIS_RINGS - 1; i++) {
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
  
  /* Generate end caps */
  for (int cap = 0; cap < 2; cap++) {
    Vec3 centerPoint;
    Vec3 centerNormal;
    
    float scaleForSmoothing = 1.0 - (2.0 / MAJOR_AXIS_RINGS);
    if (cap == 0) {
      j = 0;
      centerPoint = center - majorAxis * scaleForSmoothing;
      centerNormal = -majorAxis / a;
    } else {
      j = MAJOR_AXIS_RINGS - 1;
      centerPoint = center + majorAxis * scaleForSmoothing;
      centerNormal = majorAxis / a;
    }
    
    VecX v0(6);
    v0.segment(0, 3) = centerPoint; v0.segment(3, 3) = centerNormal;
    
    Vec3 *ring = points[j];
    Vec3 *norm = normals[j];
    for (i = 0; i < SEGMENTS_IN_CIRCLE; i++) {
      int adjacent = i == 0 ? SEGMENTS_IN_CIRCLE - 1 : i - 1;
      VecX v1(6), v2(6);
      v1.segment(0, 3) = ring[i]; v1.segment(3, 3) = norm[i];
      v2.segment(0, 3) = ring[adjacent]; v2.segment(3, 3) = norm[adjacent];
      
      for (k = 0; k < 6; k++, dataidx++) [mesh put:v0[k] at:dataidx];
      for (k = 0; k < 6; k++, dataidx++) [mesh put:v1[k] at:dataidx];
      for (k = 0; k < 6; k++, dataidx++) [mesh put:v2[k] at:dataidx];
    }
  }
  
  for (i = 0; i < MAJOR_AXIS_RINGS; i++) {
    free(points[i]); free(normals[i]);
  }
  free(points); free(normals);
  return mesh;
}

- (void)calculatePath {
  path = CGPathCreateMutable();
  
  Vec2 c(com.x, com.y), cs(cosf(phi), sinf(phi)), sc(sinf(phi), -cosf(phi));
  cs *= a; sc *= b;
  
  for (CGFloat t = 0; t <= 2 * M_PI; t += 2 * M_PI / ANGULAR_RESOLUTION) {
    Vec2 x = c + cosf(t) * cs + sinf(t) * sc;
    
    if (t <= 1e-10 /* ~= 0 */) {
      CGPathMoveToPoint(path, NULL, x[0], x[1]);
    } else {
      CGPathAddLineToPoint(path, NULL, x[0], x[1]);
    }
  }
  
  CGPathCloseSubpath(path);
}

+ (Ellipsoid*) withPoints:(NSArray *)points {
  // Uses the method from http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.1.7559
  uint N = [points count];
  
  // Translate to origin to make the math easier later
  CGPoint com = CGPointMake(0, 0);
  for (int i = 0; i < N; i++) {
    CGPoint a = [[points objectAtIndex:i] CGPointValue];
    com.x += a.x;
    com.y += a.y;
  }
  com.x /= N; com.y /= N;
  
  VecX x(N), y(N);
  for (uint i = 0; i < N; i++) {
    CGPoint point = [[points objectAtIndex:i] CGPointValue];
    x[i] = (double) (point.x - com.x);
    y[i] = (double) (point.y - com.y);
  }
  
  MatX D1(N, 3);
  D1.col(0) = x.cwiseAbs2();
  D1.col(1) = x.array() * y.array();
  D1.col(2) = y.cwiseAbs2();
  
  MatX D2(N, 3);
  D2.col(0) = x;
  D2.col(1) = y;
  D2.col(2).setOnes();
  
  Mat3 S1 = D1.transpose() * D1,
       S2 = D1.transpose() * D2,
       S3 = D2.transpose() * D2;
  
  Mat3 T = -S3.inverse() * S2.transpose();
  
  Mat3 M = S1 + S2 * T;
  M << M.row(2) / 2, -M.row(1), M.row(0) / 2;
  
  EigenSolver<Mat3> eigens(M);
  Mat3 evecs = -(eigens.eigenvectors().real());
  
  RowVector3f cond = 
    (4 * evecs.row(0)).cwiseProduct(evecs.row(2)) - evecs.row(1).cwiseAbs2();
  int firstPosEV = cond[0] > 0 ? 0 : cond[1] > 0 ? 1 : cond[2] > 0 ? 2 : -1;
  int minPosEV = firstPosEV;
  for (int i = firstPosEV; i < 3; i++)
    if (0 < cond[i] && cond[i] < cond[minPosEV]) minPosEV = i;

  Vec3 a1 = evecs.col(minPosEV).real();
  Vec3 a2 = T * a1;
  
  VecX params(6);
  params.segment<3>(0) = a1;
  params.segment<3>(3) = a2;
  
  // We now have the 6 implicit parameters to the equation
  // ax^2 + bxy + cy^2 + dx + fy + g = 0, but we want major/minor axis and
  // center point. That's what the next bit does.
  
  float a = params[0],
        b = params[1] / 2,
        c = params[2],
        d = params[3] / 2,
        f = params[4] / 2,
        g = params[5];
  
  com.x = (c * d - b * f) / (b * b - a * c) + com.x;
  com.y = (a * f - b * d) / (b * b - a * c) + com.y;
  
  float denom = 2 * (a * f * f + c * d * d + g * b * b - 2 * b * d * f - a * c * g),
        numer_product = b * b - a * c,
        discriminant = sqrtf((a - c) * (a - c) + 4 * b * b);
  
  float a_len = sqrtf(denom / (numer_product * (discriminant - a - c))),
        b_len = sqrtf(denom / (numer_product * (-discriminant - a - c)));
  
  float phi = 0;
  if (b == 0 && a > c) phi = M_PI / 2;
  if (b != 0)
    if (a < c) phi = .5 * atan(2 * b / (a - c));
    else phi = M_PI / 2 + .5 * atan(2 * b / (a - c));
  
  Ellipsoid* el = [[Ellipsoid alloc] init];
  [el setIdent:[Drawable nextIdent]];
  el->com = com;
  if (a_len > b_len) {
    el->a = a_len;
    el->b = b_len;
  } else {
    el->a = b_len;
    el->b = a_len;
  }
  el->phi = phi;
  
  [el calculatePath];
  return el;
}

@end
