//
//  WorkspaceUIView.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorkspaceUIView.h"
#define NO_SELECTION -1

@implementation WorkspaceUIView
@synthesize drawables, shapeWantsTouching;

- (void)initArrays {
  self.drawables = [[NSMutableArray alloc] init];
  selectedIndex = NO_SELECTION;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self initArrays];
    [self setUserInteractionEnabled:true];
    [self setMultipleTouchEnabled:true];
  }
  return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self initArrays];
    [self setUserInteractionEnabled:true];
    [self setMultipleTouchEnabled:true];
  }
  return self;
}

#pragma mark User interaction methods

- (bool)tapAtPoint:(CGPoint)point {
  if (selectedIndex == NO_SELECTION) {
    bool selected = [self selectAtPoint:point];
    [self setNeedsDisplay];
    return selected;
  }
  
  if ([selectedShape tapAt:point]) {
    [self setNeedsDisplay];
    return YES;
  }
  
  selectedIndex = NO_SELECTION;
  [self setNeedsDisplay];
  return NO;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  shapeWantsTouching = NO;
  if (selectedIndex != NO_SELECTION) {
    shapeWantsTouching = [selectedShape touchesBegan:touches inView:self];
  }
  
  //if (!shapeWantsTouching) [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (shapeWantsTouching) {
    [selectedShape touchesMoved:touches inView:self];
    [self setNeedsDisplay];
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (shapeWantsTouching) {
    [selectedShape touchesEnded:touches inView:self];
  }
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
  
  if (!selected) selectedIndex = NO_SELECTION;
  else {
    selectedShape = [ShapeTransformer 
                     transformerForShape:[drawables objectAtIndex:selectedIndex]];
  }
  
  [self setNeedsDisplay];
  return selected;
}

- (void) handleLongPress:(UIGestureRecognizer *)sender {
  if ([sender state] != UIGestureRecognizerStateBegan) return;
  
  CGPoint pressPoint = [sender locationInView:self];
  bool foundShape = NO;
  
  if (selectedIndex != NO_SELECTION) {
    Drawable* shape = [drawables objectAtIndex:selectedIndex];
    if ([shape getPath] != NULL && 
        CGPathContainsPoint([shape getPath], NULL, pressPoint, false)) {
      foundShape = YES;
    }
  }
  if (!foundShape) {
    foundShape = [self selectAtPoint:pressPoint];
  }
  
  if (foundShape) {
    /* Create UIActionSheet for shape context menu */
    UIActionSheet* actionSheet =
    [[UIActionSheet alloc]
     initWithTitle:@"Shape Menu" delegate:self cancelButtonTitle:nil
     destructiveButtonTitle:@"Delete shape" otherButtonTitles:nil];
    CGRect loc = CGRectMake(pressPoint.x, pressPoint.y, 1, 1);
    [actionSheet showFromRect:loc inView:self animated:true];
  }
}

- (void) deleteSelectedShape {
  if (selectedIndex != NO_SELECTION) {
    [drawables removeObjectAtIndex:selectedIndex];
    selectedIndex = NO_SELECTION;
  }
}

- (void) actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [self deleteSelectedShape];
    [self setNeedsDisplay];
  }
}

#pragma mark Drawing methods

- (void)addDrawable:(Drawable*)draw {
  if (draw == nil) return;
  
  [drawables addObject:draw];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  for (int i = 0; i < [self.drawables count]; i++) {
    if (i == selectedIndex && selectedShape != nil) {
      [selectedShape drawShapeWithHandles:context];
      continue;
    }
    
    CGContextSetLineWidth(context, 5);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextBeginPath(context);
    CGContextAddPath(context, [[drawables objectAtIndex:i] getPath]);
    CGContextDrawPath(context, kCGPathFillStroke);
  }
}

@end
