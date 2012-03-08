//
//  Ellipsoid.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Ellipsoid.h"
#import "MathDefs.h"

@implementation Ellipsoid
@synthesize com;

- (Mesh)generateMesh {
  Mesh result;
  
  GLfloat cubeData[216] = {
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
  };
  
  result.size = 36;
  result.data = (GLfloat*) malloc(216 * sizeof(GLfloat));
  memcpy(result.data, cubeData, sizeof(cubeData));
  
  return result;
}

- (void)scaleBy:(CGFloat)factor {
  [super scaleBy:factor];
  a *= factor;
  b *= factor;
}

- (void)rotateBy:(CGFloat)angle {
  [super rotateBy:angle];
  phi += angle;
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
  el->com = com;
  el->a = a_len;
  el->b = b_len;
  el->phi = phi;
  
  NSLog(@"el center = %f, %f", com.x, com.y);
  
  [el calculatePath];
  return el;
}

@end
