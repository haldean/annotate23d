//
//  Cylinderoid.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"

@interface Cylinderoid : Drawable
@property (strong) NSMutableArray* spine;
@property (strong) NSMutableArray* radii;
@property (assign) float capRadius1, capRadius2;

- (void)calculateSurfacePoints;
- (void)smoothSpine:(int)factor;

@end
