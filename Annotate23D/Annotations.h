//
//  SameLengthAnnotation.h
//  Annotate23D
//
//  Created by William Brown on 2012/04/04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cylinderoid.h"
#import "CGVec.h"

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

@interface ConnectionAnnotation : NSObject {
  CGVec *translate1, *translate2;
}
@property (strong) Cylinderoid* first;
@property (strong) Cylinderoid* second;
@property (assign) CGPoint location;
- (bool) isValid;
- (CGVec*) firstTranslation;
- (CGVec*) secondTranslation;
@end

@interface AlignAnnotation : NSObject
@property (strong) Cylinderoid* first;
@property (strong) Cylinderoid* second;
@property (strong) Cylinderoid* alignTo;
@end

@interface SameTiltAnnotation : NSObject
@property (strong) Cylinderoid* first;
@property (assign) int firstHandleIndex;
@property (strong) Cylinderoid* second;
@property (assign) int secondHandleIndex;
- (float) targetTilt;
+ (SameTiltAnnotation*) newWithFirst:(Cylinderoid*)first handle:(int)firstHandle second:(Cylinderoid*)second handle:(int)secondHandle;
@end

@interface MirrorAnnotation : NSObject
@property (strong) Cylinderoid* alignTo;
@property (strong) Drawable* first;
@property (strong) Drawable* second;
@end