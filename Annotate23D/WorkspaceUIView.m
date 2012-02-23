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
  selectedIndex = -1;
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

- (bool)selectAtPoint:(CGPoint)point {
  bool selected = NO;
  for (int i = [cylinderoids count] - 1; i >= 0; i--) {
    if ([[cylinderoids objectAtIndex:i] pointInside:point]) {
      if (i == selectedIndex) break;
      
      selectedIndex = i;
      selected = YES;
      break;
    }
  }
  if (!selected) selectedIndex = -1;
  [self setNeedsDisplay];
  return selected;
}

- (void)translateSelectedShape:(CGPoint)translation {
  [[cylinderoids objectAtIndex:selectedIndex] translate:translation];
  [self setNeedsDisplay];
}

- (void)addCylinderoid:(Cylinderoid *)cyl {
  [cylinderoids addObject:cyl];
  [self setNeedsDisplay];
}

- (void)drawCylinderoid:(Cylinderoid *)cyl onContext:(CGContextRef)context {
  if ([[cyl surfacePoints] count] == 0) return;
  
  CGContextBeginPath(context);
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
  
  /*
   Uncomment this to draw spines.
   
  CGContextBeginPath(context);
  for (int i = 0; i < [[cyl spine] count]; i++) {
    CGPoint point = [[[cyl spine] objectAtIndex:i] CGPointValue];
    if (i == 0) {
      CGContextMoveToPoint(context, point.x, point.y);
    } else {
      CGContextAddLineToPoint(context, point.x, point.y);
    }
  }
  CGContextStrokePath(context);
   */
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, 5);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
  
  for (int i = 0; i < [self.cylinderoids count]; i++) {
    if (i == selectedIndex) {
      CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    } else {
      CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    Cylinderoid* cyl = [self.cylinderoids objectAtIndex:i];
    [self drawCylinderoid:cyl onContext:context];
  }
}

@end
