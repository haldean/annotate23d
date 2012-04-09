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
  NSLog(@"SSA: %f", [ssa targetRadius]);
  return ssa;
}
@end

