//
//  SameLengthAnnotation.m
//  Annotate23D
//
//  Created by William Brown on 2012/04/04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Annotations.h"
#import "MathDefs.h"
#import "CGVec.h"
#include <iostream>

@implementation SameLengthAnnotation
@synthesize first, second;

- (float) targetLength {
  return ([first spineLength] + [second spineLength]) / 2.0;
}

+ (SameLengthAnnotation*) newWithFirst:(Cylinderoid*)first second:(Cylinderoid*)second {
  SameLengthAnnotation* sml = [[SameLengthAnnotation alloc] init];
  [sml setFirst:first];
  [sml setSecond:second];
  return sml;
}
@end

@implementation SameScaleAnnotation
@synthesize first, firstHandleIndex, second, secondHandleIndex;

- (float) targetRadius {
  float sum = [[[first radii] objectAtIndex:firstHandleIndex] floatValue];
  sum += [[[second radii] objectAtIndex:secondHandleIndex] floatValue];
  return sum / 2.0;
}

+ (SameScaleAnnotation*) newWithFirst:(Cylinderoid*)first handle:(int)firstHandle second:(Cylinderoid*)second handle:(int)secondHandle {
  SameScaleAnnotation* ssa = [[SameScaleAnnotation alloc] init];
  [ssa setFirst:first];
  [ssa setFirstHandleIndex:firstHandle];
  [ssa setSecond:second];
  [ssa setSecondHandleIndex:secondHandle];
  return ssa;
}
@end

@implementation SameTiltAnnotation
@synthesize first, firstHandleIndex, second, secondHandleIndex;

- (float) targetTilt {
  float sum = [[[first tilt] objectAtIndex:firstHandleIndex] floatValue];
  sum += [[[second tilt] objectAtIndex:secondHandleIndex] floatValue];
  return sum / 2.0;
}

+ (SameTiltAnnotation*) newWithFirst:(Cylinderoid*)first handle:(int)firstHandle second:(Cylinderoid*)second handle:(int)secondHandle {
  SameTiltAnnotation* sta = [[SameTiltAnnotation alloc] init];
  [sta setFirst:first];
  [sta setFirstHandleIndex:firstHandle];
  [sta setSecond:second];
  [sta setSecondHandleIndex:secondHandle];
  return sta;
}
@end

@implementation ConnectionAnnotation
@synthesize first, second, location;

- (id) init {
  self = [super init];
  if (self != nil) {
    translate1 = nil; translate2 = nil;
  }
  return self;
}

- (bool) calculateTranslations {
  translate1 = [CGVec zero];
  translate2 = [CGVec zero];
  
  Mesh* mesh1 = [first generateMeshWithConnectionConstraints:false];
  Mesh* mesh2 = [second generateMeshWithConnectionConstraints:false];
  
  Vec3 origin = Vec3ForPoint(location);
  /* An arbitrarily large z, since the object is allowed to extend far out
   * of the image plane, and the intersect method only checks for
   * intersections that occur at origin + s * dir with positive s. */
  origin.z() = -9001;
  Vec3 direction(0, 0, 1);
  
  Intersection i1 = intersect(origin, direction, mesh1);
  Intersection i2 = intersect(origin, direction, mesh2);
  if (!i1.intersects || !i2.intersects) {
    return false;
  }
  
  translate2 = CGVecForVec3(i2.intersection - i1.intersection);
  return true;
}

- (bool) isValid {
  return [self calculateTranslations];
}

- (CGVec*) firstTranslation {
  [self calculateTranslations];
  return translate1;
}

- (CGVec*) secondTranslation {
  [self calculateTranslations];
  return translate2;
}

@end

@implementation MirrorAnnotation
@synthesize alignTo, mirror;

- (Mesh*) mirrored {
  bool isCyl = [mirror isKindOfClass:[Cylinderoid class]];
  
  /* First, pick a point on the mirror object to reflect. This will either be
   * one of the ends or the center -- whichever is closest to its attachment
   * point. */
  CGPoint refPoint;
  if (isCyl) {
    Cylinderoid* cyl = (Cylinderoid*) mirror;
    CGPoint connect = [[cyl connectionConstraint] location];
    float dist_ep1 = squareDistance(connect, [cyl getEndpoint1])
    , dist_ep2 = squareDistance(connect, [cyl getEndpoint2])
    , dist_center = squareDistance(connect, [cyl center]);
    
    /* Find the reference point. The condition spaghetti is an unrolled linear
     * min-find. */
    if (dist_ep1 < dist_ep2) {
      if (dist_center < dist_ep1) {
        refPoint = [cyl center];
      } else {
        refPoint = [cyl getEndpoint1];
      }
    } else {
      if (dist_center < dist_ep2) {
        refPoint = [cyl center];
      } else {
        refPoint = [cyl getEndpoint2];
      }
    }
  } else {
    refPoint = [mirror com];
  }
  
  /* Find closest point on mirror-about cylindroid */
  float nearest_dist = INFINITY;
  int nearest_idx = -1;
  for (int i = 0; i < [[alignTo spine] count]; i++) {
    CGPoint pt = [[[alignTo spine] objectAtIndex:i] CGPointValue];
    float dist = squareDistance(pt, refPoint);
    if (dist < nearest_dist) {
      nearest_dist = dist;
      nearest_idx = i;
    }
  }
  
  NSMutableArray* spinevecs = [alignTo spineVecsWithConstraints];
  Vec3 spinePt = [[spinevecs objectAtIndex:nearest_idx] vec3];
  Vec3 tangent = Vec3ForCGVec([alignTo tangentVectorAtIndex:nearest_idx onSpine:spinevecs]);
  Vec3 perp = Vec3ForCGVec([alignTo perpVectorAtIndex:nearest_idx onSpine:spinevecs]);
  
  Vec3 plane_normal = tangent.cross(perp);
  plane_normal.normalize();
  
  if (isCyl) {
    Cylinderoid* cyl = (Cylinderoid*) mirror;
    NSMutableArray* mirror_spine = [cyl spineVecsWithConnectionConstraints];
    for (int i = 0; i < [mirror_spine count]; i++) {
      Vec3 oldpt = [[mirror_spine objectAtIndex:i] vec3];      
      Vec3 elevation = (oldpt - spinePt).dot(plane_normal) * plane_normal;
      Vec3 newpt = oldpt - 2 * elevation;
      [mirror_spine replaceObjectAtIndex:i withObject:[NSVec3 with:newpt]];
    }
    
    return [cyl generateMeshWithSpine:mirror_spine];
  }
  return nil;
}

@end