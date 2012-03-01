//
//  MathDefs.mm
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MathDefs.h"

Vec2 VectorForPoint(CGPoint point) {
  return Vec2(point.x, point.y);
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