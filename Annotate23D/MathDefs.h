//
//  MathDefs.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Annotate23D_MathDefs_h
#define Annotate23D_MathDefs_h

#import "Eigen/Eigen"
#import "Eigen/Geometry"
using namespace Eigen;

// In case we want to switch precision later
typedef Vector2f Vec2;
typedef Vector3f Vec3;
typedef VectorXf VecX;
typedef Matrix3f Mat3;
typedef MatrixXf MatX;

Vec2 VectorForPoint(CGPoint point);
NSString* VecToStr(VecX vec);

#endif
