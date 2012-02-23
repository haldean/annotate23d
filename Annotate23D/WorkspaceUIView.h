//
//  WorkspaceUIView.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cylinderoid.h"

@interface WorkspaceUIView : UIView

@property (strong) NSMutableArray *cylinderoids;
@property (strong) NSMutableArray *ellipsoids;

- (void)addCylinderoid:(Cylinderoid*)cyl;
//- (void)addEllipsoid:(Ellipsoid*)ell;

@end
