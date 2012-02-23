//
//  WorkspaceUIView.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorkspaceUIView.h"

@implementation WorkspaceUIView
@synthesize cylinderoids, ellipsoids;

- (void)initArrays {
  self.cylinderoids = [[NSMutableArray alloc] init];
  self.ellipsoids = [[NSMutableArray alloc] init];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self initArrays];
  }
  return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self initArrays];
  }
  return self;
}

- (void)addCylinderoid:(Cylinderoid *)cyl {
  [self.cylinderoids addObject:cyl];
  [self setNeedsDisplay];
}

- (void)drawCylinderoid:(Cylinderoid *)cyl onContext:(CGContextRef)context {
  CGContextBeginPath(context);
  if ([[cyl surfacePoints] count] == 0) return;
  
  for (int i = 0; i < [[cyl surfacePoints] count]; i++) {
    CGPoint point = [[[cyl surfacePoints] objectAtIndex:i] CGPointValue];
    if (i == 0) {
      CGContextMoveToPoint(context, point.x, point.y);
    } else {
      CGContextAddLineToPoint(context, point.x, point.y);
    }
  }
  
  CGContextClosePath(context);
  CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, 5);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
  
  for (int i = 0; i < [self.cylinderoids count]; i++) {
    Cylinderoid* cyl = [self.cylinderoids objectAtIndex:i];
    [self drawCylinderoid:cyl onContext:context];
  }
}

@end
