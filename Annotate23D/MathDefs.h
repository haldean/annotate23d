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

bool isnan(double x);

// In case we want to switch precision later
typedef Vector2f Vec2;
typedef Vector3f Vec3;
typedef VectorXf VecX;
typedef Matrix3f Mat3;
typedef MatrixXf MatX;

@interface NSVec3 : NSObject
@property (assign) Vec3 vec3;
+ (NSVec3*) with:(Vec3)vec;
@end

@interface NSVec2 : NSObject
@property (assign) Vec2 vec2;
+ (NSVec2*) with:(Vec2)vec;
@end

Vec2 VectorForPoint(CGPoint point);
Vec3 Vec3ForPoint(CGPoint point);

NSString* VecToStr(VecX vec);

float squareDistance(CGPoint p1, CGPoint p2);

#endif
