//
//  Cylinderoid.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"
#import "CGVec.h"
#import "Annotations.h"

/* These provided to get around circular dependencies */
@class SameLengthAnnotation;
@class ConnectionAnnotation;
@class MirrorAnnotation;
@class AlignToSheetAnnotation;

@interface Cylinderoid : Drawable

@property (strong) NSMutableArray* spine;
@property (strong) NSMutableArray* radii;
@property (strong) NSMutableArray* tilt;

@property (strong) MirrorAnnotation* mirrorAnnotation;
@property (strong) AlignToSheetAnnotation* alignmentConstraint;
@property (strong) ConnectionAnnotation* connectionConstraint;
@property (strong) SameLengthAnnotation* lengthConstraint;
@property (strong) NSMutableArray* radiusConstraints;
@property (strong) NSMutableArray* tiltConstraints;

@property (assign) float capRadius1, capRadius2;

- (Mesh*) generateMeshWithConnectionConstraints:(bool)useConnection;
- (Mesh*) generateMesh;
- (Mesh*) generateMeshWithSpine:(NSMutableArray*)spine;

- (CGPoint) center;
- (CGPoint) getEndpoint1;
- (CGPoint) getEndpoint2;

/* These calls are expensive! */
- (NSMutableArray*) spineVecsWithConstraints;
- (NSMutableArray*) spineVecsWithConnectionConstraints;
- (CGVec*) tangentVectorAtIndex:(int)i;
- (CGVec*) perpVectorAtIndex:(int)i;
- (CGVec*) spineVectorAtIndex:(int)i;

/* These calls are not. */
- (CGPoint) cgDerivativeAtIndex:(int)i;
- (CGVec*) tangentVectorAtIndex:(int)i onSpine:(NSMutableArray*)spinevecs;
- (CGVec*) perpVectorAtIndex:(int)i onSpine:(NSMutableArray*)spinevecs;

- (bool) hasTiltAt:(int)i;
- (void) calculateSurfacePoints;
- (void) smoothRadii:(int)factor lockPoint:(int)point;
- (void) smoothSpine:(int)factor lockPoint:(int)point;
- (NSMutableArray*) smoothRadii:(NSMutableArray*)rads withFactor:(int)factor lockPoint:(int)lock;
- (void) resampleSpine;
- (double) spineLength;

@end

