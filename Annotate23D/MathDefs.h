//
//  MathDefs.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Annotate23D_MathDefs_h
#define Annotate23D_MathDefs_h 

#import "Mesh.h"
#import "CGVec.h"
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

#pragma mark Vector type conversions

Vec2 VectorForPoint(CGPoint point);
Vec3 Vec3ForCGVec(CGVec* vec);
Vec3 Vec3ForPoint(CGPoint point);
CGVec* CGVecForVec3(Vec3 vec);
NSString* VecToStr(VecX vec);

#pragma mark Geometry functions

float squareDistance(CGPoint p1, CGPoint p2);

struct intersect_struct {
  Vec3 intersection;
  bool intersects;
} typedef Intersection;

Intersection intersect(Vec3 origin, Vec3 direction, Mesh* mesh);

#pragma mark Symmetry sheet utilities

struct symmetrysheet_struct {
  Vec3 plane_normal;
  Vec3 spine_point;
} typedef symmetrysheet;

@class Cylinderoid;
@class Drawable;
symmetrysheet getSymmetrySheet(Cylinderoid* alignTo, Drawable* other, float symmetryTilt);
Vec3 elevation(symmetrysheet ss, Vec3 point);

#endif
