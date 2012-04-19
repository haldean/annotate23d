//
//  AnnotationArtist.h
//  Annotate23D
//
//  Created by William Brown on 2012/04/07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Annotations.h"

@interface AnnotationArtist : NSObject

+ (void) drawSameLengthAnnotation:(SameLengthAnnotation*)ann
                        onContext:(CGContextRef)context;

+ (void) drawSameScaleAnnotation:(SameScaleAnnotation*)ann
                       onContext:(CGContextRef)context;

+ (void) drawSameTiltAnnotation:(SameTiltAnnotation*)ann
                      onContext:(CGContextRef)context;

+ (void) drawConnectionAnnotation:(ConnectionAnnotation*)ann
                        onContext:(CGContextRef)context;
@end
