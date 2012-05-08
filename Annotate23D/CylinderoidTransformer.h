//
//  CylinderoidTransformer.h
//  Annotate23D
//
//  Created by William Brown on 2012/03/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cylinderoid.h"
#import "ShapeTransformer.h"

typedef enum {
  ENDCAP,
  SPINE,
  COM,
  TILT
} CylinderoidHandleType;

@interface CylinderoidTransformer : ShapeTransformer {
  CylinderoidHandleType selectedHandleType;
}

@property (strong) Cylinderoid* cylinderoid;
@property bool showOnlyTiltHandles;
@property bool readOnly;

- (id) initWithCylinderoid:(Cylinderoid*)shape;
- (void) drawShapeWithHandles:(CGContextRef)context;

@end
