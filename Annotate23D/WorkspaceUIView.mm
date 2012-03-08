//
//  WorkspaceUIView.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorkspaceUIView.h"

@implementation WorkspaceUIView
@synthesize drawables;

- (void)initArrays {
  self.drawables = [[NSMutableArray alloc] init];
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
  for (int i = [drawables count] - 1; i >= 0; i--) {
    Drawable* shape = [drawables objectAtIndex:i];
    if ([shape getPath] != NULL && 
        CGPathContainsPoint([shape getPath], NULL, point, false)) {
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
  if (selectedIndex < 0) return;
  [[drawables objectAtIndex:selectedIndex] translate:translation];
  [self setNeedsDisplay];
}

- (void)scaleSelectedShape:(CGFloat)factor {
  if (selectedIndex < 0) return;
  [[drawables objectAtIndex:selectedIndex] scaleBy:factor];
  [self setNeedsDisplay];
}

- (void)rotateSelectedShape:(CGFloat)angle {
  if (selectedIndex < 0) return;
  [[drawables objectAtIndex:selectedIndex] rotateBy:angle];
  [self setNeedsDisplay];
}

- (void)addDrawable:(Drawable*)draw {
  [drawables addObject:draw];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, 5);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
  
  for (int i = 0; i < [self.drawables count]; i++) {
    if (i == selectedIndex) {
      CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    } else {
      CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    
    CGContextBeginPath(context);
    CGContextAddPath(context, [[drawables objectAtIndex:i] getPath]);
    CGContextDrawPath(context, kCGPathFillStroke);
  }
}

@end
