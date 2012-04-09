//
//  SameLengthAnnotation.h
//  Annotate23D
//
//  Created by William Brown on 2012/04/04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cylinderoid.h"

@class Cylinderoid;

@interface SameLengthAnnotation : NSObject
@property (strong) Cylinderoid* first;
@property (strong) Cylinderoid* second;
- (float) targetLength;
+ (SameLengthAnnotation*) newWithFirst:(Cylinderoid*)first second:(Cylinderoid*)second;
@end

@interface SameScaleAnnotation : NSObject
@property (strong) Cylinderoid* first;
@property (assign) int firstHandleIndex;
@property (strong) Cylinderoid* second;
@property (assign) int secondHandleIndex;
- (float) targetRadius;
+ (SameScaleAnnotation*) newWithFirst:(Cylinderoid*)first handle:(int)firstHandle second:(Cylinderoid*)second handle:(int)secondHandle;
@end

@interface AlignAnnotation : NSObject
@property (strong) Cylinderoid* first;
@property (strong) Cylinderoid* second;
@property (strong) Cylinderoid* alignTo;
@end

@interface ConnectionAnnotation : NSObject
@property (strong) Cylinderoid* first;
@property (strong) Cylinderoid* second;
@property (assign) CGPoint location;
@end

@interface SameTiltAnnotation : NSObject
@property (strong) Cylinderoid* first;
@property (assign) int firstHandleIndex;
@property (strong) Cylinderoid* second;
@property (assign) int secondHandleIndex;
- (float) targetTilt;
@end

@interface MirrorAnnotation : NSObject
@property (strong) Cylinderoid* alignTo;
@property (strong) Drawable* first;
@property (strong) Drawable* second;
@end