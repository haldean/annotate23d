//
//  MathDefs.h
//  Annotate23D
//

#ifndef Annotate23D_MathDefs_h
#define Annotate23D_MathDefs_h

#import "CLVector.h"

CLVector CLVectorFromCGPoint(CGPoint pt) {
  CLVector vec;
  vec.x = pt.x;
  vec.y = pt.y;
  vec.z = 0;
  return vec;
}

#endif
