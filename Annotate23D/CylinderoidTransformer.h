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
  int selectedHandle;
  CylinderoidHandleType selectedHandleType;
}

@property (strong) Cylinderoid* cylinderoid;

- (int) selectedSpineHandle;
- (id) initWithCylinderoid:(Cylinderoid*)shape;
- (void) drawShapeWithHandles:(CGContextRef)context;

@end
