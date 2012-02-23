//
//  Cylinderoid.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cylinderoid : NSObject 

@property (strong) NSMutableArray* spine;
@property (strong) NSMutableArray* radii;
@property (strong) NSMutableArray* surfacePoints;

- (void)calculateSurfacePoints;

+ (Cylinderoid*)cylinderoidWithPoints:(NSArray*)points;

@end
