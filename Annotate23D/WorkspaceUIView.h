//
//  WorkspaceUIView.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cylinderoid.h"

@interface WorkspaceUIView : UIView {
  int selectedIndex;
}

@property (strong) NSMutableArray *cylinderoids;
@property (strong) NSMutableArray *ellipsoids;

- (bool)selectAtPoint:(CGPoint)point;
- (void)translateSelectedShape:(CGPoint)translation;
- (void)scaleSelectedShape:(CGFloat)factor;
- (void)rotateSelectedShape:(CGFloat)angle;
- (void)addCylinderoid:(Cylinderoid*)cyl;
//- (void)addEllipsoid:(Ellipsoid*)ell;

@end
