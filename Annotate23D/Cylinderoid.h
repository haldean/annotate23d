//
//  Cylinderoid.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cylinderoid : NSObject {
  CGPoint com;
}

@property (strong) NSMutableArray* spine;
@property (strong) NSMutableArray* radii;
@property (strong) NSMutableArray* surfacePoints;

- (void)calculateSurfacePoints;
- (bool)pointInside:(CGPoint)point;
- (void)translate:(CGPoint)translate;
- (void)scaleBy:(CGFloat)factor;
- (void)rotateBy:(CGFloat)angle;

+ (Cylinderoid*)cylinderoidWithPoints:(NSArray*)points;

@end
