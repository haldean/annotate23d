//
//  Cylinderoid.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"
#import "Annotations.h"

@class SameLengthAnnotation;

@interface Cylinderoid : Drawable
@property (strong) NSMutableArray* spine;
@property (strong) NSMutableArray* radii;
@property (strong) NSMutableArray* tilt;

@property (strong) SameLengthAnnotation* lengthConstraint;
@property (strong) NSMutableArray* radiusConstraints;
@property (assign) float capRadius1, capRadius2;

- (CGPoint) center;
- (CGPoint) getEndpoint1;
- (CGPoint) getEndpoint2;
- (CGPoint) cgDerivativeAtIndex:(int)i;
- (void) calculateSurfacePoints;
- (void) smoothRadii:(int)factor lockPoint:(int)point;
- (void) smoothSpine:(int)factor lockPoint:(int)point;
- (void) resampleSpine;
- (double) spineLength;

@end

