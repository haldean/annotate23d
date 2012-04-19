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