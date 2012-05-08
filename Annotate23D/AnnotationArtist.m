//
//  AnnotationArtist.m
//  Annotate23D
//
//  Created by William Brown on 2012/04/07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnnotationArtist.h"
#import "ShapeTransformer.h"

@implementation AnnotationArtist

+ (void) drawSameLengthAnnotation:(SameLengthAnnotation*)ann onContext:(CGContextRef)context {
  CGPoint first = [[ann first] center];
  CGPoint second = [[ann second] center];
  
  CGContextSetLineCap(context, kCGLineCapRound);
  CGContextSetLineWidth(context, 16);
  CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
  CGContextMoveToPoint(context, first.x, first.y);
  CGContextAddLineToPoint(context, second.x, second.y);
  CGContextDrawPath(context, kCGPathStroke);
}

+ (void) drawConnectionAnnotation:(ConnectionAnnotation *)ann onContext:(CGContextRef)context {
  CGContextAddEllipseInRect(context, CGRectMake([ann location].x - HANDLE_RADIUS,
                                                [ann location].y - HANDLE_RADIUS,
                                                HANDLE_SIZE, HANDLE_SIZE));
  CGContextSetLineWidth(context, 2);
  CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextDrawPath(context, kCGPathFillStroke);
}

+ (void) drawSameScaleAnnotation:(SameScaleAnnotation*)ann onContext:(CGContextRef)context {
  CGPoint first = [[[[ann first] spine] objectAtIndex:[ann firstHandleIndex]] CGPointValue];
  CGPoint second = [[[[ann second] spine] objectAtIndex:[ann secondHandleIndex]] CGPointValue];
  
  CGContextSetLineCap(context, kCGLineCapRound);
  CGContextSetLineWidth(context, 15);
  CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
  CGContextMoveToPoint(context, first.x, first.y);
  CGContextAddLineToPoint(context, second.x, second.y);
  CGContextDrawPath(context, kCGPathStroke);
  
  CGContextAddEllipseInRect(context, CGRectMake(first.x - HANDLE_RADIUS,
                                                first.y - HANDLE_RADIUS, 
                                                HANDLE_SIZE, HANDLE_SIZE));
  CGContextSetLineWidth(context, 2);
  CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextDrawPath(context, kCGPathFillStroke);
  
  CGContextAddEllipseInRect(context, CGRectMake(second.x - HANDLE_RADIUS,
                                                second.y - HANDLE_RADIUS, 
                                                HANDLE_SIZE, HANDLE_SIZE));
  CGContextSetLineWidth(context, 2);
  CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextDrawPath(context, kCGPathFillStroke);
}

+ (void) drawSameTiltAnnotation:(SameScaleAnnotation*)ann onContext:(CGContextRef)context {
  CGPoint first = [[[[ann first] spine] objectAtIndex:[ann firstHandleIndex]] CGPointValue];
  CGPoint second = [[[[ann second] spine] objectAtIndex:[ann secondHandleIndex]] CGPointValue];
  
  CGContextSetLineCap(context, kCGLineCapRound);
  CGContextSetLineWidth(context, 15);
  CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
  CGContextMoveToPoint(context, first.x, first.y);
  CGContextAddLineToPoint(context, second.x, second.y);
  CGContextDrawPath(context, kCGPathStroke);
  
  CGContextAddEllipseInRect(context, CGRectMake(first.x - HANDLE_RADIUS,
                                                first.y - HANDLE_RADIUS, 
                                                HANDLE_SIZE, HANDLE_SIZE));
  CGContextSetLineWidth(context, 2);
  CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextDrawPath(context, kCGPathFillStroke);
  
  CGContextAddEllipseInRect(context, CGRectMake(second.x - HANDLE_RADIUS,
                                                second.y - HANDLE_RADIUS, 
                                                HANDLE_SIZE, HANDLE_SIZE));
  CGContextSetLineWidth(context, 2);
  CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextDrawPath(context, kCGPathFillStroke);
}

@end
