//
//  ShapeTransformer.h
//  Annotate23D
//
//  Created by William Brown on 2012/03/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"

/* Must be odd. Represents number of pixels from center of
 * handle circle to edge of circle, including central point. */
#define HANDLE_SIZE 19
#define HANDLE_RADIUS ((HANDLE_SIZE - 1) / 2)

/* Handles have an effective radius of 30 pixels */
#define HANDLE_TOUCH_RADIUS_SQUARED 900

@interface ShapeTransformer : NSObject {
  CGAffineTransform currentTransformation;
}
- (void) drawShapeWithHandles:(CGContextRef)context;
- (bool) tapAt:(CGPoint) pt;
- (bool) touchesBegan:(NSSet *) touches inView:(UIView*) view;
- (void) touchesMoved:(NSSet *) touches inView:(UIView*) view;
- (void) touchesEnded:(NSSet *) touches inView:(UIView*) view;
+ (ShapeTransformer*) transformerForShape:(Drawable*)shape;
@end
