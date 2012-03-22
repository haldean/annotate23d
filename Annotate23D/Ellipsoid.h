//
//  Ellipsoid.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"

#define ANGULAR_RESOLUTION 360

@interface Ellipsoid : Drawable

@property (assign) CGFloat phi;
@property (assign) CGFloat a;
@property (assign) CGFloat b;

- (Mesh*)generateMesh;
- (void)calculatePath;

@end

