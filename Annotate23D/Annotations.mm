//
//  SameLengthAnnotation.m
//  Annotate23D
//
//  Created by William Brown on 2012/04/04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Annotations.h"

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