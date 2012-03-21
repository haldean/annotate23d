//
//  ShapeTransformer.h
//  Annotate23D
//
//  Created by William Brown on 2012/03/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drawable.h"

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
