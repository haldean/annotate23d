//
//  DrawPreviewUIView.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReceivesDrawEvents <NSObject>
-(void)onPathDraw:(NSMutableArray*) points;
@end

@interface DrawPreviewUIView : UIView {
  NSMutableArray* points;
  CGPoint lastPoint;
}
@property bool canHandleClicks;
@property (nonatomic, assign) id<ReceivesDrawEvents> delegate;
@end
