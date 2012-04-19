//
//  CGVec.m
//  Annotate23D
//
//  Created by William Brown on 2012/04/18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CGVec.h"

@implementation CGVec
@synthesize x, y, z;

- (NSString*) description {
  return [NSString stringWithFormat:@"(%f %f %f)", x, y, z];
}

+ (CGVec*) x:(float)x y:(float)y z:(float)z {
  CGVec* v = [[CGVec alloc] init];
  v.x = x;
  v.y = y;
  v.z = z;
  return v;
}

+ (CGVec*) zero {
  return [CGVec x:0 y:0 z:0];
}
@end
