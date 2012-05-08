//
//  EllipsoidTransformer.h
//  Annotate23D
//
//  Created by William Brown on 2012/03/21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ellipsoid.h"
#import "ShapeTransformer.h"

typedef enum {
  MAJOR_AXIS,
  MINOR_AXIS
} EllipsoidHandleType;

@interface EllipsoidTransformer : ShapeTransformer {
  EllipsoidHandleType selectedHandleType;
}

@property (strong) Ellipsoid* ellipsoid;

- (id) initWithEllipsoid:(Ellipsoid*)shape;
- (void) drawShapeWithHandles:(CGContextRef)context;

@end
