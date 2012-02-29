//
//  MathDefs.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Annotate23D_MathDefs_h
#define Annotate23D_MathDefs_h

#import "Eigen/Core"
using namespace Eigen;

// In case we want to switch precision later
typedef Vector2f Vec2;
typedef Vector3f Vec3;

// Signature repeated to silence (otherwise useful) warnings
Vec2 VectorForPoint(CGPoint point);
Vec2 VectorForPoint(CGPoint point) {
  return Vec2(point.x, point.y);
}

#endif
