//
//  CGVec.h
//  Annotate23D
//
//  Created by William Brown on 2012/04/18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 CGVec is a skeleton 3-vector class for shuttling between
 Objective-C and Objective-C++ code, and acts as the R3
 equivalent of CGPoint. MathDefs contains code for
 translating a CGVec to an Eigen Vec3.
 */
@interface CGVec : NSObject
@property float x, y, z;
+ (CGVec*) x:(float)x y:(float)y z:(float)z;
+ (CGVec*) zero;
@end
