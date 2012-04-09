//
//  MathDefs.mm
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MathDefs.h"

bool isnan(double x) {
  return x != x;
}

Vec2 VectorForPoint(CGPoint point) {
  return Vec2(point.x, point.y);
}

Vec3 Vec3ForPoint(CGPoint point) {
  return Vec3(point.x, point.y, 0);
}

NSString* VecToStr(VecX v) {
  NSMutableString* str = [[NSMutableString alloc] init];
  [str appendString:@"("];
  for (int i = 0; i < v.size() - 1; i++) {
    [str appendFormat:@"%f, ", v[i]];
  }
  [str appendFormat:@"%f)", v[v.size()-1]];
  return [[NSString alloc] initWithString:str];
}

float squareDistance(CGPoint p1, CGPoint p2) {
  return pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2);
}

@implementation NSVec3
@synthesize vec3;
+ (NSVec3*) with:(Vec3)vec {
  NSVec3* nsv = [[NSVec3 alloc] init];
  nsv.vec3 = vec;
  return nsv;
}
@end

@implementation NSVec2
@synthesize vec2;
+ (NSVec2*) with:(Vec2)vec {
  NSVec2* nsv = [[NSVec2 alloc] init];
  nsv.vec2 = vec;
  return nsv;
}
@end