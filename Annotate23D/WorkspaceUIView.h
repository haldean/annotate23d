//
//  WorkspaceUIView.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cylinderoid.h"
#import "Ellipsoid.h"
#import "Drawable.h"
#import "ShapeTransformer.h"

@interface WorkspaceUIView : UIView <UIActionSheetDelegate> {
  int selectedIndex;
  ShapeTransformer* selectedShape;
}

@property (assign) bool shapeWantsTouching;
@property (strong) NSMutableArray *drawables;

/* Returns YES if a shape is currently selected, and false otherwise. */
- (bool)tapAtPoint:(CGPoint)point;
- (void)handleLongPress:(UIGestureRecognizer*)sender;

/* Returns YES if a shape is currently selected, and false otherwise. */
- (bool)selectAtPoint:(CGPoint)point;

- (void)translateSelectedShape:(CGPoint)translation;
- (void)scaleSelectedShape:(CGFloat)factor;
- (void)rotateSelectedShape:(CGFloat)angle;
- (void)deleteSelectedShape;

- (void)addDrawable:(Drawable*)draw;

- (void)actionSheet:(UIActionSheet*)sheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
